create or replace table
    edwprodhh.hermes.report_test_replace_letters_20231211_split_consistency
as
with temp_master_prediction_pool_log as
(
    select      debtor_idx,
                treatment_group,
                pass_debtor_active
    from        edwprodhh.hermes.master_prediction_pool_log
    where       execute_time = (select max(execute_time) from edwprodhh.hermes.master_prediction_pool_log)
)
, temp_master_prediction_pool_log_cumulative as
(
    select      debtor_idx,
                treatment_group,
                pass_debtor_active
    from        edwprodhh.hermes.master_prediction_pool_log
    where       execute_time >= '2023-12-16 00:20:11.749 -0800'
)

, consistent_packets as
(
    with summary as
    (
        select      debtor.packet_idx,
                    count(distinct pool.treatment_group) as n_treatments
        from        temp_master_prediction_pool_log as pool
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on pool.debtor_idx = debtor.debtor_idx
                        and debtor.batch_date >= '2023-12-11'
                        and debtor.pl_group not in (
                            'LURIE CHILDRENS - 1P',
                            'CARLE HEALTHCARE - PHY - 1P',
                            'PROVIDENCE ST JOSEPH HEALTH - 3P-2'
                        )
        group by    1
    )
    select      'Packet Consistency'                                    as validation_name,
                count(case when n_treatments = 1 then 1 end)::float     as n_pass,
                count(case when n_treatments > 1 then 1 end)::float     as n_fail
    from        summary
    group by    1
    order by    1
)
, consistent_time as
(
    with summary as
    (
        select      debtor.packet_idx,
                    count(distinct pool.treatment_group) as n_treatments
        from        temp_master_prediction_pool_log_cumulative as pool
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on pool.debtor_idx = debtor.debtor_idx
                        and debtor.batch_date >= '2023-12-11'
                        and debtor.pl_group not in (
                            'LURIE CHILDRENS - 1P',
                            'CARLE HEALTHCARE - PHY - 1P',
                            'PROVIDENCE ST JOSEPH HEALTH - 3P-2'
                        )
        group by    1
    )
    select      'Time Consistency'                                      as validation_name,
                count(case when n_treatments = 1 then 1 end)::float     as n_pass,
                count(case when n_treatments > 1 then 1 end)::float     as n_fail
    from        summary
    group by    1
    order by    1
)
, unioned as
(
    select      *
    from        consistent_packets
    union all
    select      *
    from        consistent_time
)
select      *,
            edwprodhh.pub_jchang.divide(n_pass, n_pass + n_fail) as pass_perc,
            'bbbbb' as tableau_relation
from        unioned
order by    1
;



create or replace task
    edwprodhh.pub_jchang.replace_report_test_replace_letters_20231211_split_consistency
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.merge_master_debtor
as
create or replace table
    edwprodhh.hermes.report_test_replace_letters_20231211_split_consistency
as
with temp_master_prediction_pool_log as
(
    select      debtor_idx,
                treatment_group,
                pass_debtor_active
    from        edwprodhh.hermes.master_prediction_pool_log
    where       execute_time = (select max(execute_time) from edwprodhh.hermes.master_prediction_pool_log)
)
, temp_master_prediction_pool_log_cumulative as
(
    select      debtor_idx,
                treatment_group,
                pass_debtor_active
    from        edwprodhh.hermes.master_prediction_pool_log
    where       execute_time >= '2023-12-16 00:20:11.749 -0800'
)

, consistent_packets as
(
    with summary as
    (
        select      debtor.packet_idx,
                    count(distinct pool.treatment_group) as n_treatments
        from        temp_master_prediction_pool_log as pool
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on pool.debtor_idx = debtor.debtor_idx
                        and debtor.batch_date >= '2023-12-11'
                        and debtor.pl_group not in (
                            'LURIE CHILDRENS - 1P',
                            'CARLE HEALTHCARE - PHY - 1P',
                            'PROVIDENCE ST JOSEPH HEALTH - 3P-2'
                        )
        group by    1
    )
    select      'Packet Consistency'                                    as validation_name,
                count(case when n_treatments = 1 then 1 end)::float     as n_pass,
                count(case when n_treatments > 1 then 1 end)::float     as n_fail
    from        summary
    group by    1
    order by    1
)
, consistent_time as
(
    with summary as
    (
        select      debtor.packet_idx,
                    count(distinct pool.treatment_group) as n_treatments
        from        temp_master_prediction_pool_log_cumulative as pool
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on pool.debtor_idx = debtor.debtor_idx
                        and debtor.batch_date >= '2023-12-11'
                        and debtor.pl_group not in (
                            'LURIE CHILDRENS - 1P',
                            'CARLE HEALTHCARE - PHY - 1P',
                            'PROVIDENCE ST JOSEPH HEALTH - 3P-2'
                        )
        group by    1
    )
    select      'Time Consistency'                                      as validation_name,
                count(case when n_treatments = 1 then 1 end)::float     as n_pass,
                count(case when n_treatments > 1 then 1 end)::float     as n_fail
    from        summary
    group by    1
    order by    1
)
, unioned as
(
    select      *
    from        consistent_packets
    union all
    select      *
    from        consistent_time
)
select      *,
            edwprodhh.pub_jchang.divide(n_pass, n_pass + n_fail) as pass_perc,
            'bbbbb' as tableau_relation
from        unioned
order by    1
;