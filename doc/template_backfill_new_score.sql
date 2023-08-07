-- edwprodhh.hermes.master_prediction_pool              --contains newly scored debtors
-- edwprodhh.hermes.master_prediction_pool_log          --does NOT contain newly scored debtors

-- edwprodhh.hermes.master_prediction_scores            --does NOT contain newly scored debtors
-- edwprodhh.hermes.master_prediction_scores_log        --does NOT contain newly scored debtors
-- edwprodhh.pub_mbutler.test_backfill_scores_scored    --contains newly scored debtors


----------------------
-------  POOL  -------
----------------------
insert into
    edwprodhh.hermes.master_prediction_pool_log
with backfill_scores as
(
    select      debtor_idx,
                raw_score
    from        edwprodhh.pub_mbutler.test_backfill_scores_scored --34,562,100
)
, current_log as
(
    select      debtor_idx
    from        edwprodhh.hermes.master_prediction_pool_log --47,721,301
    qualify     execute_time = max(execute_time) over ()
)
, incremental_log as
(
    select      pool_.*,
                '2023-08-04 22:37:00.576 -0700' as execute_time
    from        edwprodhh.hermes.master_prediction_pool as pool_
                inner join
                    backfill_scores
                    on pool_.debtor_idx = backfill_scores.debtor_idx
    where       pool_.debtor_idx not in (select debtor_idx from current_log)
)
select      *
from        incremental_log --17,413,527
;


with current_log as
(
    select      debtor_idx
    from        edwprodhh.hermes.master_prediction_pool_log
    qualify     execute_time = max(execute_time) over ()
)
select      count(*), count(distinct debtor_idx)
from        current_log --65,134,828
;







----------------------
------  SCORES  ------
----------------------

with current_log as
(
    select      debtor_idx
    from        edwprodhh.hermes.master_prediction_scores_log
    qualify     execute_time = max(execute_time) over ()
)
select      count(*), count(distinct debtor_idx)
from        current_log
;

create or replace temporary table edwprodhh.hermes.temp_master_prediction_scores clone edwprodhh.hermes.master_prediction_scores;

update      edwprodhh.hermes.temp_master_prediction_scores as target
set         target.score_debtor = source.raw_score
from        edwprodhh.pub_mbutler.test_backfill_scores_scored as source
where       target.debtor_idx = source.debtor_idx
;

insert into
    edwprodhh.hermes.temp_master_prediction_scores      --4,084,474
select      scores.debtor_idx,
            debtor.client_idx,
            debtor.pl_group,
            NULL as score_letters,
            NULL as score_texts,
            NULL as score_voapps,
            NULL as score_emails,
            NULL as score_dialer_agent,
            NULL as score_dialer_agentless,
            scores.raw_score as score_debtor
from        edwprodhh.pub_mbutler.test_backfill_scores_scored as scores ----34,562,100
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on scores.debtor_idx = debtor.debtor_idx
where       scores.debtor_idx not in (select debtor_idx from edwprodhh.hermes.temp_master_prediction_scores)
;

create or replace table edwprodhh.hermes.master_prediction_scores as select * from edwprodhh.hermes.temp_master_prediction_scores; --34,702,811

delete from
    edwprodhh.hermes.master_prediction_scores_log
where
    execute_time = '2023-08-04 22:37:00.576 -0700'
;

insert into
    edwprodhh.hermes.master_prediction_scores_log
select      *,
            '2023-08-04 22:37:00.576 -0700' as execute_time
from        edwprodhh.hermes.master_prediction_scores
;