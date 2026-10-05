create or replace package pkg_df_history authid definer as
    procedure log_action(
        p_document_id      in number,
        p_action_type      in varchar2,
        p_action_by_emp_id in varchar2,
        p_action_to_emp_id in varchar2 default null,
        p_route_id         in number default null,
        p_task_id          in number default null,
        p_from_status      in varchar2 default null,
        p_to_status        in varchar2 default null,
        p_comments         in varchar2 default null,
        p_parent_action_id in number default null);
end pkg_df_history;
/

create or replace package body pkg_df_history as
    procedure log_action(
        p_document_id      in number,
        p_action_type      in varchar2,
        p_action_by_emp_id in varchar2,
        p_action_to_emp_id in varchar2 default null,
        p_route_id         in number default null,
        p_task_id          in number default null,
        p_from_status      in varchar2 default null,
        p_to_status        in varchar2 default null,
        p_comments         in varchar2 default null,
        p_parent_action_id in number default null) is
        l_remote_address varchar2(64);
    begin
        begin
            l_remote_address := sys_context('USERENV','IP_ADDRESS');
        exception
            when others then
                l_remote_address := null;
        end;

        if p_document_id is null or p_action_by_emp_id is null then
            raise_application_error(-20001, 'Document and acting employee are required for history.');
        end if;

        insert into df_action_history(
            document_id, route_id, task_id, action_type,
            action_by_emp_id, action_to_emp_id, from_status, to_status,
            comments, parent_action_id, ip_address, apex_session_id, app_user)
        values (
            p_document_id, p_route_id, p_task_id, upper(trim(p_action_type)),
            upper(trim(p_action_by_emp_id)), upper(trim(p_action_to_emp_id)),
            upper(trim(p_from_status)), upper(trim(p_to_status)),
            p_comments, p_parent_action_id, l_remote_address,
            sys_context('APEX$SESSION','APP_SESSION'),
            coalesce(sys_context('APEX$SESSION','APP_USER'), sys_context('USERENV','SESSION_USER')));
    end log_action;
end pkg_df_history;
/

create or replace package pkg_df_actor authid definer as
    function is_active_employee(p_emp_id in varchar2) return varchar2;

    function get_role_employee(
        p_role_code   in varchar2,
        p_document_id in number,
        p_role_id     out number) return varchar2;

    function get_department_head(p_document_id in number, p_role_id out number) return varchar2;
    function get_item_expert(p_document_id in number) return varchar2;
    function get_concerned_ed(p_document_id in number, p_role_id out number) return varchar2;

    function resolve_actor(
        p_actor_type        in varchar2,
        p_actor_id          in varchar2,
        p_document_id       in number,
        p_role_id           out number,
        p_delegated_from_emp_id out varchar2) return varchar2;

    function resolve_actor_for_display(
        p_actor_type  in varchar2,
        p_actor_id    in varchar2,
        p_document_id in number) return varchar2;
end pkg_df_actor;
/

