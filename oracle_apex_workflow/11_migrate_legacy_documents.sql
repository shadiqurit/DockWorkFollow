-- Optional legacy transaction migration. Run after configuration migration.
-- It accepts either DF_MASTER or DOC_FORWARDING, because the supplied
-- DF_MASTER.sql creates DOC_FORWARDING but later alters DF_MASTER.
-- Review fields are intentionally not migrated as nested/single-column review;
-- all L0..L12 actions become route/history rows.

set define off
set serveroutput on

declare
    l_source_table varchar2(30);
    l_sql          varchar2(32767);
begin
    select case
             when exists (select 1 from user_tables where table_name = 'DF_MASTER') then 'DF_MASTER'
             when exists (select 1 from user_tables where table_name = 'DOC_FORWARDING') then 'DOC_FORWARDING'
           end
      into l_source_table
      from dual;
    if l_source_table is null then
        raise_application_error(-20100, 'Neither DF_MASTER nor DOC_FORWARDING exists.');
    end if;

    l_sql := '
        insert into df_document(
            document_no, type_id, workflow_id, subject, body_clob, creator_emp_id,
            department_id, department_code, unit_id, unit_code,
            company_id, location_id, document_date, current_status,
            total_amount, submitted_at, approved_at, version_no, legacy_df_slno,
            created_by, created_at)
        select m.df_tran_no, m.type_id,
               (select min(w.workflow_id) keep (dense_rank first order by w.priority_no, w.version_no desc)
                  from df_workflow w where w.type_id = m.type_id and w.active_yn = ''Y''),
               nvl(m.df_tite, ''Legacy document '' || m.df_slno), m.df_detail,
               m.empcode, e.dept_id, m.dept_id, e.branch_id, m.unit_id,
               e.com_id, e.loc_id, nvl(m.df_tran_date, trunc(sysdate)),
               case upper(nvl(m.df_status,''PENDING''))
                 when ''APPROVE'' then ''APPROVED'' when ''APPROVED'' then ''APPROVED''
                 when ''REJECT'' then ''REJECTED'' when ''REJECTED'' then ''REJECTED''
                 when ''RETURN'' then ''RETURNED'' when ''RETURNED'' then ''RETURNED''
                 else ''IN_PROCESS'' end,
               m.item_amt, cast(m.df_tran_date as timestamp),
               case when upper(nvl(m.df_status,''X'')) in (''APPROVE'',''APPROVED'')
                    then cast(nvl(m.upd_date,m.df_tran_date) as timestamp) end,
               1, m.df_slno, nvl(m.ent_by,m.empcode),
               cast(nvl(m.ent_date,m.df_tran_date) as timestamp)
          from ' || l_source_table || ' m
          left join employees e on upper(e.emp_id) = upper(m.empcode)
         where not exists (select 1 from df_document d where d.legacy_df_slno = m.df_slno)';
    execute immediate l_sql;
    dbms_output.put_line(sql%rowcount || ' legacy document headers migrated.');

    insert into df_document_version(
        document_id, version_no, subject, body_clob, total_amount, change_reason, created_by, created_at)
    select d.document_id, 1, d.subject, d.body_clob, d.total_amount,
           'Migrated from legacy document', d.created_by, d.created_at
      from df_document d
     where d.legacy_df_slno is not null
       and not exists (select 1 from df_document_version v where v.document_id = d.document_id and v.version_no = 1);

    for i in 0 .. 12 loop
        l_sql := '
            insert into df_document_route(
                document_id, step_no, source_type, source_id, step_name, step_type,
                action_required, assigned_emp_id, status, started_at, completed_at)
            select d.document_id, ' || (i * 10) || ', ''WORKFLOW_STEP'', null,
                   ''Legacy Level ' || i || ''', ''APPROVAL'',
                   case when ' || i || ' = 12 then ''APPROVE'' else ''FORWARD'' end,
                   m.l' || i || '_empcode,
                   case when m.l' || i || '_type is not null then ''COMPLETED'' else ''WAITING'' end,
                   cast(m.df_tran_date as timestamp), cast(m.l' || i || '_date as timestamp)
              from ' || l_source_table || ' m
              join df_document d on d.legacy_df_slno = m.df_slno
             where m.l' || i || '_empcode is not null
               and not exists (select 1 from df_document_route r
                                where r.document_id = d.document_id and r.step_no = ' || (i * 10) || ')';
        execute immediate l_sql;

        l_sql := '
            insert into df_action_history(
                document_id, route_id, action_type, action_by_emp_id, action_at,
                from_status, to_status, comments, app_user)
            select d.document_id, r.route_id,
                   case upper(m.l' || i || '_type)
                     when ''FORWARD'' then ''FORWARDED''
                     when ''RETURN'' then ''RETURNED''
                     when ''APPROVE'' then ''APPROVED''
                     when ''REJECT'' then ''REJECTED''
                     else upper(m.l' || i || '_type) end,
                   m.l' || i || '_empcode, cast(nvl(m.l' || i || '_date,m.df_tran_date) as timestamp),
                   null, upper(m.l' || i || '_type), m.l' || i || '_comment, ''LEGACY_MIGRATION''
              from ' || l_source_table || ' m
              join df_document d on d.legacy_df_slno = m.df_slno
              join df_document_route r on r.document_id = d.document_id and r.step_no = ' || (i * 10) || '
             where m.l' || i || '_type is not null
               and not exists (select 1 from df_action_history h
                                where h.document_id = d.document_id and h.route_id = r.route_id
                                  and h.app_user = ''LEGACY_MIGRATION'')';
        execute immediate l_sql;
    end loop;

    update df_document_route r set is_final_yn = 'Y', step_type = 'FINAL_APPROVAL', action_required = 'APPROVE'
     where r.route_id = (select max(x.route_id) keep (dense_rank last order by x.step_no)
                           from df_document_route x where x.document_id = r.document_id)
       and exists (select 1 from df_document d where d.document_id = r.document_id and d.legacy_df_slno is not null);

    -- Recreate only the current pending legacy inbox task.
    l_sql := '
        insert into df_task(document_id, route_id, task_type, assigned_to_emp_id, status, assigned_at)
        select d.document_id, r.route_id, ''WORKFLOW'', r.assigned_emp_id, ''PENDING'',
               cast(nvl(m.upd_date,m.df_tran_date) as timestamp)
          from ' || l_source_table || ' m
          join df_document d on d.legacy_df_slno = m.df_slno
          join df_document_route r on r.document_id = d.document_id and r.step_no = m.status_sl * 10
         where d.current_status in (''IN_PROCESS'',''RETURNED'')
           and not exists (select 1 from df_task t where t.document_id = d.document_id and t.status = ''PENDING'')';
    execute immediate l_sql;

    update df_document_route r set status = 'ACTIVE', started_at = nvl(started_at,systimestamp)
     where exists (select 1 from df_task t where t.route_id = r.route_id and t.status = 'PENDING');
    update df_document d
       set (current_route_id, current_assignee_emp_id) =
           (select t.route_id, t.assigned_to_emp_id from df_task t
             where t.document_id = d.document_id and t.status = 'PENDING')
     where d.legacy_df_slno is not null
       and exists (select 1 from df_task t where t.document_id = d.document_id and t.status = 'PENDING');

    insert into df_action_history(document_id, action_type, action_by_emp_id,
        action_at, from_status, to_status, comments, app_user)
    select d.document_id, 'CREATED', d.creator_emp_id, d.created_at,
           null, 'DRAFT', 'Migrated legacy creation record', 'LEGACY_MIGRATION'
      from df_document d
     where d.legacy_df_slno is not null
       and not exists (select 1 from df_action_history h
                        where h.document_id = d.document_id and h.action_type = 'CREATED');

    commit;
    dbms_output.put_line('Legacy routes, tasks, versions and history migrated from ' || l_source_table || '.');
end;
/
