create or replace table
    edwprodhh.hermes.transform_businessrules_contact_priority_delay
as
with debtor as
(
    select      debtor.debtor_idx,
                debtor.pl_group,
                debtor.batch_date,
                datediff(day, debtor.batch_date, current_date()) as days_since_placement,

                router.treatment_group

    from        edwprodhh.pub_jchang.master_debtor as debtor
                left join
                    edwprodhh.hermes.master_config_treatment_router as router
                    on debtor.debtor_idx = router.debtor_idx
)
, rules_letters as
(
    select      debtor.debtor_idx,

                case    when    debtor.days_since_placement >= rules.delay_days_placement
                        then    1
                        else    0
                        end     as pass_delay_letters

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      = 'Letter'

    qualify     row_number() over (partition by debtor.debtor_idx order by rules.delay_days_placement desc) = 1
)
, rules_texts as
(
    select      debtor.debtor_idx,

                case    when    debtor.days_since_placement >= rules.delay_days_placement
                        then    1
                        else    0
                        end     as pass_delay_texts

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      = 'Text Message'

    qualify     row_number() over (partition by debtor.debtor_idx order by rules.delay_days_placement desc) = 1
)
, rules_voapps as
(
    select      debtor.debtor_idx,

                case    when    debtor.days_since_placement >= rules.delay_days_placement
                        then    1
                        else    0
                        end     as pass_delay_voapps

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      = 'VoApp'

    qualify     row_number() over (partition by debtor.debtor_idx order by rules.delay_days_placement desc) = 1
)
, rules_emails as
(
    select      debtor.debtor_idx,

                case    when    debtor.days_since_placement >= rules.delay_days_placement
                        then    1
                        else    0
                        end     as pass_delay_emails

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      = 'Email'

    qualify     row_number() over (partition by debtor.debtor_idx order by rules.delay_days_placement desc) = 1
)
, rules_dialeragent as
(
    select      debtor.debtor_idx,

                case    when    debtor.days_since_placement >= rules.delay_days_placement
                        then    1
                        else    0
                        end     as pass_delay_dialeragent

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      = 'Dialer-Agent Call'

    qualify     row_number() over (partition by debtor.debtor_idx order by rules.delay_days_placement desc) = 1
)
, rules_dialeragentless as
(
    select      debtor.debtor_idx,

                case    when    debtor.days_since_placement >= rules.delay_days_placement
                        then    1
                        else    0
                        end     as pass_delay_dialeragentless

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      = 'Dialer-Agentless Call'

    qualify     row_number() over (partition by debtor.debtor_idx order by rules.delay_days_placement desc) = 1
)
select      debtor.debtor_idx,
            debtor.pl_group,
            debtor.batch_date,
            debtor.days_since_placement,

            coalesce(rules_letters.pass_delay_letters,                  1)  as pass_delay_letters,
            coalesce(rules_texts.pass_delay_texts,                      1)  as pass_delay_texts,
            coalesce(rules_voapps.pass_delay_voapps,                    1)  as pass_delay_voapps,
            coalesce(rules_emails.pass_delay_emails,                    1)  as pass_delay_emails,
            coalesce(rules_dialeragent.pass_delay_dialeragent,          1)  as pass_delay_dialeragent,
            coalesce(rules_dialeragentless.pass_delay_dialeragentless,  1)  as pass_delay_dialeragentless

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
    edwprodhh.pub_jchang.replace_transform_businessrules_contact_priority_delay
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_contact_priority_delay
as
with debtor as
(
    select      debtor.debtor_idx,
                debtor.pl_group,
                debtor.batch_date,
                datediff(day, debtor.batch_date, current_date()) as days_since_placement,

                router.treatment_group

    from        edwprodhh.pub_jchang.master_debtor as debtor
                left join
                    edwprodhh.hermes.master_config_treatment_router as router
                    on debtor.debtor_idx = router.debtor_idx
)
, rules_letters as
(
    select      debtor.debtor_idx,

                case    when    debtor.days_since_placement >= rules.delay_days_placement
                        then    1
                        else    0
                        end     as pass_delay_letters

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      = 'Letter'

    qualify     row_number() over (partition by debtor.debtor_idx order by rules.delay_days_placement desc) = 1
)
, rules_texts as
(
    select      debtor.debtor_idx,

                case    when    debtor.days_since_placement >= rules.delay_days_placement
                        then    1
                        else    0
                        end     as pass_delay_texts

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      = 'Text Message'

    qualify     row_number() over (partition by debtor.debtor_idx order by rules.delay_days_placement desc) = 1
)
, rules_voapps as
(
    select      debtor.debtor_idx,

                case    when    debtor.days_since_placement >= rules.delay_days_placement
                        then    1
                        else    0
                        end     as pass_delay_voapps

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      = 'VoApp'

    qualify     row_number() over (partition by debtor.debtor_idx order by rules.delay_days_placement desc) = 1
)
, rules_emails as
(
    select      debtor.debtor_idx,

                case    when    debtor.days_since_placement >= rules.delay_days_placement
                        then    1
                        else    0
                        end     as pass_delay_emails

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      = 'Email'

    qualify     row_number() over (partition by debtor.debtor_idx order by rules.delay_days_placement desc) = 1
)
, rules_dialeragent as
(
    select      debtor.debtor_idx,

                case    when    debtor.days_since_placement >= rules.delay_days_placement
                        then    1
                        else    0
                        end     as pass_delay_dialeragent

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      = 'Dialer-Agent Call'

    qualify     row_number() over (partition by debtor.debtor_idx order by rules.delay_days_placement desc) = 1
)
, rules_dialeragentless as
(
    select      debtor.debtor_idx,

                case    when    debtor.days_since_placement >= rules.delay_days_placement
                        then    1
                        else    0
                        end     as pass_delay_dialeragentless

    from        debtor
                inner join
                    edwprodhh.hermes.master_config_contact_minimums as rules
                    on  (debtor.pl_group            =  rules.pl_group        or rules.pl_group           = 'ALL')
                    and (debtor.treatment_group     =  rules.treatment_group or rules.treatment_group    = 'ALL')
                    and rules.proposed_channel      = 'Dialer-Agentless Call'

    qualify     row_number() over (partition by debtor.debtor_idx order by rules.delay_days_placement desc) = 1
)
select      debtor.debtor_idx,
            debtor.pl_group,
            debtor.batch_date,
            debtor.days_since_placement,

            coalesce(rules_letters.pass_delay_letters,                  1)  as pass_delay_letters,
            coalesce(rules_texts.pass_delay_texts,                      1)  as pass_delay_texts,
            coalesce(rules_voapps.pass_delay_voapps,                    1)  as pass_delay_voapps,
            coalesce(rules_emails.pass_delay_emails,                    1)  as pass_delay_emails,
            coalesce(rules_dialeragent.pass_delay_dialeragent,          1)  as pass_delay_dialeragent,
            coalesce(rules_dialeragentless.pass_delay_dialeragentless,  1)  as pass_delay_dialeragentless

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