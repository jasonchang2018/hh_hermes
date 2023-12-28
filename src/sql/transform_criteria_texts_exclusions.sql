create or replace table
    edwprodhh.hermes.transform_criteria_texts_exclusions
as
with texts as
(
    select      texts.emid_idx,
                texts.debtor_idx,
                debtor.packet_idx,
                texts.contact as phone_number,
                texts.status_date,
                upper(nullif(trim(texts.content), '')) as content_clean
                
    from        edwprodhh.pub_jchang.transform_electronicsmedia as texts
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on texts.debtor_idx = debtor.debtor_idx
    where       texts.channel = 'TEXT'
)
, tagged as
(
    select      debtor_idx,
                packet_idx,
                phone_number,

                case    when    content_clean is not null
                        and     not regexp_like(content_clean, '^CARRIER.*')
                        and     not regexp_like(content_clean, '^MESSAGE\\s(WAS UNDELIVERABLE|WAS REJECTED|WAS DELETED|VALIDITY EXPIRED).*')
                        and     not regexp_like(content_clean, '^(API|VBT|FALSE|INVALID DESTINATION ADDRESS|REJECTED AS SPAM)$')
                        then    1
                        else    0
                        end     as has_inbound_response_,


                
                case    when    content_clean is not null
                        and     regexp_like(content_clean, '^CARRIER.*')
                        then    1
                        else    0
                        end     as has_carrier_error_,

                case    when    content_clean is not null
                        and     regexp_like(content_clean, '^CARRIER\\s(RETURNED|REJECTED).*')
                        then    1
                        else    0
                        end     as has_carrier_error_reject_,


                
                case    when    content_clean is not null
                        and     regexp_like(content_clean, '^MESSAGE\\s(WAS UNDELIVERABLE|WAS REJECTED|WAS DELETED|VALIDITY EXPIRED).*')
                        then    1
                        else    0
                        end     as has_phone_error_,

                case    when    content_clean is not null
                        and     regexp_like(content_clean, '^MESSAGE\\s(WAS UNDELIVERABLE|WAS REJECTED|WAS DELETED).*')
                        then    1
                        else    0
                        end     as has_phone_error_reject_,


                
                case    when    content_clean is not null
                        and     content_clean = 'INVALID DESTINATION ADDRESS'
                        then    1
                        else    0
                        end     as has_address_error_

    from        texts
)
, agg_debtor as
(
    select      debtor_idx,
                packet_idx,
                phone_number,
                max(has_inbound_response_)      as has_inbound_response,
                max(has_carrier_error_)         as has_carrier_error,
                max(has_carrier_error_reject_)  as has_carrier_error_reject,
                max(has_phone_error_)           as has_phone_error,
                max(has_phone_error_reject_)    as has_phone_error_reject,
                max(has_address_error_)         as has_address_error,

                case    when    has_inbound_response        = 1
                        then    1
                        else    0
                        end     as stop_text_intent,

                case    when    has_carrier_error_reject    = 1
                        or      has_phone_error_reject      = 1
                        or      has_address_error           = 1
                        then    1
                        else    0
                        end     as stop_text_error,

                case    when    stop_text_intent            = 1
                        or      stop_text_error             = 1
                        then    1
                        else    0
                        end     as stop_text

    from        tagged
    group by    1,2,3
)
, agg_packet as
(
    select      debtor_idx,
                packet_idx,
                phone_number,
                max(has_inbound_response)       over (partition by packet_idx, phone_number) as has_inbound_response,
                max(has_carrier_error)          over (partition by packet_idx, phone_number) as has_carrier_error,
                max(has_carrier_error_reject)   over (partition by packet_idx, phone_number) as has_carrier_error_reject,
                max(has_phone_error)            over (partition by packet_idx, phone_number) as has_phone_error,
                max(has_phone_error_reject)     over (partition by packet_idx, phone_number) as has_phone_error_reject,
                max(has_address_error)          over (partition by packet_idx, phone_number) as has_address_error,
                max(stop_text_intent)           over (partition by packet_idx, phone_number) as stop_text_intent,
                max(stop_text_error)            over (partition by packet_idx, phone_number) as stop_text_error,
                max(stop_text)                  over (partition by packet_idx, phone_number) as stop_text
    from        agg_debtor
)
select      *
from        agg_packet
;



