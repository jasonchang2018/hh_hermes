create or replace table
    edwprodhh.hermes.report_volume_send_summary
as
select      'def' as tableau_relation,
            proposed.execute_time::date as proposal_date,

            proposed.pl_group,
            client.industry,
            client.team,
            client.director,

            count(case when proposed.proposed_channel = 'Letter'         then 1 end) as proposed_letters,
            count(case when proposed.proposed_channel = 'VoApp'          then 1 end) as proposed_voapps,
            count(case when proposed.proposed_channel = 'Text Message'   then 1 end) as proposed_texts

from        edwprodhh.hermes.master_prediction_proposal_log as proposed
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on proposed.debtor_idx = debtor.debtor_idx
            inner join
                edwprodhh.pub_jchang.master_client as client
                on debtor.client_idx = client.client_idx

where       proposed.is_proposed_contact = 1
group by    1,2,3,4,5,6
order by    4,3,2 desc
;



create or replace task
    edwprodhh.pub_jchang.replace_report_volume_send_summary
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.merge_master_debtor
as
create or replace table
    edwprodhh.hermes.report_volume_send_summary
as
select      'def' as tableau_relation,
            proposed.execute_time::date as proposal_date,

            proposed.pl_group,
            client.industry,
            client.team,
            client.director,

            count(case when proposed.proposed_channel = 'Letter'         then 1 end) as proposed_letters,
            count(case when proposed.proposed_channel = 'VoApp'          then 1 end) as proposed_voapps,
            count(case when proposed.proposed_channel = 'Text Message'   then 1 end) as proposed_texts

from        edwprodhh.hermes.master_prediction_proposal_log as proposed
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on proposed.debtor_idx = debtor.debtor_idx
            inner join
                edwprodhh.pub_jchang.master_client as client
                on debtor.client_idx = client.client_idx

where       proposed.is_proposed_contact = 1
group by    1,2,3,4,5,6
order by    4,3,2 desc
;