# APEX application design

Use Universal Theme, a desktop-first responsive layout, and the parsing schema that owns the `DF_*` objects. All transaction buttons call packages. Do not use Automatic Row Processing on `DF_DOCUMENT`, `DF_TASK`, `DF_DOCUMENT_ROUTE`, `DF_ACTION_HISTORY`, or `DF_DISTRIBUTION`.

## Shared components

Create application item `G_EMP_ID`, protected and restricted to session state. Existing applications may keep `G_UNAME`; both items should contain `EMPLOYEES.EMP_ID`. Add an After Authentication application process:

```plsql
:G_EMP_ID := pkg_df_security.current_emp_id;
if :G_EMP_ID is null then
    raise_application_error(-20080,
        'Your login must match an active EMPLOYEES.EMP_ID or an active DF_APP_USER alias.');
end if;
:G_UNAME := :G_EMP_ID;
```

Page 9999 may authenticate directly with `P9999_USERNAME = EMPLOYEES.EMP_ID`. In that case a `DF_APP_USER` row is not required. `DF_APP_USER` is only needed when the APEX username is an alias that differs from `EMP_ID`.

Authorization schemes:

- `MAPPED_EMPLOYEE`: `return pkg_df_security.current_emp_id is not null;` (the name is retained, but direct `EMP_ID` logins are also accepted)
- `CAN_VIEW_DOCUMENT`: `return pkg_df_security.can_view_document(:P121_DOCUMENT_ID, :G_EMP_ID) = 'Y';`
- `HAS_WORKFLOW_TASK`: `return pkg_df_security.has_pending_workflow_task(:P121_DOCUMENT_ID, :G_EMP_ID) = 'Y';`
- `HAS_REVIEW_TASK`: `return pkg_df_security.has_pending_review(:P131_DOCUMENT_ID, :G_EMP_ID) = 'Y';`
- `WORKFLOW_ADMIN`: use the organization’s existing admin-role check; do not infer admin rights from page access alone.

Create employee LOVs from the normalized adapter view. Return employee codes because all workflow actor columns store `EMPLOYEES.EMP_ID`:

```sql
select employee_name || ' (' || employee_code || ')' d, employee_code r
  from v_df_employee
 where active_yn = 'Y'
 order by employee_name
```

Organization LOVs must return numbers: `DEPT_ID` for department, `BRANCH_ID` for unit, `COM_ID` for company, and `LOC_ID` for location. Use the organization master tables if available. If they are not available, distinct fallback LOVs can be built from `V_DF_EMPLOYEE`; display the numeric ID or join the proper master to obtain its code/name. Optional page items for `*_CODE` are display snapshots only.

## Navigation

```text
Dashboard
Documents
  Create Document
  My Drafts
  My Submitted Documents
My Work
  My Inbox
  Review Requests
  Returned Documents
  Completed Tasks
Approved Documents
  Approved
  Received Documents
Search
  Document Search
Administration
  Document Types
  Items and Experts
  Roles and Assignments
  Workflows and Steps
  Approval Policy
  Delegations
```

## Page 1 — Dashboard

Use five cards sourced from `V_DF_DASHBOARD_COUNTS`: My Pending, Review Requests, Returned, Draft, and Approved Today. Card links target pages 130, 131, 132, 120, and 140. Add charts for pending by department, current route step, document type, and elapsed-time bucket using `V_DF_DOCUMENT_TRACKING`.

## Pages 101–106 — Administration masters

- 101 Document Types: interactive grid on `DF_DOCUMENT_TYPE`; protect codes once documents exist.
- 102 Item Master: interactive grid on `DF_ITEM`.
- 103 Item Experts: master-detail from `DF_ITEM` to `DF_ITEM_EXPERT`; validate one highest-priority active primary expert per scope.
- 104 Roles: interactive grid on `DF_ROLE`.
- 105 Role Assignments: faceted search plus editable form on `DF_ROLE_ASSIGNMENT`. Display scope specificity and effective dates.
- 106 Approval Policy: master `DF_APPROVAL_RULE`, detail grid `DF_APPROVAL_RULE_STEP`. Display a “Cumulative” badge; `APPROVAL_MODE` is read-only.

