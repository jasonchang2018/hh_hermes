create or replace table
    edwprodhh.hermes.transform_criteria_address_allowed_phone
as
with dialable_debtors as
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
        select      phones.*,
                    debtor.packet_idx
        from        edwprodhh.pub_jchang.transform_directory_phone_number as phones
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on phones.debtor_idx = debtor.debtor_idx
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
                    debtor.packet_idx,
                    -- client.is_fdcpa
                    coalesce(client.is_fdcpa, 0) as is_fdcpa
        from        edwprodhh.pub_jchang.transform_directory_phone_number as phones
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on phones.debtor_idx = debtor.debtor_idx
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
                        
        where       not (
                        -- client.is_fdcpa = 1
                        coalesce(client.is_fdcpa, 0) = 1
                        and phones.phone_number_source = 'OTHER' --Skips, which cannot be texted for FDCPA.
                    )
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
            -- client.is_fdcpa                             as is_fdcpa,
            coalesce(client.is_fdcpa, 0)                as is_fdcpa,
                    
            case    when    voappable_debtors.debtor_idx is not null
                    and     debtor.phone_number is not null
                    then    1
                    else    0
                    end     as pass_phone_voapps,

            case    when    dimdebtor.st in ('NV', 'CT')
                    then    0
                    -- when    client.is_fdcpa = 1
                    when    coalesce(client.is_fdcpa, 0) = 1
                    and     dimdebtor.st in ('DC')
                    then    0
                    when    textable_debtors.debtor_idx is not null
                    and     debtor.phone_number is not null
                    and     not regexp_like(coalesce(dimfiscal_co_a.commercial, ''), '^COM.*')
                    then    1
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



create task
    edwprodhh.pub_jchang.replace_transform_criteria_address_allowed_phone
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_criteria_address_allowed_phone
as
with dialable_debtors as
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
        select      phones.*,
                    debtor.packet_idx
        from        edwprodhh.pub_jchang.transform_directory_phone_number as phones
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on phones.debtor_idx = debtor.debtor_idx
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
                    debtor.packet_idx,
                    -- client.is_fdcpa
                    coalesce(client.is_fdcpa, 0) as is_fdcpa
        from        edwprodhh.pub_jchang.transform_directory_phone_number as phones
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on phones.debtor_idx = debtor.debtor_idx
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
                        
        where       not (
                        -- client.is_fdcpa = 1
                        coalesce(client.is_fdcpa, 0) = 1
                        and phones.phone_number_source = 'OTHER' --Skips, which cannot be texted for FDCPA.
                    )
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
            -- client.is_fdcpa                             as is_fdcpa,
            coalesce(client.is_fdcpa, 0)                as is_fdcpa,
                    
            case    when    voappable_debtors.debtor_idx is not null
                    and     debtor.phone_number is not null
                    then    1
                    else    0
                    end     as pass_phone_voapps,

            case    when    dimdebtor.st in ('NV', 'CT')
                    then    0
                    -- when    client.is_fdcpa = 1
                    when    coalesce(client.is_fdcpa, 0) = 1
                    and     dimdebtor.st in ('DC')
                    then    0
                    when    textable_debtors.debtor_idx is not null
                    and     debtor.phone_number is not null
                    and     not regexp_like(coalesce(dimfiscal_co_a.commercial, ''), '^COM.*')
                    then    1
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