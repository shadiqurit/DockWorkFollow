-- Normalized Document Approval Workflow schema for Oracle 19c / APEX.
-- Design choices: cumulative approval, one-level review, no external recipient.

create sequence df_role_seq start with 1000 nocache;
create sequence df_document_type_seq start with 1000 nocache;
create sequence df_app_user_seq start with 1000 nocache;
create sequence df_role_assignment_seq start with 1000 nocache;
create sequence df_delegation_seq start with 1000 nocache;
create sequence df_item_seq start with 1000 nocache;
create sequence df_item_expert_seq start with 1000 nocache;
create sequence df_workflow_seq start with 1000 nocache;
create sequence df_workflow_step_seq start with 1000 nocache;
create sequence df_workflow_condition_seq start with 1000 nocache;
create sequence df_approval_rule_seq start with 1000 nocache;
create sequence df_approval_rule_step_seq start with 1000 nocache;
create sequence df_number_format_seq start with 1000 nocache;
create sequence df_document_seq start with 1000 nocache;
create sequence df_purchase_seq start with 1000 nocache;
create sequence df_purchase_item_seq start with 1000 nocache;
create sequence df_document_version_seq start with 1000 nocache;
create sequence df_attachment_seq start with 1000 nocache;
create sequence df_route_seq start with 1000 nocache;
create sequence df_task_seq start with 1000 nocache;
create sequence df_action_history_seq start with 1000 nocache;
create sequence df_distribution_seq start with 1000 nocache;

create table df_role (
    role_id       number default df_role_seq.nextval not null,
    role_code     varchar2(40) not null,
    role_name     varchar2(120) not null,
    active_yn     varchar2(1) default 'Y' not null,
    created_by    varchar2(255) default user not null,
    created_at    timestamp with local time zone default systimestamp not null,
    constraint df_role_pk primary key (role_id),
    constraint df_role_u1 unique (role_code),
    constraint df_role_active_ck check (active_yn in ('Y','N'))
);

create table df_document_type (
    type_id                number default df_document_type_seq.nextval not null,
    type_code              varchar2(20) not null,
    type_name              varchar2(120) not null,
    description            varchar2(1000),
    is_purchase_yn         varchar2(1) default 'N' not null,
    allow_review_yn        varchar2(1) default 'Y' not null,
    allow_return_yn        varchar2(1) default 'Y' not null,
    allow_distribution_yn  varchar2(1) default 'Y' not null,
    number_prefix          varchar2(20) not null,
    active_yn              varchar2(1) default 'Y' not null,
    created_by             varchar2(255) default user not null,
    created_at             timestamp with local time zone default systimestamp not null,
    constraint df_document_type_pk primary key (type_id),
    constraint df_document_type_u1 unique (type_code),
    constraint df_document_type_flags_ck check (
        is_purchase_yn in ('Y','N') and allow_review_yn in ('Y','N') and
        allow_return_yn in ('Y','N') and allow_distribution_yn in ('Y','N') and
        active_yn in ('Y','N'))
);

create table df_app_user (
    app_user_id   number default df_app_user_seq.nextval not null,
    app_username  varchar2(255) not null,
    emp_id        varchar2(30) not null,
    active_yn     varchar2(1) default 'Y' not null,
    created_at    timestamp with local time zone default systimestamp not null,
    constraint df_app_user_pk primary key (app_user_id),
    constraint df_app_user_u1 unique (app_username),
    constraint df_app_user_u2 unique (emp_id),
    constraint df_app_user_active_ck check (active_yn in ('Y','N'))
);

create table df_role_assignment (
    assignment_id  number default df_role_assignment_seq.nextval not null,
    role_id        number not null,
    emp_id         varchar2(30) not null,
    company_id     number,
    company_code   varchar2(30),
    unit_id        number,
    unit_code      varchar2(30),
    location_id    number,
    location_code  varchar2(30),
    department_id  number,
    department_code varchar2(200),
    priority_no    number default 100 not null,
    effective_from date default trunc(sysdate) not null,
    effective_to   date,
    active_yn      varchar2(1) default 'Y' not null,
    created_by     varchar2(255) default user not null,
    created_at     timestamp with local time zone default systimestamp not null,
    constraint df_role_assignment_pk primary key (assignment_id),
    constraint df_role_assignment_fk1 foreign key (role_id) references df_role(role_id),
    constraint df_role_assignment_dates_ck check (effective_to is null or effective_to >= effective_from),
    constraint df_role_assignment_active_ck check (active_yn in ('Y','N'))
);

