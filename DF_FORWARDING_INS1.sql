CREATE OR REPLACE PROCEDURE DBMIS.df_forwarding_ins (p_type_id           NUMBER,
                                               p_categroy          NUMBER,
                                               p_item_id           NUMBER,
                                               p_item_amt          NUMBER,
                                               p_unit_id           VARCHAR2,
                                               p_dept_id           VARCHAR2,
                                               p_empcode           VARCHAR2,
                                             --  p_seq           OUT NUMBER,
                                               p_l0_empcode    OUT VARCHAR2,
                                               p_l1_empcode    OUT VARCHAR2,
                                               p_l2_empcode    OUT VARCHAR2,
                                               p_l3_empcode    OUT VARCHAR2,
                                               p_l4_empcode    OUT VARCHAR2,
                                               p_l5_empcode    OUT VARCHAR2,
                                               p_l6_empcode    OUT VARCHAR2,
                                               p_l7_empcode    OUT VARCHAR2,
                                               p_l8_empcode    OUT VARCHAR2,
                                               p_l9_empcode    OUT VARCHAR2,
                                               p_l10_empcode   OUT VARCHAR2,
                                               p_l11_empcode   OUT VARCHAR2,
                                               p_l12_empcode   OUT VARCHAR2)
IS
    v_sq_id         NUMBER;
    v_l0_empcode    VARCHAR2 (30);
    v_l1_empcode    VARCHAR2 (30);
    v_l2_empcode    VARCHAR2 (30);
    v_l3_empcode    VARCHAR2 (30);
    v_l4_empcode    VARCHAR2 (30);
    v_l5_empcode    VARCHAR2 (30);
    v_l6_empcode    VARCHAR2 (30);
    v_l7_empcode    VARCHAR2 (30);
    v_l8_empcode    VARCHAR2 (30);
    v_l9_empcode    VARCHAR2 (30);
    v_l10_empcode   VARCHAR2 (30);
    v_l11_empcode   VARCHAR2 (30);
    v_l12_empcode   VARCHAR2 (30);
    v_department    VARCHAR2 (150);
    v_unit          VARCHAR2 (100);
    v_item_amt      NUMBER;
    v_exit          NUMBER;
    v_categroy      NUMBER;
