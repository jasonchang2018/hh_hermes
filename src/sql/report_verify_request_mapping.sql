select      hermes.execute_time,
            count(*) as n_hermes,
            count(case when texts.emid_idx is not null then 1 end) as n_texts
from        edwprodhh.hermes.master_prediction_proposal_log as hermes
            left join
                edwprodhh.pub_jchang.master_texts as texts
                on hermes.request_id = texts.hermes_request_id
where       hermes.is_proposed_contact = 1
            and hermes.proposed_channel = 'Text Message'
group by    1
order by    1 desc
;