create table df_delegation (
    delegation_id number default df_delegation_seq.nextval not null,
    from_emp_id   varchar2(30) not null,
    to_emp_id     varchar2(30) not null,
    role_id       number,
    start_date    date not null,
    end_date      date not null,
    active_yn     varchar2(1) default 'Y' not null,
    reason        varchar2(1000),
    created_by    varchar2(255) default user not null,
    created_at    timestamp with local time zone default systimestamp not null,
    constraint df_delegation_pk primary key (delegation_id),
    constraint df_delegation_fk1 foreign key (role_id) references df_role(role_id),
    constraint df_delegation_dates_ck check (end_date >= start_date),
    constraint df_delegation_self_ck check (from_emp_id <> to_emp_id),
    constraint df_delegation_active_ck check (active_yn in ('Y','N'))
);

create table df_item (
    item_id        number default df_item_seq.nextval not null,
    item_code      varchar2(60) not null,
    item_name      varchar2(200) not null,
    category_id    number,
    category_code  varchar2(60),
    department_id  number,
    department_code varchar2(200),
    company_id     number,
    company_code   varchar2(30),
    unit_id        number,
    unit_code      varchar2(30),
    legacy_item_id number,
    active_yn      varchar2(1) default 'Y' not null,
    created_by     varchar2(255) default user not null,
    created_at     timestamp with local time zone default systimestamp not null,
    constraint df_item_pk primary key (item_id),
    constraint df_item_u1 unique (item_code),
    constraint df_item_active_ck check (active_yn in ('Y','N'))
);

create table df_item_expert (
    item_expert_id number default df_item_expert_seq.nextval not null,
    item_id        number not null,
    emp_id         varchar2(30) not null,
    company_id     number,
    company_code   varchar2(30),
    unit_id        number,
    unit_code      varchar2(30),
    location_id    number,
    location_code  varchar2(30),
    primary_yn     varchar2(1) default 'Y' not null,
    priority_no    number default 100 not null,
    effective_from date default trunc(sysdate) not null,
    effective_to   date,
    active_yn      varchar2(1) default 'Y' not null,
    created_by     varchar2(255) default user not null,
    created_at     timestamp with local time zone default systimestamp not null,
    constraint df_item_expert_pk primary key (item_expert_id),
    constraint df_item_expert_fk1 foreign key (item_id) references df_item(item_id),
    constraint df_item_expert_dates_ck check (effective_to is null or effective_to >= effective_from),
    constraint df_item_expert_flags_ck check (primary_yn in ('Y','N') and active_yn in ('Y','N'))
);

create table df_workflow (
    workflow_id    number default df_workflow_seq.nextval not null,
    workflow_code  varchar2(40) not null,
    workflow_name  varchar2(150) not null,
    type_id        number not null,
    company_id     number,
    company_code   varchar2(30),
    unit_id        number,
    unit_code      varchar2(30),
    location_id    number,
    location_code  varchar2(30),
    department_id  number,
    department_code varchar2(200),
    version_no     number default 1 not null,
    effective_from date default trunc(sysdate) not null,
    effective_to   date,
    priority_no    number default 100 not null,
    active_yn      varchar2(1) default 'Y' not null,
    created_by     varchar2(255) default user not null,
    created_at     timestamp with local time zone default systimestamp not null,
    constraint df_workflow_pk primary key (workflow_id),
    constraint df_workflow_u1 unique (workflow_code, version_no),
    constraint df_workflow_fk1 foreign key (type_id) references df_document_type(type_id),
    constraint df_workflow_dates_ck check (effective_to is null or effective_to >= effective_from),
    constraint df_workflow_active_ck check (active_yn in ('Y','N'))
);

