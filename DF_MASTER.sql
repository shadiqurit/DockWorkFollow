/* Formatted on 9/15/2025 3:00:06 PM (QP5 v5.362) */
CREATE TABLE doc_forwarding
(
    df_slno           NUMBER (15),
    df_tran_no        VARCHAR2 (25 BYTE),
    type_id           NUMBER (15),
    empcode           VARCHAR2 (15 BYTE),
    df_tite           VARCHAR2 (200 BYTE),
    unit_id           VARCHAR2 (15 BYTE),
    dept_id           VARCHAR2 (200 BYTE),
    sq_id             NUMBER (15),
    df_tran_date      DATE NOT NULL,
    df_status         VARCHAR2 (50 BYTE), 
    category_id       NUMBER,  -- Purchase or General 
    item_id           NUMBER,  --For Procurement Doc
    item_amt          NUMBER,  --For Procurement Doc
    l0_empcode        VARCHAR2 (15 BYTE),
    l1_empcode        VARCHAR2 (15 BYTE),
    l2_empcode        VARCHAR2 (15 BYTE),
    l3_empcode        VARCHAR2 (15 BYTE),
    l4_empcode        VARCHAR2 (15 BYTE),
    l5_empcode        VARCHAR2 (15 BYTE),
    l6_empcode        VARCHAR2 (15 BYTE),
    l7_empcode        VARCHAR2 (15 BYTE),
    l8_empcode        VARCHAR2 (15 BYTE),
    l9_empcode        VARCHAR2 (15 BYTE),
    l10_empcode       VARCHAR2 (15 BYTE),
    l11_empcode       VARCHAR2 (15 BYTE),
    l12_empcode       VARCHAR2 (15 BYTE),
    l0_comment        VARCHAR2 (300 BYTE),
    l1_comment        VARCHAR2 (300 BYTE),
    l2_comment        VARCHAR2 (300 BYTE),
    l3_comment        VARCHAR2 (300 BYTE),
    l4_comment        VARCHAR2 (300 BYTE),
    l5_comment        VARCHAR2 (300 BYTE),
    l6_comment        VARCHAR2 (300 BYTE),
    l7_comment        VARCHAR2 (300 BYTE),
    l8_comment        VARCHAR2 (300 BYTE),
    l9_comment        VARCHAR2 (300 BYTE),
    l10_comment       VARCHAR2 (300 BYTE),
    l11_comment       VARCHAR2 (300 BYTE),
    l12_comment       VARCHAR2 (300 BYTE),
    l0_type           VARCHAR2 (15 BYTE),
    l1_type           VARCHAR2 (15 BYTE),
    l2_type           VARCHAR2 (15 BYTE),
    l3_type           VARCHAR2 (15 BYTE),
    l4_type           VARCHAR2 (15 BYTE),
    l5_type           VARCHAR2 (15 BYTE),
    l6_type           VARCHAR2 (15 BYTE),
    l7_type           VARCHAR2 (15 BYTE),
    l8_type           VARCHAR2 (15 BYTE),
    l9_type           VARCHAR2 (15 BYTE),
    l10_type          VARCHAR2 (15 BYTE),
    l11_type          VARCHAR2 (15 BYTE),
    l12_type          VARCHAR2 (15 BYTE),
    l0_date           DATE,
    l1_date           DATE,
    l2_date           DATE,
    l3_date           DATE,
    l4_date           DATE,
    l5_date           DATE,
    l6_date           DATE,
    l7_date           DATE,
    l8_date           DATE,
    l9_date           DATE,
    l10_date          DATE,
    l11_date          DATE,
    l12_date          DATE,
    status_sl         NUMBER,
    status_details    VARCHAR2 (1000 BYTE),
    df_detail         CLOB,
    ent_by            VARCHAR2 (20 BYTE),
    ent_date          DATE,
    upd_by            VARCHAR2 (30 BYTE),
    upd_date          DATE
);


ALTER TABLE df_master
    ADD (
        CONSTRAINT pk_dfm PRIMARY KEY (df_slno),
        CONSTRAINT uk_dfm UNIQUE (df_tran_no)
            USING INDEX uk_dfm ENABLE VALIDATE);


