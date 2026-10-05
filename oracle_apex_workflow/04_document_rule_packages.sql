create or replace package pkg_df_document authid definer as
    procedure create_document(
        p_type_id               in number,
        p_subject               in varchar2,
        p_body_clob             in clob,
        p_creator_emp_id        in varchar2,
        p_department_id         in number default null,
        p_unit_id               in number default null,
        p_company_id            in number default null,
        p_location_id           in number default null,
        p_department_code       in varchar2 default null,
        p_unit_code             in varchar2 default null,
        p_company_code          in varchar2 default null,
        p_location_code         in varchar2 default null,
        p_document_date         in date default trunc(sysdate),
        p_priority_code         in varchar2 default 'NORMAL',
        p_confidentiality_level in varchar2 default 'NORMAL',
        p_total_amount          in number default null,
        p_currency_code         in varchar2 default 'BDT',
        p_document_id           out number);

    procedure update_draft(
        p_document_id   in number,
        p_emp_id        in varchar2,
        p_subject       in varchar2,
        p_body_clob     in clob,
        p_total_amount  in number,
        p_lock_version  in number);

    procedure save_purchase(
        p_document_id    in number,
        p_emp_id         in varchar2,
        p_primary_item_id in number,
        p_purchase_type  in varchar2,
        p_total_amount   in number,
        p_currency_code  in varchar2 default 'BDT',
        p_purpose        in varchar2 default null,
        p_required_date  in date default null);

    procedure add_purchase_item(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_item_id     in number,
        p_description in varchar2,
        p_qty         in number,
        p_unit_price  in number);

    procedure create_version(
        p_document_id  in number,
        p_created_by   in varchar2,
        p_change_reason in varchar2 default null);

    function generate_document_no(p_type_id in number) return varchar2;
end pkg_df_document;
/

