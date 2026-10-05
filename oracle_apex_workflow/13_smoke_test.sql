-- Run after installation and configuration. All test transaction data is rolled
-- back; sequence gaps are expected and harmless.

set serveroutput on
set define off
savepoint df_smoke_start;

declare
    l_document_id number;
    l_item_id number;
    l_status varchar2(20);
    l_emp varchar2(30);
    l_action varchar2(20);
    l_review_done boolean := false;
    l_distribution_id number;

    procedure add_employee(p_id number, p_emp_id varchar2, p_name varchar2) is
    begin
        insert into employees(
            id, emp_id, f_name, l_name, dept_id, loc_id, branch_id, com_id, status)
        values(p_id, p_emp_id, p_name, 'WORKFLOW TEST', 9004, 9003, 9002, 9001, 1);
    end;

    procedure assign_role(p_role_code varchar2, p_emp varchar2,
                          p_department_id number default null) is
    begin
        insert into df_role_assignment(
            role_id, emp_id, company_id, company_code, unit_id, unit_code,
            location_id, location_code, department_id, department_code, priority_no)
        select role_id, p_emp, 9001, 'UT', 9002, 'UT-UNIT', 9003, 'UT-LOC',
               p_department_id, case when p_department_id is not null then 'UT-DEPT' end, 1
          from df_role where role_code = p_role_code;
    end;
begin
    add_employee(-90001, 'TEST-CREATOR', 'CREATOR');
    add_employee(-90002, 'TEST-DEPT', 'DEPARTMENT HEAD');
    add_employee(-90003, 'TEST-PURCHASE', 'PURCHASE HEAD');
    add_employee(-90004, 'TEST-ACCOUNTS', 'ACCOUNTS HEAD');
    add_employee(-90005, 'TEST-CFO', 'CFO');
    add_employee(-90006, 'TEST-ED', 'EXECUTIVE DIRECTOR');
    add_employee(-90007, 'TEST-MD', 'MANAGING DIRECTOR');
    add_employee(-90008, 'TEST-EXPERT', 'ITEM EXPERT');
    add_employee(-90009, 'TEST-REVIEWER', 'REVIEWER');
    add_employee(-90010, 'TEST-RECIPIENT', 'RECIPIENT');

    assign_role('DEPT_HEAD', 'TEST-DEPT', 9004);
    assign_role('PURCHASE_HEAD', 'TEST-PURCHASE');
    assign_role('ACCOUNTS_HEAD', 'TEST-ACCOUNTS');
    assign_role('CFO', 'TEST-CFO');
    assign_role('CONCERNED_ED', 'TEST-ED', 9004);
    assign_role('MANAGING_DIRECTOR', 'TEST-MD');

    insert into df_item(
        item_code, item_name, department_id, department_code,
        company_id, company_code, unit_id, unit_code)
    values('UT-SMOKE-ITEM-' || df_item_seq.nextval, 'Smoke Test Item',
        9004, 'UT-DEPT', 9001, 'UT', 9002, 'UT-UNIT')
    returning item_id into l_item_id;
    insert into df_item_expert(
        item_id, emp_id, company_id, company_code, unit_id, unit_code,
        location_id, location_code, primary_yn, priority_no)
    values(l_item_id, 'TEST-EXPERT', 9001, 'UT', 9002, 'UT-UNIT',
        9003, 'UT-LOC', 'Y', 1);

    pkg_df_document.create_document(
        p_type_id => 7, p_subject => 'Workflow smoke test',
        p_body_clob => to_clob('This document is rolled back.'),
        p_creator_emp_id => 'TEST-CREATOR', p_department_id => 9004,
        p_unit_id => 9002, p_company_id => 9001, p_location_id => 9003,
        p_department_code => 'UT-DEPT', p_unit_code => 'UT-UNIT',
        p_company_code => 'UT', p_location_code => 'UT-LOC',
        p_total_amount => 75000, p_document_id => l_document_id);
    pkg_df_document.save_purchase(l_document_id, 'TEST-CREATOR', l_item_id,
        'CAPEX', 75000, 'BDT', 'Smoke test', trunc(sysdate) + 7);
    pkg_df_document.add_purchase_item(l_document_id, 'TEST-CREATOR', l_item_id,
        'Smoke line', 1, 75000);
    pkg_df_workflow.submit_document(l_document_id, 'TEST-CREATOR', 'Submit test');

    loop
        select current_status into l_status from df_document where document_id = l_document_id;
        exit when l_status = 'APPROVED';
        select t.assigned_to_emp_id, r.action_required
          into l_emp, l_action
          from df_task t join df_document_route r on r.route_id = t.route_id
         where t.document_id = l_document_id and t.task_type = 'WORKFLOW'
           and t.status = 'PENDING';

        if l_emp = 'TEST-CFO' and not l_review_done then
            pkg_df_review.request_review(l_document_id, l_emp, 'TEST-REVIEWER',
                'Check the technical specification');
            pkg_df_review.complete_review(l_document_id, 'TEST-REVIEWER', 'Specification is acceptable');
            l_review_done := true;
        end if;

        if l_action = 'FORWARD' then
            pkg_df_workflow.forward_document(l_document_id, l_emp, 'Forwarded by smoke test');
        elsif l_action = 'RECOMMEND' then
            pkg_df_workflow.recommend_document(l_document_id, l_emp, 'Recommended by smoke test');
        elsif l_action = 'APPROVE' then
            pkg_df_workflow.approve_document(l_document_id, l_emp, 'Approved by smoke test');
        end if;
    end loop;

    pkg_df_distribution.send_document(
        p_document_id => l_document_id,
        p_sent_by_emp_id => 'TEST-CREATOR',
        p_recipient_type => 'EMPLOYEE',
        p_recipient_emp_id => 'TEST-RECIPIENT',
        p_message => 'Smoke distribution');
    select max(distribution_id) into l_distribution_id from df_distribution
     where document_id = l_document_id and recipient_emp_id = 'TEST-RECIPIENT';
    pkg_df_distribution.mark_viewed(l_distribution_id, 'TEST-RECIPIENT');
    pkg_df_distribution.acknowledge_document(l_distribution_id, 'TEST-RECIPIENT');

    select current_status into l_status from df_document where document_id = l_document_id;
    if l_status <> 'APPROVED' or not l_review_done then
        raise_application_error(-20800, 'Smoke test did not reach the expected state.');
    end if;
    dbms_output.put_line('PASS: cumulative approval, one-level review and internal distribution.');
end;
/

rollback to df_smoke_start;
prompt Smoke-test rows rolled back.