CREATE OR REPLACE TRIGGER df_forward_t
    BEFORE INSERT OR UPDATE OR DELETE
    ON df_master
    REFERENCING NEW AS new OLD AS old
    FOR EACH ROW
DECLARE
    v_hod_exists   NUMBER;
BEGIN
    IF INSERTING
    THEN
        df_forwarding_ins (:new.type_id,
                           :new.category_id,
                           :new.item_id,
                           :new.item_amt,
                           :new.unit_id,
                           :new.dept_id,
                           :new.empcode,
                           p_seq           => :new.sq_id,
                           p_l0_empcode    => :new.l0_empcode,
                           p_l1_empcode    => :new.l1_empcode,
                           p_l2_empcode    => :new.l2_empcode,
                           p_l3_empcode    => :new.l3_empcode,
                           p_l4_empcode    => :new.l4_empcode,
                           p_l5_empcode    => :new.l5_empcode,
                           p_l6_empcode    => :new.l6_empcode,
                           p_l7_empcode    => :new.l7_empcode,
                           p_l8_empcode    => :new.l8_empcode,
                           p_l9_empcode    => :new.l9_empcode,
                           p_l10_empcode   => :new.l10_empcode,
                           p_l11_empcode   => :new.l11_empcode,
                           p_l12_empcode   => :new.l12_empcode);

        IF :new.empcode = :new.l0_empcode
        THEN
            :new.l0_empcode := NULL;
        END IF;

        IF :new.empcode = :new.l1_empcode
        THEN
            :new.l1_empcode := NULL;
        END IF;

        IF :new.l0_empcode = :new.l1_empcode
        THEN
            :new.l1_empcode := NULL;
        END IF;

        IF :new.l0_empcode IS NOT NULL
        THEN
            :new.status_sl := 0;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l0_empcode);
        ELSIF :new.l1_empcode IS NOT NULL
        THEN
            :new.status_sl := 1;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l1_empcode);
        ELSIF :new.l2_empcode IS NOT NULL
        THEN
            :new.status_sl := 2;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l2_empcode);
        ELSIF :new.l3_empcode IS NOT NULL
        THEN
            :new.status_sl := 3;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l3_empcode);
        ELSIF :new.l4_empcode IS NOT NULL
        THEN
            :new.status_sl := 4;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l4_empcode);
        ELSIF :new.l5_empcode IS NOT NULL
        THEN
            :new.status_sl := 5;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l5_empcode);
        ELSIF :new.l6_empcode IS NOT NULL
        THEN
            :new.status_sl := 6;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l6_empcode);
        ELSIF :new.l7_empcode IS NOT NULL
        THEN
            :new.status_sl := 7;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l7_empcode);
        ELSIF :new.l8_empcode IS NOT NULL
        THEN
            :new.status_sl := 8;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l8_empcode);
        ELSIF :new.l9_empcode IS NOT NULL
        THEN
            :new.status_sl := 9;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l9_empcode);
        ELSIF :new.l10_empcode IS NOT NULL
        THEN
            :new.status_sl := 10;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l10_empcode);
        ELSIF :new.l11_empcode IS NOT NULL
        THEN
            :new.status_sl := 11;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l11_empcode);
        ELSIF :new.l12_empcode IS NOT NULL
        THEN
            :new.status_sl := 12;
            :new.df_status := 'pending';
            :new.status_details := df_status_detail (:new.l12_empcode);
        END IF;
    END IF;



    IF UPDATING ('l0_type')
    THEN
        IF :new.l0_type = 'forward'
        THEN
            :new.l0_date := SYSDATE;

            IF :new.l1_empcode IS NOT NULL
            THEN
                :new.status_sl := 1;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l1_empcode);
            ELSIF :new.l2_empcode IS NOT NULL
            THEN
                :new.status_sl := 2;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l2_empcode);
            ELSIF :new.l3_empcode IS NOT NULL
            THEN
                :new.status_sl := 3;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l3_empcode);
            ELSIF :new.l4_empcode IS NOT NULL
            THEN
                :new.status_sl := 4;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l4_empcode);
            ELSIF :new.l5_empcode IS NOT NULL
            THEN
                :new.status_sl := 5;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l4_empcode);
            ELSIF :new.l6_empcode IS NOT NULL
            THEN
                :new.status_sl := 6;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l6_empcode);
            ELSIF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved autohority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l1_type')
    THEN
        IF :new.l1_type = 'forward'
        THEN
            :new.l1_date := SYSDATE;

            IF :new.l2_empcode IS NOT NULL
            THEN
                :new.status_sl := 2;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l2_empcode);
            ELSIF :new.l3_empcode IS NOT NULL
            THEN
                :new.status_sl := 3;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l3_empcode);
            ELSIF :new.l4_empcode IS NOT NULL
            THEN
                :new.status_sl := 4;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l4_empcode);
            ELSIF :new.l5_empcode IS NOT NULL
            THEN
                :new.status_sl := 5;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l5_empcode);
            ELSIF :new.l6_empcode IS NOT NULL
            THEN
                :new.status_sl := 6;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l6_empcode);
            ELSIF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l2_type')
    THEN
        IF :new.l2_type = 'forward'
        THEN
            :new.l2_date := SYSDATE;

            IF :new.l3_empcode IS NOT NULL
            THEN
                :new.status_sl := 3;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l3_empcode);
            ELSIF :new.l4_empcode IS NOT NULL
            THEN
                :new.status_sl := 4;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l4_empcode);
            ELSIF :new.l5_empcode IS NOT NULL
            THEN
                :new.status_sl := 5;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l5_empcode);
            ELSIF :new.l6_empcode IS NOT NULL
            THEN
                :new.status_sl := 6;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l6_empcode);
            ELSIF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l3_type')
    THEN
        IF :new.l3_type = 'forward'
        THEN
            :new.l3_date := SYSDATE;

            IF :new.l4_empcode IS NOT NULL
            THEN
                :new.status_sl := 4;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l4_empcode);
            ELSIF :new.l5_empcode IS NOT NULL
            THEN
                :new.status_sl := 5;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l5_empcode);
            ELSIF :new.l6_empcode IS NOT NULL
            THEN
                :new.status_sl := 6;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l6_empcode);
            ELSIF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l4_type')
    THEN
        IF :new.l4_type = 'forward'
        THEN
            :new.l4_date := SYSDATE;

            IF :new.l5_empcode IS NOT NULL
            THEN
                :new.status_sl := 5;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l5_empcode);
            ELSIF :new.l6_empcode IS NOT NULL
            THEN
                :new.status_sl := 6;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l6_empcode);
            ELSIF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l5_type')
    THEN
        IF :new.l5_type = 'forward'
        THEN
            :new.l5_date := SYSDATE;

            IF :new.l6_empcode IS NOT NULL
            THEN
                :new.status_sl := 6;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l6_empcode);
            ELSIF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l6_type')
    THEN
        IF :new.l6_type = 'forward'
        THEN
            :new.l6_date := SYSDATE;

            IF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l7_type')
    THEN
        IF :new.l7_type = 'forward'
        THEN
            :new.l7_date := SYSDATE;

            IF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l8_type')
    THEN
        IF :new.l8_type = 'forward'
        THEN
            :new.l8_date := SYSDATE;

            IF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l9_type')
    THEN
        IF :new.l9_type = 'forward'
        THEN
            :new.l9_date := SYSDATE;

            IF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l10_type')
    THEN
        IF :new.l10_type = 'forward'
        THEN
            :new.l10_date := SYSDATE;

            IF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l11_type')
    THEN
        IF :new.l11_type = 'forward'
        THEN
            :new.l11_date := SYSDATE;

            IF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approve by authority';
            END IF;
        END IF;
    END IF;


    IF UPDATING ('l12_type')
    THEN
        IF :new.l12_type = 'forward'
        THEN
            :new.l12_date := SYSDATE;

            :new.status_sl := 100;
            :new.df_status := 'approve';
            :new.status_details := df_status_detail (:new.l12_empcode);
        END IF;
    END IF;



    IF UPDATING ('l0_type')
    THEN
        IF :new.l0_type = 'approved'
        THEN
            :new.l0_date := SYSDATE;

            IF :new.l1_empcode IS NOT NULL
            THEN
                :new.status_sl := 1;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l1_empcode);
            ELSIF :new.l2_empcode IS NOT NULL
            THEN
                :new.status_sl := 2;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l2_empcode);
            ELSIF :new.l3_empcode IS NOT NULL
            THEN
                :new.status_sl := 3;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l3_empcode);
            ELSIF :new.l4_empcode IS NOT NULL
            THEN
                :new.status_sl := 4;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l4_empcode);
            ELSIF :new.l5_empcode IS NOT NULL
            THEN
                :new.status_sl := 5;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l4_empcode);
            ELSIF :new.l6_empcode IS NOT NULL
            THEN
                :new.status_sl := 6;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l6_empcode);
            ELSIF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved autohority';
            END IF;
        END IF;
    END IF;



    IF UPDATING ('l1_type')
    THEN
        IF :new.l1_type = 'approved'
        THEN
            :new.l1_date := SYSDATE;

            IF :new.l2_empcode IS NOT NULL
            THEN
                :new.status_sl := 2;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l2_empcode);
            ELSIF :new.l3_empcode IS NOT NULL
            THEN
                :new.status_sl := 3;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l3_empcode);
            ELSIF :new.l4_empcode IS NOT NULL
            THEN
                :new.status_sl := 4;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l4_empcode);
            ELSIF :new.l5_empcode IS NOT NULL
            THEN
                :new.status_sl := 5;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l5_empcode);
            ELSIF :new.l6_empcode IS NOT NULL
            THEN
                :new.status_sl := 6;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l6_empcode);
            ELSIF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l2_type')
    THEN
        IF :new.l2_type = 'approved'
        THEN
            :new.l2_date := SYSDATE;

            IF :new.l3_empcode IS NOT NULL
            THEN
                :new.status_sl := 3;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l3_empcode);
            ELSIF :new.l4_empcode IS NOT NULL
            THEN
                :new.status_sl := 4;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l4_empcode);
            ELSIF :new.l5_empcode IS NOT NULL
            THEN
                :new.status_sl := 5;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l5_empcode);
            ELSIF :new.l6_empcode IS NOT NULL
            THEN
                :new.status_sl := 6;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l6_empcode);
            ELSIF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;


    IF UPDATING ('l3_type')
    THEN
        IF :new.l3_type = 'approved'
        THEN
            :new.l3_date := SYSDATE;

            IF :new.l4_empcode IS NOT NULL
            THEN
                :new.status_sl := 4;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l4_empcode);
            ELSIF :new.l5_empcode IS NOT NULL
            THEN
                :new.status_sl := 5;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l5_empcode);
            ELSIF :new.l6_empcode IS NOT NULL
            THEN
                :new.status_sl := 6;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l6_empcode);
            ELSIF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l4_type')
    THEN
        IF :new.l4_type = 'approved'
        THEN
            :new.l4_date := SYSDATE;

            IF :new.l5_empcode IS NOT NULL
            THEN
                :new.status_sl := 5;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l5_empcode);
            ELSIF :new.l6_empcode IS NOT NULL
            THEN
                :new.status_sl := 6;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l6_empcode);
            ELSIF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l5_type')
    THEN
        IF :new.l5_type = 'approved'
        THEN
            :new.l5_date := SYSDATE;

            IF :new.l6_empcode IS NOT NULL
            THEN
                :new.status_sl := 6;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l6_empcode);
            ELSIF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;


    IF UPDATING ('l6_type')
    THEN
        IF :new.l6_type = 'approved'
        THEN
            :new.l6_date := SYSDATE;

            IF :new.l7_empcode IS NOT NULL
            THEN
                :new.status_sl := 7;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l7_empcode);
            ELSIF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l7_type')
    THEN
        IF :new.l7_type = 'approved'
        THEN
            :new.l7_date := SYSDATE;

            IF :new.l8_empcode IS NOT NULL
            THEN
                :new.status_sl := 8;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l8_empcode);
            ELSIF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;


    IF UPDATING ('l8_type')
    THEN
        IF :new.l8_type = 'approved'
        THEN
            :new.l8_date := SYSDATE;

            IF :new.l9_empcode IS NOT NULL
            THEN
                :new.status_sl := 9;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l9_empcode);
            ELSIF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;


    IF UPDATING ('l9_type')
    THEN
        IF :new.l9_type = 'approved'
        THEN
            :new.l9_date := SYSDATE;

            IF :new.l10_empcode IS NOT NULL
            THEN
                :new.status_sl := 10;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l10_empcode);
            ELSIF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l10_type')
    THEN
        IF :new.l10_type = 'approved'
        THEN
            :new.l10_date := SYSDATE;

            IF :new.l11_empcode IS NOT NULL
            THEN
                :new.status_sl := 11;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l11_empcode);
            ELSIF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approved by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l11_type')
    THEN
        IF :new.l11_type = 'approved'
        THEN
            :new.l11_date := SYSDATE;

            IF :new.l12_empcode IS NOT NULL
            THEN
                :new.status_sl := 12;
                :new.df_status := 'pending';
                :new.status_details := df_status_detail (:new.l12_empcode);
            ELSE
                :new.status_sl := 100;
                :new.df_status := 'approve';
                :new.status_details := 'finaly approve by authority';
            END IF;
        END IF;
    END IF;

    IF UPDATING ('l12_type')
    THEN
        IF :new.l12_type = 'approved'
        THEN
            :new.l12_date := SYSDATE;

            :new.status_sl := 100;
            :new.df_status := 'approve';
            :new.status_details := df_status_detail (:new.l12_empcode);
        END IF;
    END IF;



    IF UPDATING ('l0_type')
    THEN
        IF :new.l0_type = 'reject'
        THEN
            :new.l0_date := SYSDATE;

            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l0_empcode);
        END IF;
    END IF;


    IF UPDATING ('l1_type')
    THEN
        IF :new.l1_type = 'reject'
        THEN
            :new.l1_date := SYSDATE;
            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l1_empcode);
        END IF;
    END IF;


    IF UPDATING ('l2_type')
    THEN
        IF :new.l2_type = 'reject'
        THEN
            :new.l2_date := SYSDATE;
            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l2_empcode);
        END IF;
    END IF;


    IF UPDATING ('l3_type')
    THEN
        IF :new.l3_type = 'reject'
        THEN
            :new.l3_date := SYSDATE;
            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l3_empcode);
        END IF;
    END IF;


    IF UPDATING ('l4_type')
    THEN
        IF :new.l4_type = 'reject'
        THEN
            :new.l4_date := SYSDATE;
            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l4_empcode);
        END IF;
    END IF;


    IF UPDATING ('l5_type')
    THEN
        IF :new.l5_type = 'reject'
        THEN
            :new.l5_date := SYSDATE;
            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l5_empcode);
        END IF;
    END IF;


    IF UPDATING ('l6_type')
    THEN
        IF :new.l6_type = 'reject'
        THEN
            :new.l6_date := SYSDATE;
            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l6_empcode);
        END IF;
    END IF;


    IF UPDATING ('l7_type')
    THEN
        IF :new.l7_type = 'reject'
        THEN
            :new.l7_date := SYSDATE;

            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l7_empcode);
        END IF;
    END IF;


    IF UPDATING ('l8_type')
    THEN
        IF :new.l8_type = 'reject'
        THEN
            :new.l8_date := SYSDATE;
            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l8_empcode);
        END IF;
    END IF;


    IF UPDATING ('l9_type')
    THEN
        IF :new.l9_type = 'reject'
        THEN
            :new.l9_date := SYSDATE;
            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l9_empcode);
        END IF;
    END IF;


    IF UPDATING ('l10_type')
    THEN
        IF :new.l10_type = 'reject'
        THEN
            :new.l10_date := SYSDATE;
            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l10_empcode);
        END IF;
    END IF;

    IF UPDATING ('l11_type')
    THEN
        IF :new.l11_type = 'reject'
        THEN
            :new.l11_date := SYSDATE;
            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l11_empcode);
        END IF;
    END IF;


    IF UPDATING ('l12_type')
    THEN
        IF :new.l12_type = 'reject'
        THEN
            :new.l12_date := SYSDATE;
            :new.status_sl := 99;
            :new.df_status := 'rejected';
            :new.status_details :=
                df_status_rejected_detail (:new.l12_empcode);
        END IF;
    END IF;



    IF UPDATING ('l0_type')
    THEN
        IF :new.l0_type = 'return'
        THEN
            :new.l0_date := SYSDATE;
            :new.l0_type := NULL;

            :new.status_sl := NULL;
            :new.l0_type := NULL;
            :new.df_status := 'returned';
            :new.status_details := df_status_back_detail (:new.l0_empcode);
        END IF;
    END IF;



    IF UPDATING ('l1_type')
    THEN
        IF :new.l1_type = 'return'
        THEN
            :new.l1_date := SYSDATE;
            :new.l1_type := NULL;

            :new.status_sl := 0;
            :new.df_status := 'return';
            :new.status_details := df_status_back_detail (:new.l1_empcode);
        END IF;
    END IF;

    IF UPDATING ('l2_type')
    THEN
        IF :new.l2_type = 'return'
        THEN
            :new.l2_date := SYSDATE;
            :new.l1_type := NULL;


            :new.status_sl := 1;
            :new.df_status := 'returned';
            :new.status_details := df_status_back_detail (:new.l1_empcode);
        END IF;
    END IF;

    IF UPDATING ('l3_type')
    THEN
        IF :new.l3_type = 'return'
        THEN
            :new.l3_date := SYSDATE;
            :new.l3_type := NULL;

            :new.status_sl := 2;
            :new.df_status := 'returned';
            :new.status_details := df_status_back_detail (:new.l2_empcode);
        END IF;
    END IF;


    IF UPDATING ('l4_type')
    THEN
        IF :new.l4_type = 'return'
        THEN
            :new.l4_date := SYSDATE;
            :new.l4_type := NULL;


            :new.status_sl := 3;
            :new.df_status := 'returned';
            :new.status_details := df_status_back_detail (:new.l3_empcode);
        END IF;
    END IF;

    IF UPDATING ('l5_type')
    THEN
        IF :new.l5_type = 'return'
        THEN
            :new.l5_date := SYSDATE;

            :new.l5_type := NULL;
            :new.status_sl := 5;
            :new.df_status := 'return';
            :new.status_details := df_status_back_detail (:new.l6_empcode);
        END IF;
    END IF;

    IF UPDATING ('l7_type')
    THEN
        IF :new.l7_type = 'return'
        THEN
            :new.l7_date := SYSDATE;

            :new.l7_type := NULL;
            :new.status_sl := 6;
            :new.df_status := 'returned';

            :new.status_details := df_status_back_detail (:new.l8_empcode);
        END IF;
    END IF;


    IF UPDATING ('l8_type')
    THEN
        IF :new.l8_type = 'return'
        THEN
            :new.l8_date := SYSDATE;
            :new.l8_type := NULL;

            :new.status_sl := 7;
            :new.df_status := 'returned';
            :new.status_details := df_status_back_detail (:new.l9_empcode);
        END IF;
    END IF;


    IF UPDATING ('l9_type')
    THEN
        IF :new.l9_type = 'return'
        THEN
            :new.l9_date := SYSDATE;

            :new.l9_type := NULL;
            :new.status_sl := 8;
            :new.df_status := 'returned';
            :new.status_details := df_status_back_detail (:new.l10_empcode);
        END IF;
    END IF;

    IF UPDATING ('l10_type')
    THEN
        IF :new.l10_type = 'return'
        THEN
            :new.l10_date := SYSDATE;
            :new.l10_type := NULL;

            :new.status_sl := 9;
            :new.df_status := 'returned';
            :new.status_details := df_status_back_detail (:new.l11_empcode);
        END IF;
    END IF;

    IF UPDATING ('l11_type')
    THEN
        IF :new.l11_type = 'return'
        THEN
            :new.l11_type := NULL;
            :new.l11_date := SYSDATE;

            :new.status_sl := 10;
            :new.df_status := 'returned';
            :new.status_details := df_status_back_detail (:new.l11_empcode);
        END IF;
    END IF;

    IF UPDATING ('l12_type')
    THEN
        IF :new.l12_type = 'return'
        THEN
            :new.l12_date := SYSDATE;
            :new.l12_type := NULL;

            :new.status_sl := 11;
            :new.df_status := 'returned';
            :new.status_details := df_status_back_detail (:new.l12_empcode);
        END IF;
    END IF;
END;
/


ALTER TABLE dbmis.df_master
    ADD (
        CONSTRAINT fk_dfm FOREIGN KEY (type_id)
            REFERENCES dbmis.df_type (type_id)
            ENABLE VALIDATE);