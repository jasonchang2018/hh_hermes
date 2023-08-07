create or replace table
    edwprodhh.hermes.transform_criteria_debtor_client_active
as
select      debtor_idx,

            case    when    client_idx in (select client_idx from edwprodhh.hermes.master_config_clients_active)
                    then    1
                    else    0
                    end     as pass_client_active_hermes_contacts

from        edwprodhh.pub_jchang.master_debtor
;



create or replace task
    edwprodhh.pub_jchang.replace_transform_criteria_debtor_client_active
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_criteria_debtor_client_active
as
select      debtor_idx,

            case    when    client_idx in (select client_idx from edwprodhh.hermes.master_config_clients_active)
                    then    1
                    else    0
                    end     as pass_client_active_hermes_contacts

from        edwprodhh.pub_jchang.master_debtor
;