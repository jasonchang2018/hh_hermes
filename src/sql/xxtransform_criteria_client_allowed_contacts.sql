create or replace table
    edwprodhh.hermes.transform_criteria_client_allowed_contacts
as
select      debtor_idx,
            case    when    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_letters)
                    then    1
                    else    0
                    end     as pass_client_allowed_letters,
            case    when    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_texts)
                    then    1
                    else    0
                    end     as pass_client_allowed_texts,
            case    when    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_voapps)
                    then    1
                    else    0
                    end     as pass_client_allowed_voapps,
            case    when    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_calls)
                    then    1
                    else    0
                    end     as pass_client_allowed_calls
                    
from        edwprodhh.pub_jchang.master_debtor
;



create task
    edwprodhh.pub_jchang.replace_transform_criteria_client_allowed_contacts
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_criteria_client_allowed_contacts
as
select      debtor_idx,
            case    when    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_letters)
                    then    1
                    else    0
                    end     as pass_client_allowed_letters,
            case    when    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_texts)
                    then    1
                    else    0
                    end     as pass_client_allowed_texts,
            case    when    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_voapps)
                    then    1
                    else    0
                    end     as pass_client_allowed_voapps,
            case    when    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_calls)
                    then    1
                    else    0
                    end     as pass_client_allowed_calls
                    
from        edwprodhh.pub_jchang.master_debtor
;