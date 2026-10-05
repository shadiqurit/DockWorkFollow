create or replace package pkg_df_review authid definer as
    procedure request_review(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_reviewer_emp_id in varchar2,
        p_instruction in varchar2,
        p_due_at      in timestamp with local time zone default null);

    procedure complete_review(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2);
end pkg_df_review;
/

create or replace package body pkg_df_review as
    procedure request_review(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_reviewer_emp_id in varchar2,
        p_instruction in varchar2,
        p_due_at      in timestamp with local time zone default null) is
        l_parent_task_id number;
        l_route_id number;
        l_can_review varchar2(1);
        l_allow_review varchar2(1);
        l_review_task_id number;
    begin
        if trim(p_reviewer_emp_id) is null or trim(p_instruction) is null then
            raise_application_error(-20060, 'Reviewer and review instruction are required.');
        end if;
        if pkg_df_actor.is_active_employee(p_reviewer_emp_id) <> 'Y' then
            raise_application_error(-20066, 'Reviewer employee is missing or inactive.');
        end if;
        if upper(trim(p_reviewer_emp_id)) = upper(trim(p_emp_id)) then
            raise_application_error(-20061, 'A task owner cannot send a review to themselves.');
        end if;

        select t.task_id, t.route_id, r.can_review_yn, dt.allow_review_yn
          into l_parent_task_id, l_route_id, l_can_review, l_allow_review
          from df_task t
          join df_document_route r on r.route_id = t.route_id
          join df_document d on d.document_id = t.document_id
          join df_document_type dt on dt.type_id = d.type_id
         where t.document_id = p_document_id
           and t.task_type = 'WORKFLOW'
           and t.status = 'PENDING'
           and upper(t.assigned_to_emp_id) = upper(trim(p_emp_id))
         for update of t.status;
        if l_can_review <> 'Y' or l_allow_review <> 'Y' then
            raise_application_error(-20062, 'Review is not allowed for this document or route step.');
        end if;

        update df_task set status = 'WAITING_REVIEW' where task_id = l_parent_task_id;
        insert into df_task(
            document_id, route_id, task_type, assigned_to_emp_id,
            assigned_by_emp_id, due_at, parent_task_id, return_to_task_id, instruction)
        values (
            p_document_id, l_route_id, 'REVIEW', upper(trim(p_reviewer_emp_id)),
            upper(trim(p_emp_id)), p_due_at, l_parent_task_id, l_parent_task_id, p_instruction)
        returning task_id into l_review_task_id;

        update df_document set current_status = 'UNDER_REVIEW',
               current_assignee_emp_id = upper(trim(p_reviewer_emp_id))
         where document_id = p_document_id;
        pkg_df_history.log_action(p_document_id, 'REVIEW_REQUESTED', p_emp_id,
            p_reviewer_emp_id, l_route_id, l_review_task_id,
            'IN_PROCESS', 'UNDER_REVIEW', p_instruction);
    exception when no_data_found then
        raise_application_error(-20063, 'No pending workflow task belongs to this employee.');
    end request_review;

    procedure complete_review(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2) is
        l_review_task_id number;
        l_parent_task_id number;
        l_route_id number;
        l_parent_emp varchar2(30);
    begin
        if trim(p_comments) is null then
            raise_application_error(-20064, 'Review comments are required.');
        end if;
        select task_id, parent_task_id, route_id
          into l_review_task_id, l_parent_task_id, l_route_id
          from df_task
         where document_id = p_document_id and task_type = 'REVIEW'
           and status = 'PENDING'
           and upper(assigned_to_emp_id) = upper(trim(p_emp_id))
         for update;

        select assigned_to_emp_id into l_parent_emp
          from df_task
         where task_id = l_parent_task_id and task_type = 'WORKFLOW'
           and status = 'WAITING_REVIEW'
         for update;

        update df_task set status = 'COMPLETED', completed_at = systimestamp,
               completion_comments = p_comments
         where task_id = l_review_task_id;
        update df_task set status = 'PENDING' where task_id = l_parent_task_id;
        update df_document set current_status = 'IN_PROCESS',
               current_assignee_emp_id = l_parent_emp
         where document_id = p_document_id;

        pkg_df_history.log_action(p_document_id, 'REVIEWED', p_emp_id,
            l_parent_emp, l_route_id, l_review_task_id,
            'UNDER_REVIEW', 'IN_PROCESS', p_comments);
    exception when no_data_found then
        raise_application_error(-20065, 'No pending review belongs to this employee, or its parent is no longer waiting.');
    end complete_review;
end pkg_df_review;
/

create or replace package pkg_df_distribution authid definer as
    procedure send_document(
        p_document_id      in number,
        p_sent_by_emp_id   in varchar2,
        p_recipient_type   in varchar2,
        p_recipient_emp_id in varchar2 default null,
        p_recipient_dept_id in number default null,
        p_recipient_dept_code in varchar2 default null,
        p_message          in varchar2 default null);

    procedure mark_viewed(
        p_distribution_id in number,
        p_emp_id          in varchar2);

    procedure acknowledge_document(
        p_distribution_id in number,
        p_emp_id          in varchar2);
