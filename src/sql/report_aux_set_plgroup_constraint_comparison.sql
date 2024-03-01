--  PROPOSALS
with map_industry as
(
    with sums as
    (
        select      pl_group,
                    industry,
                    count(*) as n
        from        edwprodhh.pub_jchang.master_debtor
        where       batch_date >= '2022-01-01'
                    and industry is not null
        group by    1,2
    )
    select      *
    from        sums
    qualify     row_number() over (partition by pl_group order by n desc) = 1
)
, budgeted as
(
    select      pl_group,
                -- max_cost_running_texts / 1.25 as max_cost_running_texts
                max_cost_running_texts
    from        edwprodhh.hermes.master_config_plgroup
    where       is_client_active_hermes_contacts = 1
                and is_client_allowed_texts = 1
)
, executed as
(
    select      hermes.pl_group,
                map_industry.industry,
                count(*) as n
    from        edwprodhh.hermes.master_prediction_proposal_log as hermes
                left join
                    map_industry
                    on hermes.pl_group = map_industry.pl_group
    -- where       hermes.execute_time = '2024-02-03 08:06:21.464 -0800'
    where       hermes.execute_time = '2024-02-10 09:46:43.011 -0800'
                and hermes.is_proposed_contact = 1
                and hermes.proposed_channel = 'Text Message'
    group by    1,2
    order by    2,3 desc
)
select      budgeted.pl_group,
            executed.industry,
            budgeted.max_cost_running_texts,
            executed.n
from        budgeted
            left join
                executed
                on budgeted.pl_group = executed.pl_group
order by    2,4 desc
;

--ELIGIBILITY
select      debtor.pl_group,
            debtor.industry,
            sum(is_eligible_texts) as is_eligible_texts
from        edwprodhh.hermes.master_prediction_pool as hermes
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on hermes.debtor_idx = debtor.debtor_idx
group by    1,2
order by    2,3 desc
;