### Page 105 — Role Assignments

Use two APEX pages: Page 105 is a Faceted Search page on `V_DF_ROLE_ASSIGNMENT_ADMIN`; Page 107 is a Modal Dialog Form on the base table `DF_ROLE_ASSIGNMENT`. Page 107 does not appear in navigation. Apply the `WORKFLOW_ADMIN` authorization scheme to both pages, not only to their navigation entry.

Create Page 105 with **Create Page > Faceted Search**. Use this report source:

```sql
select assignment_id, role_id, role_code, role_name,
       emp_id, employee_name, email,
       company_id, company_code, unit_id, unit_code,
       location_id, location_code, department_id, department_code,
       scope_specificity, scope_summary, priority_no,
       effective_from, effective_to, active_yn, effective_status,
       created_by, created_at
  from v_df_role_assignment_admin
```

Recommended facets:

- Search: `ROLE_CODE`, `ROLE_NAME`, `EMP_ID`, `EMPLOYEE_NAME`, `EMAIL`.
- Checkbox Group: `ROLE_NAME`, `EFFECTIVE_STATUS`, `ACTIVE_YN`, and `SCOPE_SPECIFICITY`.
- Select List: `COMPANY_ID`, `UNIT_ID`, `LOCATION_ID`, and `DEPARTMENT_ID` with “Show Counts” enabled.
- Date Range: `EFFECTIVE_FROM` and `EFFECTIVE_TO` if supported by the installed APEX version.

Report column `ASSIGNMENT_ID` is hidden but used as the edit link target. Link the employee/role column to Page 107, set `P107_ASSIGNMENT_ID = #ASSIGNMENT_ID#`, and clear Page 107 cache. Add a Create button targeting Page 107 with its cache cleared. Add an **After Dialog Closed** dynamic action that refreshes both the faceted-search region and its result region.

Create Page 107 with **Create Page > Form > Form on a Table > Modal Dialog**, table `DF_ROLE_ASSIGNMENT`, primary key `ASSIGNMENT_ID`. Keep Automatic Row Fetch/Initialization and Automatic Row Processing. Do not expose `CREATED_BY` or `CREATED_AT` for editing. Prefer deactivation over physical deletion.

Page 107 items:

- `P107_ASSIGNMENT_ID`: Hidden, primary key.
- `P107_ROLE_ID`: required Popup LOV returning `DF_ROLE.ROLE_ID`.
- `P107_EMP_ID`: required Popup LOV returning `V_DF_EMPLOYEE.EMPLOYEE_CODE`.
- `P107_COMPANY_ID`, `P107_UNIT_ID`, `P107_LOCATION_ID`, `P107_DEPARTMENT_ID`: optional numeric Popup LOVs.
- The matching `*_CODE` items: optional text/display snapshots; populate them from organization master tables when available.
- `P107_PRIORITY_NO`: Number Field, required, default `100`, minimum `1`. Lower number wins when two assignments have equal specificity.
- `P107_EFFECTIVE_FROM`: Date Picker, required, default `TRUNC(SYSDATE)`.
- `P107_EFFECTIVE_TO`: optional Date Picker.
- `P107_ACTIVE_YN`: Switch with return values `Y` and `N`, default `Y`.

Role LOV:

```sql
select role_name || ' (' || role_code || ')' d, role_id r
  from df_role
 where active_yn = 'Y' or role_id = :P107_ROLE_ID
 order by role_name
```

Employee LOV:

```sql
select employee_name || ' (' || employee_code || ')' d, employee_code r
  from v_df_employee
 where active_yn = 'Y' or employee_code = :P107_EMP_ID
 order by employee_name
```

When organization master tables are unavailable, use this numeric fallback pattern and substitute the required ID column:

```sql
select to_char(company_id) d, company_id r
  from v_df_employee
 where company_id is not null
 group by company_id
 order by company_id
```

Add an item validation for dates:

```plsql
return case
         when :P107_EFFECTIVE_TO is not null
          and :P107_EFFECTIVE_TO < :P107_EFFECTIVE_FROM
         then 'Effective To cannot be earlier than Effective From.'
       end;
```

