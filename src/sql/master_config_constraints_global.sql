create table
    edwprodhh.hermes.master_config_constraints_global
(
    constraint_name     varchar,
    value               float
)
;

truncate table edwprodhh.hermes.master_config_constraints_global;

insert into
    edwprodhh.hermes.master_config_constraints_global
values
    --  COST
    --  INCREMENT: RUNNING LEVEL ONLY.
    ('MAX_COST_RUNNING_TOTAL',          26000),
    ('MAX_COST_RUNNING_LETTERS',        7500),
    ('MAX_COST_RUNNING_TEXTS',          3400),
    ('MAX_COST_RUNNING_VOAPPS',         21000),
    ('MAX_COST_RUNNING_EMAILS',         0),
    
    --  MARGIN
    --  INCREMENT: RUNNING.
    ('MIN_MARGIN_RUNNING_TOTAL',        -1000),
    ('MIN_MARGIN_RUNNING_LETTERS',      -1000),
    ('MIN_MARGIN_RUNNING_VOAPPS',       -1000),
    ('MIN_MARGIN_RUNNING_TEXTS',        -1000),
    ('MIN_MARGIN_RUNNING_EMAILS',       -1000),
    
    
    --  MARGIN
    --  INCREMENT: MARGINAL.
    ('MIN_MARGIN_MARGINAL',             -1000),

    --  PROFIT
    --  INCREMENT: MARGINAL.
    ('MIN_PROFIT_MARGINAL',             -1)
;