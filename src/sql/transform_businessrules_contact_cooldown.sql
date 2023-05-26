create or replace table
    edwprodhh.hermes.transform_businessrules_contact_cooldown
as
with contact_history as
(
    select      packet_idx,
                
                count(*)                                                                                                            as prev_n_contacts,
                count(case when contact_type in ('Letter')                                      then contact_id     end)            as prev_n_letters,
                count(case when contact_type in ('VoApp')                                       then contact_id     end)            as prev_n_voapps,
                count(case when contact_type in ('Text Message')                                then contact_id     end)            as prev_n_texts,
                count(case when contact_type in ('Email')                                       then contact_id     end)            as prev_n_emails,
                count(case when contact_type in ('Inbound-Agent Call')                          then contact_id     end)            as prev_n_inbounds,
                count(case when contact_type in ('Dialer-Agent Call')                           then contact_id     end)            as prev_n_dialer_agent,
                count(case when contact_type in ('Dialer-Agentless Call')                       then contact_id     end)            as prev_n_dialer_agentless,
                count(case when contact_type in ('Outbound-Manual Call')                        then contact_id     end)            as prev_n_outbound_manual,
                
                max(                                                                                 contact_time      )::date      as prev_date_contacts,
                max(  case when contact_type in ('Letter')                                      then contact_time   end)::date      as prev_date_letters,
                max(  case when contact_type in ('VoApp')                                       then contact_time   end)::date      as prev_date_voapps,
                max(  case when contact_type in ('Text Message')                                then contact_time   end)::date      as prev_date_texts,
                max(  case when contact_type in ('Email')                                       then contact_time   end)::date      as prev_date_emails,
                max(  case when contact_type in ('Inbound-Agent Call')                          then contact_time   end)::date      as prev_date_inbounds,
                max(  case when contact_type in ('Dialer-Agent Call')                           then contact_time   end)::date      as prev_date_dialer_agent,
                max(  case when contact_type in ('Dialer-Agentless Call')                       then contact_time   end)::date      as prev_date_dialer_agentless,
                max(  case when contact_type in ('Outbound-Manual Call')                        then contact_time   end)::date      as prev_date_outbound_manual

    from        edwprodhh.pub_jchang.transform_contacts
    group by    1
)
select      debtor.debtor_idx,

            coalesce(contact_history.prev_n_contacts,               0)                  as prev_n_contacts,
            coalesce(contact_history.prev_n_letters,                0)                  as prev_n_letters,
            coalesce(contact_history.prev_n_voapps,                 0)                  as prev_n_voapps,
            coalesce(contact_history.prev_n_texts,                  0)                  as prev_n_texts,
            coalesce(contact_history.prev_n_emails,                 0)                  as prev_n_emails,
            coalesce(contact_history.prev_n_inbounds,               0)                  as prev_n_inbounds,
            coalesce(contact_history.prev_n_dialer_agent,           0)                  as prev_n_dialer_agent,
            coalesce(contact_history.prev_n_dialer_agentless,       0)                  as prev_n_dialer_agentless,
            coalesce(contact_history.prev_n_outbound_manual,        0)                  as prev_n_outbound_manual,
            coalesce(contact_history.prev_date_contacts,            '1970-01-01'::date) as prev_date_contacts,
            coalesce(contact_history.prev_date_letters,             '1970-01-01'::date) as prev_date_letters,
            coalesce(contact_history.prev_date_voapps,              '1970-01-01'::date) as prev_date_voapps,
            coalesce(contact_history.prev_date_texts,               '1970-01-01'::date) as prev_date_texts,
            coalesce(contact_history.prev_date_emails,              '1970-01-01'::date) as prev_date_emails,
            coalesce(contact_history.prev_date_inbounds,            '1970-01-01'::date) as prev_date_inbounds,
            coalesce(contact_history.prev_date_dialer_agent,        '1970-01-01'::date) as prev_date_dialer_agent,
            coalesce(contact_history.prev_date_dialer_agentless,    '1970-01-01'::date) as prev_date_dialer_agentless,
            coalesce(contact_history.prev_date_outbound_manual,     '1970-01-01'::date) as prev_date_outbound_manual,

            case    when    coalesce(contact_history.prev_n_letters,        0)                  <= 4
                    and     coalesce(contact_history.prev_n_voapps,         0)                  <= 10000
                    and     coalesce(contact_history.prev_n_texts,          0)                  <= 10000
                    and     coalesce(contact_history.prev_n_inbounds,       0)                  <= 10000
                    and     coalesce(contact_history.prev_date_letters,     '2000-01-01'::date) <= current_date() - 35
                    and     coalesce(contact_history.prev_date_voapps,      '2000-01-01'::date) <= current_date()
                    and     coalesce(contact_history.prev_date_texts,       '2000-01-01'::date) <= current_date()
                    and     coalesce(contact_history.prev_date_inbounds,    '2000-01-01'::date) <= current_date()
                    then    1
                    else    0
                    end     as pass_letters_cooldown,

            case    when    coalesce(contact_history.prev_n_letters,        0)                  <= 10000
                    and     coalesce(contact_history.prev_n_voapps,         0)                  <= 19
                    and     coalesce(contact_history.prev_n_texts,          0)                  <= 10000
                    and     coalesce(contact_history.prev_n_inbounds,       0)                  <= 10000
                    and     coalesce(contact_history.prev_date_letters,     '2000-01-01'::date) <= current_date() - 8
                    and     coalesce(contact_history.prev_date_voapps,      '2000-01-01'::date) <= current_date() - 8
                    and     coalesce(contact_history.prev_date_texts,       '2000-01-01'::date) <= current_date()
                    and     coalesce(contact_history.prev_date_inbounds,    '2000-01-01'::date) <= current_date()
                    then    1
                    else    0
                    end     as pass_voapps_cooldown,

            case    when    coalesce(contact_history.prev_n_letters,        0)                  <= 10000
                    and     coalesce(contact_history.prev_n_voapps,         0)                  <= 10000
                    and     coalesce(contact_history.prev_n_texts,          0)                  <= 19
                    and     coalesce(contact_history.prev_n_inbounds,       0)                  <= 10000
                    and     coalesce(contact_history.prev_date_letters,     '2000-01-01'::date) <= current_date() - 8
                    and     coalesce(contact_history.prev_date_voapps,      '2000-01-01'::date) <= current_date()
                    and     coalesce(contact_history.prev_date_texts,       '2000-01-01'::date) <= current_date() - 8
                    and     coalesce(contact_history.prev_date_inbounds,    '2000-01-01'::date) <= current_date()
                    then    1
                    else    0
                    end     as pass_texts_cooldown

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                contact_history
                on debtor.packet_idx = contact_history.packet_idx
