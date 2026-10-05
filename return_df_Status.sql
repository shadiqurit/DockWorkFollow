/* Formatted on 9/15/2025 5:03:26 PM (QP5 v5.362) */
CREATE OR REPLACE FUNCTION DBMIS.df_Status_Rejected_detail (
    p_empcode   VARCHAR2)
    RETURN VARCHAR2
IS
    vStatusDetail   VARCHAR2 (500);
BEGIN
    SELECT ' Your Document is Rejected By ' || E_NAME || ',' || DESIG_NAME
      INTO vStatusDetail
      FROM emp_v
     WHERE empcode = p_empcode;

    RETURN vStatusDetail;
END;
/

/* Formatted on 9/15/2025 5:03:21 PM (QP5 v5.362) */
CREATE OR REPLACE FUNCTION DBMIS.df_Status_Detail (p_empcode VARCHAR2)
    RETURN VARCHAR2
IS
    vStatusDetail   VARCHAR2 (500);
BEGIN
    SELECT    'Wating for Reporting Person (RP) - '
           || E_NAME
           || ','
           || DESIG_NAME
      INTO vStatusDetail
      FROM t_emp_v
     WHERE empcode = p_empcode;

    RETURN vStatusDetail;
END;
/

/* Formatted on 9/15/2025 5:03:32 PM (QP5 v5.362) */
CREATE OR REPLACE FUNCTION DBMIS.df_Status_Back_detail (p_empcode VARCHAR2)
    RETURN VARCHAR2
IS
    vStatusDetail   VARCHAR2 (500);
BEGIN
    SELECT 'Document is returned by ' || E_NAME || ',' || DESIG_NAME
      INTO vStatusDetail
      FROM t_emp_v
     WHERE empcode = p_empcode;

    RETURN vStatusDetail;
END;
/