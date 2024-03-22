create or replace table
    edwprodhh.hermes.transform_config_artificialgroup_associations
(
    CLIENT_IDX                          VARCHAR(16777216),
    ARTIFICIAL_GROUP                    VARCHAR(16777216)
)
;

insert into
    edwprodhh.hermes.transform_config_artificialgroup_associations
values
    ('CO-OTAPP',    'OTA-PIKEPASS'),
    ('CO-OTAPPB',   'OTA-PIKEPASS'),
    ('CO-OTAPAY',   'OTA-PLATEPAY'),
    ('CO-OTAPAYB',  'OTA-PLATEPAY'),
    ('CO-OTA',      'OTA-OTHER'),
    ('CO-OTAP',     'OTA-OTHER'),
    ('CO-OTATOL',   'OTA-OTHER'),
    ('CO-OTATOLB',  'OTA-OTHER'),
    ('CO-OTAY',     'OTA-OTHER')
;



create or replace table
    edwprodhh.hermes.master_config_artificialgroup
(
    ARTIFICIAL_GROUP                    VARCHAR(16777216),          --1
    IS_CLIENT_ACTIVE_HERMES_CONTACTS    NUMBER(1,0),                --2
    IS_CLIENT_ALLOWED_LETTERS           NUMBER(1,0),                --3
    IS_CLIENT_ALLOWED_TEXTS             NUMBER(1,0),                --4
    IS_CLIENT_ALLOWED_VOAPPS            NUMBER(1,0),                --5
    IS_CLIENT_ALLOWED_CALLS             NUMBER(1,0),                --6

    MAX_COST_RUNNING_CLIENT             NUMBER(18,2),               --7
    MAX_COST_RUNNING_LETTERS            NUMBER(18,2),               --8
    MAX_COST_RUNNING_TEXTS              NUMBER(18,2),               --9
    MAX_COST_RUNNING_VOAPPS             NUMBER(18,2),               --10
    MAX_COST_RUNNING_EMAILS             NUMBER(18,2),               --11

    MIN_COST_RUNNING_CLIENT             NUMBER(18,2),               --12
    MIN_COST_RUNNING_LETTERS            NUMBER(18,2),               --13
    MIN_COST_RUNNING_TEXTS              NUMBER(18,2),               --14
    MIN_COST_RUNNING_VOAPPS             NUMBER(18,2),               --15
    MIN_COST_RUNNING_EMAILS             NUMBER(18,2),               --16

    MIN_MARGIN_RUNNING_CLIENT           NUMBER(18,2),               --17
    MIN_MARGIN_RUNNING_LETTERS          NUMBER(18,2),               --18
    MIN_MARGIN_RUNNING_TEXTS            NUMBER(18,2),               --19
    MIN_MARGIN_RUNNING_VOAPPS           NUMBER(18,2),               --20
    MIN_MARGIN_RUNNING_EMAILS           NUMBER(18,2),               --21

    LETTER_CODE                         VARCHAR(8),                 --22
    TEXT_CODE                           VARCHAR(8),                 --23
    VOAPP_CODE                          VARCHAR(5),                 --24

    LETTER_CODE_CLIENT                  VARCHAR(16777216),          --25
    TEXT_CODE_CLIENT                    VARCHAR(16777216),          --26
    VOAPP_CODE_CLIENT                   VARCHAR(16777216),          --27
    min_cost_JSON                       OBJECT                      --28
)
;



insert into
    edwprodhh.hermes.master_config_artificialgroup
values
    --1                                                         2,      3,      4,      5,      6,                  7,      8,      9,      10,     11,                 12,     13,     14,     15,     16,                 17,     18,     19,     20,     21,                 22,             23,             24,                         25,     26,     27,     28 ,
    ('OTA-PIKEPASS',                                            1,      0,      1,      0,      0,                  90,     0,      90,     0,      0,                  90,     0,      90,     0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('OTA-PLATEPAY',                                            1,      0,      1,      0,      0,                  135,    0,      135,    0,      0,                  135,    0,      135,    0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('OTA-OTHER',                                               1,      0,      1,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL)
;