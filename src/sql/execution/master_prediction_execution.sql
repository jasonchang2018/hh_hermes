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


end
;



create task
    edwprodhh.pub_jchang.sp_master_prediction_log
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.replace_master_prediction_proposal
as
call    edwprodhh.hermes.master_prediction_log(current_timestamp())
;