create or replace task
    edwprodhh.pub_jchang.replace_transform_criteria_texts_exclusions
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_criteria_texts_exclusions
as
with texts as
(
    select      texts.emid_idx,
                texts.debtor_idx,
                debtor.packet_idx,
                texts.contact as phone_number,
                texts.status_date,
                upper(nullif(trim(texts.content), '')) as content_clean
                
    from        edwprodhh.pub_jchang.transform_electronicsmedia as texts
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on texts.debtor_idx = debtor.debtor_idx
    where       texts.channel = 'TEXT'
)
, tagged as
(
    select      debtor_idx,
                packet_idx,
                phone_number,

                case    when    content_clean is not null
                        and     not regexp_like(content_clean, '^CARRIER.*')
                        and     not regexp_like(content_clean, '^MESSAGE\\s(WAS UNDELIVERABLE|WAS REJECTED|WAS DELETED|VALIDITY EXPIRED).*')
                        and     not regexp_like(content_clean, '^(API|VBT|FALSE|INVALID DESTINATION ADDRESS|REJECTED AS SPAM)$')
                        then    1
                        else    0
                        end     as has_inbound_response_,


                
                case    when    content_clean is not null
                        and     regexp_like(content_clean, '^CARRIER.*')
                        then    1
                        else    0
                        end     as has_carrier_error_,

                case    when    content_clean is not null
                        and     regexp_like(content_clean, '^CARRIER\\s(RETURNED|REJECTED).*')
                        then    1
                        else    0
                        end     as has_carrier_error_reject_,


                
                case    when    content_clean is not null
                        and     regexp_like(content_clean, '^MESSAGE\\s(WAS UNDELIVERABLE|WAS REJECTED|WAS DELETED|VALIDITY EXPIRED).*')
                        then    1
                        else    0
                        end     as has_phone_error_,

                case    when    content_clean is not null
                        and     regexp_like(content_clean, '^MESSAGE\\s(WAS UNDELIVERABLE|WAS REJECTED|WAS DELETED).*')
                        then    1
                        else    0
                        end     as has_phone_error_reject_,


                
                case    when    content_clean is not null
                        and     content_clean = 'INVALID DESTINATION ADDRESS'
                        then    1
                        else    0
                        end     as has_address_error_

    from        texts
)
, agg_debtor as
(
    select      debtor_idx,
                packet_idx,
                phone_number,
                max(has_inbound_response_)      as has_inbound_response,
                max(has_carrier_error_)         as has_carrier_error,
                max(has_carrier_error_reject_)  as has_carrier_error_reject,
                max(has_phone_error_)           as has_phone_error,
                max(has_phone_error_reject_)    as has_phone_error_reject,
                max(has_address_error_)         as has_address_error,

                case    when    has_inbound_response        = 1
                        then    1
                        else    0
                        end     as stop_text_intent,

                case    when    has_carrier_error_reject    = 1
                        or      has_phone_error_reject      = 1
                        or      has_address_error           = 1
                        then    1
                        else    0
                        end     as stop_text_error,

                case    when    stop_text_intent            = 1
                        or      stop_text_error             = 1
                        then    1
                        else    0
                        end     as stop_text

    from        tagged
    group by    1,2,3
)
, agg_packet as
(
    select      debtor_idx,
                packet_idx,
                phone_number,
                max(has_inbound_response)       over (partition by packet_idx, phone_number) as has_inbound_response,
                max(has_carrier_error)          over (partition by packet_idx, phone_number) as has_carrier_error,
                max(has_carrier_error_reject)   over (partition by packet_idx, phone_number) as has_carrier_error_reject,
                max(has_phone_error)            over (partition by packet_idx, phone_number) as has_phone_error,
                max(has_phone_error_reject)     over (partition by packet_idx, phone_number) as has_phone_error_reject,
                max(has_address_error)          over (partition by packet_idx, phone_number) as has_address_error,
                max(stop_text_intent)           over (partition by packet_idx, phone_number) as stop_text_intent,
                max(stop_text_error)            over (partition by packet_idx, phone_number) as stop_text_error,
                max(stop_text)                  over (partition by packet_idx, phone_number) as stop_text
    from        agg_debtor
)
select      *
from        agg_packet
;