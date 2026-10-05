/* Formatted on 10/6/2025 4:02:49 PM (QP5 v5.362) */
CREATE TABLE df_type
(
    type_id      NUMBER,
    type_name    VARCHAR2 (20 BYTE),
    type_desc    VARCHAR2 (150 BYTE),
    ent_by       NUMBER,
    ent_date     DATE,
    upd_by       NUMBER,
    upd_date     DATE,
    com_id       NUMBER
);

ALTER TABLE df_type
    ADD CONSTRAINT df_type_pk PRIMARY KEY (type_id);

---If df type 5 then select item and item expart---

CREATE TABLE df_items
(
    id           NUMBER,
    item_name    VARCHAR2 (100 BYTE),
    ent_by       NUMBER,
    ent_date     DATE,
    upd_by       NUMBER,
    upd_date     DATE
);

ALTER TABLE df_items
    ADD (CONSTRAINT df_items_pk PRIMARY KEY (id));

CREATE TABLE df_item_expart
(
    id          NUMBER,
    item_id     NUMBER,
    emp_id      NUMBER,
    com_id      NUMBER,
    ent_by      NUMBER,
    ent_date    DATE,
    upd_by      NUMBER,
    upd_date    DATE
);

ALTER TABLE df_item_expart
    ADD (CONSTRAINT df_item_expart_pk PRIMARY KEY (id));

ALTER TABLE df_item_expart
    ADD CONSTRAINT df_item_expart_r01 FOREIGN KEY (item_id)
            REFERENCES df_items (id);
            