create or replace package body pkg_df_document as
    procedure assert_editable(p_document_id number, p_emp_id varchar2) is
        l_creator df_document.creator_emp_id%type;
        l_status  df_document.current_status%type;
    begin
        select creator_emp_id, current_status
          into l_creator, l_status
          from df_document
         where document_id = p_document_id
         for update;
        if upper(l_creator) <> upper(trim(p_emp_id)) then
            raise_application_error(-20010, 'Only the document creator may edit this document.');
        end if;
        if l_status not in ('DRAFT','RETURNED') then
            raise_application_error(-20011, 'Only DRAFT or RETURNED documents may be edited.');
        end if;
    exception when no_data_found then
        raise_application_error(-20012, 'Document not found: ' || p_document_id);
    end;

    procedure create_document(
        p_type_id               in number,
        p_subject               in varchar2,
        p_body_clob             in clob,
        p_creator_emp_id        in varchar2,
        p_department_id         in number default null,
        p_unit_id               in number default null,
        p_company_id            in number default null,
        p_location_id           in number default null,
        p_department_code       in varchar2 default null,
        p_unit_code             in varchar2 default null,
        p_company_code          in varchar2 default null,
        p_location_code         in varchar2 default null,
        p_document_date         in date default trunc(sysdate),
        p_priority_code         in varchar2 default 'NORMAL',
        p_confidentiality_level in varchar2 default 'NORMAL',
        p_total_amount          in number default null,
        p_currency_code         in varchar2 default 'BDT',
        p_document_id           out number) is
        l_active number;
        l_emp_department_id employees.dept_id%type;
        l_emp_unit_id employees.branch_id%type;
        l_emp_company_id employees.com_id%type;
        l_emp_location_id employees.loc_id%type;
    begin
        if trim(p_subject) is null or trim(p_creator_emp_id) is null then
            raise_application_error(-20013, 'Subject and creator employee are required.');
        end if;
        begin
            select e.dept_id, e.branch_id, e.com_id, e.loc_id
              into l_emp_department_id, l_emp_unit_id, l_emp_company_id, l_emp_location_id
              from employees e
             where upper(e.emp_id) = upper(trim(p_creator_emp_id))
               and nvl(e.status, 0) = 1;
        exception when no_data_found then
            raise_application_error(-20009, 'Creator employee is missing or inactive: ' || p_creator_emp_id);
        when too_many_rows then
            raise_application_error(-20008, 'Duplicate active EMPLOYEES.EMP_ID: ' || p_creator_emp_id);
        end;
        select count(*) into l_active from df_document_type
         where type_id = p_type_id and active_yn = 'Y';
        if l_active = 0 then
            raise_application_error(-20014, 'Document type is missing or inactive.');
        end if;

        insert into df_document(
            type_id, subject, body_clob, creator_emp_id,
            department_id, department_code, unit_id, unit_code,
            company_id, company_code, location_id, location_code,
            document_date, priority_code,
            confidentiality_level, total_amount, currency_code)
        values (
            p_type_id, trim(p_subject), p_body_clob, upper(trim(p_creator_emp_id)),
            nvl(p_department_id,l_emp_department_id), p_department_code,
            nvl(p_unit_id,l_emp_unit_id), p_unit_code,
            nvl(p_company_id,l_emp_company_id), p_company_code,
            nvl(p_location_id,l_emp_location_id), p_location_code,
            nvl(p_document_date, trunc(sysdate)), upper(trim(p_priority_code)),
            upper(trim(p_confidentiality_level)), p_total_amount, upper(trim(p_currency_code)))
        returning document_id into p_document_id;

        pkg_df_history.log_action(p_document_id, 'CREATED', p_creator_emp_id,
            p_to_status => 'DRAFT');
    end create_document;

    procedure update_draft(
        p_document_id   in number,
        p_emp_id        in varchar2,
        p_subject       in varchar2,
        p_body_clob     in clob,
        p_total_amount  in number,
        p_lock_version  in number) is
    begin
        assert_editable(p_document_id, p_emp_id);
        update df_document
           set subject = trim(p_subject), body_clob = p_body_clob,
               total_amount = p_total_amount
         where document_id = p_document_id
           and lock_version = p_lock_version;
        if sql%rowcount = 0 then
            raise_application_error(-20015, 'Document was changed by another user. Reload and retry.');
        end if;
        pkg_df_history.log_action(p_document_id, 'UPDATED', p_emp_id,
            p_from_status => 'DRAFT', p_to_status => 'DRAFT');
    end update_draft;

    procedure save_purchase(
        p_document_id     in number,
        p_emp_id          in varchar2,
        p_primary_item_id in number,
        p_purchase_type   in varchar2,
        p_total_amount    in number,
        p_currency_code   in varchar2 default 'BDT',
        p_purpose         in varchar2 default null,
        p_required_date   in date default null) is
        l_purchase_yn varchar2(1);
    begin
        assert_editable(p_document_id, p_emp_id);
        select dt.is_purchase_yn into l_purchase_yn
          from df_document d join df_document_type dt on dt.type_id = d.type_id
         where d.document_id = p_document_id;
        if l_purchase_yn <> 'Y' then
            raise_application_error(-20016, 'Purchase details are allowed only for purchase document types.');
        end if;
        if p_primary_item_id is null or p_total_amount is null or p_total_amount < 0 then
            raise_application_error(-20017, 'Primary item and non-negative amount are required.');
        end if;

        merge into df_purchase p
        using (select p_document_id document_id from dual) s
           on (p.document_id = s.document_id)
        when matched then update set
            p.primary_item_id = p_primary_item_id,
            p.purchase_type = p_purchase_type,
            p.total_amount = p_total_amount,
            p.currency_code = upper(trim(p_currency_code)),
            p.purpose = p_purpose,
            p.required_date = p_required_date
        when not matched then insert (
            document_id, primary_item_id, purchase_type, total_amount,
            currency_code, purpose, required_date)
        values (p_document_id, p_primary_item_id, p_purchase_type, p_total_amount,
            upper(trim(p_currency_code)), p_purpose, p_required_date);

        update df_document set total_amount = p_total_amount,
            currency_code = upper(trim(p_currency_code))
         where document_id = p_document_id;
    end save_purchase;

    procedure add_purchase_item(
        p_document_id in number,
        p_emp_id      in varchar2,
        p_item_id     in number,
        p_description in varchar2,
        p_qty         in number,
        p_unit_price  in number) is
    begin
        assert_editable(p_document_id, p_emp_id);
        insert into df_purchase_item(document_id, item_id, description, qty, unit_price)
        values (p_document_id, p_item_id, p_description, p_qty, p_unit_price);
    end add_purchase_item;

    procedure create_version(
        p_document_id  in number,
        p_created_by   in varchar2,
        p_change_reason in varchar2 default null) is
    begin
        insert into df_document_version(
            document_id, version_no, subject, body_clob, total_amount,
            change_reason, created_by)
        select document_id, version_no, subject, body_clob, total_amount,
               p_change_reason, p_created_by
          from df_document
         where document_id = p_document_id;
    exception when dup_val_on_index then
        raise_application_error(-20018, 'This document version already has a snapshot.');
    end create_version;

    function generate_document_no(p_type_id in number) return varchar2 is
        l_prefix       df_number_format.prefix%type;
        l_reset_type   df_number_format.reset_type%type;
        l_mask         df_number_format.format_mask%type;
        l_width        df_number_format.sequence_width%type;
        l_last_period  df_number_format.last_period%type;
        l_period       varchar2(12);
        l_next         number;
        l_result       varchar2(200);
    begin
        select prefix, reset_type, format_mask, sequence_width, last_period, last_number
          into l_prefix, l_reset_type, l_mask, l_width, l_last_period, l_next
          from df_number_format
         where type_id = p_type_id and active_yn = 'Y'
         for update;

        l_period := case l_reset_type
            when 'MONTHLY' then to_char(sysdate, 'YYYYMM')
            when 'YEARLY' then to_char(sysdate, 'YYYY')
            else 'ALL' end;
        if l_last_period is null or l_last_period <> l_period then
            l_next := 1;
        else
            l_next := l_next + 1;
        end if;

        update df_number_format
           set last_period = l_period, last_number = l_next
         where type_id = p_type_id;

        l_result := replace(l_mask, '{PREFIX}', l_prefix);
        l_result := replace(l_result, '{YYYYMM}', to_char(sysdate, 'YYYYMM'));
        l_result := replace(l_result, '{YYYY}', to_char(sysdate, 'YYYY'));
        l_result := replace(l_result, '{SEQ}', lpad(l_next, l_width, '0'));
        return l_result;
    exception when no_data_found then
        raise_application_error(-20019, 'No active number format for document type ' || p_type_id || '.');
    end generate_document_no;
