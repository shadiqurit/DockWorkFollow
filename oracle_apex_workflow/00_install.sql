-- Run from SQLcl, SQL*Plus, or APEX SQL Scripts as the application owner.
-- Oracle Database 19c+. Existing legacy objects are not dropped or modified.

set define off
set serveroutput on
whenever sqlerror exit sql.sqlcode rollback

prompt [1/10] EMPLOYEES prerequisite
@@00_hr_prerequisite.sql
prompt [2/10] Schema objects
@@01_schema.sql
prompt [3/10] Safety and audit triggers
@@02_triggers.sql
prompt [4/10] History and actor packages
@@03_core_packages.sql
prompt [5/10] Document and rule packages
@@04_document_rule_packages.sql
prompt [6/10] Workflow package
@@05_workflow_package.sql
prompt [7/10] Review and distribution packages
@@06_review_distribution_packages.sql
prompt [8/10] APEX/reporting views
@@07_apex_views.sql
prompt [9/10] Seed configuration
@@08_seed_configuration.sql
prompt [10/10] Compile validation
@@12_validate_install.sql

prompt Installation completed successfully.
