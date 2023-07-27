create or replace table
    edwprodhh.hermes.report_performance_pilot_backlogs
as
with proposed_debtors as
(
    with rails_hermes as
    (
        select      proposal.debtor_idx,
                    proposal.proposed_channel,

                    date_trunc('week', proposal.execute_time)::date     as week_proposal,
                    dateadd(week, 1, week_proposal)                     as week_send_start,
                    dateadd(week, 3, week_proposal)                     as week_send_end,

                    debtor.packet_idx,
                    debtor.pl_group

        from        edwprodhh.hermes.master_prediction_proposal_log as proposal
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on proposal.debtor_idx = debtor.debtor_idx

        where       is_proposed_contact = 1
                    and is_fasttrack = 1
                    and execute_time in (
                        '2023-06-09 01:38:24.605 -0700'
                    )
    )
    select      *,
                row_number() over (order by 1) as id_rn
    from        rails_hermes
)
, proposed_contacts as
(
    with join_master_contacts as
    (
        select      proposed_debtors.*,
                    contacts.contact_id,
                    contacts.contact_type

        from        proposed_debtors
                    inner join
                        edwprodhh.pub_jchang.master_contacts as contacts
                        on  proposed_debtors.packet_idx         = contacts.packet_idx
                        and proposed_debtors.proposed_channel   = contacts.contact_type
                        and contacts.contact_time               >= proposed_debtors.week_send_start
                        and contacts.contact_time               <  proposed_debtors.week_send_end

        qualify    row_number() over (partition by proposed_debtors.id_rn order by contacts.contact_time asc) = 1
    )
    select      distinct
                contact_id,
                contact_type
    from        join_master_contacts
)
, contacts as
(
    select      contacts.contact_id,

                contacts.contact_type,
                case    when    proposed_contacts.contact_id is not null
                        then    'Adhoc'
                        else    'Strategy'
                        end     as contact_grouping,
                date_trunc('week', contacts.contact_time)::date                                         as contact_week,

                debtor.debtor_idx,
                debtor.packet_idx,
                debtor.industry,
                debtor.pl_group,

                case    when    contacts.contact_type = 'Letter'
                        then    0.643
                        when    contacts.contact_type = 'VoApp'
                        then    0.06
                        when    contacts.contact_type = 'Text Message'
                        then    0.03
                        end                                                                             as cost,

                count(distinct debtor.debtor_idx) over (partition by debtor.packet_idx)                 as packet_size,
                row_number() over (partition by contacts.contact_type, debtor.packet_idx order by 1)    as packet_size_flag


    from        edwprodhh.pub_jchang.master_contacts as contacts
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on contacts.debtor_idx = debtor.debtor_idx
                left join
                    proposed_contacts
                    on contacts.contact_id = proposed_contacts.contact_id
                left join
                    edwprodhh.pub_jchang.master_letters as letters
                    on  contacts.contact_id = letters.letter_id
                    and letters.attribution_valid = 1
                    and letters.collection_type != 'Validation'

    where       contacts.contact_type in ('Letter', 'Text Message', 'VoApp')
                and contacts.contact_time >= '2023-04-12'
                and case    when    contacts.contact_type = 'VoApp'
                            then    TRUE
                            when    contacts.contact_type = 'Text Message'
                            then    TRUE
                            when    contacts.contact_type = 'Letter'
                            then    letters.letter_id is not null
                            end

)
, contact_agg as
(
    select      *
    from        (
                    select      pl_group,
                                industry,
                                contact_type,
                                contact_grouping,
                                contact_week,

                                count(*)                                                                                                        as n_contacts,
                                count(distinct packet_idx)                                                                                      as n_packets,
                                sum(case when packet_size_flag = 1 then 1 else 0 end)                                                           as n_packets_check,
                                sum(packet_size * case when packet_size_flag = 1 then 1 else 0 end)                                             as n_debtors_reached,
                                sum(cost)                                                                                                       as cost

                    from        contacts
                    group by    1,2,3,4,5
                )   as summarized

    qualify     count(distinct contact_grouping) over (partition by pl_group, contact_type, contact_week) = 2
                or contact_grouping = 'Adhoc'

    order by    3,2,sum(n_contacts) over (partition by pl_group, contact_type) desc,5,4
)
, payments as
(
    with attr as
    (
        select      contact_id,
                    date_trunc('week', trans_date)          as trans_week,

                    sum(attribution_weight)                     as qty_collected_attr,
                    sum(sig_trans_amt   * attribution_weight)   as dol_collected_attr,
                    sum(sig_comm_amt    * attribution_weight)   as dol_commission_attr

        from        edwprodhh.pub_jchang.transform_payment_attribution_contact_weights
        where       contact_time >= '2023-04-12'
        group by    1,2
    )
    select      contacts.contact_id,
                contacts.pl_group,
                contacts.industry,
                contacts.contact_type,
                contacts.contact_grouping,
                contacts.contact_week,

                attr.trans_week,
                datediff(day, contacts.contact_week, attr.trans_week) as days_maturity,

                attr.qty_collected_attr,
                attr.dol_collected_attr,
                attr.dol_commission_attr

    from        contacts
                inner join
                    attr
                    on  contacts.contact_id = attr.contact_id
                    and attr.trans_week >= contacts.contact_week
)
, payment_agg as
(
    with segments_to_include as
    (
        select      distinct
                    pl_group,
                    contact_type,
                    contact_week
        from        contact_agg
    )

    select      *
    from        (
                    select      payments.pl_group,
                                payments.industry,
                                payments.contact_type,
                                payments.contact_grouping,
                                payments.contact_week,

                                payments.trans_week,
                                payments.days_maturity,

                                sum(payments.qty_collected_attr)    as qty_collected_attr,
                                sum(payments.dol_collected_attr)    as dol_collected_attr,
                                sum(payments.dol_commission_attr)   as dol_commission_attr

                    from        payments
                                inner join
                                    segments_to_include
                                    on  payments.pl_group       = segments_to_include.pl_group
                                    and payments.contact_type   = segments_to_include.contact_type
                                    and payments.contact_week   = segments_to_include.contact_week

                    group by    1,2,3,4,5,6,7
                )   as summarized
)
select      'zyx' as tableau_relation,
            
            coalesce(contact_agg.pl_group,          payment_agg.pl_group)           as pl_group,
            coalesce(contact_agg.industry,          payment_agg.industry)           as industry,
            coalesce(contact_agg.contact_type,      payment_agg.contact_type)       as contact_type,
            coalesce(contact_agg.contact_grouping,  payment_agg.contact_grouping)   as contact_grouping,
            coalesce(contact_agg.contact_week,      payment_agg.contact_week)       as contact_week,
            coalesce(payment_agg.trans_week,        contact_agg.contact_week)       as trans_week,

            coalesce(payment_agg.days_maturity,     0)                              as days_maturity,

            coalesce(contact_agg.n_contacts,            0) as n_contacts,
            coalesce(contact_agg.n_packets,             0) as n_packets,
            coalesce(contact_agg.n_packets_check,       0) as n_packets_check,
            coalesce(contact_agg.n_debtors_reached,     0) as n_debtors_reached,
            coalesce(contact_agg.cost,                  0) as cost,

            coalesce(payment_agg.qty_collected_attr,    0) as qty_collected,
            coalesce(payment_agg.dol_collected_attr,    0) as dol_collected,
            coalesce(payment_agg.dol_commission_attr,   0) as revenue

