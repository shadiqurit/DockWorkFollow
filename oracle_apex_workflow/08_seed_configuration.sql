-- Idempotent baseline configuration. Employee assignments are intentionally
-- limited to roles proven by the legacy files; department-specific data is
-- loaded by 10_migrate_legacy_configuration.sql.

merge into df_role d using (
    select 1 role_id, 'DEPT_HEAD' role_code, 'Department Head' role_name from dual union all
    select 2, 'PURCHASE_HEAD', 'Head of Purchase Department' from dual union all
    select 3, 'ACCOUNTS_HEAD', 'Accounts Head' from dual union all
    select 4, 'CFO', 'Finance Director / CFO' from dual union all
    select 5, 'CONCERNED_ED', 'Concerned Executive Director' from dual union all
    select 6, 'MANAGING_DIRECTOR', 'Managing Director' from dual
) s on (d.role_code = s.role_code)
when not matched then insert(role_id, role_code, role_name)
values(s.role_id, s.role_code, s.role_name);

merge into df_document_type d using (
    select 1 type_id, 'GEN' type_code, 'General Note / Memo' type_name, 'GENE' prefix, 'N' purchase from dual union all
    select 2, 'OO',  'Office Order / Memo', 'OO', 'N' from dual union all
    select 3, 'CIR', 'Notice / Circular', 'CIR', 'N' from dual union all
    select 4, 'DEP', 'Departmental Note', 'DEP', 'N' from dual union all
    select 5, 'MAN', 'Manpower Note', 'MAN', 'N' from dual union all
    select 6, 'MOM', 'Meeting Minutes', 'MOM', 'N' from dual union all
    select 7, 'PUR', 'Procurement Note', 'PUR', 'Y' from dual
) s on (d.type_code = s.type_code)
when not matched then insert(type_id, type_code, type_name, number_prefix, is_purchase_yn)
values(s.type_id, s.type_code, s.type_name, s.prefix, s.purchase);

merge into df_number_format d using (
    select type_id, number_prefix prefix from df_document_type where type_id between 1 and 7
) s on (d.type_id = s.type_id)
when not matched then insert(type_id, prefix, reset_type, format_mask, sequence_width)
values(s.type_id, s.prefix, 'MONTHLY', '{PREFIX}-{YYYYMM}/{SEQ}', 5);

-- One configurable workflow per document type.
merge into df_workflow d using (
    select type_id workflow_id, type_code || '_STANDARD' workflow_code,
           type_name || ' Standard Workflow' workflow_name, type_id
      from df_document_type where type_id between 1 and 7
) s on (d.workflow_code = s.workflow_code and d.version_no = 1)
when not matched then insert(workflow_id, workflow_code, workflow_name, type_id, version_no)
values(s.workflow_id, s.workflow_code, s.workflow_name, s.type_id, 1);

-- Non-procurement default: Department Head -> Concerned ED -> MD.
begin
    for w in (select workflow_id from df_workflow where type_id <> 7 and workflow_id between 1 and 7) loop
        merge into df_workflow_step d using (select w.workflow_id workflow_id from dual) s
          on (d.workflow_id = s.workflow_id and d.step_no = 10)
        when not matched then insert(workflow_id, step_no, step_name, step_type,
          actor_type, action_required)
        values(s.workflow_id, 10, 'Department Review', 'RECOMMEND', 'DEPT_HEAD', 'RECOMMEND');
        merge into df_workflow_step d using (select w.workflow_id workflow_id from dual) s
          on (d.workflow_id = s.workflow_id and d.step_no = 20)
        when not matched then insert(workflow_id, step_no, step_name, step_type,
          actor_type, action_required)
        values(s.workflow_id, 20, 'Executive Review', 'RECOMMEND', 'CONCERNED_ED', 'RECOMMEND');
        merge into df_workflow_step d using (select w.workflow_id workflow_id from dual) s
          on (d.workflow_id = s.workflow_id and d.step_no = 30)
        when not matched then insert(workflow_id, step_no, step_name, step_type,
          actor_type, actor_id, action_required)
        values(s.workflow_id, 30, 'Final Approval', 'FINAL_APPROVAL', 'ROLE', 'MANAGING_DIRECTOR', 'APPROVE');
    end loop;
