with df as
(
    select      debtor.packet_idx,
                debtor.debtor_idx,
                hermes.proposed_channel,
                hermes.upload_date,
                lag(hermes.upload_date, 1) over (partition by debtor.packet_idx, hermes.proposed_channel order by hermes.upload_date asc) as last_upload_date,
                datediff(day, last_upload_date, hermes.upload_date) as diffdays
    from        edwprodhh.hermes.master_prediction_proposal_log as hermes
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on hermes.debtor_idx = debtor.debtor_idx
    where       hermes.is_proposed_contact = 1
                and hermes.upload_date >= '2023-07-24'
)
select      proposed_channel,
            diffdays,
            count(*) as n
from        df
group by    1,2
order by    1,2
;