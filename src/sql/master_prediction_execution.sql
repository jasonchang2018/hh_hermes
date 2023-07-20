create or replace procedure
    edwprodhh.hermes.master_prediction_log(EXECUTE_TIME TIMESTAMP_LTZ(9))
returns     boolean
language    sql
as
begin


    insert into
        edwprodhh.hermes.master_prediction_pool_log
    select      *,
                :execute_time as execute_time
    from        edwprodhh.hermes.master_prediction_pool
    ;


    insert into
        edwprodhh.hermes.master_prediction_scores_log
    select      *,
                :execute_time as execute_time
    from        edwprodhh.hermes.master_prediction_scores
    ;


    insert into
        edwprodhh.hermes.master_prediction_proposal_log
    select      *,
                :execute_time as execute_time
    from        edwprodhh.hermes.master_prediction_proposal
    ;


    insert into
        edwprodhh.hermes.master_prediction_dialer_rank_global_log
    select      *,
                :execute_time as execute_time
    from        edwprodhh.hermes.master_prediction_dialer_rank_global
    ;

    insert into
        edwprodhh.hermes.master_prediction_execution_log
    select      :execute_time as execute_time,
                count(case when proposed_channel = 'Letter'                     then 1 end) as n_proposed_letters,
                count(case when proposed_channel = 'Text Message'               then 1 end) as n_proposed_texts,
                count(case when proposed_channel = 'VoApp'                      then 1 end) as n_proposed_voapps,
                count(case when proposed_channel = 'Email'                      then 1 end) as n_proposed_emails,
                count(case when proposed_channel = 'Dialer-Agent Call'          then 1 end) as n_proposed_dialer_agent,
                count(case when proposed_channel = 'Dialer-Agentless Call'      then 1 end) as n_proposed_dialer_agentless
    from        edwprodhh.hermes.master_prediction_proposal
    where       is_proposed_contact = 1
    ;

end
;



create task
    edwprodhh.pub_jchang.sp_master_prediction_log
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.replace_master_prediction_proposal
as
call    edwprodhh.hermes.master_prediction_log(current_timestamp())
;