Add a PL/SQL Function Returning Error Text validation to prevent ambiguous active assignments. Specificity is evaluated first; within the same specificity, the lower `PRIORITY_NO` wins. Therefore the same role, exact scope, priority, and overlapping effective period must not identify two employees:

```plsql
declare
    l_count number;
begin
    if :P107_ACTIVE_YN = 'Y' then
        select count(*)
          into l_count
          from df_role_assignment x
         where x.assignment_id <> nvl(:P107_ASSIGNMENT_ID, -1)
           and x.role_id = :P107_ROLE_ID
           and nvl(x.company_id, -1) = nvl(:P107_COMPANY_ID, -1)
           and nvl(x.unit_id, -1) = nvl(:P107_UNIT_ID, -1)
           and nvl(x.location_id, -1) = nvl(:P107_LOCATION_ID, -1)
           and nvl(x.department_id, -1) = nvl(:P107_DEPARTMENT_ID, -1)
           and x.priority_no = :P107_PRIORITY_NO
           and x.active_yn = 'Y'
           and nvl(x.effective_to, date '2999-12-31') >= :P107_EFFECTIVE_FROM
           and nvl(:P107_EFFECTIVE_TO, date '2999-12-31') >= x.effective_from;

        if l_count > 0 then
            return 'Another active assignment has the same role, scope, priority, and overlapping dates.';
        end if;
    end if;

    return null;
end;
```

Examples: all four scope IDs null means global specificity `0`; company plus department means specificity `2`; company, unit, location, and department means specificity `4`. Actor resolution chooses the highest specificity, then the lowest priority number, then the newest effective date.

### Page 106 — Approval Policy Master–Detail

Create the policy designer with **Create Page > Master Detail > Drill Down**. Use `DF_APPROVAL_RULE` as the master and `DF_APPROVAL_RULE_STEP` as the detail. Configure Page 106 as the policy list and Page 108 as the normal-mode policy editor. The wizard's Drill Down pattern provides a master report followed by a standard master form with a detail Interactive Grid; this fits the policy header/ladder design better than Stacked, which presents editable grids for both levels. Apply `WORKFLOW_ADMIN` authorization to both pages. Page 108 must be a normal page, not a modal, because the approval ladder and preview need horizontal space.

Recommended visual hierarchy:

1. **Page 106 Policy List** — searchable report/cards with status, workflow, scope, amount range, and an edit link to Page 108.
2. **Policy Header on Page 108** — rule name, document type, workflow, `CUMULATIVE` badge, effective-status badge, and Active switch.
3. **Applicability & Scope** — company, unit, location, item category, item, amount range, dates, and priority in a collapsible region.
4. **Cumulative Approval Ladder** — editable Interactive Grid containing the authority levels.
5. **Route Preview** — cards/timeline driven by a test amount so administrators can see which authorities will be included before activation.

Use Page 106 report query:

```sql
select r.rule_id,
       r.rule_name,
       dt.type_name,
       w.workflow_name,
       w.version_no,
       r.min_amount,
       r.max_amount,
       r.company_id,
       r.unit_id,
       r.location_id,
       r.item_category_id,
       i.item_name,
       r.priority_no,
       r.effective_from,
       r.effective_to,
       r.active_yn,
       case
         when r.active_yn = 'N' then 'INACTIVE'
         when trunc(sysdate) < r.effective_from then 'FUTURE'
         when r.effective_to is not null and trunc(sysdate) > r.effective_to then 'EXPIRED'
         else 'CURRENT'
       end effective_status,
       (select count(*) from df_approval_rule_step s
         where s.rule_id = r.rule_id and s.active_yn = 'Y') active_step_count
  from df_approval_rule r
  join df_workflow w on w.workflow_id = r.workflow_id
  join df_document_type dt on dt.type_id = w.type_id
  left join df_item i on i.item_id = r.item_id
```

Make `RULE_NAME` the edit link to Page 108 and pass `P108_RULE_ID = #RULE_ID#`. The Create button targets Page 108 with `P108_RULE_ID` null and Page 108 cache cleared. Keep Page 106 in navigation; Page 108 is reached only through Create/Edit links.

Master items:

