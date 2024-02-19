create or replace view
    edwprodhh.hermes.report_tax_sif_splits
as
with test_population as
(
    select      debtor_idx,
                pl_group,
                proposed_channel,
                template,
                case when template in ('SIF-SIF', 'SIF-TAX') then 1 else 0 end as is_in_experiment,
                marginal_fee as score,
                request_id,
                execute_time
    from        edwprodhh.hermes.master_prediction_proposal_log
    where       execute_time >= '2024-01-22 15:03:45.294 -0800'
                and is_proposed_contact = 1
                and proposed_channel = 'Text Message'
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
, aggregated as
(
    select      execute_time::date as execute_time,
                pl_group,
                is_in_experiment,
                regexp_replace(test_population.template, '^SIF\\-', '') as template,
                count(*) as n_proposed
    from        test_population
    group by    1,2,3,4
)
, template as
(
    with clients as
    (
        select      distinct
                    pl_group
        from        aggregated
    )
    , treatments as
    (
        select      distinct
                    is_in_experiment,
                    template
        from        aggregated
    )
    , dates as
    (
        select      distinct
                    execute_time
        from        aggregated
    )
    select      clients.pl_group,
                treatments.is_in_experiment,
                treatments.template,
                dates.execute_time::date as execute_time
    from        clients
                cross join
                    treatments
                cross join
                    dates
)
, joined as
(
    select      template.execute_time,
                template.pl_group,
                case    when    template.is_in_experiment = 0
                        then    'NOT_IN_EXP'
                        else    case    when    template.template = 'TAX'
                                        then    'REGULAR'
                                        when    template.template = 'SIF'
                                        then    'SIF'
                                        end
                        end     as grouping,
                coalesce(aggregated.n_proposed, 0) as n_proposed
    from        template
                left join
                    aggregated
                    on  template.execute_time               = aggregated.execute_time
                    and template.pl_group                   = aggregated.pl_group
                    and template.is_in_experiment           = aggregated.is_in_experiment
                    and coalesce(template.template, '')     = coalesce(aggregated.template, '')
    order by    2,1,3,4
)
select      *,
            regular + sif           as in_exp,
            not_in_exp + in_exp     as total,
            'pqrs'                  as tableau_relation
from        joined
            pivot (
                max(n_proposed) for grouping in (
                    'NOT_IN_EXP',
                    'REGULAR',
                    'SIF'
                )
            )   as pvt (
                EXECUTE_TIME,
                PL_GROUP,
                NOT_IN_EXP,
                REGULAR,
                SIF
            )
order by    2,1
;

