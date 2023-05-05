create or replace table
    edwprodhh.hermes.report_eval_model_v1_voapps
as
with internal_scores as
(
    select      tax_season.contact_id,
                tax_season.debtor_idx,
                contacts.contact_time,
                voapps_base.dol_commission_attr     as fee_actual,
                tax_season.score_value              as score_tax,
                hermes_v1.score_value_voapp         as score_hermesv1

    from        edwprodhh.pub_jchang.report_tax_hermes_comparison_scored as tax_season
                inner join
                    edwprodhh.pub_jchang.master_contacts as contacts
                    on tax_season.contact_id = contacts.contact_id
                inner join
                    edwprodhh.jchang_tax_season_2023.temp_project_taxseason2023_training_voapps_base as voapps_base
                    on tax_season.contact_id = voapps_base.contact_id
                inner join
                    (select distinct * from edwprodhh.pub_mbutler.voapp_reserve_predicted) as hermes_v1
                    on tax_season.contact_id = hermes_v1.contact_id

    where       tax_season.contact_type = 'VoApp'
)
, external_scores as
(
    with filtered as
    (
        select      *
        from        edwprodhh.pub_jchang.master_scores_equabli
        where       debtor_idx in (select debtor_idx from internal_scores)
    )
    select      internal_scores.contact_id,
                filtered.netcash_localrank      as eqb_local,
                filtered.netcash_globalrank     as eqb_global
    from        filtered
                inner join
                    internal_scores
                    on  filtered.debtor_idx = internal_scores.debtor_idx
                    and filtered.scoredate  < internal_scores.contact_time
    qualify     row_number() over (partition by internal_scores.contact_id order by filtered.scoredate desc) = 1
)
, joined_scores as
(
    select      internal_scores.contact_id,
                internal_scores.debtor_idx,
                internal_scores.contact_time,
                internal_scores.fee_actual,
                internal_scores.score_tax,
                internal_scores.score_hermesv1,
                external_scores.eqb_local,
                external_scores.eqb_global
    from        internal_scores
                inner join
                    external_scores
                    on internal_scores.contact_id = external_scores.contact_id
)
select      *
from        joined_scores
;