create table
    edwprodhh.hermes.master_config_channel_costs
(
    contact_channel     varchar,
    unit_cost           number(9,2)
)
;

truncate table edwprodhh.hermes.master_config_channel_costs;

insert into
    edwprodhh.hermes.master_config_channel_costs
values
    ('Letter',                  0.780),
    ('Text Message',            0.045),
    ('VoApp',                   0.055),
    ('Email',                   0.03),
    ('Dialer-Agent Call',       NULL),
    ('Dialer-Agentless Call',   NULL)
;