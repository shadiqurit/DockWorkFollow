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