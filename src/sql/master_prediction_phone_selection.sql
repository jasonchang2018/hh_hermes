create or replace table
    edwprodhh.hermes.master_prediction_phone_selection
as
with all_phones as
(
    with qualified as
    (
        select      distinct
                    packet_idx,
                    phone_format as phone,
                    dialer_file_label
        from        edwprodhh.pub_jchang.master_phone_number
        where       packet_idx not in (select packet_idx from edwprodhh.pub_jchang.transform_directory_phone_number where current_status = 'DNC')

                    --  Take most conservative.
        qualify     row_number() over (
                        partition by    packet_idx, phone_format
                        order by        case    when    dialer_file_label = 'DNC'       then    0
                                                when    dialer_file_label = 'DOMAN'     then    1
                                                when    dialer_file_label = 'CLTMAN'    then    2
                                                when    dialer_file_label = 'DOIPA'     then    3
                                                when    dialer_file_label = 'DOAUTH'    then    4
                                                when    dialer_file_label = 'CLTIPA'    then    5
                                                when    dialer_file_label = 'CLTAUTH'   then    6
                                                when    dialer_file_label = 'DOLAND'    then    7
                                                when    dialer_file_label = 'LAND'      then    8
                                                else    9
                                                end     asc
                    )   = 1
    )
    select      *
    from        qualified
    where       dialer_file_label not in ('DNC', 'DOMAN', 'CLTMAN')
)
, activity_calls_ob as
(
    select      packet_idx,
                phone_debtor                                            as phone,
                count(case when is_answered = 1             then 1 end) as is_answered,
                count(case when is_answered = 0             then 1 end) as is_not_answered,
                count(case when rpc = 1 or talktime >= 60   then 1 end) as is_rpc,
                count(case when rpc = 0 or talktime >= 60   then 1 end) as is_not_rpc
    from        edwprodhh.pub_jchang.master_calls
    where       calldirection = 'Outbound'
                and edwprodhh.pub_jchang.contact_address_valid_phone(edwprodhh.pub_jchang.contact_address_format_phone(phone)) = 1
    group by    1,2
)
, activity_calls_ib as
(
    select      packet_idx,
                phone_debtor                                            as phone,
                count(*)                                                as n_calls_inbound
    from        edwprodhh.pub_jchang.master_calls
    where       calldirection = 'Inbound'
                and edwprodhh.pub_jchang.contact_address_valid_phone(edwprodhh.pub_jchang.contact_address_format_phone(phone)) = 1
                and packet_idx is not null
    group by    1,2
)
, activity_texts as
(
    with unioned as
    (
        select      packet_idx,
                    contact as phone,
                    0       as is_bounced
        from        edwprodhh.pub_jchang.master_texts
        union all
        select      packet_idx,
                    contact as phone,
                    1       as is_bounced
        from        edwprodhh.pub_jchang.master_texts_bounced
    )
    select      packet_idx,
                phone,
                count(case when is_bounced = 0 then 1 end) as is_successful,
                count(case when is_bounced = 1 then 1 end) as is_error
    from        unioned
    where       edwprodhh.pub_jchang.contact_address_valid_phone(edwprodhh.pub_jchang.contact_address_format_phone(phone)) = 1
    group by    1,2
)
, activity_voapps as
(
    with unioned as
    (
        select      packet_idx,
                    contact as phone,
                    0       as is_bounced
        from        edwprodhh.pub_jchang.master_voapps
        union all
        select      packet_idx,
                    contact as phone,
                    1       as is_bounced
        from        edwprodhh.pub_jchang.master_voapps_bounced
    )
    select      packet_idx,
                phone,
                count(case when is_bounced = 0 then 1 end) as is_successful,
                count(case when is_bounced = 1 then 1 end) as is_error
    from        unioned
    where       edwprodhh.pub_jchang.contact_address_valid_phone(edwprodhh.pub_jchang.contact_address_format_phone(phone)) = 1
    group by    1,2
)
, activity_attr as
(
    select      distinct
                attr.packet_idx,
                contacts.phone_debtor                       as phone,
                1                                           as has_last_attr
    from        edwprodhh.pub_jchang.transform_payment_attribution_contact_weights as attr
                inner join
                    edwprodhh.pub_jchang.master_contacts as contacts
                    on attr.contact_id = contacts.contact_id
    where       attr.contact_type in ('Text Message', 'VoApp', 'Inbound-Agent Call', 'Outbound-Manual Call', 'Dialer-Agent Call', 'Dialer-Agentless Call', 'Dialer-IMC Call')
                and attr.last_model_scaled = 1
                and datediff(day, attr.contact_time, attr.trans_date) between 0 and 45
                and contacts.phone_debtor is not null
    group by    1,2
)

