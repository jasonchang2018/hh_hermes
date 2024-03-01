--  SET SPENDS

with weekly_spends as
(
    select      debtor.pl_group,
                floor((count(*) / 26 * 0.03) / 10) * 10 as weekly_spend
    from        edwprodhh.pub_jchang.master_texts as texts
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on texts.debtor_idx = debtor.debtor_idx
                inner join
                    edwprodhh.hermes.master_config_plgroup as hermes
                    on  debtor.pl_group = hermes.pl_group
                    and hermes.is_client_active_hermes_contacts = 1
                    and hermes.is_client_allowed_texts = 1
    where       texts.status_date >= '2023-08-01'
                and texts.status_date < '2024-02-01'
    group by    1
    order by    1
)
select      plgroups.pl_group,
            coalesce(weekly_spends.weekly_spend, 0) as weekly_spend
from        edwprodhh.hermes.master_config_plgroup as plgroups
            left join
                weekly_spends
                on plgroups.pl_group = weekly_spends.pl_group
order by    1
;



with weekly_spends as
(
    select      debtor.pl_group,
                floor((count(*) / 26 * 0.06) / 10) * 10 as weekly_spend
    from        edwprodhh.pub_jchang.master_voapps as voapps
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on voapps.debtor_idx = debtor.debtor_idx
                inner join
                    edwprodhh.hermes.master_config_plgroup as hermes
                    on  debtor.pl_group = hermes.pl_group
                    and hermes.is_client_active_hermes_contacts = 1
                    and hermes.is_client_allowed_voapps = 1
    where       voapps.status_date >= '2023-08-01'
                and voapps.status_date < '2024-02-01'
    group by    1
    order by    1
)
select      plgroups.pl_group,
            coalesce(weekly_spends.weekly_spend, 0) as weekly_spend
from        edwprodhh.hermes.master_config_plgroup as plgroups
            left join
                weekly_spends
                on plgroups.pl_group = weekly_spends.pl_group
order by    1
;


with weekly_spends as
(
    select      debtor.pl_group,
                floor((count(*) / 26 * 0.78) / 10) * 10 as weekly_spend
    from        edwprodhh.pub_jchang.master_letters as letters
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on letters.debtor_idx = debtor.debtor_idx
                inner join
                    edwprodhh.hermes.master_config_plgroup as hermes
                    on  debtor.pl_group = hermes.pl_group
                    and hermes.is_client_active_hermes_contacts = 1
                    and hermes.is_client_allowed_letters = 1
    where       letters.print_date >= '2023-08-01'
                and letters.print_date < '2024-02-01'
    group by    1
    order by    1
)
select      plgroups.pl_group,
            coalesce(weekly_spends.weekly_spend, 0) as weekly_spend
from        edwprodhh.hermes.master_config_plgroup as plgroups
            left join
                weekly_spends
                on plgroups.pl_group = weekly_spends.pl_group
order by    1
;



--  CHECK EXECUTION
with execution as
(
    select      pl_group,
                count(case when proposed_channel = 'Letter'         then 1 end) * 0.78 as n_letters,
                count(case when proposed_channel = 'Text Message'   then 1 end) * 0.03 as n_texts,
                count(case when proposed_channel = 'VoApp'          then 1 end) * 0.06 as n_voapps
    -- from        edwprodhh.hermes.master_prediction_proposal
    from        edwprodhh.hermes.temp_master_prediction_proposal
    where       is_proposed_contact = 1
    group by    1
    order by    1
)
select      plgroups.pl_group,
            coalesce(n_letters, 0) as n_letters,
            coalesce(n_texts,   0) as n_texts,
            coalesce(n_voapps,  0) as n_voapps
from        edwprodhh.hermes.master_config_plgroup as plgroups
            left join
                execution
                on plgroups.pl_group = execution.pl_group
order by    1
;