end;
/

-- Procurement fixed technical path.
merge into df_workflow_step d using (select 7 workflow_id from dual) s
  on (d.workflow_id = s.workflow_id and d.step_no = 10)
when not matched then insert(workflow_id, step_no, step_name, step_type,
  actor_type, action_required)
values(7, 10, 'Department Review', 'RECOMMEND', 'DEPT_HEAD', 'RECOMMEND');
merge into df_workflow_step d using (select 7 workflow_id from dual) s
  on (d.workflow_id = s.workflow_id and d.step_no = 20)
when not matched then insert(workflow_id, step_no, step_name, step_type,
  actor_type, action_required)
values(7, 20, 'Item Expert Review', 'REVIEW', 'ITEM_EXPERT', 'RECOMMEND');
merge into df_workflow_step d using (select 7 workflow_id from dual) s
  on (d.workflow_id = s.workflow_id and d.step_no = 30)
when not matched then insert(workflow_id, step_no, step_name, step_type,
  actor_type, actor_id, action_required)
values(7, 30, 'Purchase Review', 'CHECK', 'ROLE', 'PURCHASE_HEAD', 'FORWARD');

merge into df_approval_rule d using (select 1 rule_id from dual) s
  on (d.rule_id = s.rule_id)
when not matched then insert(rule_id, workflow_id, rule_name, approval_mode,
  min_amount, max_amount, priority_no)
values(1, 7, 'Default Procurement Cumulative Authority', 'CUMULATIVE', 0, null, 100);

-- Option B cumulative ceiling. The duplicate DEPT_HEAD is used as the 10,000
-- ceiling marker; route de-duplication keeps only the earlier Department step.
merge into df_approval_rule_step d using (
    select 1 rule_step_id, 40 step_no, 'Department Authority' step_name,
           'DEPT_HEAD' actor_type, cast(null as varchar2(60)) actor_id, 10000 approval_limit from dual union all
    select 2, 50, 'Accounts Authority', 'ROLE', 'ACCOUNTS_HEAD', 30000 from dual union all
    select 3, 60, 'Finance Authority', 'ROLE', 'CFO', 50000 from dual union all
    select 4, 70, 'Executive Authority', 'CONCERNED_ED', null, 100000 from dual union all
    select 5, 80, 'Managing Director Authority', 'ROLE', 'MANAGING_DIRECTOR', null from dual
) s on (d.rule_id = 1 and d.step_no = s.step_no)
when not matched then insert(rule_step_id, rule_id, step_no, step_name,
  actor_type, actor_id, action_required, approval_limit)
values(s.rule_step_id, 1, s.step_no, s.step_name, s.actor_type, s.actor_id, 'APPROVE', s.approval_limit);

-- Fixed enterprise roles found in the supplied legacy data.
begin
    for x in (
        select 'PURCHASE_HEAD' role_code, 'IPI-000831' emp_id from dual union all
        select 'ACCOUNTS_HEAD', 'IPI-000001' from dual union all
        select 'CFO', 'IPI-000790' from dual union all
        select 'MANAGING_DIRECTOR', 'IPI-000789' from dual
    ) loop
        insert into df_role_assignment(role_id, emp_id, priority_no)
        select r.role_id, x.emp_id, 100
          from df_role r
          join employees e on upper(e.emp_id) = upper(x.emp_id) and nvl(e.status,0) = 1
         where r.role_code = x.role_code
           and not exists (select 1 from df_role_assignment a
                            where a.role_id = r.role_id and a.emp_id = x.emp_id
                              and a.company_id is null and a.unit_id is null
                              and a.location_id is null and a.department_id is null);
    end loop;
end;
/

commit;
