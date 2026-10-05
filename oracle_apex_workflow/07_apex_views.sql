create or replace view v_df_employee as
select employee_id, employee_code, employee_name, email, mobile,
       department_id, unit_id, company_id, location_id,
       designation_id, job_id, status, active_yn
  from (
        select e.id employee_id,
               upper(e.emp_id) employee_code,
               trim(e.f_name || ' ' || e.l_name) employee_name,
               e.email, e.mobile, e.dept_id department_id,
               e.branch_id unit_id, e.com_id company_id, e.loc_id location_id,
               e.desig_id designation_id, e.job_id, e.status,
               case when nvl(e.status,0) = 1 then 'Y' else 'N' end active_yn,
               row_number() over(
                   partition by upper(e.emp_id)
                   order by case when nvl(e.status,0) = 1 then 0 else 1 end,
                            e.upd_date desc nulls last, e.id desc) rn
          from employees e
         where e.emp_id is not null
       )
 where rn = 1;

create or replace view v_df_role_assignment_admin as
select ra.assignment_id,
       ra.role_id,
       r.role_code,
       r.role_name,
       upper(ra.emp_id) emp_id,
       e.employee_name,
       e.email,
       ra.company_id,
       ra.company_code,
       ra.unit_id,
       ra.unit_code,
       ra.location_id,
       ra.location_code,
       ra.department_id,
       ra.department_code,
       (case when ra.company_id is not null then 1 else 0 end +
        case when ra.unit_id is not null then 1 else 0 end +
        case when ra.location_id is not null then 1 else 0 end +
        case when ra.department_id is not null then 1 else 0 end) scope_specificity,
       'C:' || nvl(to_char(ra.company_id), '*') ||
       ' / U:' || nvl(to_char(ra.unit_id), '*') ||
       ' / L:' || nvl(to_char(ra.location_id), '*') ||
       ' / D:' || nvl(to_char(ra.department_id), '*') scope_summary,
       ra.priority_no,
       ra.effective_from,
       ra.effective_to,
       ra.active_yn,
       case
           when ra.active_yn = 'N' then 'INACTIVE'
           when trunc(sysdate) < ra.effective_from then 'FUTURE'
           when ra.effective_to is not null and trunc(sysdate) > ra.effective_to then 'EXPIRED'
           else 'CURRENT'
       end effective_status,
       ra.created_by,
       ra.created_at
  from df_role_assignment ra
  join df_role r on r.role_id = ra.role_id
  left join v_df_employee e on e.employee_code = upper(ra.emp_id);

create or replace package pkg_df_security authid definer as
    function current_emp_id return varchar2;
    function has_pending_workflow_task(p_document_id number, p_emp_id varchar2 default null) return varchar2;
    function has_pending_review(p_document_id number, p_emp_id varchar2 default null) return varchar2;
    function can_view_document(p_document_id number, p_emp_id varchar2 default null) return varchar2;
end pkg_df_security;
/

create or replace package body pkg_df_security as
    function current_emp_id return varchar2 is
        l_emp_id varchar2(30);
        l_user varchar2(255) := coalesce(sys_context('APEX$SESSION','APP_USER'),
                                         sys_context('USERENV','SESSION_USER'));
    begin
        -- Optional alias mapping: use this when APP_USER is not EMPLOYEES.EMP_ID.
        begin
            select upper(a.emp_id)
              into l_emp_id
              from df_app_user a
              join employees e on upper(e.emp_id) = upper(a.emp_id)
             where upper(a.app_username) = upper(trim(l_user))
               and a.active_yn = 'Y'
               and nvl(e.status,0) = 1
               and rownum = 1;

            return l_emp_id;
        exception
            when no_data_found then
                null;
        end;

        -- Page 9999 authenticates with EMPLOYEES.EMP_ID, so no alias row is required.
        select upper(e.emp_id)
          into l_emp_id
          from employees e
         where upper(e.emp_id) = upper(trim(l_user))
           and nvl(e.status,0) = 1
           and rownum = 1;

        return l_emp_id;
    exception
        when no_data_found then
            return null;
    end;

    function has_pending_workflow_task(p_document_id number, p_emp_id varchar2 default null) return varchar2 is
        l_count number;
        l_emp varchar2(30) := nvl(upper(trim(p_emp_id)), current_emp_id);
    begin
        select count(*) into l_count from df_task
         where document_id = p_document_id and task_type = 'WORKFLOW'
           and status = 'PENDING' and upper(assigned_to_emp_id) = l_emp;
        return case when l_count > 0 then 'Y' else 'N' end;
    end;

    function has_pending_review(p_document_id number, p_emp_id varchar2 default null) return varchar2 is
        l_count number;
        l_emp varchar2(30) := nvl(upper(trim(p_emp_id)), current_emp_id);
    begin
        select count(*) into l_count from df_task
         where document_id = p_document_id and task_type = 'REVIEW'
           and status = 'PENDING' and upper(assigned_to_emp_id) = l_emp;
        return case when l_count > 0 then 'Y' else 'N' end;
    end;

    function can_view_document(p_document_id number, p_emp_id varchar2 default null) return varchar2 is
        l_count number;
        l_emp varchar2(30) := nvl(upper(trim(p_emp_id)), current_emp_id);
    begin
        if l_emp is null then return 'N'; end if;
        select count(*) into l_count
          from dual
         where exists (select 1 from df_document d
                        where d.document_id = p_document_id and upper(d.creator_emp_id) = l_emp)
            or exists (select 1 from df_task t
                        where t.document_id = p_document_id and upper(t.assigned_to_emp_id) = l_emp)
            or exists (select 1 from df_distribution x
                        where x.document_id = p_document_id and x.recipient_type = 'EMPLOYEE'
                          and upper(x.recipient_emp_id) = l_emp);
        return case when l_count > 0 then 'Y' else 'N' end;
    end;
