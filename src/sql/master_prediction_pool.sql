create or replace table
    edwprodhh.hermes.master_prediction_pool
as
with joined as
(
    select      debtor.debtor_idx,
                debtor.client_idx,
                debtor.pl_group,

                router.treatment_group,
                router.treatment_description,
                router.test_name,
                router.test_description,

                client_active.pass_client_active_hermes_contacts,

                debtor_status.status,
                debtor_status.cancel_dt,
                debtor_status.pass_debtor_status,
                debtor_status.pass_debtor_active,

                client_config.is_client_allowed_letters as pass_client_allowed_letters,
                client_config.is_client_allowed_texts   as pass_client_allowed_texts,
                client_config.is_client_allowed_voapps  as pass_client_allowed_voapps,
                client_config.is_client_allowed_calls   as pass_client_allowed_calls,

                validation_requirement.requires_validation,
                validation_requirement.pass_received_validation,
                -- validation_requirement.pass_age_validation,
                -- validation_requirement.pass_validation_requirement_debtor,
                -- validation_requirement.pass_validation_requirement,
                validation_requirement.pass_validation_age_nonoffer,
                validation_requirement.pass_validation_age_offer,
                validation_requirement.pass_validation_requirement_debtor_nonoffer,
                validation_requirement.pass_validation_requirement_debtor_offer,
                validation_requirement.pass_validation_requirement_nonoffer,
                validation_requirement.pass_validation_requirement_offer,
                validation_requirement.validation_letter_date,

                address_allowed_email.email_address,
                address_allowed_email.pass_address_emails,

                address_allowed_mail.mailing_address,
                address_allowed_mail.mailing_city,
                address_allowed_mail.mailing_state,
                address_allowed_mail.mailing_zip_code,
                address_allowed_mail.pass_address_letters,

                address_allowed_phone.valid_phone_number_voapps,
                address_allowed_phone.valid_phone_number_texts,
                address_allowed_phone.valid_phone_number_dialer,
                address_allowed_phone.phone_number_debtor,
                address_allowed_phone.cell_code_debtor,
                address_allowed_phone.cell_code_packet_agg,
                address_allowed_phone.cell_code_packet_factorized,
                address_allowed_phone.cell_code_packet,
                address_allowed_phone.phone_number_source,
                address_allowed_phone.current_status_phone,
                address_allowed_phone.commercial_code,
                address_allowed_phone.state,
                address_allowed_phone.is_fdcpa,
                address_allowed_phone.ash_cli,
                address_allowed_phone.payplan,
                address_allowed_phone.pass_phone_voapps,
                address_allowed_phone.pass_phone_texts,
                address_allowed_phone.pass_phone_calls,

                contact_cooldown.next_date_letters,
                contact_cooldown.prev_n_contacts,
                contact_cooldown.prev_n_letters,
                contact_cooldown.prev_n_voapps,
                contact_cooldown.prev_n_texts,
                contact_cooldown.prev_n_emails,
                contact_cooldown.prev_n_inbounds,
                contact_cooldown.prev_n_dialer_agent,
                contact_cooldown.prev_n_dialer_agentless,
                contact_cooldown.prev_n_outbound_manual,
                contact_cooldown.prev_n_voapps_7,
                contact_cooldown.prev_n_dialer_agent_7,
                contact_cooldown.prev_n_dialer_agentless_7,
                contact_cooldown.prev_n_outbound_manual_7,
                contact_cooldown.prev_date_contacts,
                contact_cooldown.prev_date_letters,
                contact_cooldown.prev_date_voapps,
                contact_cooldown.prev_date_texts,
                contact_cooldown.prev_date_emails,
                contact_cooldown.prev_date_inbounds,
                contact_cooldown.prev_date_dialer_agent,
                contact_cooldown.prev_date_dialer_agentless,
                contact_cooldown.prev_date_outbound_manual,
                contact_cooldown.prev_date_rpc,
                contact_cooldown.pass_letters_warmup,
                contact_cooldown.pass_letters_cooldown,
                contact_cooldown.pass_voapps_cooldown,
                contact_cooldown.pass_texts_cooldown,
                contact_cooldown.pass_7in7,

                contact_minimums.batch_date,
                contact_minimums.days_since_placement,
                contact_minimums.prev_n_letters_since_placement,
                contact_minimums.prev_n_texts_since_placement,
                contact_minimums.prev_n_voapps_since_placement,
                contact_minimums.prev_n_emails_since_placement,
                contact_minimums.prev_n_dialer_agent_since_placement,
                contact_minimums.prev_n_dialer_agentless_since_placement,
                contact_minimums.is_priority_minimum_letters,
                contact_minimums.is_priority_minimum_texts,
                contact_minimums.is_priority_minimum_voapps,
                contact_minimums.is_priority_minimum_emails,
                contact_minimums.is_priority_minimum_dialeragent,
                contact_minimums.is_priority_minimum_dialeragentless,
                contact_delay.pass_delay_letters,
                contact_delay.pass_delay_texts,
                contact_delay.pass_delay_voapps,
                contact_delay.pass_delay_emails,
                contact_delay.pass_delay_dialeragent,
                contact_delay.pass_delay_dialeragentless,
                
                debtor_balance.assigned,
                debtor_balance.balance_dimdebtor,
                debtor_balance.balance_dimdebtor_packet_ as balance_dimdebtor_packet,
                debtor_balance.pass_debtor_balance,
                debtor_balance.pass_packet_balance,
                debtor_balance.pass_debtor_assigned,
                
                debtor_experian.experian_score,
                debtor_experian.pass_debtor_experian,

                debtor_income.median_household_income,
                debtor_income.pass_debtor_income,
                
                debtor_lastpayment.packet_has_previous_payment,
                debtor_lastpayment.debtor_is_first_in_packet,
                debtor_lastpayment.last_payment_date,
                debtor_lastpayment.pass_contraints_packet_last_payment,

                debtor_payplan.desk_team_name,
                debtor_payplan.pass_existing_payplan,
                
                debtor_maturity.age_placement,
                debtor_maturity.age_debt,
                debtor_maturity.age_packet,
                debtor_maturity.pass_debtor_age_debt,
                debtor_maturity.pass_debtor_age_placement,
                debtor_maturity.pass_debtor_age_packet,

                debtor_taxyear.tax_year,
                debtor_taxyear.pass_debtor_tax_year,

                debtor_debttype.is_debttype_gov_parking,
                debtor_debttype.is_debttype_gov_toll,
                debtor_debttype.is_debttype_hc_ai,
                debtor_debttype.is_debttype_hc_sp,

                debtor_scorehist.pass_debtor_first_score_dialer_agent
                
                

    from        edwprodhh.pub_jchang.master_debtor as debtor

                inner join edwprodhh.hermes.master_config_plgroup                               as client_config                on debtor.pl_group   = client_config.pl_group
                inner join edwprodhh.hermes.transform_criteria_debtor_client_active             as client_active                on debtor.debtor_idx = client_active.debtor_idx
                inner join edwprodhh.hermes.transform_criteria_debtor_status                    as debtor_status                on debtor.debtor_idx = debtor_status.debtor_idx
                inner join edwprodhh.hermes.transform_criteria_validation_requirement           as validation_requirement       on debtor.debtor_idx = validation_requirement.debtor_idx
                inner join edwprodhh.hermes.transform_criteria_address_allowed_email            as address_allowed_email        on debtor.debtor_idx = address_allowed_email.debtor_idx
                inner join edwprodhh.hermes.transform_criteria_address_allowed_mail             as address_allowed_mail         on debtor.debtor_idx = address_allowed_mail.debtor_idx
                inner join edwprodhh.hermes.transform_criteria_address_allowed_phone            as address_allowed_phone        on debtor.debtor_idx = address_allowed_phone.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_contact_cooldown            as contact_cooldown             on debtor.debtor_idx = contact_cooldown.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_contact_priority_minimums   as contact_minimums             on debtor.debtor_idx = contact_minimums.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_contact_priority_delay      as contact_delay                on debtor.debtor_idx = contact_delay.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_balance              as debtor_balance               on debtor.debtor_idx = debtor_balance.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_experian             as debtor_experian              on debtor.debtor_idx = debtor_experian.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_income               as debtor_income                on debtor.debtor_idx = debtor_income.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_lastpayment          as debtor_lastpayment           on debtor.debtor_idx = debtor_lastpayment.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_maturity             as debtor_maturity              on debtor.debtor_idx = debtor_maturity.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_taxyear              as debtor_taxyear               on debtor.debtor_idx = debtor_taxyear.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_payplan              as debtor_payplan               on debtor.debtor_idx = debtor_payplan.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_score_history        as debtor_scorehist             on debtor.debtor_idx = debtor_scorehist.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_debttype             as debtor_debttype              on debtor.debtor_idx = debtor_debttype.debtor_idx
                inner join edwprodhh.hermes.master_config_treatment_router                      as router                       on debtor.debtor_idx = router.debtor_idx
)
select      *,

            case    when    pass_client_active_hermes_contacts      =   1
                    and     pass_client_allowed_letters             =   1
                    and     pass_validation_requirement_offer       =   1
                    and     pass_debtor_status                      =   1
                    and     pass_debtor_active                      =   1
                    and     pass_address_letters                    =   1
                    and     pass_packet_balance                     =   1
                    and     pass_debtor_age_packet                  =   1
                    and     pass_letters_cooldown                   =   1
                    and     pass_letters_warmup                     =   1
                    and     pass_delay_letters                      =   1
                    then    1
                    else    0
                    end     as is_eligible_letters,

            case    when    pass_client_active_hermes_contacts      =   1
                    and     pass_client_allowed_texts               =   1
                    and     pass_validation_requirement_nonoffer    =   1
                    and     pass_debtor_status                      =   1
                    and     pass_debtor_active                      =   1
                    and     pass_phone_texts                        =   1
                    and     pass_debtor_balance                     =   1
                    and     pass_packet_balance                     =   1
                    and     pass_debtor_age_packet                  =   1
                    and     pass_texts_cooldown                     =   1
                    and     pass_delay_texts                        =   1
                    then    1
                    else    0
                    end     as is_eligible_texts,

            case    when    pass_client_active_hermes_contacts      =   1
                    and     pass_client_allowed_voapps              =   1
                    and     pass_validation_requirement_nonoffer    =   1
                    and     pass_debtor_status                      =   1
                    and     pass_debtor_active                      =   1
                    and     pass_phone_voapps                       =   1
                    and     pass_debtor_balance                     =   1
                    and     pass_packet_balance                     =   1
                    and     pass_debtor_age_packet                  =   1
                    and     pass_voapps_cooldown                    =   1
                    and     pass_delay_voapps                       =   1
                    and     pass_7in7                               =   1
                    then    1
                    else    0
                    end     as is_eligible_voapps,


            NULL as is_eligible_emails,
            
            case    when    pass_client_allowed_calls               in  (0,1)
                    and     pass_validation_requirement_nonoffer    =   1
                    and     pass_debtor_status                      =   1
                    and     pass_debtor_active                      =   1
                    and     pass_phone_calls                        =   1
                    and     pass_delay_dialeragent                  =   1
                    and     pass_7in7                               =   1
                    then    1
                    else    0
                    end     as is_eligible_dialer_agent,


            NULL as is_eligible_dialer_agentless,

            case    when    pass_debtor_status                      =   1
                    and     pass_debtor_active                      =   1
                    then    1
                    else    0
                    end     as is_eligible_debtor

