-- Workflow changes are performed by packages. Triggers only enforce audit safety.

create or replace trigger df_document_biu
before insert or update on df_document
for each row
begin
    if inserting then
        :new.created_at := nvl(:new.created_at, systimestamp);
        :new.created_by := nvl(:new.created_by,
            coalesce(sys_context('APEX$SESSION','APP_USER'), sys_context('USERENV','SESSION_USER')));
    else
        :new.updated_at := systimestamp;
        :new.updated_by := coalesce(sys_context('APEX$SESSION','APP_USER'), sys_context('USERENV','SESSION_USER'));
        :new.lock_version := :old.lock_version + 1;
    end if;
end;
/

create or replace trigger df_action_history_immutable
before update or delete on df_action_history
begin
    raise_application_error(-20090, 'DF_ACTION_HISTORY is immutable; UPDATE and DELETE are not allowed.');
end;
/

create or replace trigger df_document_no_delete
before delete on df_document
begin
    raise_application_error(-20091, 'Documents cannot be deleted. Use CANCELLED status.');
end;
/

create or replace trigger df_route_no_delete
before delete on df_document_route
begin
    raise_application_error(-20092, 'Route snapshots cannot be deleted. Use CANCELLED status.');
end;
/

create or replace trigger df_task_no_delete
before delete on df_task
begin
    raise_application_error(-20093, 'Tasks cannot be deleted. Use CANCELLED status.');
end;
/

create or replace trigger df_task_no_nested_review
for insert or update of parent_task_id, task_type on df_task
compound trigger
    type t_parent_ids is table of number index by pls_integer;
    g_parent_ids t_parent_ids;
    g_count pls_integer := 0;

    before each row is
    begin
        if :new.task_type = 'REVIEW' then
            g_count := g_count + 1;
            g_parent_ids(g_count) := :new.parent_task_id;
        end if;
    end before each row;

    after statement is
        l_parent_type df_task.task_type%type;
    begin
        if g_count > 0 then
            for i in 1 .. g_count loop
                begin
                    select task_type into l_parent_type
                      from df_task where task_id = g_parent_ids(i);
                exception when no_data_found then
                    raise_application_error(-20095, 'Review parent workflow task was not found.');
                end;
                if l_parent_type <> 'WORKFLOW' then
                    raise_application_error(-20094, 'Nested review is disabled; a review must belong to a workflow task.');
                end if;
            end loop;
        end if;
    end after statement;
end;
/

create or replace trigger df_app_user_employee_ck
before insert or update of emp_id on df_app_user
for each row
declare
    l_count number;
begin
    select count(*) into l_count from employees e
     where upper(e.emp_id) = upper(:new.emp_id) and nvl(e.status,0) = 1;
    if l_count <> 1 then
        raise_application_error(-20096, 'DF_APP_USER requires one active EMPLOYEES.EMP_ID.');
    end if;
end;
/

create or replace trigger df_role_assignment_employee_ck
before insert or update of emp_id on df_role_assignment
for each row
declare
    l_count number;
begin
    select count(*) into l_count from employees e
     where upper(e.emp_id) = upper(:new.emp_id) and nvl(e.status,0) = 1;
    if l_count <> 1 then
        raise_application_error(-20097, 'Role assignment requires one active EMPLOYEES.EMP_ID.');
    end if;
end;
/

create or replace trigger df_item_expert_employee_ck
before insert or update of emp_id on df_item_expert
for each row
declare
    l_count number;
begin
    select count(*) into l_count from employees e
     where upper(e.emp_id) = upper(:new.emp_id) and nvl(e.status,0) = 1;
    if l_count <> 1 then
        raise_application_error(-20098, 'Item expert requires one active EMPLOYEES.EMP_ID.');
    end if;
end;
/

create or replace trigger df_delegation_employee_ck
before insert or update of from_emp_id, to_emp_id on df_delegation
for each row
declare
    l_count number;
begin
    select count(*) into l_count from employees e
     where upper(e.emp_id) in (upper(:new.from_emp_id), upper(:new.to_emp_id))
       and nvl(e.status,0) = 1;
    if l_count <> 2 then
        raise_application_error(-20099, 'Delegation requires two active EMPLOYEES.EMP_ID values.');
    end if;
end;
/
