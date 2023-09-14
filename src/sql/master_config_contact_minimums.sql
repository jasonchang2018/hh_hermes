create or replace table
    edwprodhh.hermes.master_config_contact_minimums
(
    PL_GROUP                    VARCHAR(16777216),
    PROPOSED_CHANNEL            VARCHAR(16777216),
    NUMBER_CONTACTS             NUMBER(18,0),
    WITHIN_DAYS_PLACEMENT       NUMBER(18,0)
)
;


insert into
    edwprodhh.hermes.master_config_contact_minimums
values
    ('STATE OF PA - TURNPIKE COMMISSION - 3P', 'Text Message', 2, 10),
    ('STATE OF PA - TURNPIKE COMMISSION - 3P', 'Text Message', 10, 300),
    ('STATE OF PA - TURNPIKE COMMISSION - 3P', 'Text Message', 20, 1000)
;