create table df_workflow_step (
    step_id           number default df_workflow_step_seq.nextval not null,
    workflow_id       number not null,
    step_no           number not null,
    step_name         varchar2(150) not null,
    step_type         varchar2(20) not null,
    actor_type        varchar2(30) not null,
    actor_id          varchar2(60),
    action_required   varchar2(20) default 'FORWARD' not null,
    mandatory_yn      varchar2(1) default 'Y' not null,
    can_review_yn     varchar2(1) default 'Y' not null,
    can_return_yn     varchar2(1) default 'Y' not null,
    can_reject_yn     varchar2(1) default 'Y' not null,
    active_yn         varchar2(1) default 'Y' not null,
    created_by        varchar2(255) default user not null,
    created_at        timestamp with local time zone default systimestamp not null,
    constraint df_workflow_step_pk primary key (step_id),
    constraint df_workflow_step_u1 unique (workflow_id, step_no),
    constraint df_workflow_step_fk1 foreign key (workflow_id) references df_workflow(workflow_id),
    constraint df_workflow_step_type_ck check (step_type in ('REVIEW','RECOMMEND','CHECK','APPROVAL','FINAL_APPROVAL')),
    constraint df_workflow_step_actor_ck check (actor_type in ('EMPLOYEE','ROLE','DEPT_HEAD','ITEM_EXPERT','CONCERNED_ED','DOCUMENT_CREATOR')),
    constraint df_workflow_step_action_ck check (action_required in ('FORWARD','RECOMMEND','APPROVE')),
    constraint df_workflow_step_flags_ck check (mandatory_yn in ('Y','N') and can_review_yn in ('Y','N') and can_return_yn in ('Y','N') and can_reject_yn in ('Y','N') and active_yn in ('Y','N'))
);

create table df_workflow_condition (
    condition_id   number default df_workflow_condition_seq.nextval not null,
    step_id        number not null,
    condition_no   number not null,
    field_name     varchar2(30) not null,
    operator_code  varchar2(10) not null,
    value1         varchar2(4000),
    value2         varchar2(4000),
    active_yn      varchar2(1) default 'Y' not null,
    constraint df_workflow_condition_pk primary key (condition_id),
    constraint df_workflow_condition_u1 unique (step_id, condition_no),
    constraint df_workflow_condition_fk1 foreign key (step_id) references df_workflow_step(step_id),
    constraint df_workflow_condition_field_ck check (field_name in (
        'TYPE_ID','COMPANY_ID','UNIT_ID','LOCATION_ID','DEPARTMENT_ID',
        'COMPANY_CODE','UNIT_CODE','LOCATION_CODE','DEPARTMENT_CODE',
        'TOTAL_AMOUNT','ITEM_ID')),
    constraint df_workflow_condition_op_ck check (operator_code in ('=','<>','>','>=','<','<=','BETWEEN','IN')),
    constraint df_wf_condition_active_ck check (active_yn in ('Y','N'))
);

create table df_approval_rule (
    rule_id          number default df_approval_rule_seq.nextval not null,
    workflow_id      number not null,
    rule_name        varchar2(150) not null,
    approval_mode    varchar2(20) default 'CUMULATIVE' not null,
    company_id       number,
    company_code     varchar2(30),
    unit_id          number,
    unit_code        varchar2(30),
    location_id      number,
    location_code    varchar2(30),
    item_category_id number,
    item_category_code varchar2(60),
    item_id          number,
    min_amount       number default 0 not null,
    max_amount       number,
    priority_no      number default 100 not null,
    effective_from   date default trunc(sysdate) not null,
    effective_to     date,
    active_yn        varchar2(1) default 'Y' not null,
    created_by       varchar2(255) default user not null,
    created_at       timestamp with local time zone default systimestamp not null,
    constraint df_approval_rule_pk primary key (rule_id),
    constraint df_approval_rule_fk1 foreign key (workflow_id) references df_workflow(workflow_id),
    constraint df_approval_rule_fk2 foreign key (item_id) references df_item(item_id),
    constraint df_approval_rule_mode_ck check (approval_mode = 'CUMULATIVE'),
    constraint df_approval_rule_amt_ck check (min_amount >= 0 and (max_amount is null or max_amount >= min_amount)),
    constraint df_approval_rule_dates_ck check (effective_to is null or effective_to >= effective_from),
    constraint df_approval_rule_active_ck check (active_yn in ('Y','N'))
);

