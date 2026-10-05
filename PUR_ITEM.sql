/* Formatted on 10/6/2025 3:38:49 PM (QP5 v5.362) */
CREATE TABLE df_items
(
    id           NUMBER,    
    item_name    VARCHAR2 (100 BYTE),
    ent_by       NUMBER,
    ent_date     DATE,
    upd_by       NUMBER,
    upd_date     DATE
);


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