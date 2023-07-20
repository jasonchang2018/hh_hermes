create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_score_history
as
select      debtor_idx,
            
            case    when    debtor_idx not in (select debtor_idx from edwprodhh.hermes.master_prediction_scores_log where score_dialer_agent is not null)
                    and     batch_date >= current_date() - 14
                    then    1
                    else    0
                    end     as pass_debtor_first_score_dialer_agent

from        edwprodhh.pub_jchang.master_debtor
;



create task
    edwprodhh.pub_jchang.replace_transform_businessrules_debtor_score_history
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_score_history
as
select      debtor_idx,
            
            case    when    debtor_idx not in (select debtor_idx from edwprodhh.hermes.master_prediction_scores_log where score_dialer_agent is not null)
                    and     batch_date >= current_date() - 14
                    then    1
                    else    0
                    end     as pass_debtor_first_score_dialer_agent

from        edwprodhh.pub_jchang.master_debtor
;