--  First, for each given packet, calculate the PHONE_SCORE_RAW based on all historical activity.
, calculate_phone_score as
(
    select      all_phones.packet_idx,
                all_phones.phone,
                all_phones.dialer_file_label,

                coalesce(calls_ob.is_answered,      0)          as ob_call_is_answered,
                coalesce(calls_ob.is_not_answered,  0)          as ob_call_is_not_answered,
                coalesce(calls_ob.is_rpc,           0)          as ob_call_is_rpc,
                coalesce(calls_ob.is_not_rpc,       0)          as ob_call_is_not_rpc,
                coalesce(calls_ib.n_calls_inbound,  0)          as ib_call_n,
                coalesce(texts.is_successful,       0)          as text_is_successful,
                coalesce(texts.is_error,            0)          as text_is_error,
                coalesce(voapps.is_successful,      0)          as voapp_is_successful,
                coalesce(voapps.is_error,           0)          as voapp_is_error,
                coalesce(attr.has_last_attr,        0)          as attr_last,
                
                ob_call_is_answered                                                             *  1.00     +
                ob_call_is_not_answered                                                         * -0.50     +
                ob_call_is_rpc                                                                  *  1.00     +
                ob_call_is_not_rpc                                                              * -0.50     +
                text_is_successful                                                              *  0.00     +
                text_is_error                                                                   * -2.00     +
                voapp_is_successful                                                             *  0.00     +
                voapp_is_error                                                                  * -2.00     +
                ib_call_n                                                                       *  4.00     +
                attr_last                                                                       *  8.00     +
                (all_phones.dialer_file_label in ('CLTAUTH', 'CLTIPA', 'LAND'))::number(1,0)    *  2.00     +
                (all_phones.dialer_file_label in ('DOIPA', 'DOAUTH', 'DOLAND'))::number(1,0)    * -2.00

                as phone_score_raw

        from    all_phones
                left join
                    activity_calls_ob as calls_ob
                    on  all_phones.packet_idx   = calls_ob.packet_idx
                    and all_phones.phone        = calls_ob.phone
                left join
                    activity_calls_ib as calls_ib
                    on  all_phones.packet_idx   = calls_ib.packet_idx
                    and all_phones.phone        = calls_ib.phone
                left join
                    activity_texts as texts
                    on  all_phones.packet_idx   = texts.packet_idx
                    and all_phones.phone        = texts.phone
                left join
                    activity_voapps as voapps
                    on  all_phones.packet_idx   = voapps.packet_idx
                    and all_phones.phone        = voapps.phone
                left join
                    activity_attr as attr
                    on  all_phones.packet_idx   = attr.packet_idx
                    and all_phones.phone        = attr.phone
)

--  Second, convert PHONE_SCORE_RAW into a % (Sums to 100% per packet).
, calculate_rotation as
(
    with transform as
    (
        select      *,

                    --  Base must be >= 1.
                    --  1 represents random selection.
                    --  Bases much larger than 1 represents heavier weight towards history.
                    power(1.25, phone_score_raw)                                                        as phone_score_transform,
                    edwprodhh.pub_jchang.divide(
                        phone_score_transform,
                        sum(phone_score_transform) over (partition by packet_idx)
                    )                                                                                   as phone_score
                    
        from        calculate_phone_score
    )
    , rand_cutoff as
    (
        with packets as
        (
            select      distinct
                        packet_idx
            from        calculate_phone_score
        )
        select      *,
                    uniform(0::float, 1::float, random())                                               as rand_cutoff
        from        packets
    )
    select      transform.*,
                sum(transform.phone_score) over (partition by transform.packet_idx order by random())   as phone_score_cdf,
                rand_cutoff.rand_cutoff
    from        transform
                inner join
                    rand_cutoff
                    on transform.packet_idx = rand_cutoff.packet_idx
)

--  Third, select a phone number with probability determined by the above %.
--  We accomplish this by taking a random number [0-1] and taking the **first CDF value that is greater** than this random number.
, filter_rotation as
(
    select      *
    from        calculate_rotation
    where       phone_score_cdf > rand_cutoff
    qualify     row_number() over (partition by packet_idx order by phone_score_cdf asc) = 1
)
select      calculate_rotation.*,
            case when filter_rotation.packet_idx is not null then 1 else 0 end as is_proposed_phone
from        calculate_rotation
            left join
                filter_rotation
                on  calculate_rotation.packet_idx   = filter_rotation.packet_idx
                and calculate_rotation.phone        = filter_rotation.phone
