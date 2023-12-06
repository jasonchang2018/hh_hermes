create or replace table
    edwprodhh.hermes.transform_businessrules_contact_cooldown
as
with contact_history as
(
    with last_rpc as
    (
        select      packet_idx,
                    max(callplacedtime)::date as last_rpc_date
        from        edwprodhh.pub_jchang.master_calls
        where       rpc = 1
        group by    1
    )
    select      contacts.packet_idx,
                
                count(*)                                                                                                                                as prev_n_contacts,
                count(case when contact_type in ('Letter')                                                          then contact_id     end)            as prev_n_letters,
                count(case when contact_type in ('VoApp')                                                           then contact_id     end)            as prev_n_voapps,
                count(case when contact_type in ('Text Message')                                                    then contact_id     end)            as prev_n_texts,
                count(case when contact_type in ('Email')                                                           then contact_id     end)            as prev_n_emails,
                count(case when contact_type in ('Inbound-Agent Call')                                              then contact_id     end)            as prev_n_inbounds,
                count(case when contact_type in ('Dialer-Agent Call')                                               then contact_id     end)            as prev_n_dialer_agent,
                count(case when contact_type in ('Dialer-Agentless Call')                                           then contact_id     end)            as prev_n_dialer_agentless,
                count(case when contact_type in ('Outbound-Manual Call')                                            then contact_id     end)            as prev_n_outbound_manual,
                
                count(case when contact_type in ('VoApp')                   and contact_time >= current_date() - 7  then contact_id     end)            as prev_n_voapps_7,
                count(case when contact_type in ('Dialer-Agent Call')       and contact_time >= current_date() - 7  then contact_id     end)            as prev_n_dialer_agent_7,
                count(case when contact_type in ('Dialer-Agentless Call')   and contact_time >= current_date() - 7  then contact_id     end)            as prev_n_dialer_agentless_7,
                count(case when contact_type in ('Outbound-Manual Call')    and contact_time >= current_date() - 7  then contact_id     end)            as prev_n_outbound_manual_7,
                
                max(                                                                                                     contact_time      )::date      as prev_date_contacts,
                max(  case when contact_type in ('Letter')                                                          then contact_time   end)::date      as prev_date_letters,
                max(  case when contact_type in ('VoApp')                                                           then contact_time   end)::date      as prev_date_voapps,
                max(  case when contact_type in ('Text Message')                                                    then contact_time   end)::date      as prev_date_texts,
                max(  case when contact_type in ('Email')                                                           then contact_time   end)::date      as prev_date_emails,
                max(  case when contact_type in ('Inbound-Agent Call')                                              then contact_time   end)::date      as prev_date_inbounds,
                max(  case when contact_type in ('Dialer-Agent Call')                                               then contact_time   end)::date      as prev_date_dialer_agent,
                max(  case when contact_type in ('Dialer-Agentless Call')                                           then contact_time   end)::date      as prev_date_dialer_agentless,
                max(  case when contact_type in ('Outbound-Manual Call')                                            then contact_time   end)::date      as prev_date_outbound_manual,
                max(last_rpc.last_rpc_date)                                                                                                 ::date      as prev_date_rpc

    from        edwprodhh.pub_jchang.transform_contacts as contacts
                left join
                    last_rpc
                    on contacts.packet_idx = last_rpc.packet_idx
    group by    1
)
select      debtor.debtor_idx,

            least(
                nullif(trim(dimdebtor.strat_next_strat_date),   '')::date,
                nullif(trim(dimdebtor.ntcp_nxt_print),          '')::date
            )                                                                           as next_date_letters,

            coalesce(contact_history.prev_n_contacts,               0)                  as prev_n_contacts,
            coalesce(contact_history.prev_n_letters,                0)                  as prev_n_letters,
            coalesce(contact_history.prev_n_voapps,                 0)                  as prev_n_voapps,
            coalesce(contact_history.prev_n_texts,                  0)                  as prev_n_texts,
            coalesce(contact_history.prev_n_emails,                 0)                  as prev_n_emails,
            coalesce(contact_history.prev_n_inbounds,               0)                  as prev_n_inbounds,
            coalesce(contact_history.prev_n_dialer_agent,           0)                  as prev_n_dialer_agent,
            coalesce(contact_history.prev_n_dialer_agentless,       0)                  as prev_n_dialer_agentless,
            coalesce(contact_history.prev_n_outbound_manual,        0)                  as prev_n_outbound_manual,
            coalesce(prev_n_voapps_7,                               0)                  as prev_n_voapps_7,
            coalesce(prev_n_dialer_agent_7,                         0)                  as prev_n_dialer_agent_7,
            coalesce(prev_n_dialer_agentless_7,                     0)                  as prev_n_dialer_agentless_7,
            coalesce(prev_n_outbound_manual_7,                      0)                  as prev_n_outbound_manual_7,
            coalesce(contact_history.prev_date_contacts,            '1970-01-01'::date) as prev_date_contacts,
            coalesce(contact_history.prev_date_letters,             '1970-01-01'::date) as prev_date_letters,
            coalesce(contact_history.prev_date_voapps,              '1970-01-01'::date) as prev_date_voapps,
            coalesce(contact_history.prev_date_texts,               '1970-01-01'::date) as prev_date_texts,
            coalesce(contact_history.prev_date_emails,              '1970-01-01'::date) as prev_date_emails,
            coalesce(contact_history.prev_date_inbounds,            '1970-01-01'::date) as prev_date_inbounds,
            coalesce(contact_history.prev_date_dialer_agent,        '1970-01-01'::date) as prev_date_dialer_agent,
            coalesce(contact_history.prev_date_dialer_agentless,    '1970-01-01'::date) as prev_date_dialer_agentless,
            coalesce(contact_history.prev_date_outbound_manual,     '1970-01-01'::date) as prev_date_outbound_manual,
            coalesce(contact_history.prev_date_rpc,                 '1970-01-01'::date) as prev_date_rpc,

            case    when    coalesce(next_date_letters,                     '3000-01-01'::date) >  current_date() + 14
                    then    1
                    else    0
                    end     as pass_letters_warmup,

            case    when    coalesce(contact_history.prev_n_letters,        0)                  <= 3
                    and     coalesce(contact_history.prev_n_voapps,         0)                  <= 10000
                    and     coalesce(contact_history.prev_n_texts,          0)                  <= 10000
                    and     coalesce(contact_history.prev_n_inbounds,       0)                  <= 10000
                    and     coalesce(contact_history.prev_date_letters,     '2000-01-01'::date) <= current_date() - 35
                    and     coalesce(contact_history.prev_date_voapps,      '2000-01-01'::date) <= current_date() - 8
                    and     coalesce(contact_history.prev_date_texts,       '2000-01-01'::date) <= current_date() - 8
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
                    and     coalesce(contact_history.prev_n_texts,          0)                  <= 11
                    and     coalesce(contact_history.prev_n_inbounds,       0)                  <= 10000
                    and     coalesce(contact_history.prev_date_letters,     '2000-01-01'::date) <= current_date() - 8
                    and     coalesce(contact_history.prev_date_voapps,      '2000-01-01'::date) <= current_date()
                    and     coalesce(contact_history.prev_date_texts,       '2000-01-01'::date) <= current_date() - 5
                    and     coalesce(contact_history.prev_date_inbounds,    '2000-01-01'::date) <= current_date()
                    then    1
                    else    0
                    end     as pass_texts_cooldown,

            case    when    coalesce(contact_history.prev_n_voapps_7,               0)              +
                            coalesce(contact_history.prev_n_dialer_agent_7,         0)              +
                            coalesce(contact_history.prev_n_dialer_agentless_7,     0)              +
                            coalesce(contact_history.prev_n_outbound_manual_7,      0)                  <  7
                    and     coalesce(contact_history.prev_date_rpc,                 '2000-01-01')       <= current_date() - 8
                    then    1
                    else    0
                    end     as pass_7in7