end pkg_df_security;
/

create or replace view v_df_my_inbox as
select t.task_id, t.document_id, t.route_id, d.document_no, d.subject,
       dt.type_name, r.step_name, r.action_required, d.priority_code,
       d.current_status, t.assigned_at, t.due_at,
       d.creator_emp_id, ce.employee_name creator_name,
       round((cast(systimestamp as date) - cast(t.assigned_at as date)) * 24, 2) elapsed_hours
  from df_task t
  join df_document d on d.document_id = t.document_id
  join df_document_type dt on dt.type_id = d.type_id
  join df_document_route r on r.route_id = t.route_id
  left join v_df_employee ce on ce.employee_code = upper(d.creator_emp_id)
 where t.task_type = 'WORKFLOW' and t.status = 'PENDING'
   and upper(t.assigned_to_emp_id) = pkg_df_security.current_emp_id;

create or replace view v_df_review_inbox as
select t.task_id, t.document_id, t.parent_task_id, d.document_no, d.subject,
       dt.type_name, t.assigned_by_emp_id requested_by_emp_id,
       t.instruction, t.assigned_at, t.due_at
  from df_task t
  join df_document d on d.document_id = t.document_id
  join df_document_type dt on dt.type_id = d.type_id
 where t.task_type = 'REVIEW' and t.status = 'PENDING'
   and upper(t.assigned_to_emp_id) = pkg_df_security.current_emp_id;

create or replace view v_df_my_submitted as
select d.document_id, d.document_no, d.subject, dt.type_name,
       d.current_status, d.current_assignee_emp_id, d.total_amount,
       d.currency_code, d.document_date, d.submitted_at, d.approved_at
  from df_document d join df_document_type dt on dt.type_id = d.type_id
 where upper(d.creator_emp_id) = pkg_df_security.current_emp_id;

create or replace view v_df_document_tracking as
select d.document_id, d.document_no, d.subject, dt.type_name,
       d.current_status, d.current_assignee_emp_id, r.step_name current_step_name,
       t.assigned_at pending_since,
       round((cast(systimestamp as date) - cast(t.assigned_at as date)) * 24, 2) elapsed_hours,
       d.creator_emp_id, d.department_id, d.department_code,
       d.company_id, d.company_code, d.unit_id, d.unit_code,
       d.location_id, d.location_code, d.total_amount, d.currency_code
  from df_document d
  join df_document_type dt on dt.type_id = d.type_id
  left join df_document_route r on r.route_id = d.current_route_id
  left join df_task t on t.route_id = d.current_route_id
       and t.task_type = 'WORKFLOW' and t.status in ('PENDING','WAITING_REVIEW');

create or replace view v_df_document_timeline as
select h.action_id, h.document_id, h.action_at, h.action_type,
       h.action_by_emp_id, by_emp.employee_name action_by_name,
       h.action_to_emp_id, to_emp.employee_name action_to_name, h.comments,
       h.from_status, h.to_status, r.step_no, r.step_name
  from df_action_history h
  left join df_document_route r on r.route_id = h.route_id
  left join v_df_employee by_emp on by_emp.employee_code = upper(h.action_by_emp_id)
  left join v_df_employee to_emp on to_emp.employee_code = upper(h.action_to_emp_id);

create or replace view v_df_route_status as
select r.route_id, r.document_id, r.step_no, r.step_name, r.step_type,
       r.action_required, r.assigned_emp_id, e.employee_name assigned_employee_name,
       ro.role_code, ro.role_name,
       r.delegated_from_emp_id, r.status, r.is_final_yn,
       r.started_at, r.completed_at
  from df_document_route r
  left join df_role ro on ro.role_id = r.assigned_role_id
  left join v_df_employee e on e.employee_code = upper(r.assigned_emp_id);

create or replace view v_df_received_documents as
select x.distribution_id, x.document_id, d.document_no, d.subject,
       dt.type_name, x.sent_by_emp_id, x.sent_at, x.delivery_status,
       x.viewed_at, x.acknowledged_at, x.message
  from df_distribution x
  join df_document d on d.document_id = x.document_id
  join df_document_type dt on dt.type_id = d.type_id
 where x.recipient_type = 'EMPLOYEE'
   and upper(x.recipient_emp_id) = pkg_df_security.current_emp_id;

create or replace view v_df_dashboard_counts as
select
    (select count(*) from df_task where task_type = 'WORKFLOW' and status = 'PENDING'
      and upper(assigned_to_emp_id) = pkg_df_security.current_emp_id) my_pending,
    (select count(*) from df_task where task_type = 'REVIEW' and status = 'PENDING'
      and upper(assigned_to_emp_id) = pkg_df_security.current_emp_id) review_requests,
    (select count(*) from df_document where current_status = 'RETURNED'
      and upper(current_assignee_emp_id) = pkg_df_security.current_emp_id) returned_documents,
    (select count(*) from df_document where current_status = 'DRAFT'
      and upper(creator_emp_id) = pkg_df_security.current_emp_id) my_drafts,
    (select count(*) from df_document where current_status = 'APPROVED'
      and approved_at >= trunc(systimestamp)) approved_today
from dual;