create table df_approval_rule_step (
    rule_step_id    number default df_approval_rule_step_seq.nextval not null,
    rule_id         number not null,
    step_no         number not null,
    step_name       varchar2(150) not null,
    actor_type      varchar2(30) not null,
    actor_id        varchar2(60),
    action_required varchar2(20) default 'APPROVE' not null,
    approval_limit  number,
    can_review_yn   varchar2(1) default 'Y' not null,
    can_return_yn   varchar2(1) default 'Y' not null,
    can_reject_yn   varchar2(1) default 'Y' not null,
    active_yn       varchar2(1) default 'Y' not null,
    constraint df_approval_rule_step_pk primary key (rule_step_id),
    constraint df_approval_rule_step_u1 unique (rule_id, step_no),
    constraint df_approval_rule_step_fk1 foreign key (rule_id) references df_approval_rule(rule_id),
    constraint df_approval_rule_step_actor_ck check (actor_type in ('EMPLOYEE','ROLE','DEPT_HEAD','ITEM_EXPERT','CONCERNED_ED','DOCUMENT_CREATOR')),
    constraint df_apr_rule_step_action_ck check (action_required in ('FORWARD','RECOMMEND','APPROVE')),
    constraint df_approval_rule_step_flags_ck check (can_review_yn in ('Y','N') and can_return_yn in ('Y','N') and can_reject_yn in ('Y','N') and active_yn in ('Y','N')),
    constraint df_approval_rule_step_limit_ck check (approval_limit is null or approval_limit >= 0)
);

create table df_number_format (
    number_format_id number default df_number_format_seq.nextval not null,
    type_id          number not null,
    prefix           varchar2(20) not null,
    reset_type       varchar2(10) default 'MONTHLY' not null,
    format_mask      varchar2(100) default '{PREFIX}-{YYYYMM}/{SEQ}' not null,
    sequence_width   number default 5 not null,
    last_period      varchar2(12),
    last_number      number default 0 not null,
    active_yn        varchar2(1) default 'Y' not null,
    constraint df_number_format_pk primary key (number_format_id),
    constraint df_number_format_u1 unique (type_id),
    constraint df_number_format_fk1 foreign key (type_id) references df_document_type(type_id),
    constraint df_number_format_reset_ck check (reset_type in ('MONTHLY','YEARLY','NEVER')),
    constraint df_number_format_width_ck check (sequence_width between 1 and 12),
    constraint df_number_format_active_ck check (active_yn in ('Y','N'))
);