;



create task
    edwprodhh.pub_jchang.replace_transform_businessrules_contact_cooldown
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_contact_cooldown
as
with contact_history as
(
    select      packet_idx,
                
                count(*)                                                                                                            as prev_n_contacts,
                count(case when contact_type in ('Letter')                                      then contact_id     end)            as prev_n_letters,
                count(case when contact_type in ('VoApp')                                       then contact_id     end)            as prev_n_voapps,
                count(case when contact_type in ('Text Message')                                then contact_id     end)            as prev_n_texts,
                count(case when contact_type in ('Email')                                       then contact_id     end)            as prev_n_emails,
                count(case when contact_type in ('Inbound-Agent Call')                          then contact_id     end)            as prev_n_inbounds,
                count(case when contact_type in ('Dialer-Agent Call')                           then contact_id     end)            as prev_n_dialer_agent,
                count(case when contact_type in ('Dialer-Agentless Call')                       then contact_id     end)            as prev_n_dialer_agentless,
                count(case when contact_type in ('Outbound-Manual Call')                        then contact_id     end)            as prev_n_outbound_manual,
                
                max(                                                                                 contact_time      )::date      as prev_date_contacts,
                max(  case when contact_type in ('Letter')                                      then contact_time   end)::date      as prev_date_letters,
                max(  case when contact_type in ('VoApp')                                       then contact_time   end)::date      as prev_date_voapps,
                max(  case when contact_type in ('Text Message')                                then contact_time   end)::date      as prev_date_texts,
                max(  case when contact_type in ('Email')                                       then contact_time   end)::date      as prev_date_emails,
                max(  case when contact_type in ('Inbound-Agent Call')                          then contact_time   end)::date      as prev_date_inbounds,
                max(  case when contact_type in ('Dialer-Agent Call')                           then contact_time   end)::date      as prev_date_dialer_agent,
                max(  case when contact_type in ('Dialer-Agentless Call')                       then contact_time   end)::date      as prev_date_dialer_agentless,
                max(  case when contact_type in ('Outbound-Manual Call')                        then contact_time   end)::date      as prev_date_outbound_manual

    from        edwprodhh.pub_jchang.transform_contacts
    group by    1
)
select      debtor.debtor_idx,

            coalesce(contact_history.prev_n_contacts,               0)                  as prev_n_contacts,
            coalesce(contact_history.prev_n_letters,                0)                  as prev_n_letters,
            coalesce(contact_history.prev_n_voapps,                 0)                  as prev_n_voapps,
            coalesce(contact_history.prev_n_texts,                  0)                  as prev_n_texts,
            coalesce(contact_history.prev_n_emails,                 0)                  as prev_n_emails,
            coalesce(contact_history.prev_n_inbounds,               0)                  as prev_n_inbounds,
            coalesce(contact_history.prev_n_dialer_agent,           0)                  as prev_n_dialer_agent,
            coalesce(contact_history.prev_n_dialer_agentless,       0)                  as prev_n_dialer_agentless,
            coalesce(contact_history.prev_n_outbound_manual,        0)                  as prev_n_outbound_manual,
            coalesce(contact_history.prev_date_contacts,            '1970-01-01'::date) as prev_date_contacts,
            coalesce(contact_history.prev_date_letters,             '1970-01-01'::date) as prev_date_letters,
            coalesce(contact_history.prev_date_voapps,              '1970-01-01'::date) as prev_date_voapps,
            coalesce(contact_history.prev_date_texts,               '1970-01-01'::date) as prev_date_texts,
            coalesce(contact_history.prev_date_emails,              '1970-01-01'::date) as prev_date_emails,
            coalesce(contact_history.prev_date_inbounds,            '1970-01-01'::date) as prev_date_inbounds,
            coalesce(contact_history.prev_date_dialer_agent,        '1970-01-01'::date) as prev_date_dialer_agent,
            coalesce(contact_history.prev_date_dialer_agentless,    '1970-01-01'::date) as prev_date_dialer_agentless,
            coalesce(contact_history.prev_date_outbound_manual,     '1970-01-01'::date) as prev_date_outbound_manual,

            case    when    coalesce(contact_history.prev_n_letters,        0)                  <= 4
                    and     coalesce(contact_history.prev_n_voapps,         0)                  <= 10000
                    and     coalesce(contact_history.prev_n_texts,          0)                  <= 10000
                    and     coalesce(contact_history.prev_n_inbounds,       0)                  <= 10000
                    and     coalesce(contact_history.prev_date_letters,     '2000-01-01'::date) <= current_date() - 35
                    and     coalesce(contact_history.prev_date_voapps,      '2000-01-01'::date) <= current_date()
                    and     coalesce(contact_history.prev_date_texts,       '2000-01-01'::date) <= current_date()
                    and     coalesce(contact_history.prev_date_inbounds,    '2000-01-01'::date) <= current_date()
                    then    1
                    else    0
                    end     as pass_letters_cooldown,

            case    when    coalesce(contact_history.prev_n_letters,        0)                  <= 10000
                    and     coalesce(contact_history.prev_n_voapps,         0)                  <= 19
                    and     coalesce(contact_history.prev_n_texts,          0)                  <= 10000
                    and     coalesce(contact_history.prev_n_inbounds,       0)                  <= 10000
                    and     coalesce(contact_history.prev_date_letters,     '2000-01-01'::date) <= current_date() - 8
                    and     coalesce(contact_history.prev_date_voapps,      '2000-01-01'::date) <= current_date() - 8
                    and     coalesce(contact_history.prev_date_texts,       '2000-01-01'::date) <= current_date()
                    and     coalesce(contact_history.prev_date_inbounds,    '2000-01-01'::date) <= current_date()
                    then    1
                    else    0
                    end     as pass_voapps_cooldown,

            case    when    coalesce(contact_history.prev_n_letters,        0)                  <= 10000
                    and     coalesce(contact_history.prev_n_voapps,         0)                  <= 10000
                    and     coalesce(contact_history.prev_n_texts,          0)                  <= 19
                    and     coalesce(contact_history.prev_n_inbounds,       0)                  <= 10000
                    and     coalesce(contact_history.prev_date_letters,     '2000-01-01'::date) <= current_date() - 8
                    and     coalesce(contact_history.prev_date_voapps,      '2000-01-01'::date) <= current_date()
                    and     coalesce(contact_history.prev_date_texts,       '2000-01-01'::date) <= current_date() - 8
                    and     coalesce(contact_history.prev_date_inbounds,    '2000-01-01'::date) <= current_date()
                    then    1
                    else    0
                    end     as pass_texts_cooldown

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                contact_history
                on debtor.packet_idx = contact_history.packet_idx
;