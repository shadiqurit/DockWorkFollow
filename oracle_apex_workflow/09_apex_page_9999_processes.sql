-- Oracle APEX Page 9999 login configuration.
-- These are APEX process source blocks. Do not execute this file in SQL*Plus.

-- PROCESS 1
-- Page: 9999
-- Point: Processing / After Submit
-- Condition: Login button pressed
-- Keep this as the page's native APEX Login process source.
begin
    apex_authentication.login(
        p_username => trim(:P9999_USERNAME),
        p_password => :P9999_PASSWORD);
end;
/

-- PROCESS 2
-- Application process point: After Authentication
-- Create protected application items:
--   G_EMP_ID, G_UNAME, G_USER_GRP, USER_ID, G_COM_ID, G_COM_CODE
-- P9999_COMPANY is optional; when null, the employee's COM_ID is used.
declare
    l_employee_company_id employees.com_id%type;
    l_selected_company_id company.id%type;
begin
    select upper(trim(e.emp_id)),
           e.user_grp,
           e.id,
           e.com_id
      into :G_EMP_ID,
           :G_USER_GRP,
           :USER_ID,
           l_employee_company_id
      from employees e
     where upper(trim(e.emp_id)) = upper(trim(:APP_USER))
       and nvl(e.status, 0) = 1;

    :G_UNAME := :G_EMP_ID;
    l_selected_company_id := nvl(:P9999_COMPANY, l_employee_company_id);

    if l_selected_company_id is null then
        raise_application_error(-20081,
            'No company is selected and the employee has no COM_ID.');
    end if;

    select c.id, c.code
      into :G_COM_ID, :G_COM_CODE
      from company c
     where c.id = l_selected_company_id;
exception
    when no_data_found then
        raise_application_error(-20080,
            'Login is not linked to one active employee and a valid company.');
    when too_many_rows then
        raise_application_error(-20082,
            'Duplicate active employee or company data exists for this login.');
end;
/

-- Do not add WHEN OTHERS that assigns USER_ID/G_COM_ID = 1.
-- Authentication or master-data failures must stop the login initialization.