create table df_document (
    document_id             number default df_document_seq.nextval not null,
    document_no             varchar2(60),
    type_id                 number not null,
    workflow_id             number,
    subject                 varchar2(500) not null,
    body_clob               clob,
    creator_emp_id          varchar2(30) not null,
    department_id           number,
    department_code         varchar2(200),
    unit_id                 number,
    unit_code               varchar2(30),
    company_id              number,
    company_code            varchar2(30),
    location_id             number,
    location_code           varchar2(30),
    document_date           date default trunc(sysdate) not null,
    priority_code           varchar2(10) default 'NORMAL' not null,
    confidentiality_level   varchar2(20) default 'NORMAL' not null,
    current_status          varchar2(20) default 'DRAFT' not null,
    current_route_id        number,
    current_assignee_emp_id varchar2(30),
    total_amount            number,
    currency_code           varchar2(3) default 'BDT',
    submitted_at            timestamp with local time zone,
    approved_at             timestamp with local time zone,
    closed_at               timestamp with local time zone,
    version_no              number default 1 not null,
    legacy_df_slno          number,
    created_by              varchar2(255) not null,
    created_at              timestamp with local time zone default systimestamp not null,
    updated_by              varchar2(255),
    updated_at              timestamp with local time zone,
    lock_version            number default 0 not null,
    constraint df_document_pk primary key (document_id),
    constraint df_document_u1 unique (document_no),
    constraint df_document_u2 unique (legacy_df_slno),
    constraint df_document_fk1 foreign key (type_id) references df_document_type(type_id),
    constraint df_document_fk2 foreign key (workflow_id) references df_workflow(workflow_id),
    constraint df_document_status_ck check (current_status in ('DRAFT','SUBMITTED','IN_PROCESS','UNDER_REVIEW','RETURNED','REJECTED','APPROVED','CLOSED','CANCELLED')),
    constraint df_document_priority_ck check (priority_code in ('LOW','NORMAL','HIGH','URGENT')),
    constraint df_document_conf_ck check (confidentiality_level in ('NORMAL','CONFIDENTIAL','RESTRICTED','MANAGEMENT_ONLY')),
    constraint df_document_amount_ck check (total_amount is null or total_amount >= 0)
);

create table df_purchase (
    purchase_id   number default df_purchase_seq.nextval not null,
    document_id   number not null,
    primary_item_id number not null,
    purchase_type varchar2(60),
    total_amount  number not null,
    currency_code varchar2(3) default 'BDT' not null,
    purpose       varchar2(2000),
    required_date date,
    constraint df_purchase_pk primary key (purchase_id),
    constraint df_purchase_u1 unique (document_id),
    constraint df_purchase_fk1 foreign key (document_id) references df_document(document_id),
    constraint df_purchase_fk2 foreign key (primary_item_id) references df_item(item_id),
    constraint df_purchase_amount_ck check (total_amount >= 0)
);

create table df_purchase_item (
    purchase_item_id number default df_purchase_item_seq.nextval not null,
    document_id      number not null,
    item_id          number not null,
    description      varchar2(1000),
    qty              number default 1 not null,
    unit_price       number default 0 not null,
    total_amount     number generated always as (qty * unit_price) virtual,
    constraint df_purchase_item_pk primary key (purchase_item_id),
    constraint df_purchase_item_fk1 foreign key (document_id) references df_document(document_id),
    constraint df_purchase_item_fk2 foreign key (item_id) references df_item(item_id),
    constraint df_purchase_item_amount_ck check (qty > 0 and unit_price >= 0)
);

create table df_document_version (
    version_id    number default df_document_version_seq.nextval not null,
    document_id   number not null,
    version_no    number not null,
    subject       varchar2(500) not null,
    body_clob     clob,
    total_amount  number,
    change_reason varchar2(2000),
    created_by    varchar2(255) not null,
    created_at    timestamp with local time zone default systimestamp not null,
    constraint df_document_version_pk primary key (version_id),
    constraint df_document_version_u1 unique (document_id, version_no),
    constraint df_document_version_fk1 foreign key (document_id) references df_document(document_id)
);

create table df_document_attachment (
    attachment_id   number default df_attachment_seq.nextval not null,
    document_id     number not null,
    version_no      number not null,
    file_name       varchar2(255) not null,
    mime_type       varchar2(255),
    file_size       number,
    file_blob       blob not null,
    attachment_type varchar2(30) default 'SUPPORTING' not null,
    uploaded_by     varchar2(255) not null,
    uploaded_at     timestamp with local time zone default systimestamp not null,
    constraint df_document_attachment_pk primary key (attachment_id),
    constraint df_document_attachment_fk1 foreign key (document_id, version_no) references df_document_version(document_id, version_no),
    constraint df_attachment_size_ck check (file_size is null or file_size >= 0)
);

