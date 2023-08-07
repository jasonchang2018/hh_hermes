create or replace temporary table
    edwprodhh.hermes.temp_master_prediction_scores_log
as
select      DEBTOR_IDX,
            CLIENT_IDX,
            PL_GROUP,
            SCORE_LETTERS,
            SCORE_TEXTS,
            SCORE_VOAPPS,
            SCORE_EMAILS,
            SCORE_DIALER_AGENT,
            SCORE_DIALER_AGENTLESS,
            NULL as SCORE_DEBTOR,
            execute_time
from        edwprodhh.hermes.master_prediction_scores_log
;


select count(*) from edwprodhh.hermes.temp_master_prediction_scores_log union all
select count(*) from edwprodhh.hermes.master_prediction_scores_log;

describe table edwprodhh.hermes.temp_master_prediction_scores_log;
describe table edwprodhh.hermes.master_prediction_scores_log;

create or replace table edwprodhh.hermes.master_prediction_scores_log as select * from edwprodhh.hermes.temp_master_prediction_scores_log;