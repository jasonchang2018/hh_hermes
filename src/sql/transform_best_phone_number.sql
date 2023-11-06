create or replace table
    edwprodhh.pub_mbutler.transform_phone_number_phone_numbers
as
select      debtor.packet_idx,
            debtor.debtor_idx,
            phones.phone_format as phone_format,
            phones.phone_is_valid
from        edwprodhh.pub_jchang.master_phone_number as phones
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on phones.debtor_idx = debtor.debtor_idx
qualify     row_number() over (partition by phones.debtor_idx, phone_format order by random()) = 1
;


create or replace table
    edwprodhh.pub_mbutler.transform_phone_number_call_logic
as
select      packet_idx,
            debtor_idx,
            phonenumber,
            case when sum(is_answered) >= 1 then 1 else 0 end as is_answered,
            case when sum(talktime) >= 60 then 1 else 0 end as successful_call
from        edwprodhh.pub_jchang.master_calls
where       calldirection = 'Outbound'
group by    1,2,3
;


--  IS IT WORTH JUST LOOKING AT THE MOST RECENT?
create or replace table
    edwprodhh.pub_mbutler.transform_phone_number_text_logic
as
with text_logic as
(
    select      packet_idx,
                debtor_idx,
                contact,
                0 as texts_bounced
    from        edwprodhh.pub_jchang.master_texts
    union all
    select      packet_idx,
                debtor_idx,
                contact,
                1 as texts_bounced
    from        edwprodhh.pub_jchang.master_texts_bounced
)
select      packet_idx,
            debtor_idx,
            contact as contact,
            case    when    sum(texts_bounced) > 0
                    then    0
                    else    1
                    end     as text_ready
from        text_logic
group by    1,2,3
;


create or replace table
    edwprodhh.pub_mbutler.transform_phone_number_voapp_logic
as
with voapp_logic as
(
    select      packet_idx,
                debtor_idx,
                contact,
                0 as voapps_bounced
    from        edwprodhh.pub_jchang.master_voapps

    union all

    select      packet_idx,
                debtor_idx,
                contact,
                1 as voapps_bounced
    from        edwprodhh.pub_jchang.master_voapps_bounced
)
select      packet_idx,
            debtor_idx,
            contact as contact,
            case    when    sum(voapps_bounced) > 0
                    then    0
                    else    1
                    end     as voapp_ready
from        voapp_logic
group by    1,2,3
;


create or replace table
    edwprodhh.pub_mbutler.transform_phone_number_prediction_pool
as
select      debtor.packet_idx,
            pp.debtor_idx,
            valid_phone_number_dialer as valid_phone,
            pass_client_allowed_texts,
            pass_client_allowed_calls
from        edwprodhh.hermes.master_prediction_pool as pp
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on debtor.debtor_idx = pp.debtor_idx
;