create table df_document_route (
    route_id          number default df_route_seq.nextval not null,
    document_id       number not null,
    step_no           number not null,
    source_type       varchar2(20) not null,
    source_id         number,
    step_name         varchar2(150) not null,
    step_type         varchar2(20) not null,
    action_required   varchar2(20) not null,
    assigned_emp_id   varchar2(30) not null,
    assigned_role_id  number,
    delegated_from_emp_id varchar2(30),
    status            varchar2(20) default 'WAITING' not null,
    can_review_yn     varchar2(1) default 'Y' not null,
    can_return_yn     varchar2(1) default 'Y' not null,
    can_reject_yn     varchar2(1) default 'Y' not null,
    is_final_yn       varchar2(1) default 'N' not null,
    started_at        timestamp with local time zone,
    completed_at      timestamp with local time zone,
    constraint df_document_route_pk primary key (route_id),
    constraint df_document_route_u1 unique (document_id, step_no),
    constraint df_document_route_fk1 foreign key (document_id) references df_document(document_id),
    constraint df_document_route_fk2 foreign key (assigned_role_id) references df_role(role_id),
    constraint df_document_route_source_ck check (source_type in ('WORKFLOW_STEP','APPROVAL_RULE')),
    constraint df_document_route_type_ck check (step_type in ('REVIEW','RECOMMEND','CHECK','APPROVAL','FINAL_APPROVAL')),
    constraint df_document_route_action_ck check (action_required in ('FORWARD','RECOMMEND','APPROVE')),
    constraint df_document_route_status_ck check (status in ('WAITING','ACTIVE','COMPLETED','RETURNED','CANCELLED')),
    constraint df_document_route_flags_ck check (can_review_yn in ('Y','N') and can_return_yn in ('Y','N') and can_reject_yn in ('Y','N') and is_final_yn in ('Y','N'))
);

create table df_task (
    task_id             number default df_task_seq.nextval not null,
    document_id         number not null,
    route_id            number,
    task_type           varchar2(20) not null,
    assigned_to_emp_id  varchar2(30) not null,
    assigned_by_emp_id  varchar2(30),
    status              varchar2(20) default 'PENDING' not null,
    assigned_at         timestamp with local time zone default systimestamp not null,
    due_at              timestamp with local time zone,
    completed_at        timestamp with local time zone,
    parent_task_id      number,
    return_to_task_id   number,
    instruction         varchar2(2000),
    completion_comments varchar2(4000),
    constraint df_task_pk primary key (task_id),
    constraint df_task_fk1 foreign key (document_id) references df_document(document_id),
    constraint df_task_fk2 foreign key (route_id) references df_document_route(route_id),
    constraint df_task_fk3 foreign key (parent_task_id) references df_task(task_id),
    constraint df_task_fk4 foreign key (return_to_task_id) references df_task(task_id),
    constraint df_task_type_ck check (task_type in ('WORKFLOW','REVIEW')),
    constraint df_task_status_ck check (status in ('PENDING','COMPLETED','CANCELLED','RETURNED','WAITING_REVIEW')),
    constraint df_task_review_parent_ck check ((task_type = 'REVIEW' and parent_task_id is not null) or (task_type = 'WORKFLOW' and parent_task_id is null))
);

create table df_action_history (
    action_id       number default df_action_history_seq.nextval not null,
    document_id     number not null,
    route_id        number,
    task_id         number,
    action_type     varchar2(30) not null,
    action_by_emp_id varchar2(30) not null,
    action_to_emp_id varchar2(30),
    action_at       timestamp with local time zone default systimestamp not null,
    from_status     varchar2(30),
    to_status       varchar2(30),
    comments        varchar2(4000),
    parent_action_id number,
    ip_address      varchar2(64),
    apex_session_id varchar2(100),
    app_user        varchar2(255),
    constraint df_action_history_pk primary key (action_id),
    constraint df_action_history_fk1 foreign key (document_id) references df_document(document_id),
    constraint df_action_history_fk2 foreign key (route_id) references df_document_route(route_id),
    constraint df_action_history_fk3 foreign key (task_id) references df_task(task_id),
    constraint df_action_history_fk4 foreign key (parent_action_id) references df_action_history(action_id)
);