end pkg_df_document;
/

create or replace package pkg_df_rule authid definer as
    function find_workflow(p_document_id in number) return number;
    function find_approval_rule(p_document_id in number, p_workflow_id in number) return number;
    function step_applies(p_step_id in number, p_document_id in number) return varchar2;
    procedure build_route(p_document_id in number, p_workflow_id in number);
end pkg_df_rule;
/

create or replace package body pkg_df_rule as
    function find_workflow(p_document_id in number) return number is
        l_workflow_id number;
    begin
        select workflow_id into l_workflow_id
          from (
                select w.workflow_id,
                       (case when w.company_id is not null then 1 else 0 end +
                        case when w.unit_id is not null then 1 else 0 end +
                        case when w.location_id is not null then 1 else 0 end +
                        case when w.department_id is not null then 1 else 0 end) specificity,
                       w.priority_no, w.version_no
                  from df_workflow w
                  join df_document d on d.document_id = p_document_id
                 where w.type_id = d.type_id and w.active_yn = 'Y'
                   and trunc(sysdate) between w.effective_from and nvl(w.effective_to, date '2999-12-31')
                   and (w.company_id is null or w.company_id = d.company_id)
                   and (w.unit_id is null or w.unit_id = d.unit_id)
                   and (w.location_id is null or w.location_id = d.location_id)
                   and (w.department_id is null or w.department_id = d.department_id)
                 order by specificity desc, w.priority_no, w.version_no desc, w.workflow_id
               ) where rownum = 1;
        return l_workflow_id;
    exception when no_data_found then
        raise_application_error(-20020, 'No active workflow matches document ' || p_document_id || '.');
    end find_workflow;

    function find_approval_rule(p_document_id in number, p_workflow_id in number) return number is
        l_rule_id number;
    begin
        select rule_id into l_rule_id
          from (
                select r.rule_id,
                       (case when r.item_id is not null then 16 else 0 end +
                        case when r.item_category_id is not null then 8 else 0 end +
                        case when r.company_id is not null then 4 else 0 end +
                        case when r.location_id is not null then 2 else 0 end +
                        case when r.unit_id is not null then 1 else 0 end) specificity,
                       r.priority_no
                  from df_approval_rule r
                  join df_document d on d.document_id = p_document_id
                  left join df_purchase p on p.document_id = d.document_id
                  left join df_item i on i.item_id = p.primary_item_id
                 where r.workflow_id = p_workflow_id and r.active_yn = 'Y'
                   and trunc(sysdate) between r.effective_from and nvl(r.effective_to, date '2999-12-31')
                   and nvl(d.total_amount,0) between r.min_amount and nvl(r.max_amount, 1e125)
                   and (r.company_id is null or r.company_id = d.company_id)
                   and (r.unit_id is null or r.unit_id = d.unit_id)
                   and (r.location_id is null or r.location_id = d.location_id)
                   and (r.item_id is null or r.item_id = p.primary_item_id)
                   and (r.item_category_id is null or r.item_category_id = i.category_id)
                 order by specificity desc, r.priority_no, r.rule_id
               ) where rownum = 1;
        return l_rule_id;
    exception when no_data_found then
        return null;
    end find_approval_rule;

    function step_applies(p_step_id in number, p_document_id in number) return varchar2 is
        l_actual varchar2(4000);
        l_num_actual number;
        l_match boolean;
    begin
        for c in (select * from df_workflow_condition
                   where step_id = p_step_id and active_yn = 'Y'
                   order by condition_no) loop
            select case c.field_name
                     when 'TYPE_ID' then to_char(d.type_id)
                     when 'COMPANY_ID' then to_char(d.company_id)
                     when 'UNIT_ID' then to_char(d.unit_id)
                     when 'LOCATION_ID' then to_char(d.location_id)
                     when 'DEPARTMENT_ID' then to_char(d.department_id)
                     when 'COMPANY_CODE' then d.company_code
                     when 'UNIT_CODE' then d.unit_code
                     when 'LOCATION_CODE' then d.location_code
                     when 'DEPARTMENT_CODE' then d.department_code
                     when 'TOTAL_AMOUNT' then to_char(nvl(d.total_amount,0),'TM9','NLS_NUMERIC_CHARACTERS=''.,''')
                     when 'ITEM_ID' then to_char(p.primary_item_id)
                   end
              into l_actual
              from df_document d left join df_purchase p on p.document_id = d.document_id
             where d.document_id = p_document_id;

            l_match := false;
            if c.field_name in ('TYPE_ID','COMPANY_ID','UNIT_ID','LOCATION_ID',
                                'DEPARTMENT_ID','TOTAL_AMOUNT','ITEM_ID')
               and c.operator_code <> 'IN' then
                l_num_actual := to_number(nvl(l_actual,'0'));
                if c.operator_code = '=' then l_match := l_num_actual = to_number(c.value1);
                elsif c.operator_code = '<>' then l_match := l_num_actual <> to_number(c.value1);
                elsif c.operator_code = '>' then l_match := l_num_actual > to_number(c.value1);
                elsif c.operator_code = '>=' then l_match := l_num_actual >= to_number(c.value1);
                elsif c.operator_code = '<' then l_match := l_num_actual < to_number(c.value1);
                elsif c.operator_code = '<=' then l_match := l_num_actual <= to_number(c.value1);
                elsif c.operator_code = 'BETWEEN' then
                    l_match := l_num_actual between to_number(c.value1) and to_number(c.value2);
                end if;
            elsif c.operator_code = 'IN' then
                l_match := instr(',' || upper(replace(c.value1,' ','')) || ',',
                                 ',' || upper(replace(nvl(l_actual,''),' ','')) || ',') > 0;
            else
                if c.operator_code = '=' then
                    l_match := upper(nvl(l_actual,chr(0))) = upper(nvl(c.value1,chr(0)));
                elsif c.operator_code = '<>' then
                    l_match := upper(nvl(l_actual,chr(0))) <> upper(nvl(c.value1,chr(0)));
                end if;
            end if;
            if not l_match then return 'N'; end if;
        end loop;
        return 'Y';
    end step_applies;

    procedure insert_route(
        p_document_id number, p_step_no number, p_source_type varchar2,
        p_source_id number, p_step_name varchar2, p_step_type varchar2,
        p_action_required varchar2, p_actor_type varchar2, p_actor_id varchar2,
        p_can_review varchar2, p_can_return varchar2, p_can_reject varchar2) is
        l_emp_id varchar2(30);
        l_role_id number;
        l_delegated_from varchar2(30);
        l_creator varchar2(30);
        l_exists number;
    begin
        l_emp_id := pkg_df_actor.resolve_actor(p_actor_type, p_actor_id,
            p_document_id, l_role_id, l_delegated_from);
        select creator_emp_id into l_creator from df_document where document_id = p_document_id;

        -- Preserve legacy behavior: creator cannot approve their own document.
        if upper(l_emp_id) = upper(l_creator) then return; end if;
        select count(*) into l_exists from df_document_route
         where document_id = p_document_id and upper(assigned_emp_id) = upper(l_emp_id);
        if l_exists > 0 then return; end if;

        insert into df_document_route(
            document_id, step_no, source_type, source_id, step_name, step_type,
            action_required, assigned_emp_id, assigned_role_id, delegated_from_emp_id,
            can_review_yn, can_return_yn, can_reject_yn)
        values (p_document_id, p_step_no, p_source_type, p_source_id, p_step_name,
            p_step_type, p_action_required, l_emp_id, l_role_id, l_delegated_from,
            p_can_review, p_can_return, p_can_reject);
    end insert_route;

    procedure build_route(p_document_id in number, p_workflow_id in number) is
        l_count number;
        l_rule_id number;
        l_amount number;
    begin
        select count(*) into l_count from df_document_route where document_id = p_document_id;
        if l_count > 0 then
            raise_application_error(-20021, 'Route snapshot already exists for document ' || p_document_id || '.');
        end if;
        select nvl(total_amount,0) into l_amount from df_document where document_id = p_document_id;

        for s in (select * from df_workflow_step
                   where workflow_id = p_workflow_id and active_yn = 'Y'
                   order by step_no) loop
            if step_applies(s.step_id, p_document_id) = 'Y' then
                insert_route(p_document_id, s.step_no, 'WORKFLOW_STEP', s.step_id,
                    s.step_name, s.step_type, s.action_required, s.actor_type, s.actor_id,
                    s.can_review_yn, s.can_return_yn, s.can_reject_yn);
            end if;
        end loop;

        l_rule_id := find_approval_rule(p_document_id, p_workflow_id);
        if l_rule_id is not null then
            for s in (select * from df_approval_rule_step
                       where rule_id = l_rule_id and active_yn = 'Y'
                       order by step_no) loop
                insert_route(p_document_id, s.step_no, 'APPROVAL_RULE', s.rule_step_id,
                    s.step_name, 'APPROVAL', s.action_required, s.actor_type, s.actor_id,
                    s.can_review_yn, s.can_return_yn, s.can_reject_yn);
                exit when s.approval_limit is null or l_amount <= s.approval_limit;
            end loop;
        end if;

        select count(*) into l_count from df_document_route where document_id = p_document_id;
        if l_count = 0 then
            raise_application_error(-20022, 'Workflow resolved to an empty route. Check actors and conditions.');
        end if;

        update df_document_route
           set is_final_yn = 'Y', step_type = 'FINAL_APPROVAL', action_required = 'APPROVE'
         where route_id = (select route_id from (
                select route_id from df_document_route
                 where document_id = p_document_id order by step_no desc) where rownum = 1);
    end build_route;
end pkg_df_rule;
/
