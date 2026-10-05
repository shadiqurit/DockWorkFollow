-- Validates the HR contract used by the workflow. This script makes no changes
-- to EMPLOYEES.

set serveroutput on

declare
    l_missing varchar2(4000);
    l_count   number;
begin
    select count(*) into l_count from user_tables where table_name = 'EMPLOYEES';
    if l_count = 0 then
        raise_application_error(-20980, 'Required table EMPLOYEES does not exist in this schema.');
    end if;

    for c in (
        select column_value column_name
          from table(sys.odcivarchar2list(
            'ID','EMP_ID','F_NAME','L_NAME','DEPT_ID','LOC_ID','BRANCH_ID',
            'DESIG_ID','COM_ID','JOB_ID','STATUS','UPD_DATE'))
         where column_value not in (
            select column_name from user_tab_columns where table_name = 'EMPLOYEES')
    ) loop
        l_missing := l_missing || case when l_missing is null then null else ', ' end || c.column_name;
    end loop;
    if l_missing is not null then
        raise_application_error(-20981, 'EMPLOYEES is missing required columns: ' || l_missing);
    end if;

    execute immediate q'[
        select count(*)
          from (select upper(emp_id) from employees
                 where emp_id is not null and nvl(status,0) = 1
                 group by upper(emp_id) having count(*) > 1)
    ]' into l_count;
    if l_count > 0 then
        raise_application_error(-20982,
            'EMPLOYEES has duplicate active EMP_ID values. Resolve them before installing workflow.');
    end if;

    dbms_output.put_line('EMPLOYEES contract is valid.');
    dbms_output.put_line('Mapping: DEPT_ID=department, BRANCH_ID=unit, COM_ID=company, LOC_ID=location.');
end;
/