;



create or replace task
    edwprodhh.pub_jchang.replace_master_prediction_phone_selection
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.master_prediction_phone_selection
as
with all_phones as
(
    with qualified as
    (
        select      distinct
                    packet_idx,
                    phone_format as phone,
                    dialer_file_label
        from        edwprodhh.pub_jchang.master_phone_number
        where       packet_idx not in (select packet_idx from edwprodhh.pub_jchang.transform_directory_phone_number where current_status = 'DNC')

                    --  Take most conservative.
        qualify     row_number() over (
                        partition by    packet_idx, phone_format
                        order by        case    when    dialer_file_label = 'DNC'       then    0
                                                when    dialer_file_label = 'DOMAN'     then    1
                                                when    dialer_file_label = 'CLTMAN'    then    2
                                                when    dialer_file_label = 'DOIPA'     then    3
                                                when    dialer_file_label = 'DOAUTH'    then    4
                                                when    dialer_file_label = 'CLTIPA'    then    5
                                                when    dialer_file_label = 'CLTAUTH'   then    6
                                                when    dialer_file_label = 'DOLAND'    then    7
                                                when    dialer_file_label = 'LAND'      then    8
                                                else    9
                                                end     asc
                    )   = 1
    )
    select      *
    from        qualified
    where       dialer_file_label not in ('DNC', 'DOMAN', 'CLTMAN')
)
, activity_calls_ob as
(
    select      packet_idx,
                phone_debtor                                            as phone,
                count(case when is_answered = 1             then 1 end) as is_answered,
                count(case when is_answered = 0             then 1 end) as is_not_answered,
                count(case when rpc = 1 or talktime >= 60   then 1 end) as is_rpc,
                count(case when rpc = 0 or talktime >= 60   then 1 end) as is_not_rpc
    from        edwprodhh.pub_jchang.master_calls
    where       calldirection = 'Outbound'
                and edwprodhh.pub_jchang.contact_address_valid_phone(edwprodhh.pub_jchang.contact_address_format_phone(phone)) = 1
    group by    1,2
)
, activity_calls_ib as
(
    select      packet_idx,
                phone_debtor                                            as phone,
                count(*)                                                as n_calls_inbound
    from        edwprodhh.pub_jchang.master_calls
    where       calldirection = 'Inbound'
                and edwprodhh.pub_jchang.contact_address_valid_phone(edwprodhh.pub_jchang.contact_address_format_phone(phone)) = 1
                and packet_idx is not null
    group by    1,2
)
, activity_texts as
(
    with unioned as
    (
        select      packet_idx,
                    contact as phone,
                    0       as is_bounced
        from        edwprodhh.pub_jchang.master_texts
        union all
        select      packet_idx,
                    contact as phone,
                    1       as is_bounced
        from        edwprodhh.pub_jchang.master_texts_bounced
    )
    select      packet_idx,
                phone,
                count(case when is_bounced = 0 then 1 end) as is_successful,
                count(case when is_bounced = 1 then 1 end) as is_error
    from        unioned
    where       edwprodhh.pub_jchang.contact_address_valid_phone(edwprodhh.pub_jchang.contact_address_format_phone(phone)) = 1
    group by    1,2
)
, activity_voapps as
(
    with unioned as
    (
        select      packet_idx,
                    contact as phone,
                    0       as is_bounced
        from        edwprodhh.pub_jchang.master_voapps
        union all
        select      packet_idx,
                    contact as phone,
                    1       as is_bounced
        from        edwprodhh.pub_jchang.master_voapps_bounced
    )
    select      packet_idx,
                phone,
                count(case when is_bounced = 0 then 1 end) as is_successful,
                count(case when is_bounced = 1 then 1 end) as is_error
    from        unioned
    where       edwprodhh.pub_jchang.contact_address_valid_phone(edwprodhh.pub_jchang.contact_address_format_phone(phone)) = 1
    group by    1,2
)
, activity_attr as
(
    select      distinct
                attr.packet_idx,
                contacts.phone_debtor                       as phone,
                1                                           as has_last_attr
    from        edwprodhh.pub_jchang.transform_payment_attribution_contact_weights as attr
                inner join
                    edwprodhh.pub_jchang.master_contacts as contacts
                    on attr.contact_id = contacts.contact_id
    where       attr.contact_type in ('Text Message', 'VoApp', 'Inbound-Agent Call', 'Outbound-Manual Call', 'Dialer-Agent Call', 'Dialer-Agentless Call', 'Dialer-IMC Call')
                and attr.last_model_scaled = 1
                and datediff(day, attr.contact_time, attr.trans_date) between 0 and 45
                and contacts.phone_debtor is not null
    group by    1,2
)

