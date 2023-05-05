create table
    edwprodhh.hermes.master_config_channel_costs
(
    contact_channel     varchar,
    unit_cost           number(9,2)
)
;

insert into
    edwprodhh.hermes.master_config_channel_costs
values
    ('Letter',                  0.65),
    ('Text Message',            0.03),
    ('VoApp',                   0.06),
    ('Email',                   0.03),
    ('Dialer-Agent Call',       NULL),
    ('Dialer-Agentless Call',   NULL)
;