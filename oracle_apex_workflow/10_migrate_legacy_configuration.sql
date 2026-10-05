-- Optional, run AFTER 00_install.sql in the same schema as the supplied legacy
-- PUR_ITEM, DEPAT_HEAD, CS_APPROVAL_ED_LIST and CS_AUTHORITY_LIST tables.
-- The script is idempotent and does not update or delete legacy data.

set define off
set serveroutput on

declare
    function table_exists(p_name varchar2) return boolean is
        l_count number;
    begin
        select count(*) into l_count from user_tables where table_name = upper(p_name);
        return l_count = 1;
    end;
begin
    if table_exists('PUR_ITEM') then
        execute immediate q'[
            merge into df_item d
            using (
                select nvl(p.ccode,'NA') || '-' || nvl(p.unitid,'NA') || '-' || p.item_id item_code,
                       p.item_name, e.dept_id department_id, p.dept_name department_code,
                       e.com_id company_id, p.ccode company_code,
                       e.branch_id unit_id, p.unitid unit_code, p.id legacy_item_id
                  from pur_item p
                  left join employees e on upper(e.emp_id) = upper(p.empcode)
            ) s on (d.item_code = s.item_code)
            when not matched then insert(
                item_code, item_name, department_id, department_code,
                company_id, company_code, unit_id, unit_code, legacy_item_id)
            values(s.item_code, s.item_name, s.department_id, s.department_code,
                s.company_id, s.company_code, s.unit_id, s.unit_code, s.legacy_item_id)
        ]';

        execute immediate q'[
            insert into df_item_expert(
                item_id, emp_id, company_id, company_code, unit_id, unit_code,
                location_id, primary_yn)
            select d.item_id, p.empcode, e.com_id, p.ccode, e.branch_id, p.unitid,
                   e.loc_id, 'Y'
              from pur_item p
              join df_item d on d.item_code = nvl(p.ccode,'NA') || '-' || nvl(p.unitid,'NA') || '-' || p.item_id
              join employees e on upper(e.emp_id) = upper(p.empcode) and nvl(e.status,0) = 1
             where p.empcode is not null
               and not exists (select 1 from df_item_expert x
                                where x.item_id = d.item_id and upper(x.emp_id) = upper(p.empcode)
                                  and nvl(x.company_id,-1) = nvl(e.com_id,-1)
                                  and nvl(x.unit_id,-1) = nvl(e.branch_id,-1)
                                  and nvl(x.location_id,-1) = nvl(e.loc_id,-1))
        ]';
        dbms_output.put_line('Migrated PUR_ITEM and item experts.');
    else
        dbms_output.put_line('Skipped PUR_ITEM: table not found.');
    end if;

    if table_exists('DEPAT_HEAD') then
        execute immediate q'[
            insert into df_role_assignment(
                role_id, emp_id, company_id, unit_id, location_id,
                department_id, department_code, priority_no)
            select r.role_id, h.empcode, e.com_id, e.branch_id, e.loc_id,
                   e.dept_id, h.dept_name, 10
              from (
                    select x.*, row_number() over(
                        partition by upper(x.dept_name), upper(nvl(x.unit,chr(0)))
                        order by x.id desc, x.create_date desc) rn
                      from depat_head x
                     where x.empcode is not null
                   ) h
              join employees e on upper(e.emp_id) = upper(h.empcode) and nvl(e.status,0) = 1
              cross join df_role r
             where r.role_code = 'DEPT_HEAD' and h.rn = 1
               and not exists (select 1 from df_role_assignment x
                                where x.role_id = r.role_id
                                  and upper(x.emp_id) = upper(h.empcode)
                                  and nvl(x.department_id,-1) = nvl(e.dept_id,-1)
                                  and nvl(x.company_id,-1) = nvl(e.com_id,-1)
                                  and nvl(x.unit_id,-1) = nvl(e.branch_id,-1)
                                  and nvl(x.location_id,-1) = nvl(e.loc_id,-1))
        ]';
        dbms_output.put_line('Migrated DEPAT_HEAD as DEPT_HEAD role assignments.');
    else
        dbms_output.put_line('Skipped DEPAT_HEAD: table not found.');
    end if;

    if table_exists('CS_APPROVAL_ED_LIST') then
        execute immediate q'[
            insert into df_role_assignment(
                role_id, emp_id, company_id, unit_id, location_id,
                department_id, department_code, priority_no, active_yn)
            select r.role_id, c.emp_code, e.com_id, e.branch_id, e.loc_id,
                   e.dept_id, c.department_name, 10,
                   case when upper(nvl(c.status,'N')) = 'Y' then 'Y' else 'N' end
              from cs_approval_ed_list c
              join employees e on upper(e.emp_id) = upper(c.emp_code) and nvl(e.status,0) = 1
              cross join df_role r
             where r.role_code = 'CONCERNED_ED' and c.emp_code is not null
               and not exists (select 1 from df_role_assignment x
                                where x.role_id = r.role_id
                                  and upper(x.emp_id) = upper(c.emp_code)
                                  and nvl(x.department_id,-1) = nvl(e.dept_id,-1)
                                  and nvl(x.company_id,-1) = nvl(e.com_id,-1)
                                  and nvl(x.unit_id,-1) = nvl(e.branch_id,-1)
                                  and nvl(x.location_id,-1) = nvl(e.loc_id,-1))
        ]';
        dbms_output.put_line('Migrated CS_APPROVAL_ED_LIST as CONCERNED_ED assignments.');
    else
        dbms_output.put_line('Skipped CS_APPROVAL_ED_LIST: table not found.');
    end if;

    commit;
end;
/
