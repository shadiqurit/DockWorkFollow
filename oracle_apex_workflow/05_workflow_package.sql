create or replace package pkg_df_workflow authid definer as
    procedure submit_document(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2 default null);

    procedure forward_document(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2 default null);

    procedure recommend_document(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2);

    procedure approve_document(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2 default null);

    procedure return_document(
        p_document_id      in number,
        p_emp_id           in varchar2,
        p_return_mode      in varchar2,
        p_return_route_id  in number default null,
        p_comments         in varchar2);

    procedure resubmit_document(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2);

    procedure reject_document(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2);

    procedure cancel_document(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2);
end pkg_df_workflow;
/

create or replace package body pkg_df_workflow as
    procedure activate_route(
        p_document_id number,
        p_route_id number,
        p_assigned_by varchar2,
        p_document_status varchar2 default 'IN_PROCESS') is
        l_emp_id varchar2(30);
        l_task_id number;
    begin
        update df_document_route
           set status = 'ACTIVE', started_at = systimestamp, completed_at = null
         where route_id = p_route_id and document_id = p_document_id
           and status in ('WAITING','RETURNED');
        if sql%rowcount <> 1 then
            raise_application_error(-20030, 'The target route is not available for activation.');
        end if;
        select assigned_emp_id into l_emp_id from df_document_route where route_id = p_route_id;
        insert into df_task(document_id, route_id, task_type, assigned_to_emp_id, assigned_by_emp_id)
        values (p_document_id, p_route_id, 'WORKFLOW', l_emp_id, upper(trim(p_assigned_by)))
        returning task_id into l_task_id;
        update df_document
           set current_status = p_document_status,
               current_route_id = p_route_id,
               current_assignee_emp_id = l_emp_id
         where document_id = p_document_id;
    end activate_route;

    procedure submit_document(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2 default null) is
        l_creator varchar2(30);
        l_status varchar2(20);
        l_type_id number;
        l_purchase_yn varchar2(1);
        l_workflow_id number;
        l_route_id number;
        l_assignee varchar2(30);
        l_count number;
        l_document_no varchar2(60);
    begin
        select d.creator_emp_id, d.current_status, d.type_id, dt.is_purchase_yn
          into l_creator, l_status, l_type_id, l_purchase_yn
          from df_document d join df_document_type dt on dt.type_id = d.type_id
         where d.document_id = p_document_id
         for update of d.current_status;
        if l_status <> 'DRAFT' then
            raise_application_error(-20031, 'Only a DRAFT document may be submitted.');
        end if;
        if upper(l_creator) <> upper(trim(p_emp_id)) then
            raise_application_error(-20032, 'Only the creator may submit this document.');
        end if;
        if l_purchase_yn = 'Y' then
            select count(*) into l_count from df_purchase where document_id = p_document_id;
            if l_count = 0 then
                raise_application_error(-20033, 'Purchase details and primary item are required before submission.');
            end if;
        end if;

        l_workflow_id := pkg_df_rule.find_workflow(p_document_id);
        l_document_no := pkg_df_document.generate_document_no(l_type_id);
        update df_document
           set document_no = l_document_no, workflow_id = l_workflow_id,
               current_status = 'SUBMITTED', submitted_at = systimestamp
         where document_id = p_document_id;

        pkg_df_document.create_version(p_document_id, p_emp_id, 'Initial submission');
        pkg_df_rule.build_route(p_document_id, l_workflow_id);
        select route_id, assigned_emp_id into l_route_id, l_assignee
          from (select route_id, assigned_emp_id from df_document_route
                 where document_id = p_document_id order by step_no)
         where rownum = 1;
        activate_route(p_document_id, l_route_id, p_emp_id);
        pkg_df_history.log_action(p_document_id, 'SUBMITTED', p_emp_id, l_assignee,
            p_route_id => l_route_id, p_from_status => 'DRAFT',
            p_to_status => 'IN_PROCESS', p_comments => p_comments);
    exception when no_data_found then
        raise_application_error(-20034, 'Document not found: ' || p_document_id);
    end submit_document;

    procedure complete_step(
        p_document_id number,
        p_emp_id varchar2,
        p_action varchar2,
        p_comments varchar2) is
        l_task_id number;
        l_route_id number;
        l_step_no number;
        l_required varchar2(20);
        l_is_final varchar2(1);
        l_old_status varchar2(20);
        l_next_route_id number;
        l_next_emp varchar2(30);
        l_action varchar2(30) := upper(trim(p_action));
        l_expected varchar2(30);
    begin
        select t.task_id, t.route_id, r.step_no, r.action_required, r.is_final_yn,
               d.current_status
          into l_task_id, l_route_id, l_step_no, l_required, l_is_final, l_old_status
          from df_task t
          join df_document_route r on r.route_id = t.route_id
          join df_document d on d.document_id = t.document_id
         where t.document_id = p_document_id
           and t.task_type = 'WORKFLOW'
           and t.status = 'PENDING'
           and upper(t.assigned_to_emp_id) = upper(trim(p_emp_id))
         for update of t.status;

        l_expected := case l_required
            when 'FORWARD' then 'FORWARDED'
            when 'RECOMMEND' then 'RECOMMENDED'
            when 'APPROVE' then 'APPROVED' end;
        if l_action <> l_expected then
            raise_application_error(-20035,
                'This step requires ' || l_required || ', not ' || l_action || '.');
        end if;
        if l_is_final = 'Y' and l_action <> 'APPROVED' then
            raise_application_error(-20036, 'The final route step must be approved.');
        end if;

        update df_task set status = 'COMPLETED', completed_at = systimestamp,
               completion_comments = p_comments
         where task_id = l_task_id;
        update df_document_route set status = 'COMPLETED', completed_at = systimestamp
         where route_id = l_route_id;

        if l_is_final = 'Y' then
            update df_document
               set current_status = 'APPROVED', current_route_id = null,
                   current_assignee_emp_id = null, approved_at = systimestamp
             where document_id = p_document_id;
            pkg_df_history.log_action(p_document_id, 'APPROVED', p_emp_id,
                p_route_id => l_route_id, p_task_id => l_task_id,
                p_from_status => l_old_status, p_to_status => 'APPROVED',
                p_comments => p_comments);
            return;
        end if;

        begin
            select route_id, assigned_emp_id into l_next_route_id, l_next_emp
              from (select route_id, assigned_emp_id from df_document_route
                     where document_id = p_document_id and step_no > l_step_no
                       and status = 'WAITING' order by step_no)
             where rownum = 1;
        exception when no_data_found then
            raise_application_error(-20037, 'No next route exists, but current step is not final.');
        end;

        activate_route(p_document_id, l_next_route_id, p_emp_id);
        pkg_df_history.log_action(p_document_id, l_action, p_emp_id, l_next_emp,
            p_route_id => l_route_id, p_task_id => l_task_id,
            p_from_status => l_old_status, p_to_status => 'IN_PROCESS',
            p_comments => p_comments);
    exception when no_data_found then
        raise_application_error(-20038, 'No pending task belongs to this employee. It may already be processed.');
    end complete_step;

    procedure forward_document(
        p_document_id in number, p_emp_id in varchar2,
        p_comments in varchar2 default null) is
    begin
        complete_step(p_document_id, p_emp_id, 'FORWARDED', p_comments);
    end;

    procedure recommend_document(
        p_document_id in number, p_emp_id in varchar2, p_comments in varchar2) is
    begin
        if trim(p_comments) is null then
            raise_application_error(-20039, 'Recommendation comments are required.');
        end if;
        complete_step(p_document_id, p_emp_id, 'RECOMMENDED', p_comments);
    end;

    procedure approve_document(
        p_document_id in number, p_emp_id in varchar2,
        p_comments in varchar2 default null) is
    begin
        complete_step(p_document_id, p_emp_id, 'APPROVED', p_comments);
    end;

    procedure return_document(
        p_document_id      in number,
        p_emp_id           in varchar2,
        p_return_mode      in varchar2,
        p_return_route_id  in number default null,
        p_comments         in varchar2) is
        l_task_id number;
        l_current_route number;
        l_current_step number;
        l_can_return varchar2(1);
        l_creator varchar2(30);
        l_target_route number;
        l_target_step number;
        l_target_emp varchar2(30);
        l_mode varchar2(20) := upper(trim(p_return_mode));
    begin
        if trim(p_comments) is null then
            raise_application_error(-20040, 'Return reason is required.');
        end if;
        select t.task_id, r.route_id, r.step_no, r.can_return_yn, d.creator_emp_id
          into l_task_id, l_current_route, l_current_step, l_can_return, l_creator
          from df_task t join df_document_route r on r.route_id = t.route_id
          join df_document d on d.document_id = t.document_id
         where t.document_id = p_document_id and t.task_type = 'WORKFLOW'
           and t.status = 'PENDING'
           and upper(t.assigned_to_emp_id) = upper(trim(p_emp_id))
         for update of t.status;
        if l_can_return <> 'Y' then
            raise_application_error(-20041, 'Return is not allowed at this route step.');
        end if;

        update df_task set status = 'RETURNED', completed_at = systimestamp,
               completion_comments = p_comments where task_id = l_task_id;
        update df_document_route set status = 'RETURNED', completed_at = systimestamp
         where route_id = l_current_route;

        if l_mode = 'CREATOR' then
            update df_document set current_status = 'RETURNED', current_route_id = null,
                   current_assignee_emp_id = l_creator where document_id = p_document_id;
            pkg_df_history.log_action(p_document_id, 'RETURNED', p_emp_id, l_creator,
                p_route_id => l_current_route, p_task_id => l_task_id,
                p_from_status => 'IN_PROCESS', p_to_status => 'RETURNED',
                p_comments => p_comments);
            return;
        elsif l_mode = 'PREVIOUS' then
            select route_id, step_no, assigned_emp_id
              into l_target_route, l_target_step, l_target_emp
              from (select route_id, step_no, assigned_emp_id from df_document_route
                     where document_id = p_document_id and step_no < l_current_step
                     order by step_no desc) where rownum = 1;
        elsif l_mode = 'SPECIFIC' then
            select route_id, step_no, assigned_emp_id
              into l_target_route, l_target_step, l_target_emp
              from df_document_route
             where document_id = p_document_id and route_id = p_return_route_id
               and step_no < l_current_step;
        else
            raise_application_error(-20042, 'Return mode must be PREVIOUS, CREATOR, or SPECIFIC.');
        end if;

        update df_document_route set status = 'WAITING', started_at = null, completed_at = null
         where document_id = p_document_id and step_no >= l_target_step;
        activate_route(p_document_id, l_target_route, p_emp_id, 'RETURNED');
        pkg_df_history.log_action(p_document_id, 'RETURNED', p_emp_id, l_target_emp,
            p_route_id => l_current_route, p_task_id => l_task_id,
            p_from_status => 'IN_PROCESS', p_to_status => 'RETURNED',
            p_comments => p_comments);
    exception when no_data_found then
        raise_application_error(-20043, 'No valid pending task or earlier return target was found.');
    end return_document;

    procedure resubmit_document(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2) is
        l_creator varchar2(30);
        l_status varchar2(20);
        l_current_route number;
        l_first_route number;
        l_first_emp varchar2(30);
    begin
        if trim(p_comments) is null then
            raise_application_error(-20044, 'Resubmission change reason is required.');
        end if;
        select creator_emp_id, current_status, current_route_id
          into l_creator, l_status, l_current_route
          from df_document where document_id = p_document_id for update;
        if upper(l_creator) <> upper(trim(p_emp_id)) or l_status <> 'RETURNED'
           or l_current_route is not null then
            raise_application_error(-20045, 'Only the creator may resubmit a document returned to the creator.');
        end if;

        update df_document set version_no = version_no + 1 where document_id = p_document_id;
        pkg_df_document.create_version(p_document_id, p_emp_id, p_comments);
        update df_document_route set status = 'WAITING', started_at = null, completed_at = null
         where document_id = p_document_id;
        select route_id, assigned_emp_id into l_first_route, l_first_emp
          from (select route_id, assigned_emp_id from df_document_route
                 where document_id = p_document_id order by step_no) where rownum = 1;
        activate_route(p_document_id, l_first_route, p_emp_id);
        pkg_df_history.log_action(p_document_id, 'RESUBMITTED', p_emp_id, l_first_emp,
            p_route_id => l_first_route, p_from_status => 'RETURNED',
            p_to_status => 'IN_PROCESS', p_comments => p_comments);
    exception when no_data_found then
        raise_application_error(-20046, 'Document or route not found for resubmission.');
    end resubmit_document;

    procedure reject_document(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2) is
        l_task_id number;
        l_route_id number;
        l_can_reject varchar2(1);
    begin
        if trim(p_comments) is null then
            raise_application_error(-20047, 'Rejection reason is required.');
        end if;
        select t.task_id, t.route_id, r.can_reject_yn
          into l_task_id, l_route_id, l_can_reject
          from df_task t join df_document_route r on r.route_id = t.route_id
         where t.document_id = p_document_id and t.task_type = 'WORKFLOW'
           and t.status = 'PENDING'
           and upper(t.assigned_to_emp_id) = upper(trim(p_emp_id))
         for update of t.status;
        if l_can_reject <> 'Y' then
            raise_application_error(-20048, 'Reject is not allowed at this route step.');
        end if;
        update df_task set status = 'COMPLETED', completed_at = systimestamp,
               completion_comments = p_comments where task_id = l_task_id;
        update df_task set status = 'CANCELLED', completed_at = systimestamp
         where document_id = p_document_id and status in ('PENDING','WAITING_REVIEW');
        update df_document_route set status = 'CANCELLED'
         where document_id = p_document_id and status in ('WAITING','ACTIVE','RETURNED');
        update df_document set current_status = 'REJECTED', current_route_id = null,
               current_assignee_emp_id = null, closed_at = systimestamp
         where document_id = p_document_id;
        pkg_df_history.log_action(p_document_id, 'REJECTED', p_emp_id,
            p_route_id => l_route_id, p_task_id => l_task_id,
            p_from_status => 'IN_PROCESS', p_to_status => 'REJECTED',
            p_comments => p_comments);
    exception when no_data_found then
        raise_application_error(-20049, 'No pending task belongs to this employee.');
    end reject_document;

    procedure cancel_document(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_comments    in varchar2) is
        l_creator varchar2(30);
        l_status varchar2(20);
    begin
        if trim(p_comments) is null then
            raise_application_error(-20050, 'Cancellation reason is required.');
        end if;
        select creator_emp_id, current_status into l_creator, l_status
          from df_document where document_id = p_document_id for update;
        if upper(l_creator) <> upper(trim(p_emp_id)) or l_status not in ('DRAFT','RETURNED') then
            raise_application_error(-20051, 'Only the creator may cancel a DRAFT or RETURNED document.');
        end if;
        update df_task set status = 'CANCELLED', completed_at = systimestamp
         where document_id = p_document_id and status in ('PENDING','WAITING_REVIEW');
        update df_document_route set status = 'CANCELLED'
         where document_id = p_document_id and status in ('WAITING','ACTIVE','RETURNED');
        update df_document set current_status = 'CANCELLED', current_route_id = null,
               current_assignee_emp_id = null, closed_at = systimestamp
         where document_id = p_document_id;
        pkg_df_history.log_action(p_document_id, 'CANCELLED', p_emp_id,
            p_from_status => l_status, p_to_status => 'CANCELLED', p_comments => p_comments);
    exception when no_data_found then
        raise_application_error(-20052, 'Document not found: ' || p_document_id);
    end cancel_document;
end pkg_df_workflow;
/