- `P108_RULE_ID`: Hidden primary key.
- `P108_RULE_NAME`: Text Field, required, 6-column width.
- `P108_TYPE_ID`: non-database required Popup LOV for filtering workflows; derive it from the saved workflow when editing.
- `P108_WORKFLOW_ID`: required cascading Popup LOV, returning `DF_WORKFLOW.WORKFLOW_ID`.
- `P108_APPROVAL_MODE`: Display Only, value `CUMULATIVE`; show it as a success-colored badge.
- `P108_COMPANY_ID`, `P108_UNIT_ID`, `P108_LOCATION_ID`: optional numeric Popup LOVs.
- `P108_ITEM_CATEGORY_ID`, `P108_ITEM_ID`: optional Popup LOVs. Make Item cascade from category when a category is selected.
- Matching `*_CODE` items: optional display snapshots populated from the selected masters.
- `P108_MIN_AMOUNT`: Number Field, required, default `0`.
- `P108_MAX_AMOUNT`: optional Number Field; null means no rule-range ceiling.
- `P108_PRIORITY_NO`: required Number Field, default `100`; lower number wins only after specificity is equal.
- `P108_EFFECTIVE_FROM`, `P108_EFFECTIVE_TO`: Date Pickers.
- `P108_ACTIVE_YN`: Switch. Default new rules to `N`; activate only after the ladder is complete and validated.

Document Type LOV (`P108_TYPE_ID`):

```sql
select type_name || ' (' || type_code || ')' d, type_id r
  from df_document_type
 where active_yn = 'Y'
    or type_id = (select type_id
                    from df_workflow
                   where workflow_id = :P108_WORKFLOW_ID)
 order by type_name
```

For edit mode, add a Before Header process **after** the generated Form Initialization process to initialize the non-database item:

```plsql
if :P108_WORKFLOW_ID is not null then
    select type_id
      into :P108_TYPE_ID
      from df_workflow
     where workflow_id = :P108_WORKFLOW_ID;
end if;
```

Workflow LOV (`P108_WORKFLOW_ID`):

```sql
select w.workflow_name || ' (' || w.workflow_code || ', v' || w.version_no || ')' d,
       w.workflow_id r
  from df_workflow w
 where w.type_id = :P108_TYPE_ID
   and (w.active_yn = 'Y' or w.workflow_id = :P108_WORKFLOW_ID)
 order by w.workflow_name, w.version_no desc
```

Set `P108_TYPE_ID` as the Cascading LOV Parent Item of `P108_WORKFLOW_ID`, submit `P108_TYPE_ID`, and clear `P108_WORKFLOW_ID` whenever the type changes. Do not return `TYPE_ID` into `P108_WORKFLOW_ID`; that would violate `DF_APPROVAL_RULE_FK1` because the approval rule belongs to a workflow, while the workflow already belongs to a document type.

Item LOV:

```sql
select item_name || ' (' || item_code || ')' d, item_id r
  from df_item
 where (active_yn = 'Y' or item_id = :P108_ITEM_ID)
   and (:P108_ITEM_CATEGORY_ID is null or category_id = :P108_ITEM_CATEGORY_ID)
 order by item_name
```

Set `P108_ITEM_CATEGORY_ID` as the cascading parent and submit it when refreshing the Item LOV. Organization LOVs must return numeric IDs; use the real organization masters, or the `V_DF_EMPLOYEE` fallback pattern described for Page 105.

Configure the detail Interactive Grid with static ID `RULE_STEPS_IG` and these columns:

- `RULE_STEP_ID`: Hidden primary key.
- `RULE_ID`: Hidden parent column; default `:P108_RULE_ID`.
- `STEP_NO`: required Number Field; use `10, 20, 30...` or `40, 50, 60...` to leave insertion gaps.
- `STEP_NAME`: required Text Field.
- `ACTOR_TYPE`: required Select List containing `EMPLOYEE`, `ROLE`, `DEPT_HEAD`, `ITEM_EXPERT`, `CONCERNED_ED`, and `DOCUMENT_CREATOR`.
- `ACTOR_ID`: Popup LOV; required only for `EMPLOYEE` and `ROLE`.
- `ACTION_REQUIRED`: Select List containing `FORWARD`, `RECOMMEND`, `APPROVE`; default `APPROVE` for cumulative authority rows.
- `APPROVAL_LIMIT`: Number Field; display “Unlimited / Final Authority” when null.
- `CAN_REVIEW_YN`, `CAN_RETURN_YN`, `CAN_REJECT_YN`, `ACTIVE_YN`: compact `Y/N` Switch columns.

