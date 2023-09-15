with df_long as
(
    select      pl_group,
                date_trunc('week', upload_date)::date as execute_week,
                count(*) as n
    from        edwprodhh.hermes.master_prediction_proposal_log
    where       is_proposed_contact = 1
                -- and proposed_channel = 'Text Message'
                and proposed_channel = 'VoApp'
                and upload_date >= '2023-09-04'
    group by    1,2
    order by    2,1
)
select      pl_group,
            coalesce(prev_, 0)  as prev,
            coalesce(curr_, 0)  as curr,
            curr - prev         as diff
from        df_long
            pivot (
                max (n) for execute_week in (
                    '2023-09-04',
                    '2023-09-11'
                )
            )   as pvt (
                pl_group,
                prev_,
                curr_
            )
order by    diff desc
;