create table df_distribution (
    distribution_id  number default df_distribution_seq.nextval not null,
    document_id       number not null,
    recipient_type    varchar2(20) not null,
    recipient_emp_id  varchar2(30),
    recipient_dept_id number,
    recipient_dept_code varchar2(200),
    sent_by_emp_id    varchar2(30) not null,
    sent_at           timestamp with local time zone default systimestamp not null,
    delivery_status   varchar2(20) default 'UNREAD' not null,
    viewed_at         timestamp with local time zone,
    acknowledged_at   timestamp with local time zone,
    message           varchar2(2000),
    constraint df_distribution_pk primary key (distribution_id),
    constraint df_distribution_fk1 foreign key (document_id) references df_document(document_id),
    constraint df_distribution_type_ck check (recipient_type in ('EMPLOYEE','DEPARTMENT')),
    constraint df_distribution_recipient_ck check (
        (recipient_type = 'EMPLOYEE' and recipient_emp_id is not null
         and recipient_dept_id is null and recipient_dept_code is null) or
        (recipient_type = 'DEPARTMENT' and recipient_dept_id is not null and recipient_emp_id is null)),
    constraint df_distribution_status_ck check (delivery_status in ('UNREAD','READ','ACKNOWLEDGED'))
);

alter table df_document add constraint df_document_fk3
    foreign key (current_route_id) references df_document_route(route_id);

create index df_role_assignment_i1 on df_role_assignment(
    role_id, company_id, unit_id, location_id, department_id, active_yn);
create index df_delegation_i1 on df_delegation(from_emp_id, active_yn, start_date, end_date);
create index df_item_expert_i1 on df_item_expert(
    item_id, company_id, unit_id, location_id, active_yn);
create index df_workflow_i1 on df_workflow(
    type_id, company_id, unit_id, location_id, department_id, active_yn);
create index df_approval_rule_i1 on df_approval_rule(workflow_id, active_yn, min_amount, max_amount);
create index df_approval_rule_i2 on df_approval_rule(
    workflow_id, item_id, item_category_id, company_id, unit_id, location_id, active_yn);
create index df_document_i1 on df_document(current_status, current_assignee_emp_id);
create index df_document_i2 on df_document(creator_emp_id, created_at);
create index df_document_route_i1 on df_document_route(document_id, step_no, status);
create index df_task_i1 on df_task(assigned_to_emp_id, status, task_type);
create index df_task_i2 on df_task(document_id, status);
create index df_action_history_i1 on df_action_history(document_id, action_at);
create index df_distribution_i1 on df_distribution(recipient_emp_id, delivery_status);
create index df_distribution_i2 on df_distribution(recipient_dept_id, delivery_status);

-- One active workflow task per document and one pending review per parent task.
create unique index df_task_u_active_workflow on df_task(
    case when task_type = 'WORKFLOW' and status in ('PENDING','WAITING_REVIEW') then document_id end);
create unique index df_task_u_pending_review on df_task(
    case when task_type = 'REVIEW' and status = 'PENDING' then parent_task_id end);

comment on column df_document.creator_emp_id is 'EMPLOYEES.EMP_ID business employee code';
comment on column df_document.department_id is 'Numeric EMPLOYEES.DEPT_ID-compatible department identifier';
comment on column df_document.unit_id is 'Numeric EMPLOYEES.BRANCH_ID-compatible unit/branch identifier';
comment on column df_document.company_id is 'Numeric EMPLOYEES.COM_ID-compatible company identifier';
comment on column df_document.location_id is 'Numeric EMPLOYEES.LOC_ID-compatible location identifier';
comment on column df_role_assignment.emp_id is 'EMPLOYEES.EMP_ID business employee code';
comment on column df_role_assignment.department_id is 'Numeric EMPLOYEES.DEPT_ID-compatible scope';
comment on column df_role_assignment.unit_id is 'Numeric EMPLOYEES.BRANCH_ID-compatible scope';
comment on column df_role_assignment.company_id is 'Numeric EMPLOYEES.COM_ID-compatible scope';
comment on column df_role_assignment.location_id is 'Numeric EMPLOYEES.LOC_ID-compatible scope';
