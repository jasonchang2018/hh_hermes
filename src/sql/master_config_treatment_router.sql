create or replace table
    edwprodhh.hermes.master_config_treatment_router
as
with mapping as
(
    with get_packet_num as
    (
        select      packet_idx,
                    debtor_idx,
                    batch_date,
                    right(debtor_idx, 1)    as num
        from        edwprodhh.pub_jchang.master_debtor
        where       regexp_like(num, '\\d+')
    )
    select      packet_idx,
                num
    from        get_packet_num
    qualify     row_number() over (partition by packet_idx order by batch_date asc, debtor_idx asc) = 1
)
select      debtor.debtor_idx,

            case    when    min(debtor.batch_date) over (partition by debtor.packet_idx) >= '1970-01-01' --insert test start here
                    then    case    when    mapping.num in (0,1,2,3,4)
                                    then    'CONTROL'
                                    else    'TEST'
                                    end
                    else    NULL
                    end     as treatment_group,

            case    when    treatment_group = 'CONTROL'
                    then    NULL
                    when    treatment_group = 'TEST'
                    then    NULL
                    else    NULL
                    end     as treatment_description,

            NULL as test_name,
            NULL as test_description

from        edwprodhh.pub_jchang.master_debtor as debtor
            inner join
                mapping
                on debtor.packet_idx = mapping.packet_idx
;



create or replace task
    edwprodhh.pub_jchang.replace_master_config_treatment_router
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.master_config_treatment_router
as
with mapping as
(
    with get_packet_num as
    (
        select      packet_idx,
                    debtor_idx,
                    batch_date,
                    right(debtor_idx, 1)    as num
        from        edwprodhh.pub_jchang.master_debtor
        where       regexp_like(num, '\\d+')
    )
    select      packet_idx,
                num
    from        get_packet_num
    qualify     row_number() over (partition by packet_idx order by batch_date asc, debtor_idx asc) = 1
)
select      debtor.debtor_idx,

            case    when    min(debtor.batch_date) over (partition by debtor.packet_idx) >= '1970-01-01' --insert test start here
                    then    case    when    mapping.num in (0,1,2,3,4)
                                    then    'CONTROL'
                                    else    'TEST'
                                    end
                    else    NULL
                    end     as treatment_group,

            case    when    treatment_group = 'CONTROL'
                    then    NULL
                    when    treatment_group = 'TEST'
                    then    NULL
                    else    NULL
                    end     as treatment_description,

            NULL as test_name,
            NULL as test_description

from        edwprodhh.pub_jchang.master_debtor as debtor
            inner join
                mapping
                on debtor.packet_idx = mapping.packet_idx
;