Use this cascading LOV for the IG `ACTOR_ID` column and set `ACTOR_TYPE` as its Parent Column:

```sql
select employee_name || ' (' || employee_code || ')' d, employee_code r
  from v_df_employee
 where :ACTOR_TYPE = 'EMPLOYEE'
   and active_yn = 'Y'
union all
select role_name || ' (' || role_code || ')' d, role_code r
  from df_role
 where :ACTOR_TYPE = 'ROLE'
   and active_yn = 'Y'
order by 1
```

Add an IG row validation: `ACTOR_ID` is mandatory for `EMPLOYEE`/`ROLE`, and must be null for the four system-resolved actor types. Add help text explaining that `DEPT_HEAD`, `ITEM_EXPERT`, `CONCERNED_ED`, and `DOCUMENT_CREATOR` are resolved from the document at submission time.

Add `P108_TEST_AMOUNT` above the preview region, default `45000`. Create a Change dynamic action that refreshes the preview and include `P108_RULE_ID,P108_TEST_AMOUNT` in **Page Items to Submit**. A Cards region can use:

```sql
with active_steps as (
    select s.*
      from df_approval_rule_step s
     where s.rule_id = :P108_RULE_ID
       and s.active_yn = 'Y'
), cutoff as (
    select min(step_no) cutoff_step
      from active_steps
     where approval_limit is null
        or nvl(:P108_TEST_AMOUNT, 0) <= approval_limit
)
select s.step_no,
       s.step_name card_title,
       case s.actor_type
         when 'EMPLOYEE' then
              (select employee_name || ' (' || employee_code || ')'
                 from v_df_employee e where e.employee_code = upper(s.actor_id))
         when 'ROLE' then
              (select role_name || ' (' || role_code || ')'
                 from df_role r where r.role_code = upper(s.actor_id))
         else initcap(replace(s.actor_type, '_', ' '))
       end card_subtitle,
       case when s.approval_limit is null then 'Unlimited'
            else 'Up to ' || to_char(s.approval_limit, 'FM999G999G999G990')
       end card_badge,
       'Action: ' || initcap(lower(s.action_required)) card_body
  from active_steps s
 where s.step_no <= nvl((select cutoff_step from cutoff), 1e125)
 order by s.step_no
```

Use the Cards template with a horizontal/compact layout or a Timeline-style Classic Report. For the sample ladder `10,000 → 30,000 → 50,000 → 100,000 → Unlimited`, test amount `45,000` must preview the first three authorities. This makes Option B cumulative behavior visible to administrators.

Master validations:

- `MIN_AMOUNT >= 0`; `MAX_AMOUNT` must be null or at least `MIN_AMOUNT`.
- `EFFECTIVE_TO` must be null or at least `EFFECTIVE_FROM`.
- When active, prevent another active rule with the same workflow, exact scope, overlapping amount range, and overlapping dates. Broad defaults and more-specific item/company/location exceptions are allowed because their scopes differ.
- If both Item and Item Category are supplied, validate that `DF_ITEM.CATEGORY_ID` matches the selected category.

The detail ladder must be checked **after** the Interactive Grid DML process, not as a normal pre-DML page validation; otherwise the query cannot see the submitted IG changes. Set process order: master Form DML, detail IG DML, then `Validate Cumulative Ladder`. The final process is:

