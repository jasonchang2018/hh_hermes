create table
    edwprodhh.hermes.master_config_constraints_plgroup
(
    pl_group                        varchar,
    max_cost_running_client         number(18,2),
    max_cost_running_letters        number(18,2),
    max_cost_running_texts          number(18,2),
    max_cost_running_voapps         number(18,2),
    max_cost_running_emails         number(18,2),
    min_margin_running_client       number(18,2),
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
            NULL::number(18,2)  as  max_cost_running_client,
            NULL::number(18,2)  as  max_cost_running_letters,
            NULL::number(18,2)  as  max_cost_running_texts,
            NULL::number(18,2)  as  max_cost_running_voapps,
            NULL::number(18,2)  as  max_cost_running_emails,
            NULL::number(18,2)  as  min_margin_running_client,
            NULL::number(18,2)  as  min_margin_running_letters,
            NULL::number(18,2)  as  min_margin_running_voapps,
            NULL::number(18,2)  as  min_margin_running_texts,
            NULL::number(18,2)  as  min_margin_running_emails
from        edwprodhh.hermes.master_config_clients_active
order by    1
;


update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_client         = 0         where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_letters        = 0         where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_texts          = 0         where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_voapps         = 0         where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_emails         = 0         where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     min_margin_running_client       = -1        where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     min_margin_running_letters      = -1        where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     min_margin_running_voapps       = -1        where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     min_margin_running_texts        = -1        where   TRUE;
update  edwprodhh.hermes.master_config_constraints_plgroup  set     min_margin_running_emails       = -1        where   TRUE;


update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_client         = (7000/4.3 + 2500/4.3)             where   pl_group = 'ELIZABETH RIVER CROSSINGS - 3P';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_letters        = (7000/4.3 + 2500/4.3) * 1.0       where   pl_group = 'ELIZABETH RIVER CROSSINGS - 3P';
-- update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_texts          = (7000/4.3 + 2500/4.3) * 0.8       where   pl_group = 'ELIZABETH RIVER CROSSINGS - 3P';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_voapps         = 0                                 where   pl_group = 'ELIZABETH RIVER CROSSINGS - 3P';

update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_client         = (8000/4.3 + 2500/4.3)             where   pl_group = 'FRANCISCAN HEALTH - 3P';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_letters        = (8000/4.3 + 2500/4.3) * 0.4       where   pl_group = 'FRANCISCAN HEALTH - 3P';
-- update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_texts          = (8000/4.3 + 2500/4.3) * 0.8       where   pl_group = 'FRANCISCAN HEALTH - 3P';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_voapps         = (8000/4.3 + 2500/4.3) * 0.8       where   pl_group = 'FRANCISCAN HEALTH - 3P';

update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_client         = (4000/4.3/2 + 2500/4.3)           where   pl_group = 'PRISMA HEALTH - 3P';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_letters        = (4000/4.3/2 + 2500/4.3) * 0.4     where   pl_group = 'PRISMA HEALTH - 3P';
-- update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_texts          = (4000/4.3/2 + 2500/4.3) * 0.8     where   pl_group = 'PRISMA HEALTH - 3P';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_voapps         = (4000/4.3/2 + 2500/4.3) * 0.8     where   pl_group = 'PRISMA HEALTH - 3P';

update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_client         = (4000/4.3/2 + 2500/4.3)           where   pl_group = 'PRISMA HEALTH - 3P-2';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_letters        = (4000/4.3/2 + 2500/4.3) * 0.4     where   pl_group = 'PRISMA HEALTH - 3P-2';
-- update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_texts          = (4000/4.3/2 + 2500/4.3) * 0.8     where   pl_group = 'PRISMA HEALTH - 3P-2';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_voapps         = (4000/4.3/2 + 2500/4.3) * 0.8     where   pl_group = 'PRISMA HEALTH - 3P-2';

update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_client         = (5000/4.3 + 2500/4.3)             where   pl_group = 'STATE OF KS - DOR - 3P';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_letters        = (5000/4.3 + 2500/4.3) * 0.4       where   pl_group = 'STATE OF KS - DOR - 3P';
-- update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_texts          = (5000/4.3 + 2500/4.3) * 0.8       where   pl_group = 'STATE OF KS - DOR - 3P';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_voapps         = (5000/4.3 + 2500/4.3) * 0.8       where   pl_group = 'STATE OF KS - DOR - 3P';

update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_client         = (4000/4.3 + 2500/4.3)             where   pl_group = 'STATE OF OK - TAX COMMISSION - 3P';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_letters        = (4000/4.3 + 2500/4.3) * 0.4       where   pl_group = 'STATE OF OK - TAX COMMISSION - 3P';
-- update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_texts          = (4000/4.3 + 2500/4.3) * 0.8       where   pl_group = 'STATE OF OK - TAX COMMISSION - 3P';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_voapps         = (4000/4.3 + 2500/4.3) * 0.8       where   pl_group = 'STATE OF OK - TAX COMMISSION - 3P';

update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_client         = (8000/4.3 + 2500/4.3)             where   pl_group = 'STATE OF VA - DOT - 3P-2';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_letters        = (8000/4.3 + 2500/4.3) * 0.4       where   pl_group = 'STATE OF VA - DOT - 3P-2';
-- update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_texts          = 0                                 where   pl_group = 'STATE OF VA - DOT - 3P-2';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_voapps         = (8000/4.3 + 2500/4.3) * 0.8       where   pl_group = 'STATE OF VA - DOT - 3P-2';

update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_client         = (6000/4.3 + 2500/4.3)             where   pl_group = 'UNIVERSAL HEALTH SERVICES - 3P';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_letters        = (6000/4.3 + 2500/4.3) * 0.4       where   pl_group = 'UNIVERSAL HEALTH SERVICES - 3P';
-- update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_texts          = (6000/4.3 + 2500/4.3) * 0.8       where   pl_group = 'UNIVERSAL HEALTH SERVICES - 3P';
update  edwprodhh.hermes.master_config_constraints_plgroup  set     max_cost_running_voapps         = (6000/4.3 + 2500/4.3) * 0.8       where   pl_group = 'UNIVERSAL HEALTH SERVICES - 3P';
