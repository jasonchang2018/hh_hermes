create or replace table
    edwprodhh.hermes.transform_criteria_address_allowed_phone
as
with fiscal_dialer_phones as
(
    select      distinct
                debtor_idx,
                phone_valid
    from        edwprodhh.pub_jchang.master_phone_number
    where       included_in_cubs_dialer_file = 1
)
, dialable_debtors as
(
    select      debtor_idx,
                listagg(distinct phone_valid, ';') as valid_phone_number_dialer
    from        edwprodhh.pub_jchang.master_phone_number
    where       included_in_cubs_dialer_file = 1
    group by    1
)
, voappable_debtors as
(
    with joined as
    (
        select      phones.*
        from        edwprodhh.pub_jchang.transform_directory_phone_number as phones
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on phones.debtor_idx = debtor.debtor_idx
                    inner join
                        fiscal_dialer_phones as fiscal
                        on  phones.debtor_idx   = fiscal.debtor_idx
                        and phones.phone_number = fiscal.phone_valid
    )
    select      debtor_idx,
                listagg(distinct phone_number, ';') as valid_phone_number_voapps
    from        joined
    where       packet_idx not in (select packet_idx from joined where current_status = 'DNC')
                and (
                    phone_number_source in ('CLIENT', 'DEBTOR')
                    or packet_idx not in (select packet_idx from joined where debtor_auth_date is null) --phone_packet.packet_cell in ('M','T')
                )
    group by    1
)
, textable_debtors as
(
    with joined as
    (
        select      phones.*,
                    client.is_fdcpa
        from        edwprodhh.pub_jchang.transform_directory_phone_number as phones
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on phones.debtor_idx = debtor.debtor_idx
                    inner join
                        edwprodhh.pub_jchang.master_client as client
                        on debtor.client_idx = client.client_idx
                    inner join
                        fiscal_dialer_phones as fiscal
                        on  phones.debtor_idx   = fiscal.debtor_idx
                        and phones.phone_number = fiscal.phone_valid
                    left join
                        edwprodhh.hermes.transform_criteria_texts_exclusions as text_stops
                        on  phones.debtor_idx   = text_stops.debtor_idx
                        and phones.phone_number = text_stops.phone_number
                        
        where       case    /*when    client.is_fdcpa = 1
                            and     phones.phone_number_source = 'OTHER'                    --Skips, which cannot be texted for FDCPA.
                            then    FALSE*/
                            when    debtor.industry = 'HC'
                            and     datediff(day, debtor.batch_date, current_date()) > 365
                            and     phones.current_status not in ('CONSENT')                --Need consent for HC if debt_age older than 1 year
                            then    FALSE
                            when    debtor.industry = 'GOV'
                            and     datediff(day, debtor.batch_date, current_date()) > 730  --Need consent for GOV if debt_age older than 2 years
                            and     phones.current_status not in ('CONSENT')
                            then    FALSE
                            else    TRUE
                            end
                        and coalesce(text_stops.stop_text, 0) = 0
    )
    select      debtor_idx,
                listagg(distinct phone_number, ';') as valid_phone_number_texts
    from        joined
    where       packet_idx not in (select packet_idx from joined where current_status = 'DNC')
    group by    1
)
, all_cells as
(
    select      debtor_idx,
                listagg(distinct phone_number_source,   ';') within group (order by phone_number_source) as phone_number_source_agg,
                listagg(distinct current_status,        ';') within group (order by current_status) as current_status_agg
    from        edwprodhh.pub_jchang.transform_directory_phone_number
    group by    1
)
select      debtor.debtor_idx,
            debtor.packet_idx,

            voappable_debtors.valid_phone_number_voapps as valid_phone_number_voapps,
            textable_debtors.valid_phone_number_texts   as valid_phone_number_texts,
            dialable_debtors.valid_phone_number_dialer  as valid_phone_number_dialer,
            debtor.phone_number                         as phone_number_debtor,

            phone_debtor.cell                           as cell_code_debtor,
            phone_packet.cell_agg_distinct              as cell_code_packet_agg,
            phone_packet.cell_factorized_distinct       as cell_code_packet_factorized,
            phone_packet.packet_cell                    as cell_code_packet,

            all_cells.phone_number_source_agg           as phone_number_source,
            all_cells.current_status_agg                as current_status_phone,

            dimfiscal_co_a.commercial                   as commercial_code,
            dimdebtor.st                                as state,
            client.is_fdcpa                             as is_fdcpa,
            client.ash_cli                              as ash_cli,
            debtor.payplan                              as payplan,
                    
            case    when    voappable_debtors.debtor_idx is not null
                    and     debtor.phone_number is not null
                    then    1
                    else    0
                    end     as pass_phone_voapps,

            case    --  Exclusions must come first
                    when    debtor.payplan is not null
                    then    0
                    when    debtor.status in ('PPA')
                    then    0
                    when    dimdebtor.st in ('MA', 'ZZ', 'BC')
                    then    0
                    when    client.is_fdcpa = 1
                    and     dimdebtor.st in ('DC')
                    then    0
                    when    client.ash_cli = 1
                    and     dimdebtor.st in ('CA', 'NJ', 'TX')
                    then    0

                    --  Inclusions next
                    when    textable_debtors.debtor_idx is not null
                    -- and     debtor.phone_number is not null
                    and     not regexp_like(coalesce(dimfiscal_co_a.commercial, ''), '^COM.*')
                    then    case    when    dimdebtor.st = 'NV'
                                    then    case    when    debtor.pl_group in (
                                                                'UNIVERSAL HEALTH SERVICES - 3P',
                                                                'UNIVERSAL HEALTH SERVICES - PHYS - 3P'
                                                            )
                                                    then    1
                                                    else    0
                                                    end
                                    when    dimdebtor.st in ('WA')
                                    then    case    when    debtor.pl_group in (
                                                                'PROVIDENCE ST JOSEPH HEALTH - 3P',
                                                                'PROVIDENCE ST JOSEPH HEALTH - 3P-2'
                                                            )
                                                    then    1
                                                    else    0
                                                    end
                                    when    dimdebtor.st = 'CO'
                                    then    case    when    debtor.pl_group in (
                                                                'STATE OF CO - JUDICIAL DEPT - 3P'
                                                            )
                                                    then    1
                                                    else    0
                                                    end
                                    when    dimdebtor.st = 'CT'
                                    then    case    when    debtor.pl_group in (
                                                                'STATE OF VA - DOT - 3P',
                                                                'STATE OF VA - DOT - 3P-2',
                                                                'STATE OF VA - DOT - ACCESS - 3P',
                                                                'STATE OF VA - DOT - BK',
                                                                'STATE OF VA - DOT - CC',
                                                                'STATE OF MD - COMPTROLLER - 3P',
                                                                'STATE OF MD - DBM CCU - 3P',
                                                                'STATE OF MD - TOLLWAY - 3P',
                                                                'COLUMBIA DENTAL - 3P',
                                                                'COLUMBIA DOCTORS - 3P',
                                                                'COLUMBIA DOCTORS - TPL',
                                                                'COLUMBIA DOCTORS LEGAL',
                                                                'MOUNT SINAI - 3P',
                                                                'WEILL CORNELL PHY - 3P'
                                                            )
                                                    then    1
                                                    else    0
                                                    end
                                    else    1
                                    end
                    else    0
                    end     as pass_phone_texts,
                    
            case    when    dialable_debtors.debtor_idx is not null
                    and     debtor.phone_number is not null
                    and     phone_packet.packet_cell is not null
                    and     phone_packet.packet_cell in ('A','B','C','L','M','N','T')
                    then    1
                    else    0
                    end     as pass_phone_calls

