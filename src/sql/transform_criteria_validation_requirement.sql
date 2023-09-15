create or replace table
    edwprodhh.hermes.transform_criteria_validation_requirement
as
with debtors_sent_vals as
(
    with validation_debtors as
    (
        select      distinct
                    debtor_idx
        from        edwprodhh.pub_jchang.master_letters
        where       collection_type in ('Validation')
    )
    , validation_packets as
    (
        select      debtor.debtor_idx,
                    debtor.packet_idx,
                    debtor.batch_date,
                    case    when    validation_debtors.debtor_idx is not null
                            then    1
                            else    0
                            end     as has_validation_row,
                    max(has_validation_row) over (partition by debtor.packet_idx order by debtor.batch_date desc, has_validation_row desc) as has_validation --assume the most recent validation validates everything placed before

        from        edwprodhh.pub_jchang.master_debtor as debtor
                    left join
                        validation_debtors
                        on debtor.debtor_idx = validation_debtors.debtor_idx
    )
    select      debtor_idx
    from        validation_packets
    where       has_validation = 1
)
, historical_contacts_sent as
(
    select      debtor_idx,
                count(*) as n_contacts
    from        edwprodhh.pub_jchang.transform_contacts as contacts
    group by    1
)
, pass_validation_age as
(
    select 		debtor_idx,
                val_ltr_date
    from        edwprodhh.dw.dimfiscal_hh_b
    where       val_ltr_date is not null
                and val_ltr_date < current_date() - 45
)
select      debtor.debtor_idx,
            debtor.packet_idx,

            pass_validation_age.val_ltr_date as validation_letter_date,

            coalesce(client.is_fdcpa, 0) as requires_validation,

            case    when    debtors_sent_vals.debtor_idx is not null
                    then    1
                    else    0
                    end     as pass_received_validation,

            case    when    pass_validation_age.debtor_idx is not null
                    then    1
                    else    0
                    end     as pass_age_validation,

            case    when    historical_contacts_sent.debtor_idx is not null
                    then    1
                    else    0
                    end     as pass_received_other_contacts,

            case    when    requires_validation             = 0
                    or      (
                                pass_received_validation            = 1
                                and pass_age_validation             = 1
                            )
                    -- or      pass_received_other_contacts    = 1
                    then    1
                    else    0
                    end     as pass_validation_requirement_debtor,

            min(pass_validation_requirement_debtor) over (partition by packet_idx) as pass_validation_requirement

from        edwprodhh.pub_jchang.master_debtor as debtor
            -- inner join
            --     edwprodhh.pub_jchang.master_client as client
            --     on debtor.client_idx = client.client_idx
            left join
                (
                    select      client_idx,
                                case    when    coalesce(nullif(trim(fdcpa_flg), ''), '') = 'Y'
                                        then    1
                                        else    0
                                        end     as is_fdcpa
                    from        edwprodhh.pub_jchang.temp_csv_master_client_fdcpa
                )   as client
                on debtor.client_idx = client.client_idx
            left join
                debtors_sent_vals
                on debtor.debtor_idx = debtors_sent_vals.debtor_idx
            left join
                historical_contacts_sent
                on debtor.debtor_idx = historical_contacts_sent.debtor_idx
                and historical_contacts_sent.n_contacts > 0
            left join
                pass_validation_age
                on debtor.debtor_idx = pass_validation_age.debtor_idx
;



create task
    edwprodhh.pub_jchang.replace_transform_criteria_validation_requirement
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_criteria_validation_requirement
as
with debtors_sent_vals as
(
    with validation_debtors as
    (
        select      distinct
                    debtor_idx
        from        edwprodhh.pub_jchang.master_letters
        where       collection_type in ('Validation')
    )
    , validation_packets as
    (
        select      debtor.debtor_idx,
                    debtor.packet_idx,
                    debtor.batch_date,
                    case    when    validation_debtors.debtor_idx is not null
                            then    1
                            else    0
                            end     as has_validation_row,
                    max(has_validation_row) over (partition by debtor.packet_idx order by debtor.batch_date desc, has_validation_row desc) as has_validation --assume the most recent validation validates everything placed before

        from        edwprodhh.pub_jchang.master_debtor as debtor
                    left join
                        validation_debtors
                        on debtor.debtor_idx = validation_debtors.debtor_idx
    )
    select      debtor_idx
    from        validation_packets
    where       has_validation = 1
)
, historical_contacts_sent as
(
    select      debtor_idx,
                count(*) as n_contacts
    from        edwprodhh.pub_jchang.transform_contacts as contacts
    group by    1
)
, pass_validation_age as
(
    select 		debtor_idx,
                val_ltr_date
    from        edwprodhh.dw.dimfiscal_hh_b
    where       val_ltr_date is not null
                and val_ltr_date < current_date() - 45
)
select      debtor.debtor_idx,
            debtor.packet_idx,

            pass_validation_age.val_ltr_date as validation_letter_date,

            coalesce(client.is_fdcpa, 0) as requires_validation,

            case    when    debtors_sent_vals.debtor_idx is not null
                    then    1
                    else    0
                    end     as pass_received_validation,

            case    when    pass_validation_age.debtor_idx is not null
                    then    1
                    else    0
                    end     as pass_age_validation,

            case    when    historical_contacts_sent.debtor_idx is not null
                    then    1
                    else    0
                    end     as pass_received_other_contacts,

            case    when    requires_validation             = 0
                    or      (
                                pass_received_validation            = 1
                                and pass_age_validation             = 1
                            )
                    -- or      pass_received_other_contacts    = 1
                    then    1
                    else    0
                    end     as pass_validation_requirement_debtor,

            min(pass_validation_requirement_debtor) over (partition by packet_idx) as pass_validation_requirement

from        edwprodhh.pub_jchang.master_debtor as debtor
            -- inner join
            --     edwprodhh.pub_jchang.master_client as client
            --     on debtor.client_idx = client.client_idx
            left join
                (
                    select      client_idx,
                                case    when    coalesce(nullif(trim(fdcpa_flg), ''), '') = 'Y'
                                        then    1
                                        else    0
                                        end     as is_fdcpa
                    from        edwprodhh.pub_jchang.temp_csv_master_client_fdcpa
                )   as client
                on debtor.client_idx = client.client_idx
            left join
                debtors_sent_vals
                on debtor.debtor_idx = debtors_sent_vals.debtor_idx
            left join
                historical_contacts_sent
                on debtor.debtor_idx = historical_contacts_sent.debtor_idx
                and historical_contacts_sent.n_contacts > 0
            left join
                pass_validation_age
                on debtor.debtor_idx = pass_validation_age.debtor_idx
;