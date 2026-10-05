set serveroutput on

declare
    l_errors number := 0;
begin
    for e in (
        select name, type, line, position, text
          from user_errors
         where name like 'PKG_DF_%'
            or name in ('DF_DOCUMENT_BIU','DF_ACTION_HISTORY_IMMUTABLE',
                        'DF_DOCUMENT_NO_DELETE','DF_ROUTE_NO_DELETE','DF_TASK_NO_DELETE',
                        'DF_TASK_NO_NESTED_REVIEW','DF_APP_USER_EMPLOYEE_CK',
                        'DF_ROLE_ASSIGNMENT_EMPLOYEE_CK','DF_ITEM_EXPERT_EMPLOYEE_CK',
                        'DF_DELEGATION_EMPLOYEE_CK')
         order by name, sequence
    ) loop
        l_errors := l_errors + 1;
        dbms_output.put_line(e.name || ' [' || e.type || '] ' || e.line || ':' ||
                             e.position || ' ' || e.text);
    end loop;

    for o in (
        select object_name, object_type
          from user_objects
         where status <> 'VALID'
           and (object_name like 'PKG_DF_%' or object_name like 'V_DF_%'
                or object_name in ('DF_DOCUMENT_BIU','DF_ACTION_HISTORY_IMMUTABLE',
                    'DF_DOCUMENT_NO_DELETE','DF_ROUTE_NO_DELETE','DF_TASK_NO_DELETE',
                    'DF_TASK_NO_NESTED_REVIEW','DF_APP_USER_EMPLOYEE_CK',
                    'DF_ROLE_ASSIGNMENT_EMPLOYEE_CK','DF_ITEM_EXPERT_EMPLOYEE_CK',
                    'DF_DELEGATION_EMPLOYEE_CK'))
    ) loop
        l_errors := l_errors + 1;
        dbms_output.put_line('INVALID: ' || o.object_type || ' ' || o.object_name);
    end loop;

    if l_errors > 0 then
        raise_application_error(-20999, 'Workflow installation has ' || l_errors || ' compilation/validation errors.');
    end if;
    dbms_output.put_line('All workflow packages, triggers and views are VALID.');
end;
/
