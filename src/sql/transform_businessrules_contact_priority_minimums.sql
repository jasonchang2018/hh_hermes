create or replace table
    edwprodhh.hermes.transform_businessrules_contact_priority_minimums
as
with debtor as
(
    select      debtor.debtor_idx,
                debtor.pl_group,
                debtor.batch_date,

                router.treatment_group,

                datediff(day, debtor.batch_date, current_date())                                                                                                                        as days_since_placement,
                
                greatest(count(case when contacts_pkt.contact_type in ('Letter')        then contacts_pkt.contact_id end) - max(case when client.is_fdcpa = 1 then 1 else 0 end), 0)    as prev_n_letters, --want to send at least one letter after first packet-validation
                count(case when contacts_pkt.contact_type in ('VoApp')                  then contacts_pkt.contact_id end)                                                               as prev_n_voapps,
                count(case when contacts_pkt.contact_type in ('Text Message')           then contacts_pkt.contact_id end)                                                               as prev_n_texts,
                count(case when contacts_pkt.contact_type in ('Email')                  then contacts_pkt.contact_id end)                                                               as prev_n_emails,
                count(case when contacts_pkt.contact_type in ('Dialer-Agent Call')      then contacts_pkt.contact_id end)                                                               as prev_n_dialer_agent,
                count(case when contacts_pkt.contact_type in ('Dialer-Agentless Call')  then contacts_pkt.contact_id end)                                                               as prev_n_dialer_agentless

    from        edwprodhh.pub_jchang.master_debtor as debtor
                inner join
                    edwprodhh.pub_jchang.master_client as client
                    on debtor.client_idx = client.client_idx
                left join
                    edwprodhh.pub_jchang.transform_contacts as contacts_pkt
                    on  debtor.packet_idx           =  contacts_pkt.packet_idx
                    and contacts_pkt.contact_time   >= debtor.batch_date
                left join
                    edwprodhh.hermes.master_config_treatment_router as router
                    on debtor.debtor_idx = router.debtor_idx

    group by    1,2,3,4
)
, rules_letters as
(
    select      debtor.debtor_idx,

                --  2. Given the selected rule, is the rule satisfied? Prioritize when not.
                case    when    debtor.prev_n_letters < rules.number_contacts
                        then    1
                        else    0
                        end     as is_priority_minimum_letters

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      =  'Letter'
                    and debtor.days_since_placement >= rules.delay_days_placement
    
    --  1. Select the rule to evaluate.
    --      There can be multiple rules for multiple channels.
    --      We evaluate channels separately.
    --      For each rule take the 
    --      For each channel, keep the rule longest range, unless you are BOTH
    --          i) under range of another AND
    --          ii) under limit of the same one.
    --          If above conditions are satisfied for multiple, keep the rule with the shorter range.

    qualify     row_number() over (
                    partition by    debtor.debtor_idx
                    order by        --  Prioritize rule when both under-contact and under-limit.
                                    case    when    debtor.prev_n_letters       < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    1
                                            else    0
                                            end     desc,
                                    --  When both under-contact and under-limit: take SHORTEST day limit when multiple rules eligible. The negative is intentional.
                                    --  Otherwise, take LONGEST day limit.
                                    case    when    debtor.prev_n_letters       < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    -rules.within_days_placement
                                            else    rules.within_days_placement
                                            end     desc
                )   = 1
)
, rules_texts as
(
    select      debtor.debtor_idx,

                case    when    debtor.prev_n_texts < rules.number_contacts
                        then    1
                        else    0
                        end     as is_priority_minimum_texts

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      =  'Text Message'
                    and debtor.days_since_placement >= rules.delay_days_placement
                    
    qualify     row_number() over (
                    partition by    debtor.debtor_idx
                    order by        case    when    debtor.prev_n_texts         < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    1
                                            else    0
                                            end     desc,
                                    case    when    debtor.prev_n_texts         < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    -rules.within_days_placement
                                            else    rules.within_days_placement
                                            end     desc
                )   = 1
)
, rules_voapps as
(
    select      debtor.debtor_idx,

                case    when    debtor.prev_n_voapps < rules.number_contacts
                        then    1
                        else    0
                        end     as is_priority_minimum_voapps

     from       debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      =  'VoApp'
                    and debtor.days_since_placement >= rules.delay_days_placement
                    
    qualify     row_number() over (
                    partition by    debtor.debtor_idx
                    order by        case    when    debtor.prev_n_voapps        < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    1
                                            else    0
                                            end     desc,
                                    case    when    debtor.prev_n_voapps        < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    -rules.within_days_placement
                                            else    rules.within_days_placement
                                            end     desc
                )   = 1
)
, rules_emails as
(
    select      debtor.debtor_idx,

                case    when    debtor.prev_n_emails < rules.number_contacts
                        then    1
                        else    0
                        end     as is_priority_minimum_emails

     from       debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      =  'Email'
                    and debtor.days_since_placement >= rules.delay_days_placement
                    
    qualify     row_number() over (
                    partition by    debtor.debtor_idx
                    order by        case    when    debtor.prev_n_emails        < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    1
                                            else    0
                                            end     desc,
                                    case    when    debtor.prev_n_emails        < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    -rules.within_days_placement
                                            else    rules.within_days_placement
                                            end     desc
                )   = 1
)
, rules_dialeragent as
(
    select      debtor.debtor_idx,

                case    when    debtor.prev_n_dialer_agent < rules.number_contacts
                        then    1
                        else    0
                        end     as is_priority_minimum_dialeragent

     from       debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      =  'Dialer-Agent Call'
                    and debtor.days_since_placement >= rules.delay_days_placement
                    
    qualify     row_number() over (
                    partition by    debtor.debtor_idx
                    order by        case    when    debtor.prev_n_dialer_agent  < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    1
                                            else    0
                                            end     desc,
                                    case    when    debtor.prev_n_dialer_agent  < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    -rules.within_days_placement
                                            else    rules.within_days_placement
                                            end     desc
                )   = 1
)
, rules_dialeragentless as
(
    select      debtor.debtor_idx,

                case    when    debtor.prev_n_dialer_agentless < rules.number_contacts
                        then    1
                        else    0
                        end     as is_priority_minimum_dialeragentless

     from       debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      =  'Dialer-Agentless Call'
                    and debtor.days_since_placement >= rules.delay_days_placement
                    
    qualify     row_number() over (
                    partition by    debtor.debtor_idx
                    order by        case    when    debtor.prev_n_dialer_agentless  < rules.number_contacts
                                            and     debtor.days_since_placement     < rules.within_days_placement
                                            then    1
                                            else    0
                                            end     desc,
                                    case    when    debtor.prev_n_dialer_agentless  < rules.number_contacts
                                            and     debtor.days_since_placement     < rules.within_days_placement
                                            then    -rules.within_days_placement
                                            else    rules.within_days_placement
                                            end     desc
                )   = 1
)
select      debtor.debtor_idx,
            debtor.pl_group,
            debtor.batch_date,
            debtor.days_since_placement,
            debtor.prev_n_letters                                                       as prev_n_letters_since_placement,
            debtor.prev_n_texts                                                         as prev_n_texts_since_placement,
            debtor.prev_n_voapps                                                        as prev_n_voapps_since_placement,
            debtor.prev_n_emails                                                        as prev_n_emails_since_placement,
            debtor.prev_n_dialer_agent                                                  as prev_n_dialer_agent_since_placement,
            debtor.prev_n_dialer_agentless                                              as prev_n_dialer_agentless_since_placement,

            coalesce(rules_letters.is_priority_minimum_letters,                     0)  as is_priority_minimum_letters,
            coalesce(rules_texts.is_priority_minimum_texts,                         0)  as is_priority_minimum_texts,
            coalesce(rules_voapps.is_priority_minimum_voapps,                       0)  as is_priority_minimum_voapps,
            coalesce(rules_emails.is_priority_minimum_emails,                       0)  as is_priority_minimum_emails,
            coalesce(rules_dialeragent.is_priority_minimum_dialeragent,             0)  as is_priority_minimum_dialeragent,
            coalesce(rules_dialeragentless.is_priority_minimum_dialeragentless,     0)  as is_priority_minimum_dialeragentless