from        contact_agg
            full outer join
                payment_agg
                on  contact_agg.pl_group            = payment_agg.pl_group
                and contact_agg.industry            = payment_agg.industry
                and contact_agg.contact_type        = payment_agg.contact_type
                and contact_agg.contact_grouping    = payment_agg.contact_grouping
                and contact_agg.contact_week        = payment_agg.contact_week
                and contact_agg.contact_week        = payment_agg.trans_week
order by    1,2,3,4,6,5,7
;



create task
    edwprodhh.pub_jchang.replace_report_performance_pilot_backlogs
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.replace_transform_payment_attribution_contact_weights
as
create or replace table
    edwprodhh.hermes.report_performance_pilot_backlogs
as
with proposed_debtors as
(
    with rails_hermes as
    (
        select      proposal.debtor_idx,
                    proposal.proposed_channel,

                    date_trunc('week', proposal.execute_time)::date     as week_proposal,
                    dateadd(week, 1, week_proposal)                     as week_send_start,
                    dateadd(week, 3, week_proposal)                     as week_send_end,

                    debtor.packet_idx,
                    debtor.pl_group

        from        edwprodhh.hermes.master_prediction_proposal_log as proposal
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on proposal.debtor_idx = debtor.debtor_idx

        where       is_proposed_contact = 1
                    and is_fasttrack = 1
                    and execute_time in (
                        '2023-06-09 01:38:24.605 -0700'
                    )
    )
    select      *,
                row_number() over (order by 1) as id_rn
    from        rails_hermes
)
, proposed_contacts as
(
    with join_master_contacts as
    (
        select      proposed_debtors.*,
                    contacts.contact_id,
                    contacts.contact_type

        from        proposed_debtors
                    inner join
                        edwprodhh.pub_jchang.master_contacts as contacts
                        on  proposed_debtors.packet_idx         = contacts.packet_idx
                        and proposed_debtors.proposed_channel   = contacts.contact_type
                        and contacts.contact_time               >= proposed_debtors.week_send_start
                        and contacts.contact_time               <  proposed_debtors.week_send_end

        qualify    row_number() over (partition by proposed_debtors.id_rn order by contacts.contact_time asc) = 1
    )
    select      distinct
                contact_id,
                contact_type
    from        join_master_contacts
)
, contacts as
(
    select      contacts.contact_id,

                contacts.contact_type,
                case    when    proposed_contacts.contact_id is not null
                        then    'Adhoc'
                        else    'Strategy'
                        end     as contact_grouping,
                date_trunc('week', contacts.contact_time)::date                                         as contact_week,

                debtor.debtor_idx,
                debtor.packet_idx,
                debtor.industry,
                debtor.pl_group,

                case    when    contacts.contact_type = 'Letter'
                        then    0.643
                        when    contacts.contact_type = 'VoApp'
                        then    0.06
                        when    contacts.contact_type = 'Text Message'
                        then    0.03
                        end                                                                             as cost,

                count(distinct debtor.debtor_idx) over (partition by debtor.packet_idx)                 as packet_size,
                row_number() over (partition by contacts.contact_type, debtor.packet_idx order by 1)    as packet_size_flag


    from        edwprodhh.pub_jchang.master_contacts as contacts
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on contacts.debtor_idx = debtor.debtor_idx
                left join
                    proposed_contacts
                    on contacts.contact_id = proposed_contacts.contact_id
                left join
                    edwprodhh.pub_jchang.master_letters as letters
                    on  contacts.contact_id = letters.letter_id
                    and letters.attribution_valid = 1
                    and letters.collection_type != 'Validation'

    where       contacts.contact_type in ('Letter', 'Text Message', 'VoApp')
                and contacts.contact_time >= '2023-04-12'
                and case    when    contacts.contact_type = 'VoApp'
                            then    TRUE
                            when    contacts.contact_type = 'Text Message'
                            then    TRUE
                            when    contacts.contact_type = 'Letter'
                            then    letters.letter_id is not null
                            end

)
, contact_agg as
(
    select      *
    from        (
                    select      pl_group,
                                industry,
                                contact_type,
                                contact_grouping,
                                contact_week,

                                count(*)                                                                                                        as n_contacts,
                                count(distinct packet_idx)                                                                                      as n_packets,
                                sum(case when packet_size_flag = 1 then 1 else 0 end)                                                           as n_packets_check,
                                sum(packet_size * case when packet_size_flag = 1 then 1 else 0 end)                                             as n_debtors_reached,
                                sum(cost)                                                                                                       as cost

                    from        contacts
                    group by    1,2,3,4,5
                )   as summarized

    qualify     count(distinct contact_grouping) over (partition by pl_group, contact_type, contact_week) = 2
                or contact_grouping = 'Adhoc'

    order by    3,2,sum(n_contacts) over (partition by pl_group, contact_type) desc,5,4
)
, payments as
(
    with attr as
    (
        select      contact_id,
                    date_trunc('week', trans_date)          as trans_week,

                    sum(attribution_weight)                     as qty_collected_attr,
                    sum(sig_trans_amt   * attribution_weight)   as dol_collected_attr,
                    sum(sig_comm_amt    * attribution_weight)   as dol_commission_attr

        from        edwprodhh.pub_jchang.transform_payment_attribution_contact_weights
        where       contact_time >= '2023-04-12'
        group by    1,2
    )
    select      contacts.contact_id,
                contacts.pl_group,
                contacts.industry,
                contacts.contact_type,
                contacts.contact_grouping,
                contacts.contact_week,

                attr.trans_week,
                datediff(day, contacts.contact_week, attr.trans_week) as days_maturity,

                attr.qty_collected_attr,
                attr.dol_collected_attr,
                attr.dol_commission_attr

    from        contacts
                inner join
                    attr
                    on  contacts.contact_id = attr.contact_id
                    and attr.trans_week >= contacts.contact_week
)
, payment_agg as
(
    with segments_to_include as
    (
        select      distinct
                    pl_group,
                    contact_type,
                    contact_week
        from        contact_agg
    )

    select      *
    from        (
                    select      payments.pl_group,
                                payments.industry,
                                payments.contact_type,
                                payments.contact_grouping,
                                payments.contact_week,

                                payments.trans_week,
                                payments.days_maturity,

                                sum(payments.qty_collected_attr)    as qty_collected_attr,
                                sum(payments.dol_collected_attr)    as dol_collected_attr,
                                sum(payments.dol_commission_attr)   as dol_commission_attr

                    from        payments
                                inner join
                                    segments_to_include
                                    on  payments.pl_group       = segments_to_include.pl_group
                                    and payments.contact_type   = segments_to_include.contact_type
                                    and payments.contact_week   = segments_to_include.contact_week

                    group by    1,2,3,4,5,6,7
                )   as summarized
)
select      'zyx' as tableau_relation,
            
            coalesce(contact_agg.pl_group,          payment_agg.pl_group)           as pl_group,
            coalesce(contact_agg.industry,          payment_agg.industry)           as industry,
            coalesce(contact_agg.contact_type,      payment_agg.contact_type)       as contact_type,
            coalesce(contact_agg.contact_grouping,  payment_agg.contact_grouping)   as contact_grouping,
            coalesce(contact_agg.contact_week,      payment_agg.contact_week)       as contact_week,
            coalesce(payment_agg.trans_week,        contact_agg.contact_week)       as trans_week,

            coalesce(payment_agg.days_maturity,     0)                              as days_maturity,

            coalesce(contact_agg.n_contacts,            0) as n_contacts,
            coalesce(contact_agg.n_packets,             0) as n_packets,
            coalesce(contact_agg.n_packets_check,       0) as n_packets_check,
            coalesce(contact_agg.n_debtors_reached,     0) as n_debtors_reached,
            coalesce(contact_agg.cost,                  0) as cost,

            coalesce(payment_agg.qty_collected_attr,    0) as qty_collected,
            coalesce(payment_agg.dol_collected_attr,    0) as dol_collected,
            coalesce(payment_agg.dol_commission_attr,   0) as revenue

from        contact_agg
            full outer join
                payment_agg
                on  contact_agg.pl_group            = payment_agg.pl_group
                and contact_agg.industry            = payment_agg.industry
                and contact_agg.contact_type        = payment_agg.contact_type
                and contact_agg.contact_grouping    = payment_agg.contact_grouping
                and contact_agg.contact_week        = payment_agg.contact_week
                and contact_agg.contact_week        = payment_agg.trans_week
order by    1,2,3,4,6,5,7
;