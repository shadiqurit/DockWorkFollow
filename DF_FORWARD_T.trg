/* Formatted on 10/6/2025 7:02:10 PM (QP5 v5.362) */
CREATE OR REPLACE TRIGGER DF_FORWARD_T
    BEFORE INSERT OR UPDATE OR DELETE
    ON DF_MASTER
    REFERENCING NEW AS NEW OLD AS OLD
    FOR EACH ROW
DECLARE
    v_hod_exists   NUMBER;
    v_status       VARCHAR2 (50);
    v_rempcode     VARCHAR2 (50);
BEGIN
    IF INSERTING
    THEN
        df_forwarding_ins (:NEW.TYPE_ID,
                           :NEW.CATEGORY_ID,
                           :NEW.ITEM_ID,
                           :NEW.ITEM_AMT,
                           :NEW.UNIT_ID,
                           :NEW.DEPT_ID,
                           :NEW.empcode,
                           p_SEQ           => :NEW.DF_SLNO,
                           p_L0_EMPCODE    => :NEW.L0_EMPCODE,
                           p_L1_EMPCODE    => :NEW.L1_EMPCODE,
                           p_L2_EMPCODE    => :NEW.L2_EMPCODE,
                           p_L3_EMPCODE    => :NEW.L3_EMPCODE,
                           p_L4_EMPCODE    => :NEW.L4_EMPCODE,
                           p_L5_EMPCODE    => :NEW.L5_EMPCODE,
                           p_L6_EMPCODE    => :NEW.L6_EMPCODE,
                           p_L7_EMPCODE    => :NEW.L7_EMPCODE,
                           p_L8_EMPCODE    => :NEW.L8_EMPCODE,
                           p_L9_EMPCODE    => :NEW.L9_EMPCODE,
                           p_L10_EMPCODE   => :NEW.L10_EMPCODE,
                           p_L11_EMPCODE   => :NEW.L11_EMPCODE,
                           p_L12_EMPCODE   => :NEW.L12_EMPCODE);

        IF :NEW.empcode = :NEW.L0_EMPCODE
        THEN
            :NEW.L0_empcode := NULL;
        END IF;

        IF :NEW.empcode = :NEW.L1_EMPCODE
        THEN
            :NEW.L1_empcode := NULL;
        END IF;

        IF :NEW.L0_empcode = :NEW.L1_empcode
        THEN
            :NEW.L1_empcode := NULL;
        END IF;

        IF :NEW.L0_empcode IS NOT NULL
        THEN
            :NEW.STATUS_SL := 0;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L0_EMPCODE);
        ELSIF :NEW.L1_EMPCODE IS NOT NULL
        THEN
            :NEW.STATUS_SL := 1;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L1_EMPCODE);
        ELSIF :NEW.L2_EMPCODE IS NOT NULL
        THEN
            :NEW.STATUS_SL := 2;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L2_EMPCODE);
        ELSIF :NEW.L3_EMPCODE IS NOT NULL
        THEN
            :NEW.STATUS_SL := 3;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L3_EMPCODE);
        ELSIF :NEW.L4_EMPCODE IS NOT NULL
        THEN
            :NEW.STATUS_SL := 4;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L4_EMPCODE);
        ELSIF :NEW.L5_EMPCODE IS NOT NULL
        THEN
            :NEW.STATUS_SL := 5;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L5_EMPCODE);
        ELSIF :NEW.L6_EMPCODE IS NOT NULL
        THEN
            :NEW.STATUS_SL := 6;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
        ELSIF :NEW.L7_EMPCODE IS NOT NULL
        THEN
            :NEW.STATUS_SL := 7;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
        ELSIF :NEW.L8_EMPCODE IS NOT NULL
        THEN
            :NEW.STATUS_SL := 8;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
        ELSIF :NEW.L9_EMPCODE IS NOT NULL
        THEN
            :NEW.STATUS_SL := 9;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
        ELSIF :NEW.L10_EMPCODE IS NOT NULL
        THEN
            :NEW.STATUS_SL := 10;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
        ELSIF :NEW.L11_EMPCODE IS NOT NULL
        THEN
            :NEW.STATUS_SL := 11;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
        ELSIF :NEW.L12_EMPCODE IS NOT NULL
        THEN
            :NEW.STATUS_SL := 12;
            :NEW.DF_STATUS := 'PENDING';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
        END IF;
    END IF;

    IF UPDATING ('REVIEWERS')
    THEN
        IF :NEW.REVIEWERS IS NOT NULL and :NEW.R_STATUS is null
        THEN
            :NEW.R_STATUS := 'Pending';
        END IF;
    ELSE
        NULL;
    END IF;


    IF UPDATING ('L0_TYPE')
    THEN
        IF :NEW.L0_TYPE = 'Forward'
        THEN
            :NEW.L0_DATE := SYSDATE;

            IF :NEW.L1_EMPCODE IS NOT NULL
            THEN
                :NEW.STATUS_SL := 1;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L1_EMPCODE);
            ELSIF :NEW.L2_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 2;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L2_EMPCODE);
            ELSIF :NEW.L3_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 3;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L3_EMPCODE);
            ELSIF :NEW.L4_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 4;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L4_EMPCODE);
            ELSIF :NEW.L5_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 5;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L4_EMPCODE);
            ELSIF :NEW.L6_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 6;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
            ELSIF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved Autohority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L1_TYPE')
    THEN
        IF :NEW.L1_TYPE = 'Forward'
        THEN
            :NEW.L1_DATE := SYSDATE;

            IF :NEW.L2_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 2;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L2_EMPCODE);
            ELSIF :NEW.L3_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 3;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L3_EMPCODE);
            ELSIF :NEW.L4_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 4;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L4_EMPCODE);
            ELSIF :NEW.L5_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 5;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L5_EMPCODE);
            ELSIF :NEW.L6_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 6;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
            ELSIF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L2_TYPE')
    THEN
        IF :NEW.L2_TYPE = 'Forward'
        THEN
            :NEW.L2_DATE := SYSDATE;

            IF :NEW.L3_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 3;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L3_EMPCODE);
            ELSIF :NEW.L4_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 4;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L4_EMPCODE);
            ELSIF :NEW.L5_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 5;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L5_EMPCODE);
            ELSIF :NEW.L6_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 6;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
            ELSIF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L3_TYPE')
    THEN
        IF :NEW.L3_TYPE = 'Forward'
        THEN
            :NEW.L3_DATE := SYSDATE;

            IF :NEW.L4_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 4;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L4_EMPCODE);
            ELSIF :NEW.L5_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 5;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L5_EMPCODE);
            ELSIF :NEW.L6_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 6;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
            ELSIF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L4_TYPE')
    THEN
        IF :NEW.L4_TYPE = 'Forward'
        THEN
            :NEW.L4_DATE := SYSDATE;

            IF :NEW.L5_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 5;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L5_EMPCODE);
            ELSIF :NEW.L6_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 6;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
            ELSIF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L5_TYPE')
    THEN
        IF :NEW.L5_TYPE = 'Forward'
        THEN
            :NEW.L5_DATE := SYSDATE;

            IF :NEW.L6_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 6;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
            ELSIF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L6_TYPE')
    THEN
        IF :NEW.L6_TYPE = 'Forward'
        THEN
            :NEW.L6_DATE := SYSDATE;

            IF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L7_TYPE')
    THEN
        IF :NEW.L7_TYPE = 'Forward'
        THEN
            :NEW.L7_DATE := SYSDATE;

            IF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L8_TYPE')
    THEN
        IF :NEW.L8_TYPE = 'Forward'
        THEN
            :NEW.L8_DATE := SYSDATE;

            IF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L9_TYPE')
    THEN
        IF :NEW.L9_TYPE = 'Forward'
        THEN
            :NEW.L9_DATE := SYSDATE;

            IF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L10_TYPE')
    THEN
        IF :NEW.L10_TYPE = 'Forward'
        THEN
            :NEW.L10_DATE := SYSDATE;

            IF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L11_TYPE')
    THEN
        IF :NEW.L11_TYPE = 'Forward'
        THEN
            :NEW.L11_DATE := SYSDATE;

            IF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approve by Authority';
            END IF;
        END IF;
    END IF;


    IF UPDATING ('L12_TYPE')
    THEN
        IF :NEW.L12_TYPE = 'Forward'
        THEN
            :NEW.L12_DATE := SYSDATE;

            :NEW.STATUS_SL := 100;
            :NEW.DF_STATUS := 'APPROVE';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
        END IF;
    END IF;



    IF UPDATING ('L0_TYPE')
    THEN
        IF :NEW.L0_TYPE = 'Approved'
        THEN
            :NEW.L0_DATE := SYSDATE;

            IF :NEW.L1_EMPCODE IS NOT NULL
            THEN
                :NEW.STATUS_SL := 1;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L1_EMPCODE);
            ELSIF :NEW.L2_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 2;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L2_EMPCODE);
            ELSIF :NEW.L3_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 3;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L3_EMPCODE);
            ELSIF :NEW.L4_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 4;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L4_EMPCODE);
            ELSIF :NEW.L5_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 5;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L4_EMPCODE);
            ELSIF :NEW.L6_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 6;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
            ELSIF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved Autohority';
            END IF;
        END IF;
    END IF;



    IF UPDATING ('L1_TYPE')
    THEN
        IF :NEW.L1_TYPE = 'Approved'
        THEN
            :NEW.L1_DATE := SYSDATE;

            IF :NEW.L2_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 2;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L2_EMPCODE);
            ELSIF :NEW.L3_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 3;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L3_EMPCODE);
            ELSIF :NEW.L4_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 4;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L4_EMPCODE);
            ELSIF :NEW.L5_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 5;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L5_EMPCODE);
            ELSIF :NEW.L6_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 6;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
            ELSIF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L2_TYPE')
    THEN
        IF :NEW.L2_TYPE = 'Approved'
        THEN
            :NEW.L2_DATE := SYSDATE;

            IF :NEW.L3_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 3;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L3_EMPCODE);
            ELSIF :NEW.L4_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 4;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L4_EMPCODE);
            ELSIF :NEW.L5_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 5;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L5_EMPCODE);
            ELSIF :NEW.L6_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 6;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
            ELSIF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;


    IF UPDATING ('L3_TYPE')
    THEN
        IF :NEW.L3_TYPE = 'Approved'
        THEN
            :NEW.L3_DATE := SYSDATE;

            IF :NEW.L4_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 4;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L4_EMPCODE);
            ELSIF :NEW.L5_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 5;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L5_EMPCODE);
            ELSIF :NEW.L6_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 6;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
            ELSIF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L4_TYPE')
    THEN
        IF :NEW.L4_TYPE = 'Approved'
        THEN
            :NEW.L4_DATE := SYSDATE;

            IF :NEW.L5_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 5;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L5_EMPCODE);
            ELSIF :NEW.L6_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 6;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
            ELSIF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L5_TYPE')
    THEN
        IF :NEW.L5_TYPE = 'Approved'
        THEN
            :NEW.L5_DATE := SYSDATE;

            IF :NEW.L6_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 6;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L6_EMPCODE);
            ELSIF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;


    IF UPDATING ('L6_TYPE')
    THEN
        IF :NEW.L6_TYPE = 'Approved'
        THEN
            :NEW.L6_DATE := SYSDATE;

            IF :NEW.L7_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 7;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L7_EMPCODE);
            ELSIF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L7_TYPE')
    THEN
        IF :NEW.L7_TYPE = 'Approved'
        THEN
            :NEW.L7_DATE := SYSDATE;

            IF :NEW.L8_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 8;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L8_EMPCODE);
            ELSIF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by authority';
            END IF;
        END IF;
    END IF;


    IF UPDATING ('L8_TYPE')
    THEN
        IF :NEW.L8_TYPE = 'Approved'
        THEN
            :NEW.L8_DATE := SYSDATE;

            IF :NEW.L9_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 9;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L9_EMPCODE);
            ELSIF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;


    IF UPDATING ('L9_TYPE')
    THEN
        IF :NEW.L9_TYPE = 'Approved'
        THEN
            :NEW.L9_DATE := SYSDATE;

            IF :NEW.L10_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 10;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L10_EMPCODE);
            ELSIF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L10_TYPE')
    THEN
        IF :NEW.L10_TYPE = 'Approved'
        THEN
            :NEW.L10_DATE := SYSDATE;

            IF :NEW.L11_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 11;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L11_EMPCODE);
            ELSIF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approved by Authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L11_TYPE')
    THEN
        IF :NEW.L11_TYPE = 'Approved'
        THEN
            :NEW.L11_DATE := SYSDATE;

            IF :NEW.L12_empcode IS NOT NULL
            THEN
                :NEW.STATUS_SL := 12;
                :NEW.DF_STATUS := 'PENDING';
                :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
            ELSE
                :NEW.STATUS_SL := 100;
                :NEW.DF_STATUS := 'APPROVE';
                :NEW.STATUS_DETAILS := 'Finaly Approve by Authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('L12_TYPE')
    THEN
        IF :NEW.L12_TYPE = 'Approved'
        THEN
            :NEW.L12_DATE := SYSDATE;

            :NEW.STATUS_SL := 100;
            :NEW.DF_STATUS := 'APPROVE';
            :NEW.STATUS_DETAILS := df_Status_Detail (:NEW.L12_EMPCODE);
        END IF;
    END IF;



    -- REVIEW Logic for L0_TYPE

    IF UPDATING ('L0_TYPE')
    THEN
        IF :NEW.L0_TYPE = 'Review'
        THEN
            :NEW.L0_DATE := SYSDATE;
            :NEW.DF_STATUS := 'Pending';

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            END IF;
        END IF;
    END IF;



    -- REVIEW Logic for L1_TYPE

    IF UPDATING ('L1_TYPE')
    THEN
        IF :NEW.L1_TYPE = 'Review'
        THEN
            :NEW.L1_DATE := SYSDATE;

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            END IF;
        END IF;
    END IF;


    -- REVIEW Logic for L2_TYPE

    IF UPDATING ('L2_TYPE')
    THEN
        IF :NEW.L2_TYPE = 'Review'
        THEN
            :NEW.L2_DATE := SYSDATE;

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            --            ELSIF :NEW.R_STATUS = 'Reviewed'
            --            THEN
            --                :NEW.STATUS_DETAILS :=
            --                    df_Status_review_done (:NEW.L2_EMPCODE);
            END IF;
        END IF;
    END IF;


    -- REVIEW Logic for L3_TYPE

    IF UPDATING ('L3_TYPE')
    THEN
        IF :NEW.L3_TYPE = 'Review'
        THEN
            :NEW.L3_DATE := SYSDATE;

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            END IF;
        END IF;
    END IF;


    -- REVIEW Logic for L4_TYPE

    IF UPDATING ('L4_TYPE')
    THEN
        IF :NEW.L4_TYPE = 'Review'
        THEN
            :NEW.L4_DATE := SYSDATE;

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            END IF;
        END IF;
    END IF;


    -- REVIEW Logic for L5_TYPE

    IF UPDATING ('L5_TYPE')
    THEN
        IF :NEW.L5_TYPE = 'Review'
        THEN
            :NEW.L5_DATE := SYSDATE;

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            END IF;
        END IF;
    END IF;


    -- REVIEW Logic for L6_TYPE

    IF UPDATING ('L6_TYPE')
    THEN
        IF :NEW.L6_TYPE = 'Review'
        THEN
            :NEW.L6_DATE := SYSDATE;

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            END IF;
        END IF;
    END IF;


    -- REVIEW Logic for L7_TYPE

    IF UPDATING ('L7_TYPE')
    THEN
        IF :NEW.L7_TYPE = 'Review'
        THEN
            :NEW.L7_DATE := SYSDATE;

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            END IF;
        END IF;
    END IF;


    -- REVIEW Logic for L8_TYPE

    IF UPDATING ('L8_TYPE')
    THEN
        IF :NEW.L8_TYPE = 'Review'
        THEN
            :NEW.L8_DATE := SYSDATE;

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            END IF;
        END IF;
    END IF;


    -- REVIEW Logic for L9_TYPE

    IF UPDATING ('L9_TYPE')
    THEN
        IF :NEW.L9_TYPE = 'Review'
        THEN
            :NEW.L9_DATE := SYSDATE;

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            END IF;
        END IF;
    END IF;


    -- REVIEW Logic for L10_TYPE

    IF UPDATING ('L10_TYPE')
    THEN
        IF :NEW.L10_TYPE = 'Review'
        THEN
            :NEW.L10_DATE := SYSDATE;

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            END IF;
        END IF;
    END IF;


    -- REVIEW Logic for L11_TYPE

    IF UPDATING ('L11_TYPE')
    THEN
        IF :NEW.L11_TYPE = 'Review'
        THEN
            :NEW.L11_DATE := SYSDATE;

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            END IF;
        END IF;
    END IF;


    -- REVIEW Logic for L12_TYPE

    IF UPDATING ('L12_TYPE')
    THEN
        IF :NEW.L12_TYPE = 'Review'
        THEN
            :NEW.L12_DATE := SYSDATE;

            IF :NEW.R_STATUS = 'Pending'
            THEN
                :NEW.STATUS_DETAILS := df_Status_review (:NEW.REVIEWERS);
            END IF;
        END IF;
    END IF;

    IF UPDATING ('R_STATUS')
    THEN
        IF :NEW.L0_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L0_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L0_EMPCODE);
            END IF;
        END IF;

        IF :NEW.L1_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L1_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L1_EMPCODE);
            END IF;
        END IF;


        IF :NEW.L2_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L2_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L2_EMPCODE);
            END IF;
        END IF;

        IF :NEW.L3_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L3_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L3_EMPCODE);
            END IF;
        END IF;

        IF :NEW.L4_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L4_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L4_EMPCODE);
            END IF;
        END IF;

        IF :NEW.L5_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L5_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L5_EMPCODE);
            END IF;
        END IF;

        IF :NEW.L6_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L6_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L6_EMPCODE);
            END IF;
        END IF;

        IF :NEW.L7_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L7_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L7_EMPCODE);
            END IF;
        END IF;

        IF :NEW.L8_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L8_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L8_EMPCODE);
            END IF;
        END IF;

        IF :NEW.L9_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L9_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L9_EMPCODE);
            END IF;
        END IF;

        IF :NEW.L10_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L10_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L10_EMPCODE);
            END IF;
        END IF;

        IF :NEW.L11_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L11_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L11_EMPCODE);
            END IF;
        END IF;

        IF :NEW.L12_TYPE = 'Review'
        THEN
            IF :NEW.R_STATUS = 'Reviewed'
            THEN
                :NEW.L12_COMMENT := NULL;
                :NEW.STATUS_DETAILS :=
                    df_Status_review_done (:NEW.L12_EMPCODE);
            END IF;
        END IF;
    END IF;

    -- REVIEW     logic    END


    IF UPDATING ('L0_TYPE')
    THEN
        IF :NEW.L0_TYPE = 'Reject'
        THEN
            :NEW.L0_DATE := SYSDATE;

            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L0_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L1_TYPE')
    THEN
        IF :NEW.L1_TYPE = 'Reject'
        THEN
            :NEW.L1_DATE := SYSDATE;
            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L1_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L2_TYPE')
    THEN
        IF :NEW.L2_TYPE = 'Reject'
        THEN
            :NEW.L2_DATE := SYSDATE;
            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L2_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L3_TYPE')
    THEN
        IF :NEW.L3_TYPE = 'Reject'
        THEN
            :NEW.L3_DATE := SYSDATE;
            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L3_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L4_TYPE')
    THEN
        IF :NEW.L4_TYPE = 'Reject'
        THEN
            :NEW.L4_DATE := SYSDATE;
            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L4_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L5_TYPE')
    THEN
        IF :NEW.L5_TYPE = 'Reject'
        THEN
            :NEW.L5_DATE := SYSDATE;
            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L5_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L6_TYPE')
    THEN
        IF :NEW.L6_TYPE = 'Reject'
        THEN
            :NEW.L6_DATE := SYSDATE;
            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L6_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L7_TYPE')
    THEN
        IF :NEW.L7_TYPE = 'Reject'
        THEN
            :NEW.L7_DATE := SYSDATE;

            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L7_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L8_TYPE')
    THEN
        IF :NEW.L8_TYPE = 'Reject'
        THEN
            :NEW.L8_DATE := SYSDATE;
            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L8_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L9_TYPE')
    THEN
        IF :NEW.L9_TYPE = 'Reject'
        THEN
            :NEW.L9_DATE := SYSDATE;
            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L9_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L10_TYPE')
    THEN
        IF :NEW.L10_TYPE = 'Reject'
        THEN
            :NEW.L10_DATE := SYSDATE;
            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L10_EMPCODE);
        END IF;
    END IF;

    IF UPDATING ('L11_TYPE')
    THEN
        IF :NEW.L11_TYPE = 'Reject'
        THEN
            :NEW.L11_DATE := SYSDATE;
            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L11_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L12_TYPE')
    THEN
        IF :NEW.L12_TYPE = 'Reject'
        THEN
            :NEW.L12_DATE := SYSDATE;
            :NEW.STATUS_SL := 99;
            :NEW.DF_STATUS := 'Rejected';
            :NEW.STATUS_DETAILS :=
                df_Status_Rejected_detail (:NEW.L12_EMPCODE);
        END IF;
    END IF;



    IF UPDATING ('L0_TYPE')
    THEN
        IF :NEW.L0_TYPE = 'Return'
        THEN
            :NEW.L0_DATE := SYSDATE;
            :NEW.L0_TYPE := NULL;

            :NEW.STATUS_SL := NULL;
            :NEW.L0_TYPE := NULL;
            :NEW.DF_STATUS := 'Returned';
            :NEW.STATUS_DETAILS := df_Status_BACK_detail (:NEW.L0_EMPCODE);
        END IF;
    END IF;



    IF UPDATING ('L1_TYPE')
    THEN
        IF :NEW.L1_TYPE = 'Return'
        THEN
            :NEW.L1_DATE := SYSDATE;
            :NEW.L1_TYPE := NULL;

            :NEW.STATUS_SL := 0;
            :NEW.DF_STATUS := 'Return';
            :NEW.STATUS_DETAILS := df_Status_BACK_detail (:NEW.L1_EMPCODE);
        END IF;
    END IF;

    IF UPDATING ('L2_TYPE')
    THEN
        IF :NEW.L2_TYPE = 'Return'
        THEN
            :NEW.L2_DATE := SYSDATE;
            :NEW.L1_TYPE := NULL;


            :NEW.STATUS_SL := 1;
            :NEW.DF_STATUS := 'Returned';
            :NEW.STATUS_DETAILS := df_Status_Back_detail (:NEW.L1_EMPCODE);
        END IF;
    END IF;

    IF UPDATING ('L3_TYPE')
    THEN
        IF :NEW.L3_TYPE = 'Return'
        THEN
            :NEW.L3_DATE := SYSDATE;
            :NEW.L3_TYPE := NULL;

            :NEW.STATUS_SL := 2;
            :NEW.DF_STATUS := 'Returned';
            :NEW.STATUS_DETAILS := df_Status_Back_detail (:NEW.L2_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L4_TYPE')
    THEN
        IF :NEW.L4_TYPE = 'Return'
        THEN
            :NEW.L4_DATE := SYSDATE;
            :NEW.L4_TYPE := NULL;


            :NEW.STATUS_SL := 3;
            :NEW.DF_STATUS := 'Returned';
            :NEW.STATUS_DETAILS := df_Status_Back_detail (:NEW.L3_EMPCODE);
        END IF;
    END IF;

    IF UPDATING ('L5_TYPE')
    THEN
        IF :NEW.L5_TYPE = 'Return'
        THEN
            :NEW.L5_DATE := SYSDATE;

            :NEW.L5_TYPE := NULL;
            :NEW.STATUS_SL := 5;
            :NEW.DF_STATUS := 'Return';
            :NEW.STATUS_DETAILS := df_Status_Back_detail (:NEW.L6_EMPCODE);
        END IF;
    END IF;

    IF UPDATING ('L7_TYPE')
    THEN
        IF :NEW.L7_TYPE = 'Return'
        THEN
            :NEW.L7_DATE := SYSDATE;

            :NEW.L7_TYPE := NULL;
            :NEW.STATUS_SL := 6;
            :NEW.DF_STATUS := 'Returned';

            :NEW.STATUS_DETAILS := df_Status_Back_detail (:NEW.L8_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L8_TYPE')
    THEN
        IF :NEW.L8_TYPE = 'Return'
        THEN
            :NEW.L8_DATE := SYSDATE;
            :NEW.L8_TYPE := NULL;

            :NEW.STATUS_SL := 7;
            :NEW.DF_STATUS := 'Returned';
            :NEW.STATUS_DETAILS := df_Status_Back_detail (:NEW.L9_EMPCODE);
        END IF;
    END IF;


    IF UPDATING ('L9_TYPE')
    THEN
        IF :NEW.L9_TYPE = 'Return'
        THEN
            :NEW.L9_DATE := SYSDATE;

            :NEW.L9_TYPE := NULL;
            :NEW.STATUS_SL := 8;
            :NEW.DF_STATUS := 'Returned';
            :NEW.STATUS_DETAILS := df_Status_Back_detail (:NEW.L10_EMPCODE);
        END IF;
    END IF;

    IF UPDATING ('L10_TYPE')
    THEN
        IF :NEW.L10_TYPE = 'Return'
        THEN
            :NEW.L10_DATE := SYSDATE;
            :NEW.L10_TYPE := NULL;

            :NEW.STATUS_SL := 9;
            :NEW.DF_STATUS := 'Returned';
            :NEW.STATUS_DETAILS := df_Status_Back_detail (:NEW.L11_EMPCODE);
        END IF;
    END IF;

    IF UPDATING ('L11_TYPE')
    THEN
        IF :NEW.L11_TYPE = 'Return'
        THEN
            :NEW.L11_TYPE := NULL;
            :NEW.L11_DATE := SYSDATE;

            :NEW.STATUS_SL := 10;
            :NEW.DF_STATUS := 'Returned';
            :NEW.STATUS_DETAILS := df_Status_Back_detail (:NEW.L11_EMPCODE);
        END IF;
    END IF;

    IF UPDATING ('L12_TYPE')
    THEN
        IF :NEW.L12_TYPE = 'Return'
        THEN
            :NEW.L12_DATE := SYSDATE;
            :NEW.L12_TYPE := NULL;

            :NEW.STATUS_SL := 11;
            :NEW.DF_STATUS := 'Returned';
            :NEW.STATUS_DETAILS := df_Status_Back_detail (:NEW.L12_EMPCODE);
        END IF;
    END IF;
END;
/

SHOW ERRORS;
/