create or replace package body pkg_df_actor as
    function is_active_employee(p_emp_id in varchar2) return varchar2 is
        l_count number;
    begin
        select count(*) into l_count
          from employees e
         where upper(e.emp_id) = upper(trim(p_emp_id))
           and nvl(e.status, 0) = 1;
        return case when l_count > 0 then 'Y' else 'N' end;
    end is_active_employee;

    function get_role_employee(
        p_role_code   in varchar2,
        p_document_id in number,
        p_role_id     out number) return varchar2 is
        l_emp_id varchar2(30);
    begin
        select role_id, emp_id
          into p_role_id, l_emp_id
          from (
                select r.role_id, ra.emp_id,
                       (case when ra.company_id  is not null then 1 else 0 end +
                        case when ra.unit_id     is not null then 1 else 0 end +
                        case when ra.location_id is not null then 1 else 0 end +
                        case when ra.department_id is not null then 1 else 0 end) specificity,
                       ra.priority_no, ra.effective_from
                  from df_role r
                  join df_role_assignment ra on ra.role_id = r.role_id
                  join df_document d on d.document_id = p_document_id
                  join employees e on upper(e.emp_id) = upper(ra.emp_id)
                 where r.role_code = upper(trim(p_role_code))
                   and r.active_yn = 'Y'
                   and ra.active_yn = 'Y'
                   and nvl(e.status, 0) = 1
                   and trunc(sysdate) between ra.effective_from and nvl(ra.effective_to, date '2999-12-31')
                   and (ra.company_id is null or ra.company_id = d.company_id)
                   and (ra.unit_id is null or ra.unit_id = d.unit_id)
                   and (ra.location_id is null or ra.location_id = d.location_id)
                   and (ra.department_id is null or ra.department_id = d.department_id)
                 order by specificity desc, ra.priority_no, ra.effective_from desc, ra.assignment_id
               )
         where rownum = 1;
        return upper(l_emp_id);
    exception
        when no_data_found then
            raise_application_error(-20002,
                'No active role assignment for ' || upper(trim(p_role_code)) ||
                ' and document ' || p_document_id || '.');
    end get_role_employee;

    function get_department_head(p_document_id in number, p_role_id out number) return varchar2 is
    begin
        return get_role_employee('DEPT_HEAD', p_document_id, p_role_id);
    end;

    function get_concerned_ed(p_document_id in number, p_role_id out number) return varchar2 is
    begin
        return get_role_employee('CONCERNED_ED', p_document_id, p_role_id);
    end;

    function get_item_expert(p_document_id in number) return varchar2 is
        l_emp_id varchar2(30);
    begin
        select emp_id
          into l_emp_id
          from (
                select ie.emp_id,
                       (case when ie.company_id is not null then 1 else 0 end +
                        case when ie.unit_id is not null then 1 else 0 end +
                        case when ie.location_id is not null then 1 else 0 end) specificity,
                       ie.primary_yn, ie.priority_no, ie.effective_from
                  from df_purchase p
                  join df_document d on d.document_id = p.document_id
                  join df_item_expert ie on ie.item_id = p.primary_item_id
                  join employees e on upper(e.emp_id) = upper(ie.emp_id)
                 where p.document_id = p_document_id
                   and ie.active_yn = 'Y'
                   and nvl(e.status, 0) = 1
                   and trunc(sysdate) between ie.effective_from and nvl(ie.effective_to, date '2999-12-31')
                   and (ie.company_id is null or ie.company_id = d.company_id)
                   and (ie.unit_id is null or ie.unit_id = d.unit_id)
                   and (ie.location_id is null or ie.location_id = d.location_id)
                 order by specificity desc, ie.primary_yn desc, ie.priority_no,
                          ie.effective_from desc, ie.item_expert_id
               )
         where rownum = 1;
        return upper(l_emp_id);
    exception
        when no_data_found then
            raise_application_error(-20003,
                'No active primary item expert for document ' || p_document_id || '.');
    end get_item_expert;

    function apply_delegation(
        p_emp_id       in varchar2,
        p_role_id      in number,
        p_original_emp out varchar2) return varchar2 is
        l_delegate varchar2(30);
    begin
        p_original_emp := null;
        select to_emp_id
          into l_delegate
          from (
                select d.to_emp_id,
                       case when d.role_id = p_role_id then 0 else 1 end role_order,
                       d.start_date, d.delegation_id
                  from df_delegation d
                  join employees e on upper(e.emp_id) = upper(d.to_emp_id)
                 where upper(d.from_emp_id) = upper(p_emp_id)
                   and d.active_yn = 'Y'
                   and nvl(e.status, 0) = 1
                   and trunc(sysdate) between d.start_date and d.end_date
                   and (d.role_id is null or d.role_id = p_role_id)
                 order by role_order, d.start_date desc, d.delegation_id
               )
         where rownum = 1;
        p_original_emp := upper(p_emp_id);
        return upper(l_delegate);
    exception when no_data_found then
        return upper(p_emp_id);
    end apply_delegation;

    function resolve_actor(
        p_actor_type        in varchar2,
        p_actor_id          in varchar2,
        p_document_id       in number,
        p_role_id           out number,
        p_delegated_from_emp_id out varchar2) return varchar2 is
        l_emp_id varchar2(30);
        l_type   varchar2(30) := upper(trim(p_actor_type));
    begin
        p_role_id := null;
        p_delegated_from_emp_id := null;

        case l_type
            when 'EMPLOYEE' then
                if p_actor_id is null then
                    raise_application_error(-20004, 'EMPLOYEE actor requires ACTOR_ID.');
                end if;
                l_emp_id := upper(trim(p_actor_id));
                if is_active_employee(l_emp_id) <> 'Y' then
                    raise_application_error(-20006, 'Employee is missing or inactive: ' || l_emp_id);
                end if;
            when 'ROLE' then
                l_emp_id := get_role_employee(p_actor_id, p_document_id, p_role_id);
            when 'DEPT_HEAD' then
                l_emp_id := get_department_head(p_document_id, p_role_id);
            when 'ITEM_EXPERT' then
                l_emp_id := get_item_expert(p_document_id);
            when 'CONCERNED_ED' then
                l_emp_id := get_concerned_ed(p_document_id, p_role_id);
            when 'DOCUMENT_CREATOR' then
                select upper(creator_emp_id) into l_emp_id
                  from df_document where document_id = p_document_id;
            else
                raise_application_error(-20005, 'Unsupported actor type: ' || l_type);
        end case;

        return apply_delegation(l_emp_id, p_role_id, p_delegated_from_emp_id);
    end resolve_actor;

    function resolve_actor_for_display(
        p_actor_type  in varchar2,
        p_actor_id    in varchar2,
        p_document_id in number) return varchar2 is
        l_role_id number;
        l_delegated_from varchar2(30);
    begin
        return resolve_actor(p_actor_type, p_actor_id, p_document_id,
            l_role_id, l_delegated_from);
    end resolve_actor_for_display;
end pkg_df_actor;
/
