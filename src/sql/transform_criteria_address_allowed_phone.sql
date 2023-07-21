create or replace table
    edwprodhh.hermes.transform_criteria_address_allowed_phone
as
with phone_numbers_voapps as
(
    with phones as
    (
        select      debtor_idx,
                    edwprodhh.pub_jchang.contact_address_format_phone(phone) as phone_
        from        edwprodhh.dw.dimdebtor
        where       edwprodhh.pub_jchang.contact_address_valid_phone(phone_) = 1
    )
    select      phones.debtor_idx,
                phones.phone_,
                phone_debtor_source.phone_number_source
    from        phones
                left join
                    edwprodhh.pub_jchang.transform_directory_phone_number as phone_debtor_source
                    on  phones.debtor_idx   = phone_debtor_source.debtor_idx
                    and phones.phone_       = phone_debtor_source.phone_number
)
, phone_numbers_texts_dialer as
(
    select      debtor_idx,
                listagg(phone_valid, ';') as phone_
    from        edwprodhh.pub_jchang.master_phone_number
    where       included_in_cubs_dialer_file = 1
    group by    1
)
select      phone_debtor.debtor_idx,
            phone_debtor.packet_idx,

            phone_numbers_voapps.phone_                 as valid_phone_number_voapps,
            phone_numbers_texts_dialer.phone_           as valid_phone_number_texts_dialer,

            phone_debtor.cell                           as cell_code_debtor,
            phone_packet.cell_agg_distinct              as cell_code_packet_agg,
            phone_packet.cell_factorized_distinct       as cell_code_packet_factorized,
            phone_packet.packet_cell                    as cell_code_packet,
            phone_numbers_voapps.phone_number_source    as phone_number_source,

            dimfiscal_co_a.commercial                   as commercial_code,
            dimdebtor.st                                as state,
                    
            case    when    phone_numbers_voapps.phone_ is not null
                    and     phone_packet.packet_cell is not null
                    then    case    when    phone_packet.packet_cell in ('M','T')
                                    then    1
                                    when    phone_packet.packet_cell in ('A','B','C','L')
                                    and     phone_numbers_voapps.phone_number_source in ('CLIENT', 'DEBTOR')
                                    then    1
                                    else    0
                                    end
                    else    0
                    end     as pass_phone_voapps,

            case    when    dimdebtor.st in ('NV', 'CT')
                    then    0
                    when    phone_numbers_texts_dialer.phone_ is not null
                    and     phone_packet.packet_cell is not null
                    and     phone_packet.packet_cell in ('A','B','C','L','M','T')
                    and     not regexp_like(coalesce(dimfiscal_co_a.commercial, ''), '^COM.*')
                    then    1
                    else    0
                    end     as pass_phone_texts,
                    
            case    when    phone_numbers_texts_dialer.phone_ is not null
                    and     phone_packet.packet_cell is not null
                    and     phone_packet.packet_cell in ('A','B','C','L','M','N','T')
                    then    1
                    else    0
                    end     as pass_phone_calls

from        edwprodhh.pub_jchang.master_debtor as debtor
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on debtor.debtor_idx = dimdebtor.debtor_idx

            -- left join
            --     phone_numbers
            --     on debtor.debtor_idx = phone_numbers.debtor_idx

            left join
                phone_numbers_voapps
                on debtor.debtor_idx = phone_numbers_voapps.debtor_idx
            left join
                phone_numbers_texts_dialer
                on debtor.debtor_idx = phone_numbers_texts_dialer.debtor_idx

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
with phone_numbers_voapps as
(
    with phones as
    (
        select      debtor_idx,
                    edwprodhh.pub_jchang.contact_address_format_phone(phone) as phone_
        from        edwprodhh.dw.dimdebtor
        where       edwprodhh.pub_jchang.contact_address_valid_phone(phone_) = 1
    )
    select      phones.debtor_idx,
                phones.phone_,
                phone_debtor_source.phone_number_source
    from        phones
                left join
                    edwprodhh.pub_jchang.transform_directory_phone_number as phone_debtor_source
                    on  phones.debtor_idx   = phone_debtor_source.debtor_idx
                    and phones.phone_       = phone_debtor_source.phone_number
)
, phone_numbers_texts_dialer as
(
    select      debtor_idx,
                listagg(phone_valid, ';') as phone_
    from        edwprodhh.pub_jchang.master_phone_number
    where       included_in_cubs_dialer_file = 1
    group by    1
)
select      phone_debtor.debtor_idx,
            phone_debtor.packet_idx,

            phone_numbers_voapps.phone_                 as valid_phone_number_voapps,
            phone_numbers_texts_dialer.phone_           as valid_phone_number_texts_dialer,

            phone_debtor.cell                           as cell_code_debtor,
            phone_packet.cell_agg_distinct              as cell_code_packet_agg,
            phone_packet.cell_factorized_distinct       as cell_code_packet_factorized,
            phone_packet.packet_cell                    as cell_code_packet,
            phone_numbers_voapps.phone_number_source    as phone_number_source,

            dimfiscal_co_a.commercial                   as commercial_code,
            dimdebtor.st                                as state,
                    
            case    when    phone_numbers_voapps.phone_ is not null
                    and     phone_packet.packet_cell is not null
                    then    case    when    phone_packet.packet_cell in ('M','T')
                                    then    1
                                    when    phone_packet.packet_cell in ('A','B','C','L')
                                    and     phone_numbers_voapps.phone_number_source in ('CLIENT', 'DEBTOR')
                                    then    1
                                    else    0
                                    end
                    else    0
                    end     as pass_phone_voapps,

            case    when    dimdebtor.st in ('NV', 'CT')
                    then    0
                    when    phone_numbers_texts_dialer.phone_ is not null
                    and     phone_packet.packet_cell is not null
                    and     phone_packet.packet_cell in ('A','B','C','L','M','T')
                    and     not regexp_like(coalesce(dimfiscal_co_a.commercial, ''), '^COM.*')
                    then    1
                    else    0
                    end     as pass_phone_texts,
                    
            case    when    phone_numbers_texts_dialer.phone_ is not null
                    and     phone_packet.packet_cell is not null
                    and     phone_packet.packet_cell in ('A','B','C','L','M','N','T')
                    then    1
                    else    0
                    end     as pass_phone_calls

from        edwprodhh.pub_jchang.master_debtor as debtor
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on debtor.debtor_idx = dimdebtor.debtor_idx

            -- left join
            --     phone_numbers
            --     on debtor.debtor_idx = phone_numbers.debtor_idx

            left join
                phone_numbers_voapps
                on debtor.debtor_idx = phone_numbers_voapps.debtor_idx
            left join
                phone_numbers_texts_dialer
                on debtor.debtor_idx = phone_numbers_texts_dialer.debtor_idx

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