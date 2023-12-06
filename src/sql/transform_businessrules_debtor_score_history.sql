create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_score_history
as
select      debtor.debtor_idx,
            
            case    when    debtor.debtor_idx not in (select debtor_idx from edwprodhh.hermes.master_prediction_scores_log where score_dialer_agent is not null)
                    and     debtor.batch_date >= current_date() - 14
                    then    1
                    else    0
                    end     as pass_debtor_first_score_dialer_agent

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                edwprodhh.hermes.master_config_treatment_router as router
                on debtor.debtor_idx = router.debtor_idx
;



create or replace task
    edwprodhh.pub_jchang.replace_transform_businessrules_debtor_score_history
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_score_history
as
select      debtor.debtor_idx,
            
            case    when    debtor.debtor_idx not in (select debtor_idx from edwprodhh.hermes.master_prediction_scores_log where score_dialer_agent is not null)
                    and     debtor.batch_date >= current_date() - 14
                    then    1
                    else    0
                    end     as pass_debtor_first_score_dialer_agent

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                edwprodhh.hermes.master_config_treatment_router as router
                on debtor.debtor_idx = router.debtor_idx
;