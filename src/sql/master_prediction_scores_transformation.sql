create or replace table
    edwprodhh.hermes.master_prediction_scores_transformation
as
with scores as
(
    select      debtor_idx,
                client_idx,
                pl_group,
                score_debtor + uniform(-0.001::float, 0.001::float, random()) as score_debtor
    from        edwprodhh.hermes.master_prediction_scores
    where       score_debtor is not null
)
, with_percentiles as
(
    select      scores.*,
                edwprodhh.pub_jchang.divide(row_number() over (                                 order by scores.score_debtor asc),  count(*) over ()                            )   as percentile_global,
                edwprodhh.pub_jchang.divide(row_number() over (partition by scores.pl_group     order by scores.score_debtor asc),  count(*) over (partition by scores.pl_group))   as percentile_local,

                debtor.packet_idx

    from        scores
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on scores.debtor_idx = debtor.debtor_idx
)
select      debtor_idx,
            packet_idx,
            client_idx,
            pl_group,
            score_debtor,
            percentile_global,
            percentile_local,

            ceil(percentile_global * 10)    as decile_global,
            ceil(percentile_local  * 10)    as decile_local,
            
            segment_bounds.segment          as segment_global

from        with_percentiles
            left join
                edwprodhh.hermes.master_config_score_transformation as segment_bounds
                on  with_percentiles.score_debtor >  segment_bounds.segment_lo
                and with_percentiles.score_debtor <= segment_bounds.segment_hi
;



create or replace task
    edwprodhh.pub_jchang.replace_master_prediction_scores_transformation
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.replace_master_prediction_scores
as
create or replace table
    edwprodhh.hermes.master_prediction_scores_transformation
as
with scores as
(
    select      debtor_idx,
                client_idx,
                pl_group,
                score_debtor + uniform(-0.001::float, 0.001::float, random()) as score_debtor
    from        edwprodhh.hermes.master_prediction_scores
    where       score_debtor is not null
)
, with_percentiles as
(
    select      scores.*,
                edwprodhh.pub_jchang.divide(row_number() over (                                 order by scores.score_debtor asc),  count(*) over ()                            )   as percentile_global,
                edwprodhh.pub_jchang.divide(row_number() over (partition by scores.pl_group     order by scores.score_debtor asc),  count(*) over (partition by scores.pl_group))   as percentile_local,

                debtor.packet_idx
                
    from        scores
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on scores.debtor_idx = debtor.debtor_idx
)
select      debtor_idx,
            packet_idx,
            client_idx,
            pl_group,
            score_debtor,
            percentile_global,
            percentile_local,

            ceil(percentile_global * 10)    as decile_global,
            ceil(percentile_local  * 10)    as decile_local,
            
            segment_bounds.segment          as segment_global

from        with_percentiles
            left join
                edwprodhh.hermes.master_config_score_transformation as segment_bounds
                on  with_percentiles.score_debtor >  segment_bounds.segment_lo
                and with_percentiles.score_debtor <= segment_bounds.segment_hi
;