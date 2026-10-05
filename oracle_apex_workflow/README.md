# Oracle APEX Document Approval Workflow

This folder is the normalized replacement for the fixed `L0...L12` document-forwarding implementation. It is designed for Oracle Database 19c and Oracle APEX, uses cumulative approval (Option B), permits one-level ad-hoc review, and permits distribution only to internal employees or departments.

The workflow integrates directly with `EMPLOYEES`. Employee actors use `EMPLOYEES.EMP_ID` (`VARCHAR2(30)`), while all organizational matching uses numeric IDs:

| Workflow field | EMPLOYEES source |
|---|---|
| `DEPARTMENT_ID` | `DEPT_ID` |
| `UNIT_ID` | `BRANCH_ID` |
| `COMPANY_ID` | `COM_ID` |
| `LOCATION_ID` | `LOC_ID` |

Optional `DEPARTMENT_CODE`, `UNIT_CODE`, `COMPANY_CODE`, and `LOCATION_CODE` columns are retained as readable snapshots. They are not used for rule or actor matching.

The legacy files are not modified or dropped. This matters because the supplied source has conflicting versions and at least one structural error: `DF_MASTER.sql` creates `DOC_FORWARDING` but then adds constraints and a trigger to `DF_MASTER`. The two `DF_FORWARDING_INS` versions also have different signatures, and the amount threshold is hard-coded at 50,000. The new packages replace that behavior explicitly.

## Installation

Run from the `oracle_apex_workflow` directory with SQLcl or SQL*Plus as the APEX parsing schema:

```sql
@00_install.sql
```

APEX SQL Workshop does not process the `@@` include commands consistently across releases. When using SQL Workshop, run `00_hr_prerequisite.sql`, files `01` through `08`, and then `12_validate_install.sql` in that order.

Then migrate the reusable legacy configuration:

```sql
@10_migrate_legacy_configuration.sql
```

Review role assignments, item experts, document types, workflows, and the approval matrix in APEX before enabling users. If old transaction history must also be retained, back up the schema and run:

```sql
@11_migrate_legacy_documents.sql
```

Finally run the rollback-safe end-to-end test:

```sql
@13_smoke_test.sql
```

`00_install.sql` is intended for a clean installation. It is not a rerunnable upgrade script because base tables and sequences are created directly. The seed and migration scripts are idempotent.

## Runtime rules

- APEX calls packages; it does not update task, route, history, or status columns directly.
- Packages never commit. APEX owns the transaction and rolls back automatically when a process raises an error.
- A submitted route is a snapshot. Later master-data changes do not rewrite it.
- The current task is locked with `SELECT ... FOR UPDATE`, preventing double approval.
- History is insert-only. Documents, route snapshots, and tasks cannot be physically deleted.
- A review task can only point to a workflow task. Reviewers cannot create another review or advance the main route.
- `DF_DISTRIBUTION` accepts only `EMPLOYEE` or `DEPARTMENT`; external-person fields do not exist.
- Employee identifiers are `VARCHAR2(30)` to remain compatible with values such as `IPI-000831`.
- Department, unit/branch, company, and location identifiers are `NUMBER` and compatible with `EMPLOYEES`.
- Only active employees (`EMPLOYEES.STATUS = 1`) can be newly resolved as actors, reviewers, delegates, or employee recipients.

## Cumulative approval

`DF_APPROVAL_RULE` selects the most specific active policy by item, category, company, location, and unit. `DF_APPROVAL_RULE_STEP` stores ordered approval ceilings. Route building adds each authority until the first ceiling covering the document amount. A `NULL` ceiling is the unlimited final authority.

The included procurement sample is:

| Ceiling | Authority |
|---:|---|
| 10,000 | Department Head |
| 30,000 | Accounts Head |
| 50,000 | CFO |
| 100,000 | Concerned Executive Director |
| Unlimited | Managing Director |

The fixed procurement checks (department, item expert, and purchase head) are configured separately as workflow steps.

## Required configuration before go-live

1. If an APEX username differs from `EMPLOYEES.EMP_ID`, map that alias in `DF_APP_USER`. Direct active `EMP_ID` logins require no mapping row.
2. Verify department-specific `DEPT_HEAD` and `CONCERNED_ED` assignments.
3. Verify `PURCHASE_HEAD`, `ACCOUNTS_HEAD`, `CFO`, and `MANAGING_DIRECTOR` assignments.
4. Verify primary item experts by company, unit, and location.
5. Test rule specificity and approval ceilings using representative amounts.
6. Create the APEX authorization schemes and pages described in `APEX_PAGE_DESIGN.md`.
7. Revoke direct DML on transaction tables from any runtime account that is not the parsing schema.

The supplied `EMPLOYEES` DDL does not declare a primary key or unique constraint. The installer therefore does not create foreign keys to it, but the prerequisite script rejects duplicate active `EMP_ID` values. Add organization-approved indexes/constraints to `EMPLOYEES.ID` and `EMPLOYEES.EMP_ID` separately if they do not already exist in the live database.

## File map

- `00_hr_prerequisite.sql`: read-only validation of the `EMPLOYEES` contract
- `01_schema.sql`: tables, constraints, sequences, numeric organization IDs, optional code snapshots, indexes
- `02_triggers.sql`: audit and no-delete/no-nested-review safeguards
- `03_core_packages.sql`: immutable history and actor resolution/delegation
- `04_document_rule_packages.sql`: document editing, numbering, conditions, rule selection, route snapshot
- `05_workflow_package.sql`: submit, forward, recommend, approve, return, resubmit, reject, cancel
- `06_review_distribution_packages.sql`: one-level review and internal distribution
- `07_apex_views.sql`: security helpers and user-facing report views
- `08_seed_configuration.sql`: document types, workflows, roles, cumulative sample policy
- `09_apex_page_9999_processes.sql`: copy-ready Page 9999 and After Authentication process source
- `10_migrate_legacy_configuration.sql`: items, experts, heads, concerned ED assignments
- `11_migrate_legacy_documents.sql`: optional legacy header/L0-L12 migration
- `12_validate_install.sql`: compilation check
- `13_smoke_test.sql`: rollback-safe end-to-end verification
- `LEGACY_AUDIT.md`: findings from every supplied legacy table/procedure/trigger variant