from        joined
;



create or replace task
    edwprodhh.pub_jchang.replace_master_prediction_pool
    warehouse = analysis_wh
    after       edwprodhh.pub_jchang.replace_transform_businessrules_contact_cooldown,
                edwprodhh.pub_jchang.replace_transform_businessrules_contact_priority_minimums,
                edwprodhh.pub_jchang.replace_transform_businessrules_contact_priority_delay,
                edwprodhh.pub_jchang.replace_transform_businessrules_debtor_balance,
                edwprodhh.pub_jchang.replace_transform_businessrules_debtor_taxyear,
                edwprodhh.pub_jchang.replace_transform_businessrules_debtor_payplan,
                edwprodhh.pub_jchang.replace_transform_businessrules_debtor_maturity,
                edwprodhh.pub_jchang.replace_transform_businessrules_debtor_lastpayment,
                edwprodhh.pub_jchang.replace_transform_businessrules_debtor_income,
                edwprodhh.pub_jchang.replace_transform_businessrules_debtor_experian,
                edwprodhh.pub_jchang.replace_transform_businessrules_debtor_debttype,
                edwprodhh.pub_jchang.replace_transform_businessrules_debtor_score_history,
                edwprodhh.pub_jchang.replace_transform_criteria_validation_requirement,
                edwprodhh.pub_jchang.replace_transform_criteria_debtor_status,
                edwprodhh.pub_jchang.replace_transform_criteria_debtor_client_active,
                edwprodhh.pub_jchang.replace_transform_criteria_address_allowed_phone,
                edwprodhh.pub_jchang.replace_transform_criteria_address_allowed_mail,
                edwprodhh.pub_jchang.replace_transform_criteria_address_allowed_email