--  First, for each given packet, calculate the PHONE_SCORE_RAW based on all historical activity.
, calculate_phone_score as
(
    select      all_phones.packet_idx,
                all_phones.phone,
                all_phones.dialer_file_label,

                coalesce(calls_ob.is_answered,      0)          as ob_call_is_answered,
                coalesce(calls_ob.is_not_answered,  0)          as ob_call_is_not_answered,
                coalesce(calls_ob.is_rpc,           0)          as ob_call_is_rpc,
                coalesce(calls_ob.is_not_rpc,       0)          as ob_call_is_not_rpc,
                coalesce(calls_ib.n_calls_inbound,  0)          as ib_call_n,
                coalesce(texts.is_successful,       0)          as text_is_successful,
                coalesce(texts.is_error,            0)          as text_is_error,
                coalesce(voapps.is_successful,      0)          as voapp_is_successful,
                coalesce(voapps.is_error,           0)          as voapp_is_error,
                coalesce(attr.has_last_attr,        0)          as attr_last,
                
                ob_call_is_answered                                                             *  1.00     +
                ob_call_is_not_answered                                                         * -0.50     +
                ob_call_is_rpc                                                                  *  1.00     +
                ob_call_is_not_rpc                                                              * -0.50     +
                text_is_successful                                                              *  0.00     +
                text_is_error                                                                   * -2.00     +
                voapp_is_successful                                                             *  0.00     +
                voapp_is_error                                                                  * -2.00     +
                ib_call_n                                                                       *  4.00     +
                attr_last                                                                       *  8.00     +
                (all_phones.dialer_file_label in ('CLTAUTH', 'CLTIPA', 'LAND'))::number(1,0)    *  2.00     +
                (all_phones.dialer_file_label in ('DOIPA', 'DOAUTH', 'DOLAND'))::number(1,0)    * -2.00

                as phone_score_raw

        from    all_phones
                left join
                    activity_calls_ob as calls_ob
                    on  all_phones.packet_idx   = calls_ob.packet_idx
                    and all_phones.phone        = calls_ob.phone
                left join
                    activity_calls_ib as calls_ib
                    on  all_phones.packet_idx   = calls_ib.packet_idx
                    and all_phones.phone        = calls_ib.phone
                left join
                    activity_texts as texts
                    on  all_phones.packet_idx   = texts.packet_idx
                    and all_phones.phone        = texts.phone
                left join
                    activity_voapps as voapps
                    on  all_phones.packet_idx   = voapps.packet_idx
                    and all_phones.phone        = voapps.phone
                left join
                    activity_attr as attr
                    on  all_phones.packet_idx   = attr.packet_idx
                    and all_phones.phone        = attr.phone
)

--  Second, convert PHONE_SCORE_RAW into a % (Sums to 100% per packet).
, calculate_rotation as
(
    with transform as
    (
        select      *,

                    --  Base must be >= 1.
                    --  1 represents random selection.
                    --  Bases much larger than 1 represents heavier weight towards history.
                    power(1.25, phone_score_raw)                                                        as phone_score_transform,
                    edwprodhh.pub_jchang.divide(
                        phone_score_transform,
                        sum(phone_score_transform) over (partition by packet_idx)
                    )                                                                                   as phone_score
                    
        from        calculate_phone_score
    )
    , rand_cutoff as
    (
        with packets as
        (
            select      distinct
                        packet_idx
            from        calculate_phone_score
        )
        select      *,
                    uniform(0::float, 1::float, random())                                               as rand_cutoff
        from        packets
    )
    select      transform.*,
                sum(transform.phone_score) over (partition by transform.packet_idx order by random())   as phone_score_cdf,
                rand_cutoff.rand_cutoff
    from        transform
                inner join
                    rand_cutoff
                    on transform.packet_idx = rand_cutoff.packet_idx
)

--  Third, select a phone number with probability determined by the above %.
--  We accomplish this by taking a random number [0-1] and taking the **first CDF value that is greater** than this random number.
, filter_rotation as
(
    select      *
    from        calculate_rotation
    where       phone_score_cdf > rand_cutoff
    qualify     row_number() over (partition by packet_idx order by phone_score_cdf asc) = 1
)
select      calculate_rotation.*,
            case when filter_rotation.packet_idx is not null then 1 else 0 end as is_proposed_phone
from        calculate_rotation
            left join
                filter_rotation
                on  calculate_rotation.packet_idx   = filter_rotation.packet_idx
                and calculate_rotation.phone        = filter_rotation.phone
;