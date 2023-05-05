create table
    edwprodhh.hermes.master_config_constraints_global
(
    constraint_name     varchar,
    value               float
)
;

insert into
    edwprodhh.hermes.master_config_constraints_global
values
    --  COST
    --  INCREMENT: RUNNING LEVEL ONLY.
    ('MAX_COST_RUNNING_TOTAL',          5000),
    ('MAX_COST_RUNNING_LETTERS',        1500),
    ('MAX_COST_RUNNING_TEXTS',          1500),
    ('MAX_COST_RUNNING_VOAPPS',         2000),
    ('MAX_COST_RUNNING_EMAILS',         0),
    
    --  MARGIN
    --  INCREMENT: RUNNING.
    ('MIN_MARGIN_RUNNING_TOTAL',        -1),
    ('MIN_MARGIN_RUNNING_LETTERS',      -1),
    ('MIN_MARGIN_RUNNING_VOAPPS',       -1),
    ('MIN_MARGIN_RUNNING_TEXTS',        -1),
    ('MIN_MARGIN_RUNNING_EMAILS',       -1),
    
    
    --  MARGIN
    --  INCREMENT: MARGINAL.
    ('MIN_MARGIN_MARGINAL',             -1),

    --  PROFIT
    --  INCREMENT: MARGINAL.
    ('MIN_PROFIT_MARGINAL',             -1)
;