as
create or replace table
    edwprodhh.hermes.master_prediction_pool
as
with joined as
(
    select      debtor.debtor_idx,
                debtor.client_idx,
                debtor.pl_group,

                router.treatment_group,
                router.treatment_description,
                router.test_name,
                router.test_description,

                client_active.pass_client_active_hermes_contacts,

                debtor_status.status,
                debtor_status.cancel_dt,
                debtor_status.pass_debtor_status,
                debtor_status.pass_debtor_active,

                client_config.is_client_allowed_letters as pass_client_allowed_letters,
                client_config.is_client_allowed_texts   as pass_client_allowed_texts,
                client_config.is_client_allowed_voapps  as pass_client_allowed_voapps,
                client_config.is_client_allowed_calls   as pass_client_allowed_calls,

                validation_requirement.requires_validation,
                validation_requirement.pass_received_validation,
                -- validation_requirement.pass_age_validation,
                -- validation_requirement.pass_validation_requirement_debtor,
                -- validation_requirement.pass_validation_requirement,
                validation_requirement.pass_validation_age_nonoffer,
                validation_requirement.pass_validation_age_offer,
                validation_requirement.pass_validation_requirement_debtor_nonoffer,
                validation_requirement.pass_validation_requirement_debtor_offer,
                validation_requirement.pass_validation_requirement_nonoffer,
                validation_requirement.pass_validation_requirement_offer,
                validation_requirement.validation_letter_date,

                address_allowed_email.email_address,
                address_allowed_email.pass_address_emails,

                address_allowed_mail.mailing_address,
                address_allowed_mail.mailing_city,
                address_allowed_mail.mailing_state,
                address_allowed_mail.mailing_zip_code,
                address_allowed_mail.pass_address_letters,

                address_allowed_phone.valid_phone_number_voapps,
                address_allowed_phone.valid_phone_number_texts,
                address_allowed_phone.valid_phone_number_dialer,
                address_allowed_phone.phone_number_debtor,
                address_allowed_phone.cell_code_debtor,
                address_allowed_phone.cell_code_packet_agg,
                address_allowed_phone.cell_code_packet_factorized,
                address_allowed_phone.cell_code_packet,
                address_allowed_phone.phone_number_source,
                address_allowed_phone.current_status_phone,
                address_allowed_phone.commercial_code,
                address_allowed_phone.state,
                address_allowed_phone.is_fdcpa,
                address_allowed_phone.ash_cli,
                address_allowed_phone.payplan,
                address_allowed_phone.pass_phone_voapps,
                address_allowed_phone.pass_phone_texts,
                address_allowed_phone.pass_phone_calls,

                contact_cooldown.next_date_letters,
                contact_cooldown.prev_n_contacts,
                contact_cooldown.prev_n_letters,
                contact_cooldown.prev_n_voapps,
                contact_cooldown.prev_n_texts,
                contact_cooldown.prev_n_emails,
                contact_cooldown.prev_n_inbounds,
                contact_cooldown.prev_n_dialer_agent,
                contact_cooldown.prev_n_dialer_agentless,
                contact_cooldown.prev_n_outbound_manual,
                contact_cooldown.prev_n_voapps_7,
                contact_cooldown.prev_n_dialer_agent_7,
                contact_cooldown.prev_n_dialer_agentless_7,
                contact_cooldown.prev_n_outbound_manual_7,
                contact_cooldown.prev_date_contacts,
                contact_cooldown.prev_date_letters,
                contact_cooldown.prev_date_voapps,
                contact_cooldown.prev_date_texts,
                contact_cooldown.prev_date_emails,
                contact_cooldown.prev_date_inbounds,
                contact_cooldown.prev_date_dialer_agent,
                contact_cooldown.prev_date_dialer_agentless,
                contact_cooldown.prev_date_outbound_manual,
                contact_cooldown.prev_date_rpc,
                contact_cooldown.pass_letters_warmup,
                contact_cooldown.pass_letters_cooldown,
                contact_cooldown.pass_voapps_cooldown,
                contact_cooldown.pass_texts_cooldown,
                contact_cooldown.pass_7in7,

                contact_minimums.batch_date,
                contact_minimums.days_since_placement,
                contact_minimums.prev_n_letters_since_placement,
                contact_minimums.prev_n_texts_since_placement,
                contact_minimums.prev_n_voapps_since_placement,
                contact_minimums.prev_n_emails_since_placement,
                contact_minimums.prev_n_dialer_agent_since_placement,
                contact_minimums.prev_n_dialer_agentless_since_placement,
                contact_minimums.is_priority_minimum_letters,
                contact_minimums.is_priority_minimum_texts,
                contact_minimums.is_priority_minimum_voapps,
                contact_minimums.is_priority_minimum_emails,
                contact_minimums.is_priority_minimum_dialeragent,
                contact_minimums.is_priority_minimum_dialeragentless,
                contact_delay.pass_delay_letters,
                contact_delay.pass_delay_texts,
                contact_delay.pass_delay_voapps,
                contact_delay.pass_delay_emails,
                contact_delay.pass_delay_dialeragent,
                contact_delay.pass_delay_dialeragentless,
                
                debtor_balance.assigned,
                debtor_balance.balance_dimdebtor,
                debtor_balance.balance_dimdebtor_packet_ as balance_dimdebtor_packet,
                debtor_balance.pass_debtor_balance,
                debtor_balance.pass_packet_balance,
                debtor_balance.pass_debtor_assigned,
                
                debtor_experian.experian_score,
                debtor_experian.pass_debtor_experian,

                debtor_income.median_household_income,
                debtor_income.pass_debtor_income,
                
                debtor_lastpayment.packet_has_previous_payment,
                debtor_lastpayment.debtor_is_first_in_packet,
                debtor_lastpayment.last_payment_date,
                debtor_lastpayment.pass_contraints_packet_last_payment,

                debtor_payplan.desk_team_name,
                debtor_payplan.pass_existing_payplan,
                
                debtor_maturity.age_placement,
                debtor_maturity.age_debt,
                debtor_maturity.age_packet,
                debtor_maturity.pass_debtor_age_debt,
                debtor_maturity.pass_debtor_age_placement,
                debtor_maturity.pass_debtor_age_packet,

                debtor_taxyear.tax_year,
                debtor_taxyear.pass_debtor_tax_year,

                debtor_debttype.is_debttype_gov_parking,
                debtor_debttype.is_debttype_gov_toll,
                debtor_debttype.is_debttype_hc_ai,
                debtor_debttype.is_debttype_hc_sp,

                debtor_scorehist.pass_debtor_first_score_dialer_agent
                
                

    from        edwprodhh.pub_jchang.master_debtor as debtor

                inner join edwprodhh.hermes.master_config_plgroup                               as client_config                on debtor.pl_group   = client_config.pl_group
                inner join edwprodhh.hermes.transform_criteria_debtor_client_active             as client_active                on debtor.debtor_idx = client_active.debtor_idx
                inner join edwprodhh.hermes.transform_criteria_debtor_status                    as debtor_status                on debtor.debtor_idx = debtor_status.debtor_idx
                inner join edwprodhh.hermes.transform_criteria_validation_requirement           as validation_requirement       on debtor.debtor_idx = validation_requirement.debtor_idx
                inner join edwprodhh.hermes.transform_criteria_address_allowed_email            as address_allowed_email        on debtor.debtor_idx = address_allowed_email.debtor_idx
                inner join edwprodhh.hermes.transform_criteria_address_allowed_mail             as address_allowed_mail         on debtor.debtor_idx = address_allowed_mail.debtor_idx
                inner join edwprodhh.hermes.transform_criteria_address_allowed_phone            as address_allowed_phone        on debtor.debtor_idx = address_allowed_phone.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_contact_cooldown            as contact_cooldown             on debtor.debtor_idx = contact_cooldown.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_contact_priority_minimums   as contact_minimums             on debtor.debtor_idx = contact_minimums.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_contact_priority_delay      as contact_delay                on debtor.debtor_idx = contact_delay.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_balance              as debtor_balance               on debtor.debtor_idx = debtor_balance.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_experian             as debtor_experian              on debtor.debtor_idx = debtor_experian.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_income               as debtor_income                on debtor.debtor_idx = debtor_income.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_lastpayment          as debtor_lastpayment           on debtor.debtor_idx = debtor_lastpayment.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_maturity             as debtor_maturity              on debtor.debtor_idx = debtor_maturity.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_taxyear              as debtor_taxyear               on debtor.debtor_idx = debtor_taxyear.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_payplan              as debtor_payplan               on debtor.debtor_idx = debtor_payplan.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_score_history        as debtor_scorehist             on debtor.debtor_idx = debtor_scorehist.debtor_idx
                inner join edwprodhh.hermes.transform_businessrules_debtor_debttype             as debtor_debttype              on debtor.debtor_idx = debtor_debttype.debtor_idx
                inner join edwprodhh.hermes.master_config_treatment_router                      as router                       on debtor.debtor_idx = router.debtor_idx
)
select      *,

            case    when    pass_client_active_hermes_contacts      =   1
                    and     pass_client_allowed_letters             =   1
                    and     pass_validation_requirement_offer       =   1
                    and     pass_debtor_status                      =   1
                    and     pass_debtor_active                      =   1
                    and     pass_address_letters                    =   1
                    and     pass_packet_balance                     =   1
                    and     pass_debtor_age_packet                  =   1
                    and     pass_letters_cooldown                   =   1
                    and     pass_letters_warmup                     =   1
                    and     pass_delay_letters                      =   1
                    then    1
                    else    0
                    end     as is_eligible_letters,

            case    when    pass_client_active_hermes_contacts      =   1
                    and     pass_client_allowed_texts               =   1
                    and     pass_validation_requirement_nonoffer    =   1
                    and     pass_debtor_status                      =   1
                    and     pass_debtor_active                      =   1
                    and     pass_phone_texts                        =   1
                    and     pass_debtor_balance                     =   1
                    and     pass_packet_balance                     =   1
                    and     pass_debtor_age_packet                  =   1
                    and     pass_texts_cooldown                     =   1
                    and     pass_delay_texts                        =   1
                    then    1
                    else    0
                    end     as is_eligible_texts,

            case    when    pass_client_active_hermes_contacts      =   1
                    and     pass_client_allowed_voapps              =   1
                    and     pass_validation_requirement_nonoffer    =   1
                    and     pass_debtor_status                      =   1
                    and     pass_debtor_active                      =   1
                    and     pass_phone_voapps                       =   1
                    and     pass_debtor_balance                     =   1
                    and     pass_packet_balance                     =   1
                    and     pass_debtor_age_packet                  =   1
                    and     pass_voapps_cooldown                    =   1
                    and     pass_delay_voapps                       =   1
                    and     pass_7in7                               =   1
                    then    1
                    else    0
                    end     as is_eligible_voapps,


            NULL as is_eligible_emails,
            
            case    when    pass_client_allowed_calls               in  (0,1)
                    and     pass_validation_requirement_nonoffer    =   1
                    and     pass_debtor_status                      =   1
                    and     pass_debtor_active                      =   1
                    and     pass_phone_calls                        =   1
                    and     pass_delay_dialeragent                  =   1
                    and     pass_7in7                               =   1
                    then    1
                    else    0
                    end     as is_eligible_dialer_agent,


            NULL as is_eligible_dialer_agentless,

            case    when    pass_debtor_status                      =   1
                    and     pass_debtor_active                      =   1
                    then    1
                    else    0
                    end     as is_eligible_debtor

from        joined
;