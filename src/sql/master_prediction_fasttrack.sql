create table
    edwprodhh.hermes.master_prediction_fasttrack
(
    debtor_idx          varchar,
    packet_idx          varchar,
    proposed_channel    varchar
)
;


truncate table  edwprodhh.hermes.master_prediction_fasttrack
;


insert into     edwprodhh.hermes.master_prediction_fasttrack
    with fast_track as
    (
        select      regexp_replace(debtor_idx, '"', '')                                 as debtor_idx,
                    regexp_replace(packet_idx, '"', '')                                 as packet_idx,
                    case    when    channel = '"Letters"'   then    'Letter'
                            when    channel = '"Voapps"'    then    'VoApp'
                            when    channel = '"Texts"'     then    'Text Message'
                            end                                                         as proposed_channel
        from        edwprodhh.pub_jchang.hermes_fasttrack_20230606_backlogs                 --C:\Users\jchang\Desktop\Projects\incidentals\2023-05-20-hermes-backlog
    )
    , master_prediction_pool as
    (
        with joined as
        (
            select      debtor.debtor_idx,
                        debtor.client_idx,
                        debtor.pl_group,

                        debtor_status.status,
                        debtor_status.pass_debtor_status,

                        client_allowed_contacts.pass_client_allowed_letters,
                        client_allowed_contacts.pass_client_allowed_texts,
                        client_allowed_contacts.pass_client_allowed_voapps,
                        client_allowed_contacts.pass_client_allowed_calls,

                        validation_requirement.requires_validation,
                        validation_requirement.pass_received_validation,
                        validation_requirement.pass_age_validation,
                        -- validation_requirement.pass_received_other_contacts,
                        validation_requirement.pass_validation_requirement_debtor,
                        validation_requirement.pass_validation_requirement,
                        validation_requirement.validation_letter_date,

                        address_allowed_email.email_address,
                        address_allowed_email.pass_address_emails,

                        address_allowed_mail.mailing_address,
                        address_allowed_mail.pass_address_letters,

                        address_allowed_phone.valid_phone_number,
                        address_allowed_phone.cell_code_debtor,
                        address_allowed_phone.cell_code_packet_agg,
                        address_allowed_phone.cell_code_packet_factorized,
                        address_allowed_phone.cell_code_packet,
                        address_allowed_phone.phone_number_source,
                        address_allowed_phone.commercial_code,
                        address_allowed_phone.state,
                        address_allowed_phone.pass_phone_voapps,
                        address_allowed_phone.pass_phone_texts,
                        address_allowed_phone.pass_phone_calls,

                        contact_cooldown.prev_n_contacts,
                        contact_cooldown.prev_n_letters,
                        contact_cooldown.prev_n_voapps,
                        contact_cooldown.prev_n_texts,
                        contact_cooldown.prev_n_emails,
                        contact_cooldown.prev_n_inbounds,
                        contact_cooldown.prev_n_dialer_agent,
                        contact_cooldown.prev_n_dialer_agentless,
                        contact_cooldown.prev_n_outbound_manual,
                        contact_cooldown.prev_date_contacts,
                        contact_cooldown.prev_date_letters,
                        contact_cooldown.prev_date_voapps,
                        contact_cooldown.prev_date_texts,
                        contact_cooldown.prev_date_emails,
                        contact_cooldown.prev_date_inbounds,
                        contact_cooldown.prev_date_dialer_agent,
                        contact_cooldown.prev_date_dialer_agentless,
                        contact_cooldown.prev_date_outbound_manual,
                        contact_cooldown.pass_letters_cooldown,
                        contact_cooldown.pass_voapps_cooldown,
                        contact_cooldown.pass_texts_cooldown,
                        
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
                        
                        fast_track.packet_idx,
                        fast_track.proposed_channel

            from        edwprodhh.pub_jchang.master_debtor as debtor

                        inner join
                            fast_track
                            on debtor.debtor_idx = fast_track.debtor_idx

                        inner join edwprodhh.hermes.transform_criteria_debtor_status                as debtor_status                on debtor.debtor_idx = debtor_status.debtor_idx
                        inner join edwprodhh.hermes.transform_criteria_client_allowed_contacts      as client_allowed_contacts      on debtor.debtor_idx = client_allowed_contacts.debtor_idx
                        inner join edwprodhh.hermes.transform_criteria_validation_requirement       as validation_requirement       on debtor.debtor_idx = validation_requirement.debtor_idx
                        inner join edwprodhh.hermes.transform_criteria_address_allowed_email        as address_allowed_email        on debtor.debtor_idx = address_allowed_email.debtor_idx
                        inner join edwprodhh.hermes.transform_criteria_address_allowed_mail         as address_allowed_mail         on debtor.debtor_idx = address_allowed_mail.debtor_idx
                        inner join edwprodhh.hermes.transform_criteria_address_allowed_phone        as address_allowed_phone        on debtor.debtor_idx = address_allowed_phone.debtor_idx
                        inner join edwprodhh.hermes.transform_businessrules_contact_cooldown        as contact_cooldown             on debtor.debtor_idx = contact_cooldown.debtor_idx
                        inner join edwprodhh.hermes.transform_businessrules_debtor_balance          as debtor_balance               on debtor.debtor_idx = debtor_balance.debtor_idx
                        inner join edwprodhh.hermes.transform_businessrules_debtor_experian         as debtor_experian              on debtor.debtor_idx = debtor_experian.debtor_idx
                        inner join edwprodhh.hermes.transform_businessrules_debtor_income           as debtor_income                on debtor.debtor_idx = debtor_income.debtor_idx
                        inner join edwprodhh.hermes.transform_businessrules_debtor_lastpayment      as debtor_lastpayment           on debtor.debtor_idx = debtor_lastpayment.debtor_idx
                        inner join edwprodhh.hermes.transform_businessrules_debtor_maturity         as debtor_maturity              on debtor.debtor_idx = debtor_maturity.debtor_idx
                        inner join edwprodhh.hermes.transform_businessrules_debtor_taxyear          as debtor_taxyear               on debtor.debtor_idx = debtor_taxyear.debtor_idx
                        inner join edwprodhh.hermes.transform_businessrules_debtor_payplan          as debtor_payplan               on debtor.debtor_idx = debtor_payplan.debtor_idx
        )
        select      *,

                    case    when    pass_client_allowed_letters             =   1
                            and     pass_validation_requirement             =   1
                            and     pass_debtor_status                      =   1
                            and     pass_address_letters                    =   1
                            and     pass_packet_balance                     =   1
                            and     pass_debtor_age_packet                  =   1
                            and     pass_letters_cooldown                   =   1
                            then    1
                            else    0
                            end     as is_eligible_letters,

                    case    when    pass_client_allowed_texts               =   1
                            and     pass_validation_requirement             =   1
                            and     pass_debtor_status                      =   1
                            and     pass_phone_texts                        =   1
                            and     pass_debtor_balance                     =   1
                            and     pass_packet_balance                     =   1
                            and     pass_debtor_age_packet                  =   1
                            and     pass_texts_cooldown                     =   1
                            then    1
                            else    0
                            end     as is_eligible_texts,

                    case    when    pass_client_allowed_voapps              =   1
                            and     pass_validation_requirement             =   1
                            and     pass_debtor_status                      =   1
                            and     pass_phone_voapps                       =   1
                            and     pass_debtor_balance                     =   1
                            and     pass_packet_balance                     =   1
                            and     pass_debtor_age_packet                  =   1
                            and     pass_voapps_cooldown                    =   1
                            then    1
                            else    0
                            end     as is_eligible_voapps,
                            

                    NULL as is_eligible_emails,
                    NULL as is_eligible_dialer_agent,
                    NULL as is_eligible_dialer_agentless

        from        joined
        where       case    when    proposed_channel = 'Letter'             then    is_eligible_letters = 1
                            when    proposed_channel = 'VoApp'              then    is_eligible_voapps  = 1
                            when    proposed_channel = 'Text Message'       then    is_eligible_texts   = 1
                            end

    )
    select      debtor_idx,
                packet_idx,
                proposed_channel
    from        master_prediction_pool
;