BEGIN
    SELECT DISTINCT category_id
      INTO v_categroy
      FROM df_sequence
     WHERE     type_id = p_type_id
           AND category_id = p_categroy
           AND unit_id = p_unit_id;


    SELECT a.empcode, b.department_name
      INTO v_l0_empcode, v_department
      FROM depat_head a, t_emp_v b
     WHERE     a.empcode = b.empcode
           AND a.dept_name = (SELECT c.department_name
                                FROM t_emp_v c
                               WHERE c.empcode = p_empcode);


    IF v_categroy = 1
    THEN
        SELECT COUNT (*)
          INTO v_exit
          FROM df_sequence a
         WHERE     a.type_id = p_type_id
               AND UPPER (a.unit_id) = UPPER (p_unit_id)
               AND a.category_id = p_categroy
               AND UPPER (NVL (a.is_active, 'N')) = 'Y';

        IF v_exit = 1
        THEN
            SELECT a.sq_id,
                   a.l1_empcode,
                   a.l2_empcode,
                   a.l3_empcode,
                   a.l4_empcode,
                   a.l5_empcode,
                   a.l6_empcode,
                   a.l7_empcode,
                   a.l8_empcode,
                   a.l9_empcode,
                   a.l10_empcode,
                   a.l11_empcode,
                   a.l12_empcode
              INTO v_sq_id,
                   v_l1_empcode,
                   v_l2_empcode,
                   v_l3_empcode,
                   v_l4_empcode,
                   v_l5_empcode,
                   v_l6_empcode,
                   v_l7_empcode,
                   v_l8_empcode,
                   v_l9_empcode,
                   v_l10_empcode,
                   v_l11_empcode,
                   v_l12_empcode
              FROM df_sequence a
             WHERE     a.type_id = p_type_id
                   AND UPPER (a.unit_id) = UPPER (p_unit_id)
                   AND category_id = p_categroy
                   AND UPPER (NVL (a.is_active, 'N')) = 'Y';
        END IF;
    END IF;

    IF v_categroy = 2
    THEN
        SELECT COUNT (*)
          INTO v_exit
          FROM df_sequence a
         WHERE     a.type_id = p_type_id
               AND UPPER (a.unit_id) = UPPER (p_unit_id)
               AND a.category_id = p_categroy
               AND a.dept_id = p_dept_id
               AND UPPER (NVL (a.is_active, 'N')) = 'Y';

        IF v_exit = 1
        THEN
            SELECT a.sq_id,
                   a.l1_empcode,
                   a.l2_empcode,
                   a.l3_empcode,
                   a.l4_empcode,
                   a.l5_empcode,
                   a.l6_empcode,
                   a.l7_empcode,
                   a.l8_empcode,
                   a.l9_empcode,
                   a.l10_empcode,
                   a.l11_empcode,
                   a.l12_empcode
              INTO v_sq_id,
                   v_l1_empcode,
                   v_l2_empcode,
                   v_l3_empcode,
                   v_l4_empcode,
                   v_l5_empcode,
                   v_l6_empcode,
                   v_l7_empcode,
                   v_l8_empcode,
                   v_l9_empcode,
                   v_l10_empcode,
                   v_l11_empcode,
                   v_l12_empcode
              FROM df_sequence a
             WHERE     a.type_id = p_type_id
                   AND UPPER (a.unit_id) = UPPER (p_unit_id)
                   AND category_id = p_categroy
                   AND a.dept_id = p_dept_id
                   AND UPPER (NVL (a.is_active, 'N')) = 'Y';
        END IF;
    END IF;

    IF v_categroy = 3
    THEN
        SELECT COUNT (*)
          INTO v_exit
          FROM df_sequence a
         WHERE     a.type_id = p_type_id
               AND UPPER (a.unit_id) = UPPER (p_unit_id)
               AND a.category_id = p_categroy
               AND a.item_id = p_item_id
               AND UPPER (NVL (a.is_active, 'N')) = 'Y';

        --        SELECT empcode
        --          INTO v_l1_empcode
        --          FROM depat_head
        --         WHERE dept_name =
        --               (SELECT dept_name
        --                  FROM pur_item
        --                 WHERE     item_id = p_item_id
        --                       AND UPPER (unitid) = UPPER (p_unit_id));



        IF v_exit >= 1 AND p_item_amt >= 50000
        THEN
            SELECT a.sq_id,
                   a.l1_empcode,
                   a.l2_empcode,
                   a.l3_empcode,
                   a.l4_empcode,
                   a.l5_empcode,
                   a.l6_empcode,
                   a.l7_empcode,
                   a.l8_empcode,
                   a.l9_empcode,
                   a.l10_empcode,
                   a.l11_empcode
              INTO v_sq_id,
                   v_l2_empcode,
                   v_l3_empcode,
                   v_l4_empcode,
                   v_l5_empcode,
                   v_l6_empcode,
                   v_l7_empcode,
                   v_l8_empcode,
                   v_l9_empcode,
                   v_l10_empcode,
                   v_l11_empcode,
                   v_l12_empcode
              FROM df_sequence a
             WHERE     a.type_id = p_type_id
                   AND UPPER (a.unit_id) = UPPER (p_unit_id)
                   AND category_id = p_categroy
                   AND item_id = p_item_id
                   AND NVL (item_amt, 0) >= 50000
                   AND UPPER (NVL (a.is_active, 'N')) = 'Y';
        ELSE
            SELECT a.sq_id,
                   a.l1_empcode,
                   a.l2_empcode,
                   a.l3_empcode,
                   a.l4_empcode,
                   a.l5_empcode,
                   a.l6_empcode,
                   a.l7_empcode,
                   a.l8_empcode,
                   a.l9_empcode,
                   a.l10_empcode,
                   a.l11_empcode
              INTO v_sq_id,
                   v_l2_empcode,
                   v_l3_empcode,
                   v_l4_empcode,
                   v_l5_empcode,
                   v_l6_empcode,
                   v_l7_empcode,
                   v_l8_empcode,
                   v_l9_empcode,
                   v_l10_empcode,
                   v_l11_empcode,
                   v_l12_empcode
              FROM df_sequence a
             WHERE     a.type_id = p_type_id
                   AND UPPER (a.unit_id) = UPPER (p_unit_id)
                   AND category_id = p_categroy
                   AND item_id = p_item_id
                   AND NVL (item_amt, 0) < 50000
                   AND UPPER (NVL (a.is_active, 'N')) = 'Y';
        END IF;
    END IF;


  --  p_seq := v_sq_id;
    p_l0_empcode := UPPER (v_l0_empcode);
    p_l1_empcode := UPPER (v_l1_empcode);
    p_l2_empcode := UPPER (v_l2_empcode);
    p_l3_empcode := UPPER (v_l3_empcode);
    p_l4_empcode := UPPER (v_l4_empcode);
    p_l5_empcode := UPPER (v_l5_empcode);
    p_l6_empcode := UPPER (v_l6_empcode);
    p_l7_empcode := UPPER (v_l7_empcode);
    p_l8_empcode := UPPER (v_l8_empcode);
    p_l9_empcode := UPPER (v_l9_empcode);
    p_l10_empcode := UPPER (v_l10_empcode);
    p_l11_empcode := UPPER (v_l11_empcode);
    p_l12_empcode := UPPER (v_l12_empcode);
EXCEPTION
    -- catches all 'no data found' errors
    WHEN NO_DATA_FOUND
    THEN
        RAISE;
END;
/
