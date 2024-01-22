create or replace temporary table
    edwprodhh.pub_jchang.temp_eqb_scores
as
select      debtor_idx,
            netcash_globalrank_debtor as equabli_score
from        edwprodhh.pub_jchang.master_scores_equabli
qualify     row_number() over (partition by debtor_idx order by scoredate asc) = 1
;


create or replace temporary table
    edwprodhh.pub_jchang.temp_hermes_letter_scores
as
select      letters.letter_id,
            proposed.marginal_fee as score,
            coalesce(attr.sig_comm_amt, 0) as dol_commission_attr,
            ceil(row_number() over (order by proposed.marginal_fee asc) / count(*) over () * 10) as decile
from        edwprodhh.pub_jchang.master_letters as letters
            inner join
                edwprodhh.hermes.master_prediction_proposal_log as proposed
                on letters.hermes_request_id = proposed.request_id
            left join
                edwprodhh.pub_jchang.master_payment_attribution_long as attr
                on letters.letter_id = attr.contact_id
;


with eqb as
(
    select      equabli.equabli_score,
                sum(attr.sig_comm_amt) / count(*) as yield_letters
    from        edwprodhh.pub_jchang.temp_eqb_scores as equabli
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on  equabli.debtor_idx = debtor.debtor_idx
                    and debtor.batch_date >= '2023-01-01'
                    and debtor.batch_date <  '2023-12-01'
                inner join
                    edwprodhh.pub_jchang.master_letters as letters
                    on debtor.debtor_idx = letters.debtor_idx
                left join
                    edwprodhh.pub_jchang.master_payment_attribution_long as attr
                    on letters.letter_id = attr.contact_id
    group by    1
)
, hermes as
(
    select      decile as hermes_score,
                sum(dol_commission_attr) / count(*) as yield_letters
    from        edwprodhh.pub_jchang.temp_hermes_letter_scores
    where       decile >= 1
    group by    1
)
, template as
(
    select      row_number() over (order by 1) as score
    from        table(generator(rowcount => 10))
)
select      template.score,
            coalesce(eqb.yield_letters,   0) as yield_letters_equabli,
            coalesce(hermes.yield_letters,    0) as yield_letters_hermes
from        template
            left join 
                eqb
                on template.score = eqb.equabli_score
            left join 
                hermes
                on template.score = hermes.hermes_score
order by    1
;