```plsql
declare
    l_bad        number;
    l_step_count number;
    l_last_limit number;
    l_max_amount df_approval_rule.max_amount%type;
    l_active_yn  df_approval_rule.active_yn%type;
begin
    select max_amount, active_yn
      into l_max_amount, l_active_yn
      from df_approval_rule
     where rule_id = :P108_RULE_ID;

    select count(*),
           max(approval_limit) keep (dense_rank last order by step_no)
      into l_step_count, l_last_limit
      from df_approval_rule_step
     where rule_id = :P108_RULE_ID
       and active_yn = 'Y';

    select count(*) into l_bad
      from (
        select step_no, approval_limit,
               lag(approval_limit) over(order by step_no) previous_limit,
               max(step_no) over() last_step
          from df_approval_rule_step
         where rule_id = :P108_RULE_ID and active_yn = 'Y'
      )
     where (step_no <> last_step and approval_limit is null)
        or (previous_limit is not null and approval_limit is not null
            and approval_limit <= previous_limit);
    if l_bad > 0 then
        raise_application_error(-20090,
            'Approval ceilings must increase; only the final active step may be unlimited.');
    end if;

    if l_active_yn = 'Y' and l_step_count = 0 then
        raise_application_error(-20091,
            'An active approval rule requires at least one active step.');
    end if;

    if l_step_count > 0 and l_max_amount is null and l_last_limit is not null then
        raise_application_error(-20092,
            'An open-ended rule requires an Unlimited final approval step.');
    end if;

    if l_step_count > 0 and l_max_amount is not null
       and l_last_limit is not null and l_last_limit < l_max_amount then
        raise_application_error(-20093,
            'The final approval ceiling must cover the rule maximum amount.');
    end if;
end;
```

Do not physically delete a policy that may explain historical routing. Set `ACTIVE_YN = 'N'`, close `EFFECTIVE_TO`, and create a new rule/version instead. Historical documents remain safe because their routes are snapshotted into `DF_DOCUMENT_ROUTE` at submission.

## Pages 110–113 — Workflow designer

- 110 Workflow Master: report/form on `DF_WORKFLOW` with copy-as-new-version action.
- 111 Workflow Steps: ordered grid on `DF_WORKFLOW_STEP`, using step numbers 10, 20, 30. Include action, actor, and permission switches.
- 112 Conditions: detail grid on `DF_WORKFLOW_CONDITION`. LOVs expose only whitelisted field/operator values from constraints; never accept SQL expressions.
- 113 Route Preview/Test: choose a saved draft. Show fixed and cumulative rows, resolved employee, and the approval ceiling. Catch actor-resolution errors and show them as configuration failures.

Page 113 classic-report source:

```sql
with cfg as (
    select s.step_no, s.step_name, s.actor_type, s.actor_id,
           cast(null as number) approval_limit
      from df_workflow_step s
     where s.workflow_id = pkg_df_rule.find_workflow(:P113_DOCUMENT_ID)
       and s.active_yn = 'Y'
       and pkg_df_rule.step_applies(s.step_id, :P113_DOCUMENT_ID) = 'Y'
    union all
    select s.step_no, s.step_name, s.actor_type, s.actor_id, s.approval_limit
      from df_approval_rule_step s
     where s.rule_id = pkg_df_rule.find_approval_rule(
               :P113_DOCUMENT_ID, pkg_df_rule.find_workflow(:P113_DOCUMENT_ID))
       and s.active_yn = 'Y'
       and s.step_no <= nvl((
             select min(x.step_no)
               from df_approval_rule_step x
               join df_document d on d.document_id = :P113_DOCUMENT_ID
              where x.rule_id = s.rule_id and x.active_yn = 'Y'
                and (x.approval_limit >= nvl(d.total_amount,0)
                     or x.approval_limit is null)), 1e9)
), resolved as (
    select c.*,
           pkg_df_actor.resolve_actor_for_display(
               c.actor_type, c.actor_id, :P113_DOCUMENT_ID) assigned_emp_id
      from cfg c
)
select step_no, step_name, actor_type, actor_id, assigned_emp_id, approval_limit
  from resolved
 where assigned_emp_id <> (select creator_emp_id from df_document
                             where document_id = :P113_DOCUMENT_ID)
 order by step_no
```

## Page 120 — Create/edit document

Regions:

1. Basic Information: type, department, subject, date, priority, confidentiality, company, unit, location.
2. Document: Rich Text Editor bound to a CLOB item.
3. Purchase Information: server-side condition `IS_PURCHASE_YN = 'Y'`; primary item, purchase type, amount, currency, purpose, required date.
4. Purchase Lines: interactive grid for additional `DF_PURCHASE_ITEM` rows.
5. Attachments: use `APEX_APPLICATION_TEMP_FILES` while draft; copy to `DF_DOCUMENT_ATTACHMENT` only after the submission version snapshot exists.
6. Route Preview: link to page 113, enabled after the draft is saved.

