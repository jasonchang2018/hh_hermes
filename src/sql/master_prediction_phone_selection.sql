create or replace table
    edwprodhh.hermes.master_prediction_phone_selection
as
with all_phones as
(
    select      distinct
                packet_idx,
                phone_format as phone
    from        edwprodhh.pub_jchang.master_phone_number
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
                and regexp_like(phone, '^\\d{10}$')
    group by    1,2
)
, activity_calls_ib as
(
    select      packet_idx,
                phone_debtor                                            as phone,
                count(*)                                                as n_calls_inbound
    from        edwprodhh.pub_jchang.master_calls
    where       calldirection = 'Inbound'
                and regexp_like(phone, '^\\d{10}$')
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
    where       regexp_like(phone, '^\\d{10}$')
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
    where       regexp_like(phone, '^\\d{10}$')
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
                

                ob_call_is_answered         *  1.00     +
                ob_call_is_not_answered     * -0.50     +
                ob_call_is_rpc              *  1.00     +
                ob_call_is_not_rpc          * -0.50     +
                text_is_successful          *  0.00     +
                text_is_error               * -2.00     +
                voapp_is_successful         *  0.00     +
                voapp_is_error              * -2.00     +
                ib_call_n                   *  4.00     +
                attr_last                   *  8.00             as phone_score_raw

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

                    power(1.25, phone_score_raw)                                                        as phone_score_transform,
                    phone_score_transform / sum(phone_score_transform) over (partition by packet_idx)   as phone_score
                    
        from        calculate_phone_score
    )
    select      *,
                sum(phone_score) over (partition by packet_idx order by random())                       as phone_score_cdf
    from        transform
)

--  Third, select a phone number with probability determined by the above %.
--  We accomplish this by taking a random number [0-1] and taking the **first CDF value that is greater** than this random number.
, filter_rotation as
(
    with rand_cutoff as
    (
        with packets as
        (
            select      distinct
                        packet_idx
            from        calculate_rotation
        )
        select      *,
                    uniform(0::float, 1::float, random())                                               as rand_cutoff
        from        packets
    )
    select      calculate_rotation.*,
                rand_cutoff.rand_cutoff
    from        calculate_rotation
                inner join
                    rand_cutoff
                    on calculate_rotation.packet_idx = rand_cutoff.packet_idx
    where       calculate_rotation.phone_score_cdf > rand_cutoff.rand_cutoff
    qualify     row_number() over (partition by calculate_rotation.packet_idx order by calculate_rotation.phone_score_cdf asc) = 1
)
select      *
from        filter_rotation
;



select      *
from        edwprodhh.hermes.temp_master_prediction_phone_selection
where       packet_idx in (
                'CO-2321651*LV1',
                'CO-3644714*KDOR',
                'HH-46919558',
                'HH-5663133*PRO'
            )
order by    packet_idx, phone_score desc