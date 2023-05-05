create table
    edwprodhh.hermes.master_config_objectives
(
    metric_name     varchar,
    weight          number(9,2)
)
;

insert into
    edwprodhh.hermes.master_config_objectives
values
    ('Profit', 0.90),
    ('Margin', 0.10)
;