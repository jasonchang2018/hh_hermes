create or replace view
    edwprodhh.hermes.report_performance_phone_explore_rate
as
with with_best_score as
(
    select      *,

                max(phone_score_raw) over (partition by execute_time, packet_idx) as best_phone_score_raw,
                case    when    phone_score_raw = best_phone_score_raw
                        then    1
                        else    0
                        end     as is_best_phone_score_raw

    from        edwprodhh.hermes.master_prediction_phone_selection_log
)
select      execute_time::date                                                                  as execute_time,
            count(distinct packet_idx)                                                          as n_packets,
            count(case when is_best_phone_score_raw = 1 and is_proposed_phone = 1 then 1 end)   as n_optimal,
            n_optimal / n_packets                                                               as p_optimal,
            1 - p_optimal                                                                       as p_explore
from        with_best_score
group by    1
order by    1 desc
;