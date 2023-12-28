create or replace table
    edwprodhh.hermes.report_test_replace_letters_20231211_split_proportions
as
with temp_master_prediction_pool_log as
(
    select      debtor_idx,
                treatment_group,
                pass_debtor_active
    from        edwprodhh.hermes.master_prediction_pool_log
    where       execute_time = (select max(execute_time) from edwprodhh.hermes.master_prediction_pool_log)
)
, summary_long as
(
    select      debtor.industry,
                
                case    when    debtor.industry = 'HC'
                        then    case    when    debtor.pl_group in (
                                                    'LURIE CHILDRENS - 1P',
                                                    'CARLE HEALTHCARE - PHY - 1P',
                                                    'PROVIDENCE ST JOSEPH HEALTH - 3P-2'
                                                )
                                        then    'NOT IN EXP'
                                        else    debtor.pl_group
                                        end
                        else    'NOT IN EXP'
                        end     as pl_group,

                pool.treatment_group,
                count(*) as n

    from        temp_master_prediction_pool_log as pool
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on pool.debtor_idx = debtor.debtor_idx
                    and debtor.batch_date >= '2000-01-01'
    where       (pool.treatment_group != 'NOT IN EXP' or (pool.treatment_group = 'NOT IN EXP' and pool.pass_debtor_active = 1))
    group by    1,2,3
    order by    1,
                case when pool.treatment_group = 'NOT IN EXP' then 1 else 2 end desc,
                2,
                pool.treatment_group
)
, summary_wide as
(
    select      industry,
                pl_group,

                coalesce(test_,         0)                                      as test,
                coalesce(control_,      0)                                      as control,
                test + control                                                  as in_exp,
                coalesce(not_in_exp_,   0)                                      as not_in_exp,


                edwprodhh.pub_jchang.divide(test,       in_exp)                 as test_perc,
                edwprodhh.pub_jchang.divide(control,    in_exp)                 as control_perc,
                edwprodhh.pub_jchang.divide(in_exp,     in_exp + not_in_exp)    as experiment_perc

    from        summary_long
                pivot (
                    max(n) for treatment_group in (
                        'TEST',
                        'CONTROL',
                        'NOT IN EXP'
                    )
                )   as pvt (
                    industry,
                    pl_group,
                    test_,
                    control_,
                    not_in_exp_
                )
)
select      *,
            'aaaaa' as tableau_relation
from        summary_wide
order by    case when industry = 'HC' then 1 else 2 end asc,
            industry,
            case when pl_group = 'NOT IN EXP' then 2 else 1 end asc,
            in_exp desc
;



create or replace task
    edwprodhh.pub_jchang.replace_report_test_replace_letters_20231211_split_proportions
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.merge_master_debtor
as
create or replace table
    edwprodhh.hermes.report_test_replace_letters_20231211_split_proportions
as
with temp_master_prediction_pool_log as
(
    select      debtor_idx,
                treatment_group,
                pass_debtor_active
    from        edwprodhh.hermes.master_prediction_pool_log
    where       execute_time = (select max(execute_time) from edwprodhh.hermes.master_prediction_pool_log)
)
, summary_long as
(
    select      debtor.industry,
                
                case    when    debtor.industry = 'HC'
                        then    case    when    debtor.pl_group in (
                                                    'LURIE CHILDRENS - 1P',
                                                    'CARLE HEALTHCARE - PHY - 1P',
                                                    'PROVIDENCE ST JOSEPH HEALTH - 3P-2'
                                                )
                                        then    'NOT IN EXP'
                                        else    debtor.pl_group
                                        end
                        else    'NOT IN EXP'
                        end     as pl_group,

                pool.treatment_group,
                count(*) as n

    from        temp_master_prediction_pool_log as pool
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on pool.debtor_idx = debtor.debtor_idx
                    and debtor.batch_date >= '2000-01-01'
    where       (pool.treatment_group != 'NOT IN EXP' or (pool.treatment_group = 'NOT IN EXP' and pool.pass_debtor_active = 1))
    group by    1,2,3
    order by    1,
                case when pool.treatment_group = 'NOT IN EXP' then 1 else 2 end desc,
                2,
                pool.treatment_group
)
, summary_wide as
(
    select      industry,
                pl_group,

                coalesce(test_,         0)                                      as test,
                coalesce(control_,      0)                                      as control,
                test + control                                                  as in_exp,
                coalesce(not_in_exp_,   0)                                      as not_in_exp,


                edwprodhh.pub_jchang.divide(test,       in_exp)                 as test_perc,
                edwprodhh.pub_jchang.divide(control,    in_exp)                 as control_perc,
                edwprodhh.pub_jchang.divide(in_exp,     in_exp + not_in_exp)    as experiment_perc

    from        summary_long
                pivot (
                    max(n) for treatment_group in (
                        'TEST',
                        'CONTROL',
                        'NOT IN EXP'
                    )
                )   as pvt (
                    industry,
                    pl_group,
                    test_,
                    control_,
                    not_in_exp_
                )
)
select      *,
            'aaaaa' as tableau_relation
from        summary_wide
order by    case when industry = 'HC' then 1 else 2 end asc,
            industry,
            case when pl_group = 'NOT IN EXP' then 2 else 1 end asc,
            in_exp desc
;