end pkg_df_distribution;
/

create or replace package body pkg_df_distribution as
    procedure send_document(
        p_document_id      in number,
        p_sent_by_emp_id   in varchar2,
        p_recipient_type   in varchar2,
        p_recipient_emp_id in varchar2 default null,
        p_recipient_dept_id in number default null,
        p_recipient_dept_code in varchar2 default null,
        p_message          in varchar2 default null) is
        l_status varchar2(20);
        l_allowed varchar2(1);
        l_distribution_id number;
        l_type varchar2(20) := upper(trim(p_recipient_type));
        l_to varchar2(200);
        l_count number;
    begin
        select d.current_status, dt.allow_distribution_yn
          into l_status, l_allowed
          from df_document d join df_document_type dt on dt.type_id = d.type_id
         where d.document_id = p_document_id;
        if l_status not in ('APPROVED','CLOSED') or l_allowed <> 'Y' then
            raise_application_error(-20070, 'Only approved documents enabled for distribution may be sent.');
        end if;
        if l_type = 'EMPLOYEE' and trim(p_recipient_emp_id) is not null
           and p_recipient_dept_id is null and p_recipient_dept_code is null then
            if pkg_df_actor.is_active_employee(p_recipient_emp_id) <> 'Y' then
                raise_application_error(-20075, 'Recipient employee is missing or inactive.');
            end if;
            l_to := upper(trim(p_recipient_emp_id));
        elsif l_type = 'DEPARTMENT' and p_recipient_dept_id is not null
           and p_recipient_emp_id is null then
            select count(*) into l_count from employees e
             where e.dept_id = p_recipient_dept_id and nvl(e.status,0) = 1;
            if l_count = 0 then
                raise_application_error(-20076, 'Recipient department has no active employee.');
            end if;
            l_to := nvl(p_recipient_dept_code, to_char(p_recipient_dept_id));
        else
            raise_application_error(-20071,
                'Recipient must be one internal EMPLOYEE or DEPARTMENT. External recipients are disabled.');
        end if;

        insert into df_distribution(
            document_id, recipient_type, recipient_emp_id,
            recipient_dept_id, recipient_dept_code,
            sent_by_emp_id, message)
        values (p_document_id, l_type, upper(trim(p_recipient_emp_id)),
            p_recipient_dept_id, p_recipient_dept_code,
            upper(trim(p_sent_by_emp_id)), p_message)
        returning distribution_id into l_distribution_id;
        pkg_df_history.log_action(p_document_id, 'DISTRIBUTED', p_sent_by_emp_id,
            case when l_type = 'EMPLOYEE' then p_recipient_emp_id end,
            p_comments => 'To ' || l_type || ': ' || l_to ||
                case when p_message is not null then ' - ' || p_message end);
    exception when no_data_found then
        raise_application_error(-20072, 'Document not found: ' || p_document_id);
    end send_document;

    procedure mark_viewed(
        p_distribution_id in number,
        p_emp_id          in varchar2) is
        l_document_id number;
    begin
        update df_distribution
           set delivery_status = case when delivery_status = 'UNREAD' then 'READ' else delivery_status end,
               viewed_at = nvl(viewed_at, systimestamp)
         where distribution_id = p_distribution_id
           and recipient_type = 'EMPLOYEE'
           and upper(recipient_emp_id) = upper(trim(p_emp_id))
        returning document_id into l_document_id;
        pkg_df_history.log_action(l_document_id, 'VIEWED', p_emp_id,
            p_from_status => 'UNREAD', p_to_status => 'READ');
    exception when no_data_found then
        raise_application_error(-20073, 'Employee distribution was not found for this user.');
    end mark_viewed;

    procedure acknowledge_document(
        p_distribution_id in number,
        p_emp_id          in varchar2) is
        l_document_id number;
        l_old_status varchar2(20);
    begin
        select document_id, delivery_status into l_document_id, l_old_status
          from df_distribution
         where distribution_id = p_distribution_id
           and recipient_type = 'EMPLOYEE'
           and upper(recipient_emp_id) = upper(trim(p_emp_id))
         for update;
        update df_distribution set delivery_status = 'ACKNOWLEDGED',
               viewed_at = nvl(viewed_at, systimestamp), acknowledged_at = systimestamp
         where distribution_id = p_distribution_id;
        pkg_df_history.log_action(l_document_id, 'ACKNOWLEDGED', p_emp_id,
            p_from_status => l_old_status, p_to_status => 'ACKNOWLEDGED');
    exception when no_data_found then
        raise_application_error(-20074, 'Employee distribution was not found for this user.');
    end acknowledge_document;
end pkg_df_distribution;
/
