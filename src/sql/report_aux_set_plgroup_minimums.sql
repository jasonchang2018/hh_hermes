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


--  CHECK AGAINST HISTORY
select      date_trunc('week', contacts.contact_time)::date as week_,
            count(case when contacts.contact_type in ('Letter')                                                                         then 1 end) as n_letters,
            count(case when contacts.contact_type in ('Letter')         and coalesce(letters.collection_type, '') not in ('Validation') then 1 end) as n_letters_dunning,
            count(case when contacts.contact_type in ('Text Message')                                                                   then 1 end) as n_texts,
            count(case when contacts.contact_type in ('VoApp')                                                                          then 1 end) as n_voapps
from        edwprodhh.pub_jchang.transform_contacts as contacts
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on contacts.debtor_idx = debtor.debtor_idx
                -- and debtor.pl_group = 'FRANCISCAN HEALTH - 3P'
                and debtor.pl_group = 'IU HEALTH - 3P'
            left join
                edwprodhh.pub_jchang.master_letters as letters
                on contacts.contact_id = letters.letter_id
where       contacts.contact_time >= '2023-08-07'
            and contacts.contact_time < date_trunc('week', current_date())
group by    1
order by    1 desc
;


select      date_trunc('week', letters.print_date)::date                                                as week_,
            count(*)                                                                                    as n_letters,
            count(case when letters.collection_type in ('Validation')                       then 1 end) as n_val,
            count(case when letters.collection_type in ('Dun', 'Dunning')                   then 1 end) as n_dun,
            count(case when letters.collection_type not in ('Validation', 'Dun', 'Dunning') then 1 end) as n_else
from        edwprodhh.pub_jchang.master_letters as letters
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on letters.debtor_idx = debtor.debtor_idx
                -- and debtor.pl_group = 'FRANCISCAN HEALTH - 3P'
                and debtor.pl_group = 'IU HEALTH - 3P'
where       letters.print_date >= '2023-08-07'
            and letters.print_date < date_trunc('week', current_date())
group by    1
order by    1 desc
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