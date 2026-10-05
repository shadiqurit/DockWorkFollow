# Legacy implementation audit

All supplied source files were reviewed before designing the replacement. No legacy file is changed by the new installer.

## Object conflicts and compile risks

- `DF_MASTER.sql` creates `DOC_FORWARDING`, then adds keys, a trigger, and a foreign key to `DF_MASTER`. A clean execution cannot produce the intended object set.
- `DF_FORWARDING_INS.sql` and `DF_FORWARDING_INS1.sql` replace the same procedure with different signatures (`P_SEQ` exists in one and is commented out in the other). Trigger copies call both variants in different files.
- `DF_FORWARD_T.sql`, `DF_FORWARD_T.trg`, `Trigger.sql`, and the trigger embedded in `DF_MASTER.sql` are divergent copies of the same business trigger.
- Some trigger versions reference `REVIEWERS` and `R_STATUS`, but those columns are absent from the supplied main-table DDL.
- `df_type.sql`, `Document Forward hrm.sql`, `df_datas.sql`, and `tablesData.sql` define or populate conflicting versions of `DF_TYPE`; type IDs do not consistently identify the same document type.

## Routing defects

- Approval actors and actions are fixed in L0–L12 columns, imposing a hard 13-actor limit and thousands of repeated branches.
- The trigger contains copy/paste defects; for example, one L5 branch builds status details from L4.
- Procurement selection hard-codes 50,000 in `DF_FORWARDING_INS*` instead of using `CS_RANGE_MASTER`.
- Category-3 output mapping selects legacy L1–L11 values into local L2–L12 variables, shifting the route.
- Route lookup does not consistently include company and location, although those fields exist in `DF_SEQUENCE`.
- `COUNT >= 1` is followed by a scalar `SELECT INTO`; multiple active matches can raise `TOO_MANY_ROWS`.
- The legacy unique constraint contains nullable scope columns, so Oracle null semantics still permit configurations that appear duplicated.

## Master-data issues

- `PUR_ITEM` stores the expert directly on the item and repeats item IDs across units. There is no effective dating, primary/backup priority, or location scope.
- `DEPAT_HEAD` joins by department name text and contains multiple Accounts head rows. The migration selects the highest legacy ID per department/unit and leaves final verification to the administrator.
- `CS_RANGE_MASTER`, `CS_AUTHORITY_LIST`, and `CS_APPROVAL_ED_LIST` contain useful policy/authority data but are not connected to the old runtime procedure.

## Transaction and audit issues

- Business transitions run implicitly from column updates in a row trigger. APEX cannot clearly distinguish validation, task completion, route advancement, and audit logging.
- There is no task row to lock, so double-click/double-submit protection is incomplete.
- Current state and history share the same row; comments/dates can be overwritten and the history is not immutable.
- Review ownership is represented by columns rather than an isolated temporary task, making return-to-requester semantics fragile.
- Return and reject behavior is repeated per level and is difficult to keep consistent.

## Replacement mapping

| Legacy | Replacement |
|---|---|
| `DF_TYPE` | `DF_DOCUMENT_TYPE` |
| `PUR_ITEM` | `DF_ITEM` + `DF_ITEM_EXPERT` |
| `DEPAT_HEAD` | `DF_ROLE_ASSIGNMENT` (`DEPT_HEAD`) |
| `CS_APPROVAL_ED_LIST` | `DF_ROLE_ASSIGNMENT` (`CONCERNED_ED`) |
| `DF_SEQUENCE` | `DF_WORKFLOW`, `DF_WORKFLOW_STEP`, approval rule tables |
| `DF_MASTER` / `DOC_FORWARDING` | `DF_DOCUMENT` plus version/purchase/attachment tables |
| L0–L12 state | `DF_DOCUMENT_ROUTE` + `DF_TASK` |
| L0–L12 comments/dates | immutable `DF_ACTION_HISTORY` |
| Reviewer columns | one-level `DF_TASK` with `TASK_TYPE='REVIEW'` |
| Post-approval forwarding | internal-only `DF_DISTRIBUTION` |

The rewritten migration resolves numeric organization scope through `EMPLOYEES`: legacy employee codes join to `EMPLOYEES.EMP_ID`, then use `DEPT_ID`, `BRANCH_ID`, `COM_ID`, and `LOC_ID`. Legacy text values are retained only in optional code columns.
