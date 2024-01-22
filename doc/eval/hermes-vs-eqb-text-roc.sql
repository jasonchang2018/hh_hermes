create or replace temporary table
    edwprodhh.pub_jchang.temp_eqb_scores
as
select      debtor_idx,
            netcash_globalrank_debtor as equabli_score
from        edwprodhh.pub_jchang.master_scores_equabli
qualify     row_number() over (partition by debtor_idx order by scoredate asc) = 1
;


create or replace temporary table
    edwprodhh.pub_jchang.temp_hermes_text_scores
as
select      texts.emid_idx,
            proposed.marginal_fee as score,
            coalesce(attr.sig_comm_amt, 0) as dol_commission_attr,
            ceil(row_number() over (order by proposed.marginal_fee asc) / count(*) over () * 10) as decile
from        edwprodhh.pub_jchang.master_texts as texts
            inner join
                edwprodhh.hermes.master_prediction_proposal_log as proposed
                on texts.hermes_request_id = proposed.request_id
            left join
                edwprodhh.pub_jchang.master_payment_attribution_long as attr
                on texts.emid_idx = attr.contact_id
;


select      texts.emid_idx,
            texts.debtor_idx,
            eqb.equabli_score,
            hermes.score as hermes_score,
            coalesce(attr.sig_comm_amt, 0) as dol_commission_attr
from        edwprodhh.pub_jchang.master_texts as texts
            inner join
                edwprodhh.pub_jchang.temp_eqb_scores as eqb
                on texts.debtor_idx = eqb.debtor_idx
            inner join
                edwprodhh.pub_jchang.temp_hermes_text_scores as hermes
                on texts.emid_idx = hermes.emid_idx
            left join
                edwprodhh.pub_jchang.master_payment_attribution_long as attr
                on texts.emid_idx = attr.contact_id
where       texts.status_date >= '2023-01-01'
            and texts.status_date < '2024-01-01'
;