from        edwprodhh.pub_jchang.master_debtor as debtor
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on debtor.debtor_idx = dimdebtor.debtor_idx
            left join
                contact_history
                on debtor.packet_idx = contact_history.packet_idx
            left join
                edwprodhh.hermes.master_config_treatment_router as router
                on debtor.debtor_idx = router.debtor_idx
;



create or replace task
    edwprodhh.pub_jchang.replace_transform_businessrules_contact_cooldown
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_contact_cooldown
as
with contact_history as
(
    with last_rpc as
    (
        select      packet_idx,
                    max(callplacedtime)::date as last_rpc_date
        from        edwprodhh.pub_jchang.master_calls
        where       rpc = 1
        group by    1
    )
    select      contacts.packet_idx,
                
                count(*)                                                                                                                                as prev_n_contacts,
                count(case when contact_type in ('Letter')                                                          then contact_id     end)            as prev_n_letters,
                count(case when contact_type in ('VoApp')                                                           then contact_id     end)            as prev_n_voapps,
                count(case when contact_type in ('Text Message')                                                    then contact_id     end)            as prev_n_texts,
                count(case when contact_type in ('Email')                                                           then contact_id     end)            as prev_n_emails,
                count(case when contact_type in ('Inbound-Agent Call')                                              then contact_id     end)            as prev_n_inbounds,
                count(case when contact_type in ('Dialer-Agent Call')                                               then contact_id     end)            as prev_n_dialer_agent,
                count(case when contact_type in ('Dialer-Agentless Call')                                           then contact_id     end)            as prev_n_dialer_agentless,
                count(case when contact_type in ('Outbound-Manual Call')                                            then contact_id     end)            as prev_n_outbound_manual,
                
                count(case when contact_type in ('VoApp')                   and contact_time >= current_date() - 7  then contact_id     end)            as prev_n_voapps_7,
                count(case when contact_type in ('Dialer-Agent Call')       and contact_time >= current_date() - 7  then contact_id     end)            as prev_n_dialer_agent_7,
                count(case when contact_type in ('Dialer-Agentless Call')   and contact_time >= current_date() - 7  then contact_id     end)            as prev_n_dialer_agentless_7,
                count(case when contact_type in ('Outbound-Manual Call')    and contact_time >= current_date() - 7  then contact_id     end)            as prev_n_outbound_manual_7,
                
                max(                                                                                                     contact_time      )::date      as prev_date_contacts,
                max(  case when contact_type in ('Letter')                                                          then contact_time   end)::date      as prev_date_letters,
                max(  case when contact_type in ('VoApp')                                                           then contact_time   end)::date      as prev_date_voapps,
                max(  case when contact_type in ('Text Message')                                                    then contact_time   end)::date      as prev_date_texts,
                max(  case when contact_type in ('Email')                                                           then contact_time   end)::date      as prev_date_emails,
                max(  case when contact_type in ('Inbound-Agent Call')                                              then contact_time   end)::date      as prev_date_inbounds,
                max(  case when contact_type in ('Dialer-Agent Call')                                               then contact_time   end)::date      as prev_date_dialer_agent,
                max(  case when contact_type in ('Dialer-Agentless Call')                                           then contact_time   end)::date      as prev_date_dialer_agentless,
                max(  case when contact_type in ('Outbound-Manual Call')                                            then contact_time   end)::date      as prev_date_outbound_manual,
                max(last_rpc.last_rpc_date)                                                                                                 ::date      as prev_date_rpc

    from        edwprodhh.pub_jchang.transform_contacts as contacts
                left join
                    last_rpc
                    on contacts.packet_idx = last_rpc.packet_idx
    group by    1
)
select      debtor.debtor_idx,

            least(
                nullif(trim(dimdebtor.strat_next_strat_date),   '')::date,
                nullif(trim(dimdebtor.ntcp_nxt_print),          '')::date
            )                                                                           as next_date_letters,

            coalesce(contact_history.prev_n_contacts,               0)                  as prev_n_contacts,
            coalesce(contact_history.prev_n_letters,                0)                  as prev_n_letters,
            coalesce(contact_history.prev_n_voapps,                 0)                  as prev_n_voapps,
            coalesce(contact_history.prev_n_texts,                  0)                  as prev_n_texts,
            coalesce(contact_history.prev_n_emails,                 0)                  as prev_n_emails,
            coalesce(contact_history.prev_n_inbounds,               0)                  as prev_n_inbounds,
            coalesce(contact_history.prev_n_dialer_agent,           0)                  as prev_n_dialer_agent,
            coalesce(contact_history.prev_n_dialer_agentless,       0)                  as prev_n_dialer_agentless,
            coalesce(contact_history.prev_n_outbound_manual,        0)                  as prev_n_outbound_manual,
            coalesce(prev_n_voapps_7,                               0)                  as prev_n_voapps_7,
            coalesce(prev_n_dialer_agent_7,                         0)                  as prev_n_dialer_agent_7,
            coalesce(prev_n_dialer_agentless_7,                     0)                  as prev_n_dialer_agentless_7,
            coalesce(prev_n_outbound_manual_7,                      0)                  as prev_n_outbound_manual_7,
            coalesce(contact_history.prev_date_contacts,            '1970-01-01'::date) as prev_date_contacts,
            coalesce(contact_history.prev_date_letters,             '1970-01-01'::date) as prev_date_letters,
            coalesce(contact_history.prev_date_voapps,              '1970-01-01'::date) as prev_date_voapps,
            coalesce(contact_history.prev_date_texts,               '1970-01-01'::date) as prev_date_texts,
            coalesce(contact_history.prev_date_emails,              '1970-01-01'::date) as prev_date_emails,
            coalesce(contact_history.prev_date_inbounds,            '1970-01-01'::date) as prev_date_inbounds,
            coalesce(contact_history.prev_date_dialer_agent,        '1970-01-01'::date) as prev_date_dialer_agent,
            coalesce(contact_history.prev_date_dialer_agentless,    '1970-01-01'::date) as prev_date_dialer_agentless,
            coalesce(contact_history.prev_date_outbound_manual,     '1970-01-01'::date) as prev_date_outbound_manual,
            coalesce(contact_history.prev_date_rpc,                 '1970-01-01'::date) as prev_date_rpc,

            case    when    coalesce(next_date_letters,                     '3000-01-01'::date) >  current_date() + 14
                    then    1
                    else    0
                    end     as pass_letters_warmup,

            case    when    coalesce(contact_history.prev_n_letters,        0)                  <= 3
                    and     coalesce(contact_history.prev_n_voapps,         0)                  <= 10000
                    and     coalesce(contact_history.prev_n_texts,          0)                  <= 10000
                    and     coalesce(contact_history.prev_n_inbounds,       0)                  <= 10000
                    and     coalesce(contact_history.prev_date_letters,     '2000-01-01'::date) <= current_date() - 35
                    and     coalesce(contact_history.prev_date_voapps,      '2000-01-01'::date) <= current_date() - 8
                    and     coalesce(contact_history.prev_date_texts,       '2000-01-01'::date) <= current_date() - 8
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
                    and     coalesce(contact_history.prev_n_texts,          0)                  <= 11
                    and     coalesce(contact_history.prev_n_inbounds,       0)                  <= 10000
                    and     coalesce(contact_history.prev_date_letters,     '2000-01-01'::date) <= current_date() - 8
                    and     coalesce(contact_history.prev_date_voapps,      '2000-01-01'::date) <= current_date()
                    and     coalesce(contact_history.prev_date_texts,       '2000-01-01'::date) <= current_date() - 5
                    and     coalesce(contact_history.prev_date_inbounds,    '2000-01-01'::date) <= current_date()
                    then    1
                    else    0
                    end     as pass_texts_cooldown,

            case    when    coalesce(contact_history.prev_n_voapps_7,               0)              +
                            coalesce(contact_history.prev_n_dialer_agent_7,         0)              +
                            coalesce(contact_history.prev_n_dialer_agentless_7,     0)              +
                            coalesce(contact_history.prev_n_outbound_manual_7,      0)                  <  7
                    and     coalesce(contact_history.prev_date_rpc,                 '2000-01-01')       <= current_date() - 8
                    then    1
                    else    0
                    end     as pass_7in7


from        edwprodhh.pub_jchang.master_debtor as debtor
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on debtor.debtor_idx = dimdebtor.debtor_idx
            left join
                contact_history
                on debtor.packet_idx = contact_history.packet_idx
            left join
                edwprodhh.hermes.master_config_treatment_router as router
                on debtor.debtor_idx = router.debtor_idx
;