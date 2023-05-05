create or replace table
    edwprodhh.hermes.transform_criteria_address_allowed_phone
as
with phone_numbers as
(
    select      debtor_idx,
                nullif(trim(regexp_replace(phone, '[\\-\\+\\.\\(\\)]')), '') as phone_
    from        edwprodhh.dw.dimdebtor
    where       phone_ is not null
                and regexp_like(phone_, '^\\!?[0-9]+$')         --  Keep only phones that are numbers and can optionally start with a `!`.
                and not regexp_like(phone_, '^\\!.*$')          --  Exclude where first character is a `!`, which signifies Do Not Call (DNC).
                and length(phone_) = 10                         --  Must be 10 digits long
                and not regexp_like(phone_, '^[01].*$')         --  First digit of area code cannot be 0 or 1, which is a standard.
                and not regexp_like(phone_, '^.9.*$')           --  Second digit of area code cannot be 9, which is a standard.
                and not regexp_like(phone_, '^.{3}1.*$')        --  4th digit overall (1st of the 2nd group of 3, called the exchange) cannot be 1
)
select      phone_debtor.debtor_idx,
            phone_debtor.packet_idx,

            phone_numbers.phone_                        as valid_phone_number,

            phone_debtor.cell                           as cell_code_debtor,
            phone_packet.cell_agg_distinct              as cell_code_packet_agg,
            phone_packet.cell_factorized_distinct       as cell_code_packet_factorized,
            phone_packet.packet_cell                    as cell_code_packet,
            phone_debtor_source.phone_number_source     as phone_number_source,

            dimfiscal_co_a.commercial                   as commercial_code,
            dimdebtor.st                                as state,
                    
            case    when    phone_numbers.phone_ is not null
                    and     phone_packet.packet_cell is not null
                    then    case    when    phone_packet.packet_cell in ('M','T')
                                    then    1
                                    when    phone_packet.packet_cell in ('A','B','C','L')
                                    and     phone_debtor_source.phone_number_source in ('CLIENT', 'DEBTOR')
                                    then    1
                                    else    0
                                    end
                    else    0
                    end     as pass_phone_voapps,

            case    when    dimdebtor.st in ('NV', 'CT')
                    then    0
                    when    phone_numbers.phone_ is not null
                    and     phone_packet.packet_cell is not null
                    and     phone_packet.packet_cell in ('A','B','C','L','M','T')
                    and     not regexp_like(coalesce(dimfiscal_co_a.commercial, ''), '^COM.*')
                    then    1
                    else    0
                    end     as pass_phone_texts,
                    
            case    when    phone_numbers.phone_ is not null
                    and     phone_packet.packet_cell is not null
                    and     phone_packet.packet_cell in ('A','B','C','L','M','N','T')
                    then    1
                    else    0
                    end     as pass_phone_calls

from        edwprodhh.pub_jchang.master_debtor as debtor
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on debtor.debtor_idx = dimdebtor.debtor_idx

            left join
                phone_numbers
                on debtor.debtor_idx = phone_numbers.debtor_idx

            left join
                edwprodhh.pub_jchang.transform_directory_phone_number as phone_debtor_source
                on  debtor.debtor_idx       = phone_debtor_source.debtor_idx
                and phone_numbers.phone_    = phone_debtor_source.phone_number

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
with phone_numbers as
(
    select      debtor_idx,
                nullif(trim(regexp_replace(phone, '[\\-\\+\\.\\(\\)]')), '') as phone_
    from        edwprodhh.dw.dimdebtor
    where       phone_ is not null
                and regexp_like(phone_, '^\\!?[0-9]+$')         --  Keep only phones that are numbers and can optionally start with a `!`.
                and not regexp_like(phone_, '^\\!.*$')          --  Exclude where first character is a `!`, which signifies Do Not Call (DNC).
                and length(phone_) = 10                         --  Must be 10 digits long
                and not regexp_like(phone_, '^[01].*$')         --  First digit of area code cannot be 0 or 1, which is a standard.
                and not regexp_like(phone_, '^.9.*$')           --  Second digit of area code cannot be 9, which is a standard.
                and not regexp_like(phone_, '^.{3}1.*$')        --  4th digit overall (1st of the 2nd group of 3, called the exchange) cannot be 1
)
select      phone_debtor.debtor_idx,
            phone_debtor.packet_idx,

            phone_numbers.phone_                        as valid_phone_number,

            phone_debtor.cell                           as cell_code_debtor,
            phone_packet.cell_agg_distinct              as cell_code_packet_agg,
            phone_packet.cell_factorized_distinct       as cell_code_packet_factorized,
            phone_packet.packet_cell                    as cell_code_packet,
            phone_debtor_source.phone_number_source     as phone_number_source,

            dimfiscal_co_a.commercial                   as commercial_code,
            dimdebtor.st                                as state,
                    
            case    when    phone_numbers.phone_ is not null
                    and     phone_packet.packet_cell is not null
                    then    case    when    phone_packet.packet_cell in ('M','T')
                                    then    1
                                    when    phone_packet.packet_cell in ('A','B','C','L')
                                    and     phone_debtor_source.phone_number_source in ('CLIENT', 'DEBTOR')
                                    then    1
                                    else    0
                                    end
                    else    0
                    end     as pass_phone_voapps,

            case    when    dimdebtor.st in ('NV', 'CT')
                    then    0
                    when    phone_numbers.phone_ is not null
                    and     phone_packet.packet_cell is not null
                    and     phone_packet.packet_cell in ('A','B','C','L','M','T')
                    and     not regexp_like(coalesce(dimfiscal_co_a.commercial, ''), '^COM.*')
                    then    1
                    else    0
                    end     as pass_phone_texts,
                    
            case    when    phone_numbers.phone_ is not null
                    and     phone_packet.packet_cell is not null
                    and     phone_packet.packet_cell in ('A','B','C','L','M','N','T')
                    then    1
                    else    0
                    end     as pass_phone_calls

from        edwprodhh.pub_jchang.master_debtor as debtor
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on debtor.debtor_idx = dimdebtor.debtor_idx

            left join
                phone_numbers
                on debtor.debtor_idx = phone_numbers.debtor_idx

            left join
                edwprodhh.pub_jchang.transform_directory_phone_number as phone_debtor_source
                on  debtor.debtor_idx       = phone_debtor_source.debtor_idx
                and phone_numbers.phone_    = phone_debtor_source.phone_number

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