create or replace view
    edwprodhh.hermes.report_tax_sif_results
as
with test_population as
(
    select      debtor_idx,
                pl_group,
                proposed_channel,
                template,
                marginal_fee as score,
                request_id,
                execute_time
    from        edwprodhh.hermes.master_prediction_proposal_log
    where       execute_time >= '2024-01-22 15:03:45.294 -0800'
                and is_proposed_contact = 1
                and proposed_channel = 'Text Message'
                and template is not null
                and pl_group in (
                    'CITY OF WASHINGTON DC - DMV - 3P',             --
                    'COLUMBIA DOCTORS - 3P',                        --
                    'COUNTY OF MCHENRY IL - 3P',                    --
                    'COUNTY OF WINNEBAGO IL - 3P',                  --
                    'FRANCISCAN HEALTH - 3P',                       --
                    'IU HEALTH - 3P',                               --
                    'MOUNT SINAI - 3P',                             --
                    'NORTHSHORE UNIV HEALTH - 3P',                  --
                    'NORTHWESTERN MEDICINE - 3P',                   --
                    'NW COMM HOSP - 3P-2',                          --
                    'NW COMM HOSP - 3P',                            --
                    'PROVIDENCE ST JOSEPH HEALTH - 3P-2',           --
                    'PROVIDENCE ST JOSEPH HEALTH - 3P',             --
                    'STATE OF KS - DOR - 3P',                       --
                    'SWEDISH HOSPITAL - 3P',                        --
                    'U OF CHICAGO MEDICAL - 3P',                    --
                    'U OF CINCINNATI HEALTH SYSTEM - 3P',           --
                    'UNIVERSAL HEALTH SERVICES - 3P',               --
                    'WEILL CORNELL PHY - 3P'                        --
                )
)
, joined as
(
    select      debtor.debtor_idx,
                debtor.packet_idx,
                debtor.pl_group,
                test_population.template,
                test_population.request_id,
                texts.emid_idx,
                texts.debtor_idx,
                texts.status_date,
                attr.num_payments as n_payors,
                attr.sig_comm_amt as dol_commission_attr
    from        test_population
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on test_population.debtor_idx = debtor.debtor_idx
                left join
                    edwprodhh.pub_jchang.master_texts as texts
                    on test_population.request_id = texts.hermes_request_id
                left join
                    edwprodhh.pub_jchang.master_payment_attribution_long as attr
                    on texts.emid_idx = attr.contact_id
)
, aggregated as
(
    select      pl_group,
                template,
                status_date,
                count(emid_idx)             as n_texts,
                sum(n_payors)               as n_payors,
                sum(dol_commission_attr)    as dol_commission_attr
    from        joined
    group by    1,2,3
)
, template as
(
    with clients as
    (
        select      distinct
                    pl_group
        from        joined
    )
    , treatments as
    (
        select      distinct
                    template
        from        joined
    )
    , dates as
    (
        select      date
        from        edwprodhh.dw.dimdate
        where       date >= '2024-01-22'
                    and date <= current_date()
                    and date <= (select max(status_date) from joined)
    )
    select      clients.pl_group,
                treatments.template,
                dates.date as send_date
    from        clients
                cross join
                    treatments
                cross join
                    dates
)
select      template.pl_group,
            template.template,
            template.send_date,
            coalesce(n_texts,               0) as n_texts,
            coalesce(n_payors,              0) as n_payors,
            coalesce(dol_commission_attr,   0) as dol_commission_attr,
            'uvw'                              as tableau_relation
from        template
            left join
                aggregated
                on  template.pl_group           = aggregated.pl_group
                and template.template           = aggregated.template
                and template.send_date          = aggregated.status_date
order by    1,2,3
;