create table
    edwprodhh.hermes.master_config_constraints_plgroup
(
    pl_group                        varchar,
    max_cost_running_letters        number(18,2),
    max_cost_running_texts          number(18,2),
    max_cost_running_voapps         number(18,2),
    max_cost_running_emails         number(18,2),
    min_margin_running_letters      number(18,2),
    min_margin_running_voapps       number(18,2),
    min_margin_running_texts        number(18,2),
    min_margin_running_emails       number(18,2)
)
;


insert into
    edwprodhh.hermes.master_config_constraints_plgroup
select      distinct
            pl_group,
            NULL::number(18,2)  as  max_cost_running_letters,
            NULL::number(18,2)  as  max_cost_running_texts,
            NULL::number(18,2)  as  max_cost_running_voapps,
            NULL::number(18,2)  as  max_cost_running_emails,
            NULL::number(18,2)  as  min_margin_running_letters,
            NULL::number(18,2)  as  min_margin_running_voapps,
            NULL::number(18,2)  as  min_margin_running_texts,
            NULL::number(18,2)  as  min_margin_running_emails
from        edwprodhh.hermes.master_config_clients_active
order by    1
;


update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_letters        = 750       where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_texts          = 750       where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_voapps         = 1000      where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_emails         = 0         where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     min_margin_running_letters      = -1        where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     min_margin_running_voapps       = -1        where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     min_margin_running_texts        = -1        where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     min_margin_running_emails       = -1        where   TRUE;