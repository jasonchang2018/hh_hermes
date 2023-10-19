create or replace table
    edwprodhh.pub_jchang.report_performance_contact_global_segments
as
with summary as
(
    select      debtor.pl_group,
                debtor.industry,
                debtor.party,
                client.department_name,

                contacts.contact_time::date as contact_date,
                contacts.contact_type,

                case    when    contacts.contact_type = 'Text Message'
                        then    case    when    hermes.marginal_fee <  0.006162372883   then    'Segment 1'
                                        when    hermes.marginal_fee <  0.007955334149   then    'Segment 2'
                                        when    hermes.marginal_fee <  0.009612775408   then    'Segment 3'
                                        when    hermes.marginal_fee <  0.01098179817    then    'Segment 4'
                                        when    hermes.marginal_fee <  0.01370088756    then    'Segment 5'
                                        when    hermes.marginal_fee <  0.01641402952    then    'Segment 6'
                                        when    hermes.marginal_fee <  0.01946630143    then    'Segment 7'
                                        when    hermes.marginal_fee <  0.02352891676    then    'Segment 8'
                                        when    hermes.marginal_fee <  0.03285023198    then    'Segment 9'
                                        when    hermes.marginal_fee >= 0.03285023198    then    'Segment 10'
                                        end
                        when    contacts.contact_type = 'VoApp'
                        then    case    when    hermes.marginal_fee <= 0                then    'Segment 1'
                                        when    hermes.marginal_fee <= 0                then    'Segment 2'
                                        when    hermes.marginal_fee <  0.01676096395    then    'Segment 3'
                                        when    hermes.marginal_fee <  0.1463155746     then    'Segment 4'
                                        when    hermes.marginal_fee <  0.272311002      then    'Segment 5'
                                        when    hermes.marginal_fee <  0.4125995636     then    'Segment 6'
                                        when    hermes.marginal_fee <  0.6002954841     then    'Segment 7'
                                        when    hermes.marginal_fee <  0.9215478301     then    'Segment 8'
                                        when    hermes.marginal_fee <  1.744248748      then    'Segment 9'
                                        when    hermes.marginal_fee >= 1.744248748      then    'Segment 10'
                                        end
                        when    contacts.contact_type = 'Letter'
                        then    case    when    hermes.marginal_fee <= 0                then    'Segment 1'
                                        when    hermes.marginal_fee <  0.2355108112     then    'Segment 2'
                                        when    hermes.marginal_fee <  0.4964566827     then    'Segment 3'
                                        when    hermes.marginal_fee <  0.6953602433     then    'Segment 4'
                                        when    hermes.marginal_fee <  0.9356393814     then    'Segment 5'
                                        when    hermes.marginal_fee <  1.171891928      then    'Segment 6'
                                        when    hermes.marginal_fee <  1.504318833      then    'Segment 7'
                                        when    hermes.marginal_fee <  1.962609172      then    'Segment 8'
                                        when    hermes.marginal_fee <  2.734417439      then    'Segment 9'
                                        when    hermes.marginal_fee >= 2.734417439      then    'Segment 10'
                                        end
                        else    NULL
                        end                                                                                     as global_segment,
                'asdf'                                                                                          as tableau_relation,

                count(*)                                                                                        as n_contacts,
                coalesce(sum(attr.sig_trans_amt),   0)                                                          as dol_collected_attr,
                coalesce(sum(attr.sig_comm_amt),    0)                                                          as dol_commission_attr

    from        edwprodhh.pub_jchang.master_contacts as contacts

                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on contacts.debtor_idx = debtor.debtor_idx
                inner join
                    edwprodhh.pub_jchang.master_client as client
                    on debtor.client_idx = client.client_idx

                inner join
                    edwprodhh.hermes.master_prediction_proposal_log as hermes
                    on contacts.hermes_request_id = hermes.request_id
                left join
                    edwprodhh.pub_jchang.master_payment_attribution_long as attr
                    on contacts.contact_id = attr.contact_id
                    
    group by    1,2,3,4,5,6,7,8
    order by    2,3,4,1,6,5,regexp_substr(global_segment, '(\\d{1,2}$)', 1, 1, 'e')::number
)
, template as
(
    with debtor_segments as
    (
        select      distinct
                    pl_group,
                    industry,
                    party,
                    department_name,
                    contact_type,
                    contact_date
        from        summary
    )
    , global_segments as
    (
        select      distinct
                    global_segment
        from        summary
    )
    select      debtor_segments.pl_group,
                debtor_segments.industry,
                debtor_segments.party,
                debtor_segments.department_name,
                debtor_segments.contact_date,
                debtor_segments.contact_type,
                global_segments.global_segment
    from        debtor_segments
                cross join
                    global_segments
)
select      template.pl_group,
            template.industry,
            template.party,
            template.department_name,
            template.contact_date,
            template.contact_type,
            template.global_segment,
            coalesce(n_contacts,            0) as n_contacts,
            coalesce(dol_collected_attr,    0) as dol_collected_attr,
            coalesce(dol_commission_attr,   0) as dol_commission_attr
from        template
            left join
                summary
                on  template.pl_group           = summary.pl_group
                and template.industry           = summary.industry
                and template.party              = summary.party
                and template.department_name    = summary.department_name
                and template.contact_date       = summary.contact_date
                and template.contact_type       = summary.contact_type
                and template.global_segment     = summary.global_segment
order by    2,3,4,1,6,5,regexp_substr(global_segment, '(\\d{1,2}$)', 1, 1, 'e')::number
;