from        edwprodhh.pub_jchang.master_debtor as debtor
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on debtor.debtor_idx = dimdebtor.debtor_idx
            inner join
                edwprodhh.pub_jchang.master_client as client
                on debtor.client_idx = client.client_idx

            left join
                textable_debtors
                on debtor.debtor_idx = textable_debtors.debtor_idx
            left join
                voappable_debtors
                on debtor.debtor_idx = voappable_debtors.debtor_idx
            left join
                dialable_debtors
                on debtor.debtor_idx = dialable_debtors.debtor_idx
            left join
                all_cells
                on debtor.debtor_idx = all_cells.debtor_idx

            left join
                edwprodhh.pub_jchang.master_phone_number_code_debtor as phone_debtor
                on debtor.debtor_idx = phone_debtor.debtor_idx
            left join
                edwprodhh.pub_jchang.master_phone_number_code_packet as phone_packet
                on debtor.packet_idx = phone_packet.packet_idx

            left join
                edwprodhh.dw.dimfiscal_co_a as  dimfiscal_co_a
                on debtor.debtor_idx = dimfiscal_co_a.debtor_idx
;



create or replace task
    edwprodhh.pub_jchang.replace_transform_criteria_address_allowed_phone
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_criteria_address_allowed_phone
as
with fiscal_dialer_phones as
(
    select      distinct
                debtor_idx,
                phone_valid
    from        edwprodhh.pub_jchang.master_phone_number
    where       included_in_cubs_dialer_file = 1
)
, dialable_debtors as
(
    select      debtor_idx,
                listagg(distinct phone_valid, ';') as valid_phone_number_dialer
    from        edwprodhh.pub_jchang.master_phone_number
    where       included_in_cubs_dialer_file = 1
    group by    1
)
, voappable_debtors as
(
    with joined as
    (
        select      phones.*
        from        edwprodhh.pub_jchang.transform_directory_phone_number as phones
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on phones.debtor_idx = debtor.debtor_idx
                    inner join
                        fiscal_dialer_phones as fiscal
                        on  phones.debtor_idx   = fiscal.debtor_idx
                        and phones.phone_number = fiscal.phone_valid
    )
    select      debtor_idx,
                listagg(distinct phone_number, ';') as valid_phone_number_voapps
    from        joined
    where       packet_idx not in (select packet_idx from joined where current_status = 'DNC')
                and (
                    phone_number_source in ('CLIENT', 'DEBTOR')
                    or packet_idx not in (select packet_idx from joined where debtor_auth_date is null) --phone_packet.packet_cell in ('M','T')
                )
    group by    1
)
, textable_debtors as
(
    with joined as
    (
        select      phones.*,
                    client.is_fdcpa
        from        edwprodhh.pub_jchang.transform_directory_phone_number as phones
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on phones.debtor_idx = debtor.debtor_idx
                    inner join
                        edwprodhh.pub_jchang.master_client as client
                        on debtor.client_idx = client.client_idx
                    inner join
                        fiscal_dialer_phones as fiscal
                        on  phones.debtor_idx   = fiscal.debtor_idx
                        and phones.phone_number = fiscal.phone_valid
                    left join
                        edwprodhh.hermes.transform_criteria_texts_exclusions as text_stops
                        on  phones.debtor_idx   = text_stops.debtor_idx
                        and phones.phone_number = text_stops.phone_number
                        
        where       case    /*when    client.is_fdcpa = 1
                            and     phones.phone_number_source = 'OTHER'                    --Skips, which cannot be texted for FDCPA.
                            then    FALSE*/
                            when    debtor.industry = 'HC'
                            and     datediff(day, debtor.batch_date, current_date()) > 365
                            and     phones.current_status not in ('CONSENT')                --Need consent for HC if debt_age older than 1 year
                            then    FALSE
                            when    debtor.industry = 'GOV'
                            and     datediff(day, debtor.batch_date, current_date()) > 730  --Need consent for GOV if debt_age older than 2 years
                            and     phones.current_status not in ('CONSENT')
                            then    FALSE
                            else    TRUE
                            end
                        and coalesce(text_stops.stop_text, 0) = 0
    )
    select      debtor_idx,
                listagg(distinct phone_number, ';') as valid_phone_number_texts
    from        joined
    where       packet_idx not in (select packet_idx from joined where current_status = 'DNC')
    group by    1
)
, all_cells as
(
    select      debtor_idx,
                listagg(distinct phone_number_source,   ';') within group (order by phone_number_source) as phone_number_source_agg,
                listagg(distinct current_status,        ';') within group (order by current_status) as current_status_agg
    from        edwprodhh.pub_jchang.transform_directory_phone_number
    group by    1
)
select      debtor.debtor_idx,
            debtor.packet_idx,

            voappable_debtors.valid_phone_number_voapps as valid_phone_number_voapps,
            textable_debtors.valid_phone_number_texts   as valid_phone_number_texts,
            dialable_debtors.valid_phone_number_dialer  as valid_phone_number_dialer,
            debtor.phone_number                         as phone_number_debtor,

            phone_debtor.cell                           as cell_code_debtor,
            phone_packet.cell_agg_distinct              as cell_code_packet_agg,
            phone_packet.cell_factorized_distinct       as cell_code_packet_factorized,
            phone_packet.packet_cell                    as cell_code_packet,

            all_cells.phone_number_source_agg           as phone_number_source,
            all_cells.current_status_agg                as current_status_phone,

            dimfiscal_co_a.commercial                   as commercial_code,
            dimdebtor.st                                as state,
            client.is_fdcpa                             as is_fdcpa,
            client.ash_cli                              as ash_cli,
            debtor.payplan                              as payplan,
                    
            case    when    voappable_debtors.debtor_idx is not null
                    and     debtor.phone_number is not null
                    then    1
                    else    0
                    end     as pass_phone_voapps,

            case    --  Exclusions must come first
                    when    debtor.payplan is not null
                    then    0
                    when    debtor.status in ('PPA')
                    then    0
                    when    dimdebtor.st in ('MA', 'ZZ', 'BC')
                    then    0
                    when    client.is_fdcpa = 1
                    and     dimdebtor.st in ('DC')
                    then    0
                    when    client.ash_cli = 1
                    and     dimdebtor.st in ('CA', 'NJ', 'TX')
                    then    0

                    --  Inclusions next
                    when    textable_debtors.debtor_idx is not null
                    -- and     debtor.phone_number is not null
                    and     not regexp_like(coalesce(dimfiscal_co_a.commercial, ''), '^COM.*')
                    then    case    when    dimdebtor.st = 'NV'
                                    then    case    when    debtor.pl_group in (
                                                                'UNIVERSAL HEALTH SERVICES - 3P',
                                                                'UNIVERSAL HEALTH SERVICES - PHYS - 3P'
                                                            )
                                                    then    1
                                                    else    0
                                                    end
                                    when    dimdebtor.st in ('WA')
                                    then    case    when    debtor.pl_group in (
                                                                'PROVIDENCE ST JOSEPH HEALTH - 3P',
                                                                'PROVIDENCE ST JOSEPH HEALTH - 3P-2'
                                                            )
                                                    then    1
                                                    else    0
                                                    end
                                    when    dimdebtor.st = 'CO'
                                    then    case    when    debtor.pl_group in (
                                                                'STATE OF CO - JUDICIAL DEPT - 3P'
                                                            )
                                                    then    1
                                                    else    0
                                                    end
                                    when    dimdebtor.st = 'CT'
                                    then    case    when    debtor.pl_group in (
                                                                'STATE OF VA - DOT - 3P',
                                                                'STATE OF VA - DOT - 3P-2',
                                                                'STATE OF VA - DOT - ACCESS - 3P',
                                                                'STATE OF VA - DOT - BK',
                                                                'STATE OF VA - DOT - CC',
                                                                'STATE OF MD - COMPTROLLER - 3P',
                                                                'STATE OF MD - DBM CCU - 3P',
                                                                'STATE OF MD - TOLLWAY - 3P',
                                                                'COLUMBIA DENTAL - 3P',
                                                                'COLUMBIA DOCTORS - 3P',
                                                                'COLUMBIA DOCTORS - TPL',
                                                                'COLUMBIA DOCTORS LEGAL',
                                                                'MOUNT SINAI - 3P',
                                                                'WEILL CORNELL PHY - 3P'
                                                            )
                                                    then    1
                                                    else    0
                                                    end
                                    else    1
                                    end
                    else    0
                    end     as pass_phone_texts,
                    
            case    when    dialable_debtors.debtor_idx is not null
                    and     debtor.phone_number is not null
                    and     phone_packet.packet_cell is not null
                    and     phone_packet.packet_cell in ('A','B','C','L','M','N','T')
                    then    1
                    else    0
                    end     as pass_phone_calls

from        edwprodhh.pub_jchang.master_debtor as debtor
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on debtor.debtor_idx = dimdebtor.debtor_idx
            inner join
                edwprodhh.pub_jchang.master_client as client
                on debtor.client_idx = client.client_idx

            left join
                textable_debtors
                on debtor.debtor_idx = textable_debtors.debtor_idx
            left join
                voappable_debtors
                on debtor.debtor_idx = voappable_debtors.debtor_idx
            left join
                dialable_debtors
                on debtor.debtor_idx = dialable_debtors.debtor_idx
            left join
                all_cells
                on debtor.debtor_idx = all_cells.debtor_idx

            left join
                edwprodhh.pub_jchang.master_phone_number_code_debtor as phone_debtor
                on debtor.debtor_idx = phone_debtor.debtor_idx
            left join
                edwprodhh.pub_jchang.master_phone_number_code_packet as phone_packet
                on debtor.packet_idx = phone_packet.packet_idx

            left join
                edwprodhh.dw.dimfiscal_co_a as  dimfiscal_co_a
                on debtor.debtor_idx = dimfiscal_co_a.debtor_idx
;