from        debtor
            left join
                rules_letters
                on debtor.debtor_idx = rules_letters.debtor_idx
            left join
                rules_texts
                on debtor.debtor_idx = rules_texts.debtor_idx
            left join
                rules_voapps
                on debtor.debtor_idx = rules_voapps.debtor_idx
            left join
                rules_emails
                on debtor.debtor_idx = rules_emails.debtor_idx
            left join
                rules_dialeragent
                on debtor.debtor_idx = rules_dialeragent.debtor_idx
            left join
                rules_dialeragentless
                on debtor.debtor_idx = rules_dialeragentless.debtor_idx
            left join
                edwprodhh.hermes.master_config_treatment_router as router
                on debtor.debtor_idx = router.debtor_idx
;



create or replace task
    edwprodhh.pub_jchang.replace_transform_businessrules_contact_priority_minimums
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_contact_priority_minimums
as
with debtor as
(
    select      debtor.debtor_idx,
                debtor.pl_group,
                debtor.batch_date,

                router.treatment_group,

                datediff(day, debtor.batch_date, current_date())                                                                                                                        as days_since_placement,
                
                greatest(count(case when contacts_pkt.contact_type in ('Letter')        then contacts_pkt.contact_id end) - max(case when client.is_fdcpa = 1 then 1 else 0 end), 0)    as prev_n_letters, --want to send at least one letter after first packet-validation
                count(case when contacts_pkt.contact_type in ('VoApp')                  then contacts_pkt.contact_id end)                                                               as prev_n_voapps,
                count(case when contacts_pkt.contact_type in ('Text Message')           then contacts_pkt.contact_id end)                                                               as prev_n_texts,
                count(case when contacts_pkt.contact_type in ('Email')                  then contacts_pkt.contact_id end)                                                               as prev_n_emails,
                count(case when contacts_pkt.contact_type in ('Dialer-Agent Call')      then contacts_pkt.contact_id end)                                                               as prev_n_dialer_agent,
                count(case when contacts_pkt.contact_type in ('Dialer-Agentless Call')  then contacts_pkt.contact_id end)                                                               as prev_n_dialer_agentless

    from        edwprodhh.pub_jchang.master_debtor as debtor
                inner join
                    edwprodhh.pub_jchang.master_client as client
                    on debtor.client_idx = client.client_idx
                left join
                    edwprodhh.pub_jchang.transform_contacts as contacts_pkt
                    on  debtor.packet_idx           =  contacts_pkt.packet_idx
                    and contacts_pkt.contact_time   >= debtor.batch_date
                left join
                    edwprodhh.hermes.master_config_treatment_router as router
                    on debtor.debtor_idx = router.debtor_idx

    group by    1,2,3,4
)
, rules_letters as
(
    select      debtor.debtor_idx,

                --  2. Given the selected rule, is the rule satisfied? Prioritize when not.
                case    when    debtor.prev_n_letters < rules.number_contacts
                        then    1
                        else    0
                        end     as is_priority_minimum_letters

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      =  'Letter'
                    and debtor.days_since_placement >= rules.delay_days_placement
    
    --  1. Select the rule to evaluate.
    --      There can be multiple rules for multiple channels.
    --      We evaluate channels separately.
    --      For each rule take the 
    --      For each channel, keep the rule longest range, unless you are BOTH
    --          i) under range of another AND
    --          ii) under limit of the same one.
    --          If above conditions are satisfied for multiple, keep the rule with the shorter range.

    qualify     row_number() over (
                    partition by    debtor.debtor_idx
                    order by        --  Prioritize rule when both under-contact and under-limit.
                                    case    when    debtor.prev_n_letters       < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    1
                                            else    0
                                            end     desc,
                                    --  When both under-contact and under-limit: take SHORTEST day limit when multiple rules eligible. The negative is intentional.
                                    --  Otherwise, take LONGEST day limit.
                                    case    when    debtor.prev_n_letters       < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    -rules.within_days_placement
                                            else    rules.within_days_placement
                                            end     desc
                )   = 1
)
, rules_texts as
(
    select      debtor.debtor_idx,

                case    when    debtor.prev_n_texts < rules.number_contacts
                        then    1
                        else    0
                        end     as is_priority_minimum_texts

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      =  'Text Message'
                    and debtor.days_since_placement >= rules.delay_days_placement
                    
    qualify     row_number() over (
                    partition by    debtor.debtor_idx
                    order by        case    when    debtor.prev_n_texts         < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    1
                                            else    0
                                            end     desc,
                                    case    when    debtor.prev_n_texts         < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    -rules.within_days_placement
                                            else    rules.within_days_placement
                                            end     desc
                )   = 1
)
, rules_voapps as
(
    select      debtor.debtor_idx,

                case    when    debtor.prev_n_voapps < rules.number_contacts
                        then    1
                        else    0
                        end     as is_priority_minimum_voapps

     from       debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      =  'VoApp'
                    and debtor.days_since_placement >= rules.delay_days_placement
                    
    qualify     row_number() over (
                    partition by    debtor.debtor_idx
                    order by        case    when    debtor.prev_n_voapps        < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    1
                                            else    0
                                            end     desc,
                                    case    when    debtor.prev_n_voapps        < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    -rules.within_days_placement
                                            else    rules.within_days_placement
                                            end     desc
                )   = 1
)
, rules_emails as
(
    select      debtor.debtor_idx,

                case    when    debtor.prev_n_emails < rules.number_contacts
                        then    1
                        else    0
                        end     as is_priority_minimum_emails

     from       debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      =  'Email'
                    and debtor.days_since_placement >= rules.delay_days_placement
                    
    qualify     row_number() over (
                    partition by    debtor.debtor_idx
                    order by        case    when    debtor.prev_n_emails        < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    1
                                            else    0
                                            end     desc,
                                    case    when    debtor.prev_n_emails        < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    -rules.within_days_placement
                                            else    rules.within_days_placement
                                            end     desc
                )   = 1
)
, rules_dialeragent as
(
    select      debtor.debtor_idx,

                case    when    debtor.prev_n_dialer_agent < rules.number_contacts
                        then    1
                        else    0
                        end     as is_priority_minimum_dialeragent

     from       debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      =  'Dialer-Agent Call'
                    and debtor.days_since_placement >= rules.delay_days_placement
                    
    qualify     row_number() over (
                    partition by    debtor.debtor_idx
                    order by        case    when    debtor.prev_n_dialer_agent  < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    1
                                            else    0
                                            end     desc,
                                    case    when    debtor.prev_n_dialer_agent  < rules.number_contacts
                                            and     debtor.days_since_placement < rules.within_days_placement
                                            then    -rules.within_days_placement
                                            else    rules.within_days_placement
                                            end     desc
                )   = 1
)
, rules_dialeragentless as
(
    select      debtor.debtor_idx,

                case    when    debtor.prev_n_dialer_agentless < rules.number_contacts
                        then    1
                        else    0
                        end     as is_priority_minimum_dialeragentless

     from       debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      =  'Dialer-Agentless Call'
                    and debtor.days_since_placement >= rules.delay_days_placement
                    
    qualify     row_number() over (
                    partition by    debtor.debtor_idx
                    order by        case    when    debtor.prev_n_dialer_agentless  < rules.number_contacts
                                            and     debtor.days_since_placement     < rules.within_days_placement
                                            then    1
                                            else    0
                                            end     desc,
                                    case    when    debtor.prev_n_dialer_agentless  < rules.number_contacts
                                            and     debtor.days_since_placement     < rules.within_days_placement
                                            then    -rules.within_days_placement
                                            else    rules.within_days_placement
                                            end     desc
                )   = 1
)
select      debtor.debtor_idx,
            debtor.pl_group,
            debtor.batch_date,
            debtor.days_since_placement,
            debtor.prev_n_letters                                                       as prev_n_letters_since_placement,
            debtor.prev_n_texts                                                         as prev_n_texts_since_placement,
            debtor.prev_n_voapps                                                        as prev_n_voapps_since_placement,
            debtor.prev_n_emails                                                        as prev_n_emails_since_placement,
            debtor.prev_n_dialer_agent                                                  as prev_n_dialer_agent_since_placement,
            debtor.prev_n_dialer_agentless                                              as prev_n_dialer_agentless_since_placement,

            coalesce(rules_letters.is_priority_minimum_letters,                     0)  as is_priority_minimum_letters,
            coalesce(rules_texts.is_priority_minimum_texts,                         0)  as is_priority_minimum_texts,
            coalesce(rules_voapps.is_priority_minimum_voapps,                       0)  as is_priority_minimum_voapps,
            coalesce(rules_emails.is_priority_minimum_emails,                       0)  as is_priority_minimum_emails,
            coalesce(rules_dialeragent.is_priority_minimum_dialeragent,             0)  as is_priority_minimum_dialeragent,
            coalesce(rules_dialeragentless.is_priority_minimum_dialeragentless,     0)  as is_priority_minimum_dialeragentless

from        debtor
            left join
                rules_letters
                on debtor.debtor_idx = rules_letters.debtor_idx
            left join
                rules_texts
                on debtor.debtor_idx = rules_texts.debtor_idx
            left join
                rules_voapps
                on debtor.debtor_idx = rules_voapps.debtor_idx
            left join
                rules_emails
                on debtor.debtor_idx = rules_emails.debtor_idx
            left join
                rules_dialeragent
                on debtor.debtor_idx = rules_dialeragent.debtor_idx
            left join
                rules_dialeragentless
                on debtor.debtor_idx = rules_dialeragentless.debtor_idx
            left join
                edwprodhh.hermes.master_config_treatment_router as router
                on debtor.debtor_idx = router.debtor_idx
;