create or replace task
    edwprodhh.pub_jchang.replace_report_performance_contact_global_segments
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.replace_transform_payment_attribution_contact_weights
as
create or replace table
    edwprodhh.pub_jchang.report_performance_contact_global_segments
as
with summary as
(
    select      debtor.pl_group,
                debtor.industry,
                debtor.party,
                client.department_name,

                contacts.contact_time::date as contact_date,
                contacts.contact_type,

                case    when    contacts.contact_type = 'Text Message'
                        then    case    when    hermes.marginal_fee <  0.006162372883   then    'Segment 1'
                                        when    hermes.marginal_fee <  0.007955334149   then    'Segment 2'
                                        when    hermes.marginal_fee <  0.009612775408   then    'Segment 3'
                                        when    hermes.marginal_fee <  0.01098179817    then    'Segment 4'
                                        when    hermes.marginal_fee <  0.01370088756    then    'Segment 5'
                                        when    hermes.marginal_fee <  0.01641402952    then    'Segment 6'
                                        when    hermes.marginal_fee <  0.01946630143    then    'Segment 7'
                                        when    hermes.marginal_fee <  0.02352891676    then    'Segment 8'
                                        when    hermes.marginal_fee <  0.03285023198    then    'Segment 9'
                                        when    hermes.marginal_fee >= 0.03285023198    then    'Segment 10'
                                        end
                        when    contacts.contact_type = 'VoApp'
                        then    case    when    hermes.marginal_fee <= 0                then    'Segment 1'
                                        when    hermes.marginal_fee <= 0                then    'Segment 2'
                                        when    hermes.marginal_fee <  0.01676096395    then    'Segment 3'
                                        when    hermes.marginal_fee <  0.1463155746     then    'Segment 4'
                                        when    hermes.marginal_fee <  0.272311002      then    'Segment 5'
                                        when    hermes.marginal_fee <  0.4125995636     then    'Segment 6'
                                        when    hermes.marginal_fee <  0.6002954841     then    'Segment 7'
                                        when    hermes.marginal_fee <  0.9215478301     then    'Segment 8'
                                        when    hermes.marginal_fee <  1.744248748      then    'Segment 9'
                                        when    hermes.marginal_fee >= 1.744248748      then    'Segment 10'
                                        end
                        when    contacts.contact_type = 'Letter'
                        then    case    when    hermes.marginal_fee <= 0                then    'Segment 1'
                                        when    hermes.marginal_fee <  0.2355108112     then    'Segment 2'
                                        when    hermes.marginal_fee <  0.4964566827     then    'Segment 3'
                                        when    hermes.marginal_fee <  0.6953602433     then    'Segment 4'
                                        when    hermes.marginal_fee <  0.9356393814     then    'Segment 5'
                                        when    hermes.marginal_fee <  1.171891928      then    'Segment 6'
                                        when    hermes.marginal_fee <  1.504318833      then    'Segment 7'
                                        when    hermes.marginal_fee <  1.962609172      then    'Segment 8'
                                        when    hermes.marginal_fee <  2.734417439      then    'Segment 9'
                                        when    hermes.marginal_fee >= 2.734417439      then    'Segment 10'
                                        end
                        else    NULL
                        end                                                                                     as global_segment,
                'asdf'                                                                                          as tableau_relation,

                count(*)                                                                                        as n_contacts,
                coalesce(sum(attr.sig_trans_amt),   0)                                                          as dol_collected_attr,
                coalesce(sum(attr.sig_comm_amt),    0)                                                          as dol_commission_attr

    from        edwprodhh.pub_jchang.master_contacts as contacts

                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on contacts.debtor_idx = debtor.debtor_idx
                inner join
                    edwprodhh.pub_jchang.master_client as client
                    on debtor.client_idx = client.client_idx

                inner join
                    edwprodhh.hermes.master_prediction_proposal_log as hermes
                    on contacts.hermes_request_id = hermes.request_id
                left join
                    edwprodhh.pub_jchang.master_payment_attribution_long as attr
                    on contacts.contact_id = attr.contact_id
                    
    group by    1,2,3,4,5,6,7,8
    order by    2,3,4,1,6,5,regexp_substr(global_segment, '(\\d{1,2}$)', 1, 1, 'e')::number
)
, template as
(
    with debtor_segments as
    (
        select      distinct
                    pl_group,
                    industry,
                    party,
                    department_name,
                    contact_type,
                    contact_date
        from        summary
    )
    , global_segments as
    (
        select      distinct
                    global_segment
        from        summary
    )
    select      debtor_segments.pl_group,
                debtor_segments.industry,
                debtor_segments.party,
                debtor_segments.department_name,
                debtor_segments.contact_date,
                debtor_segments.contact_type,
                global_segments.global_segment
    from        debtor_segments
                cross join
                    global_segments
)
select      template.pl_group,
            template.industry,
            template.party,
            template.department_name,
            template.contact_date,
            template.contact_type,
            template.global_segment,
            coalesce(n_contacts,            0) as n_contacts,
            coalesce(dol_collected_attr,    0) as dol_collected_attr,
            coalesce(dol_commission_attr,   0) as dol_commission_attr
from        template
            left join
                summary
                on  template.pl_group           = summary.pl_group
                and template.industry           = summary.industry
                and template.party              = summary.party
                and template.department_name    = summary.department_name
                and template.contact_date       = summary.contact_date
                and template.contact_type       = summary.contact_type
                and template.global_segment     = summary.global_segment
order by    2,3,4,1,6,5,regexp_substr(global_segment, '(\\d{1,2}$)', 1, 1, 'e')::number
;