Default numeric organization items from the current employee when creating a document:

```sql
select e.dept_id, e.branch_id, e.com_id, e.loc_id
  into :P120_DEPARTMENT_ID, :P120_UNIT_ID,
       :P120_COMPANY_ID, :P120_LOCATION_ID
  from employees e
 where upper(e.emp_id) = upper(:G_EMP_ID)
   and nvl(e.status,0) = 1
```

If business users may create a document for a different concerned department, allow only the department item to change and keep company/unit/location authorization-scoped.

Create process:

```plsql
pkg_df_document.create_document(
    p_type_id => :P120_TYPE_ID,
    p_subject => :P120_SUBJECT,
    p_body_clob => :P120_BODY,
    p_creator_emp_id => :G_EMP_ID,
    p_department_id => :P120_DEPARTMENT_ID,
    p_unit_id => :P120_UNIT_ID,
    p_company_id => :P120_COMPANY_ID,
    p_location_id => :P120_LOCATION_ID,
    p_department_code => :P120_DEPARTMENT_CODE,
    p_unit_code => :P120_UNIT_CODE,
    p_company_code => :P120_COMPANY_CODE,
    p_location_code => :P120_LOCATION_CODE,
    p_document_date => :P120_DOCUMENT_DATE,
    p_priority_code => :P120_PRIORITY,
    p_confidentiality_level => :P120_CONFIDENTIALITY,
    p_total_amount => :P120_TOTAL_AMOUNT,
    p_currency_code => :P120_CURRENCY,
    p_document_id => :P120_DOCUMENT_ID);
```

For procurement, call `PKG_DF_DOCUMENT.SAVE_PURCHASE` next. Submit process:

```plsql
pkg_df_workflow.submit_document(:P120_DOCUMENT_ID, :G_EMP_ID, :P120_SUBMIT_COMMENT);
```

On success branch to page 121. APEX commits only after all page processes succeed.

## Page 121 — Document detail and action bar

Authorization: `CAN_VIEW_DOCUMENT`. Header shows number, type, status badge, current holder, route step, pending since, and elapsed hours from `V_DF_DOCUMENT_TRACKING`.

Tabs:

- Document Details (`DF_DOCUMENT`, `DF_PURCHASE`, `DF_PURCHASE_ITEM`)
- Attachments (`DF_DOCUMENT_ATTACHMENT`)
- Approval Route (`V_DF_ROUTE_STATUS` ordered by `STEP_NO`)
- Timeline (`V_DF_DOCUMENT_TIMELINE` ordered by `ACTION_AT`, `ACTION_ID`)
- Versions (`DF_DOCUMENT_VERSION`)
- Distribution (`DF_DISTRIBUTION`, only after approval)

Action buttons use `HAS_WORKFLOW_TASK` plus the current route flags/action:

- Forward: `PKG_DF_WORKFLOW.FORWARD_DOCUMENT`
- Recommend: `PKG_DF_WORKFLOW.RECOMMEND_DOCUMENT`
- Approve: `PKG_DF_WORKFLOW.APPROVE_DOCUMENT`
- Send for Review: opens page 123 and requires `CAN_REVIEW_YN='Y'`
- Return: opens page 124 and requires `CAN_RETURN_YN='Y'`
- Reject: modal confirmation and `PKG_DF_WORKFLOW.REJECT_DOCUMENT`

Never show workflow actions merely because the document’s current assignee text matches the user; authorization must call the task-based security function.

## Page 122 — Attachments

File Browse item stores in `APEX_APPLICATION_TEMP_FILES`. After a version exists:

```sql
insert into df_document_attachment(
    document_id, version_no, file_name, mime_type, file_size, file_blob,
    attachment_type, uploaded_by)
select :P122_DOCUMENT_ID, :P122_VERSION_NO, filename, mime_type,
       dbms_lob.getlength(blob_content), blob_content,
       :P122_ATTACHMENT_TYPE, :APP_USER
  from apex_application_temp_files
 where name = :P122_FILE;
```

