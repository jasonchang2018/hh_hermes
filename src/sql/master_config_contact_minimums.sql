create or replace table
    edwprodhh.hermes.master_config_contact_minimums
(
    PL_GROUP                    VARCHAR(16777216),
    PROPOSED_CHANNEL            VARCHAR(16777216),
    NUMBER_CONTACTS             NUMBER(18,0),
    WITHIN_DAYS_PLACEMENT       NUMBER(18,0),
    DELAY_DAYS_PLACEMENT        NUMBER(18,0)
)
;

truncate table edwprodhh.hermes.master_config_contact_minimums;


insert into
    edwprodhh.hermes.master_config_contact_minimums
values
    --PL_GROUP                                  --PROPOSED_CHANNEL      --NUMBER_CONTACTS       --WITHIN_DAYS_PLACEMENT     --DELAY_DAYS_PLACEMENT
    ('CITY OF WASHINGTON DC - ABRA - 3P',       'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - BEGA - 3P',       'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - CCU - 3P',        'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - DHCD - 3P',       'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - DLCP - 3P',       'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - DMV - 3P',        'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - DOB - 3P',        'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - DOC - 3P',        'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - DOEE - 3P',       'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - FEMS - 3P',       'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - MPD - 3P',        'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - OAG - 3P',        'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - OLG - 3P',        'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - OP - 3P',         'Text Message',         2,                      10,                         0),
    ('CITY OF WASHINGTON DC - OSSE - 3P',       'Text Message',         2,                      10,                         0),
    ('ALL',                                     'Text Message',         1,                      90,                         0),
    ('ALL',                                     'Dialer-Agent Call',    1,                      10,                         0),
    ('ALL',                                     'Dialer-Agent Call',    2,                      30,                         0),
    ('ALL',                                     'Dialer-Agent Call',    3,                      45,                         0),
    ('ALL',                                     'Letter',               1,                      90,                         0)
;