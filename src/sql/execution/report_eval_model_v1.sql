create or replace table
    edwprodhh.hermes.report_eval_model_v1
as
with unioned as
(
    select      *,
                'VoApps' as contact_type
    from        edwprodhh.hermes.report_eval_model_v1_voapps

    union all

    select      *,
                'Letters' as contact_type
    from        edwprodhh.hermes.report_eval_model_v1_letters

    union all

    select      *,
                'Texts' as contact_type
    from        edwprodhh.hermes.report_eval_model_v1_texts
)
, with_percentiles as
(
    select      contact_id,
                debtor_idx,
                contact_time,
                contact_type,
                fee_actual,
                eqb_local           as v1_eqb_local,
                eqb_global          as v1_eqb_global,
                score_tax           as v2_score_tax,
                score_hermesv1      as v3_score_hermesv1,

                ceil(10 * row_number() over (partition by contact_type order by score_tax       asc) / count(*) over (partition by contact_type))   as v2_score_tax_decile,
                ceil(10 * row_number() over (partition by contact_type order by score_hermesv1  asc) / count(*) over (partition by contact_type))   as v3_score_hermesv1_decile

    --          this is not a random sample; it upsamples positive attribution voapps.
    --          so EQB score may not be uniformly distributed like the V2 and V3 scores
    from        unioned as validation_sample 
)
, summarize_v1 as
(
    select      *,
                n / sum(n) over () as p
    from        (
                    select      contact_type,
                                v1_eqb_global                                       as score,
                                'V1: Equabli'                                       as score_name,
                                count(*)                                            as n,
                                avg(fee_actual)                                     as avg_fee_actual,
                                avg(case when fee_actual = 0 then 1 else 0 end)     as percent_0_fee                
                    from        with_percentiles
                    group by    1,2
                )   as with_n
    order by    1
)
, summarize_v2 as
(
    select      *,
                n / sum(n) over () as p
    from        (
                    select      contact_type,
                                v2_score_tax_decile                                 as score,
                                'V2: 2023 Tax Season'                               as score_name,
                                count(*)                                            as n,
                                avg(fee_actual)                                     as avg_fee_actual,
                                avg(case when fee_actual = 0 then 1 else 0 end)     as percent_0_fee                
                    from        with_percentiles
                    group by    1,2
                )   as with_n
    order by    1
)
, summarize_v3 as
(
    select      *,
                n / sum(n) over () as p
    from        (
                    select      contact_type,
                                v3_score_hermesv1_decile                            as score,
                                'V3: Michael Proposal'                              as score_name,
                                count(*)                                            as n,
                                avg(fee_actual)                                     as avg_fee_actual,
                                avg(case when fee_actual = 0 then 1 else 0 end)     as percent_0_fee                
                    from        with_percentiles
                    group by    1,2
                )   as with_n
    order by    1
)
, unioned_summarize as
(
    select      *
    from        summarize_v1
    union all
    select      *
    from        summarize_v2
    union all
    select      *
    from        summarize_v3
)
select      *
from        unioned_summarize
order by    1,3,2
;