Validate MIME type, maximum BLOB size, document access, and version ownership before insert.

## Page 123 — Send for review modal

Items: reviewer employee LOV, due date, instruction. Do not display a Send for Review button on the reviewer page. Process:

```plsql
pkg_df_review.request_review(
    :P123_DOCUMENT_ID, :G_EMP_ID, :P123_REVIEWER_EMP_ID,
    :P123_INSTRUCTION, :P123_DUE_AT);
```

Only one pending review is allowed for the current workflow task. Nested review is blocked in both API and database trigger.

## Page 124 — Return modal

Items: return mode (`PREVIOUS`, `CREATOR`, `SPECIFIC`), earlier route LOV, mandatory reason. The specific-target LOV is:

```sql
select step_no || ' - ' || step_name d, route_id r
  from df_document_route
 where document_id = :P124_DOCUMENT_ID
   and step_no < (select step_no from df_document_route
                   where route_id = (select current_route_id from df_document
                                      where document_id = :P124_DOCUMENT_ID))
 order by step_no desc
```

Call `PKG_DF_WORKFLOW.RETURN_DOCUMENT`.

## Pages 130–133 — Work queues

- 130 My Inbox: interactive report on `V_DF_MY_INBOX`, link to page 121.
- 131 Review Requests: report on `V_DF_REVIEW_INBOX`; detail modal has one Complete Review button calling `PKG_DF_REVIEW.COMPLETE_REVIEW`. Remarks required.
- 132 Returned Documents: `DF_DOCUMENT` where status is `RETURNED` and current assignee is `:G_EMP_ID`. Creator-return rows show Edit and Resubmit; route-return rows link to page 121 for their required route action.
- 133 My Submitted Documents: report on `V_DF_MY_SUBMITTED`.

## Pages 140–143 — Search and monitoring

- 140 Document Search: faceted search on `V_DF_DOCUMENT_TRACKING`; filter number, subject, creator, department, type, item, amount, date, holder, and status.
- 141 Document Tracking: focused status card plus route diagram and elapsed time.
- 142 Workflow History: timeline and printable classic report.
- 143 Management Dashboard: pending by authority/department, average completion duration, and overdue work. Apply confidentiality authorization before exposing result rows.

## Page 150 — Print/PDF

Document content comes from `DF_DOCUMENT_VERSION` for the selected version. History query:

```sql
select h.action_by_emp_id employee_code,
       e.employee_name,
       r.step_name designation_or_role,
       h.comments remarks,
       h.action_type action,
       h.action_at action_date
  from df_action_history h
  left join df_document_route r on r.route_id = h.route_id
  left join v_df_employee e on e.employee_code = upper(h.action_by_emp_id)
 where h.document_id = :P150_DOCUMENT_ID
 order by h.action_at, h.action_id
```

This replaces all L0–L12 `UNION ALL` print logic.

## Page 151 — Distribution

Visible only for approved documents with distribution enabled. Recipient type LOV contains only Employee and Department. Department LOV returns numeric `DEPT_ID`; its readable code is passed separately when available. There are no external name/email/phone items. Add-row process calls `PKG_DF_DISTRIBUTION.SEND_DOCUMENT`. “My Received Documents” uses `V_DF_RECEIVED_DOCUMENTS`, then calls `MARK_VIEWED` and `ACKNOWLEDGE_DOCUMENT` for direct employee recipients.

```plsql
pkg_df_distribution.send_document(
    p_document_id => :P151_DOCUMENT_ID,
    p_sent_by_emp_id => :G_EMP_ID,
    p_recipient_type => :P151_RECIPIENT_TYPE,
    p_recipient_emp_id => :P151_RECIPIENT_EMP_ID,
    p_recipient_dept_id => :P151_RECIPIENT_DEPT_ID,
    p_recipient_dept_code => :P151_RECIPIENT_DEPT_CODE,
    p_message => :P151_MESSAGE);
```

## Error handling and concurrency

Use an application error-handling function that preserves `raise_application_error` text from `PKG_DF_*` while hiding internal stack details. Submit buttons should be disabled after the first click for user experience, but correctness comes from package row locks and unique active-task indexes. Do not add commits inside page processes.
