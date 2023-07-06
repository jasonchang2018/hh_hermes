create or replace table
    edwprodhh.hermes.report_conversion_funnel
as
with perc_of_total as
(
    with sums as
    (
        select      pool.pl_group,
                    pool.execute_time,

                    count(*)                                                                    ::number(18,0)  as n_total,
                    sum(pool.pass_client_allowed_letters)                                       ::number(18,0)  as pass_client_allowed_letters,
                    sum(pool.pass_debtor_status)                                                ::number(18,0)  as pass_debtor_status,
                    sum(pool.pass_address_letters)                                              ::number(18,0)  as pass_address_letters,
                    sum(pool.pass_validation_requirement)                                       ::number(18,0)  as pass_validation_requirement,
                    sum(pool.pass_letters_cooldown)                                             ::number(18,0)  as pass_letters_cooldown,
                    sum(pool.pass_letters_warmup)                                               ::number(18,0)  as pass_letters_warmup,
                    sum(pool.pass_debtor_age_packet)                                            ::number(18,0)  as pass_debtor_age_packet,
                    sum(pool.pass_packet_balance)                                               ::number(18,0)  as pass_packet_balance,
                    sum(pool.is_eligible_letters)                                               ::number(18,0)  as is_eligible_letters,
                    sum(case when proposed.proposed_channel = 'Letter' then 1 else 0 end)       ::number(18,0)  as is_proposed_letters,
                    
                    sum(pool.pass_client_allowed_voapps)                                        ::number(18,0)  as pass_client_allowed_voapps,
                    sum(pool.pass_phone_voapps)                                                 ::number(18,0)  as pass_phone_voapps,
                    sum(pool.pass_debtor_balance)                                               ::number(18,0)  as pass_debtor_balance,
                    sum(pool.pass_voapps_cooldown)                                              ::number(18,0)  as pass_voapps_cooldown,
                    sum(pool.is_eligible_voapps)                                                ::number(18,0)  as is_eligible_voapps,
                    sum(case when proposed.proposed_channel = 'VoApp' then 1 else 0 end)        ::number(18,0)  as is_proposed_voapps,
                    
                    sum(pool.pass_client_allowed_texts)                                         ::number(18,0)  as pass_client_allowed_texts,
                    sum(pool.pass_phone_texts)                                                  ::number(18,0)  as pass_phone_texts,
                    sum(pool.pass_texts_cooldown)                                               ::number(18,0)  as pass_texts_cooldown,
                    sum(pool.is_eligible_texts)                                                 ::number(18,0)  as is_eligible_texts,
                    sum(case when proposed.proposed_channel = 'Text Message' then 1 else 0 end) ::number(18,0)  as is_proposed_texts


        from        edwprodhh.hermes.master_prediction_pool_log as pool
                    left join
                        edwprodhh.hermes.master_prediction_proposal_log as proposed
                        on  pool.debtor_idx     = proposed.debtor_idx
                        and pool.execute_time   = proposed.execute_time
                        and proposed.is_proposed_contact = 1
        group by    1,2
        order by    1,2
    )
    , letters as
    (
        with sums_wide as
        (
            select      pl_group,
                        execute_time,
                        'Letters'                       as hermes_funnel,
                        n_total,
                        pass_client_allowed_letters,
                        pass_debtor_status,
                        pass_address_letters,
                        pass_validation_requirement,
                        pass_letters_cooldown,
                        pass_letters_warmup,
                        pass_debtor_age_packet,
                        pass_packet_balance,
                        is_eligible_letters,
                        is_proposed_letters
            from        sums
        )
        , sums_long as
        (
            select      *
            from        sums_wide
                        unpivot(
                            metric_value for metric_name in (
                                -- n_total,
                                pass_client_allowed_letters,
                                pass_debtor_status,
                                pass_address_letters,
                                pass_validation_requirement,
                                pass_letters_cooldown,
                                pass_letters_warmup,
                                pass_debtor_age_packet,
                                pass_packet_balance,
                                is_eligible_letters,
                                is_proposed_letters
                            )
                        )
        )
        select      *
        from        sums_long
    )
    , voapps as
    (
        with sums_wide as
        (
            select      pl_group,
                        execute_time,
                        'VoApps'                        as hermes_funnel,
                        n_total,
                        pass_client_allowed_voapps,
                        pass_debtor_status,
                        pass_phone_voapps,
                        pass_validation_requirement,
                        pass_debtor_balance,
                        pass_voapps_cooldown,
                        pass_debtor_age_packet,
                        pass_packet_balance,
                        is_eligible_voapps,
                        is_proposed_voapps
            from        sums
        )
        , sums_long as
        (
            select      *
            from        sums_wide
                        unpivot(
                            metric_value for metric_name in (
                                -- n_total,
                                pass_client_allowed_voapps,
                                pass_debtor_status,
                                pass_phone_voapps,
                                pass_validation_requirement,
                                pass_debtor_balance,
                                pass_voapps_cooldown,
                                pass_debtor_age_packet,
                                pass_packet_balance,
                                is_eligible_voapps,
                                is_proposed_voapps
                            )
                        )
        )
        select      *
        from        sums_long
    )
    , texts as
    (
        with sums_wide as
        (
            select      pl_group,
                        execute_time,
                        'Texts'                         as hermes_funnel,
                        n_total,
                        pass_client_allowed_texts,
                        pass_debtor_status,
                        pass_phone_texts,
                        pass_validation_requirement,
                        pass_debtor_balance,
                        pass_texts_cooldown,
                        pass_debtor_age_packet,
                        pass_packet_balance,
                        is_eligible_texts,
                        is_proposed_texts
            from        sums
        )
        , sums_long as
        (
            select      *
            from        sums_wide
                        unpivot(
                            metric_value for metric_name in (
                                -- n_total,
                                pass_client_allowed_texts,
                                pass_debtor_status,
                                pass_phone_texts,
                                pass_validation_requirement,
                                pass_debtor_balance,
                                pass_texts_cooldown,
                                pass_debtor_age_packet,
                                pass_packet_balance,
                                is_eligible_texts,
                                is_proposed_texts
                            )
                        )
        )
        select      *
        from        sums_long
    )
    , unioned as
    (
        with unioned_ as
        (
            select      *
            from        letters
            union all
            select      *
            from        voapps
            union all
            select      *
            from        texts
        )
        select      *,

                    case    when    hermes_funnel = 'Letters'                                           then    1
                            when    hermes_funnel = 'VoApps'                                            then    2
                            when    hermes_funnel = 'Texts'                                             then    3
                            end     as sorter_channel,

                    case    when    hermes_funnel = 'Letters'
                            then    case    when    metric_name = 'N_TOTAL'                             then    1
                                            when    metric_name = 'PASS_CLIENT_ALLOWED_LETTERS'         then    2
                                            when    metric_name = 'PASS_DEBTOR_STATUS'                  then    3
                                            when    metric_name = 'PASS_ADDRESS_LETTERS'                then    4
                                            when    metric_name = 'PASS_VALIDATION_REQUIREMENT'         then    5
                                            when    metric_name = 'PASS_LETTERS_COOLDOWN'               then    6
                                            when    metric_name = 'PASS_LETTERS_WARMUP'                 then    7
                                            when    metric_name = 'PASS_DEBTOR_AGE_PACKET'              then    8
                                            when    metric_name = 'PASS_PACKET_BALANCE'                 then    9
                                            when    metric_name = 'IS_ELIGIBLE_LETTERS'                 then    10
                                            when    metric_name = 'IS_PROPOSED_LETTERS'                 then    11
                                            end
                            when    hermes_funnel = 'VoApps'
                            then    case    when    metric_name = 'N_TOTAL'                             then    1
                                            when    metric_name = 'PASS_CLIENT_ALLOWED_VOAPPS'          then    2
                                            when    metric_name = 'PASS_DEBTOR_STATUS'                  then    3
                                            when    metric_name = 'PASS_PHONE_VOAPPS'                   then    4
                                            when    metric_name = 'PASS_VALIDATION_REQUIREMENT'         then    5
                                            when    metric_name = 'PASS_DEBTOR_BALANCE'                 then    6
                                            when    metric_name = 'PASS_VOAPPS_COOLDOWN'                then    7
                                            when    metric_name = 'PASS_DEBTOR_AGE_PACKET'              then    8
                                            when    metric_name = 'PASS_PACKET_BALANCE'                 then    9
                                            when    metric_name = 'IS_ELIGIBLE_VOAPPS'                  then    10
                                            when    metric_name = 'IS_PROPOSED_VOAPPS'                  then    11
                                            end
                            when    hermes_funnel = 'Texts'
                            then    case    when    metric_name = 'N_TOTAL'                             then    1
                                            when    metric_name = 'PASS_CLIENT_ALLOWED_TEXTS'           then    2
                                            when    metric_name = 'PASS_DEBTOR_STATUS'                  then    3
                                            when    metric_name = 'PASS_PHONE_TEXTS'                    then    4
                                            when    metric_name = 'PASS_VALIDATION_REQUIREMENT'         then    5
                                            when    metric_name = 'PASS_DEBTOR_BALANCE'                 then    6
                                            when    metric_name = 'PASS_TEXTS_COOLDOWN'                 then    7
                                            when    metric_name = 'PASS_DEBTOR_AGE_PACKET'              then    8
                                            when    metric_name = 'PASS_PACKET_BALANCE'                 then    9
                                            when    metric_name = 'IS_ELIGIBLE_TEXTS'                   then    10
                                            when    metric_name = 'IS_PROPOSED_TEXTS'                   then    11
                                            end
                            end     as sorter_funnel

        from        unioned_
        where       case    when    hermes_funnel = 'Letters'   then    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_letters)
                            when    hermes_funnel = 'VoApps'    then    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_voapps)
                            when    hermes_funnel = 'Texts'     then    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_texts)
                            end
    )
    select      *
    from        unioned
    order by    1,2,7,8
)
, perc_of_previous as
(
    with pool_mutate as
    (
        select      pool.debtor_idx,
                    pool.pl_group,
                    pool.execute_time,

                                                                                        pool.pass_client_allowed_letters                                                    as letters_pass_client_allowed_letters_,
                    case    when    letters_pass_client_allowed_letters_    = 1 then    pool.pass_debtor_status                                                 else 0 end  as letters_pass_debtor_status_,
                    case    when    letters_pass_debtor_status_             = 1 then    pool.pass_address_letters                                               else 0 end  as letters_pass_address_letters_,
                    case    when    letters_pass_address_letters_           = 1 then    pool.pass_validation_requirement                                        else 0 end  as letters_pass_validation_requirement_,
                    case    when    letters_pass_validation_requirement_    = 1 then    pool.pass_letters_cooldown                                              else 0 end  as letters_pass_letters_cooldown_,
                    case    when    letters_pass_letters_cooldown_          = 1 then    pool.pass_letters_warmup                                                else 0 end  as letters_pass_letters_warmup_,
                    case    when    letters_pass_letters_warmup_            = 1 then    pool.pass_debtor_age_packet                                             else 0 end  as letters_pass_debtor_age_packet_,
                    case    when    letters_pass_debtor_age_packet_         = 1 then    pool.pass_packet_balance                                                else 0 end  as letters_pass_packet_balance_,
                    case    when    letters_pass_packet_balance_            = 1 then    pool.is_eligible_letters                                                else 0 end  as letters_is_eligible_letters_,
                    case    when    letters_is_eligible_letters_            = 1 then    case when proposed.proposed_channel = 'Letter' then 1 else 0 end        else 0 end  as letters_is_proposed_letters_,
 
                                                                                        pool.pass_client_allowed_voapps                                                     as voapps_pass_client_allowed_voapps_,
                    case    when    voapps_pass_client_allowed_voapps_      = 1 then    pool.pass_debtor_status                                                 else 0 end  as voapps_pass_debtor_status_,
                    case    when    voapps_pass_debtor_status_              = 1 then    pool.pass_phone_voapps                                                  else 0 end  as voapps_pass_phone_voapps_,
                    case    when    voapps_pass_phone_voapps_               = 1 then    pool.pass_validation_requirement                                        else 0 end  as voapps_pass_validation_requirement_,
                    case    when    voapps_pass_validation_requirement_     = 1 then    pool.pass_debtor_balance                                                else 0 end  as voapps_pass_debtor_balance_,
                    case    when    voapps_pass_debtor_balance_             = 1 then    pool.pass_voapps_cooldown                                               else 0 end  as voapps_pass_voapps_cooldown_,
                    case    when    voapps_pass_voapps_cooldown_            = 1 then    pool.pass_debtor_age_packet                                             else 0 end  as voapps_pass_debtor_age_packet_,
                    case    when    voapps_pass_debtor_age_packet_          = 1 then    pool.pass_packet_balance                                                else 0 end  as voapps_pass_packet_balance_,
                    case    when    voapps_pass_packet_balance_             = 1 then    pool.is_eligible_voapps                                                 else 0 end  as voapps_is_eligible_voapps_,
                    case    when    voapps_is_eligible_voapps_              = 1 then    case when proposed.proposed_channel = 'VoApp' then 1 else 0 end         else 0 end  as voapps_is_proposed_voapps_,

                                                                                        pool.pass_client_allowed_texts                                                      as texts_pass_client_allowed_texts_,
                    case    when    texts_pass_client_allowed_texts_        = 1 then    pool.pass_debtor_status                                                 else 0 end  as texts_pass_debtor_status_,
                    case    when    texts_pass_debtor_status_               = 1 then    pool.pass_phone_texts                                                   else 0 end  as texts_pass_phone_texts_,
                    case    when    texts_pass_phone_texts_                 = 1 then    pool.pass_validation_requirement                                        else 0 end  as texts_pass_validation_requirement_,
                    case    when    texts_pass_validation_requirement_      = 1 then    pool.pass_debtor_balance                                                else 0 end  as texts_pass_debtor_balance_,
                    case    when    texts_pass_debtor_balance_              = 1 then    pool.pass_texts_cooldown                                                else 0 end  as texts_pass_texts_cooldown_,
                    case    when    texts_pass_texts_cooldown_              = 1 then    pool.pass_debtor_age_packet                                             else 0 end  as texts_pass_debtor_age_packet_,
                    case    when    texts_pass_debtor_age_packet_           = 1 then    pool.pass_packet_balance                                                else 0 end  as texts_pass_packet_balance_,
                    case    when    texts_pass_packet_balance_              = 1 then    pool.is_eligible_texts                                                  else 0 end  as texts_is_eligible_texts_,
                    case    when    texts_is_eligible_texts_                = 1 then    case when proposed.proposed_channel = 'Text Message' then 1 else 0 end  else 0 end  as texts_is_proposed_texts_

                    
        from        edwprodhh.hermes.master_prediction_pool_log as pool
                    left join
                        edwprodhh.hermes.master_prediction_proposal_log as proposed
                        on  pool.debtor_idx     = proposed.debtor_idx
                        and pool.execute_time   = proposed.execute_time
                        and proposed.is_proposed_contact = 1
    )
    , sums as
    (
        select      pl_group,
                    execute_time,

                    count(*)                                                                                                            ::number(18,0)  as letters_n_total,
                    sum(                                                                    letters_pass_client_allowed_letters_       )::number(18,0)  as letters_pass_client_allowed_letters,
                    sum(case    when    letters_pass_client_allowed_letters_    = 1 then    letters_pass_debtor_status_             end)::number(18,0)  as letters_pass_debtor_status,
                    sum(case    when    letters_pass_debtor_status_             = 1 then    letters_pass_address_letters_           end)::number(18,0)  as letters_pass_address_letters,
                    sum(case    when    letters_pass_address_letters_           = 1 then    letters_pass_validation_requirement_    end)::number(18,0)  as letters_pass_validation_requirement,
                    sum(case    when    letters_pass_validation_requirement_    = 1 then    letters_pass_letters_cooldown_          end)::number(18,0)  as letters_pass_letters_cooldown,
                    sum(case    when    letters_pass_letters_cooldown_          = 1 then    letters_pass_letters_warmup_            end)::number(18,0)  as letters_pass_letters_warmup,
                    sum(case    when    letters_pass_letters_warmup_            = 1 then    letters_pass_debtor_age_packet_         end)::number(18,0)  as letters_pass_debtor_age_packet,
                    sum(case    when    letters_pass_debtor_age_packet_         = 1 then    letters_pass_packet_balance_            end)::number(18,0)  as letters_pass_packet_balance,
                    sum(case    when    letters_pass_packet_balance_            = 1 then    letters_is_eligible_letters_            end)::number(18,0)  as letters_is_eligible_letters,
                    sum(case    when    letters_is_eligible_letters_            = 1 then    letters_is_proposed_letters_            end)::number(18,0)  as letters_is_proposed_letters,


                    count(*)                                                                                                            ::number(18,0)  as voapps_n_total,
                    sum(                                                                    voapps_pass_client_allowed_voapps_         )::number(18,0)  as voapps_pass_client_allowed_voapps,
                    sum(case    when    voapps_pass_client_allowed_voapps_      = 1 then    voapps_pass_debtor_status_              end)::number(18,0)  as voapps_pass_debtor_status,
                    sum(case    when    voapps_pass_debtor_status_              = 1 then    voapps_pass_phone_voapps_               end)::number(18,0)  as voapps_pass_phone_voapps,
                    sum(case    when    voapps_pass_phone_voapps_               = 1 then    voapps_pass_validation_requirement_     end)::number(18,0)  as voapps_pass_validation_requirement,
                    sum(case    when    voapps_pass_validation_requirement_     = 1 then    voapps_pass_debtor_balance_             end)::number(18,0)  as voapps_pass_debtor_balance,
                    sum(case    when    voapps_pass_debtor_balance_             = 1 then    voapps_pass_voapps_cooldown_            end)::number(18,0)  as voapps_pass_voapps_cooldown,
                    sum(case    when    voapps_pass_voapps_cooldown_            = 1 then    voapps_pass_debtor_age_packet_          end)::number(18,0)  as voapps_pass_debtor_age_packet,
                    sum(case    when    voapps_pass_debtor_age_packet_          = 1 then    voapps_pass_packet_balance_             end)::number(18,0)  as voapps_pass_packet_balance,
                    sum(case    when    voapps_pass_packet_balance_             = 1 then    voapps_is_eligible_voapps_              end)::number(18,0)  as voapps_is_eligible_voapps,
                    sum(case    when    voapps_is_eligible_voapps_              = 1 then    voapps_is_proposed_voapps_              end)::number(18,0)  as voapps_is_proposed_voapps,


                    count(*)                                                                                                            ::number(18,0)  as texts_n_total,
                    sum(                                                                    texts_pass_client_allowed_texts_           )::number(18,0)  as texts_pass_client_allowed_texts,
                    sum(case    when    texts_pass_client_allowed_texts_        = 1 then    texts_pass_debtor_status_               end)::number(18,0)  as texts_pass_debtor_status,
                    sum(case    when    texts_pass_debtor_status_               = 1 then    texts_pass_phone_texts_                 end)::number(18,0)  as texts_pass_phone_texts,
                    sum(case    when    texts_pass_phone_texts_                 = 1 then    texts_pass_validation_requirement_      end)::number(18,0)  as texts_pass_validation_requirement,
                    sum(case    when    texts_pass_validation_requirement_      = 1 then    texts_pass_debtor_balance_              end)::number(18,0)  as texts_pass_debtor_balance,
                    sum(case    when    texts_pass_debtor_balance_              = 1 then    texts_pass_texts_cooldown_              end)::number(18,0)  as texts_pass_texts_cooldown,
                    sum(case    when    texts_pass_texts_cooldown_              = 1 then    texts_pass_debtor_age_packet_           end)::number(18,0)  as texts_pass_debtor_age_packet,
                    sum(case    when    texts_pass_debtor_age_packet_           = 1 then    texts_pass_packet_balance_              end)::number(18,0)  as texts_pass_packet_balance,
                    sum(case    when    texts_pass_packet_balance_              = 1 then    texts_is_eligible_texts_                end)::number(18,0)  as texts_is_eligible_texts,
                    sum(case    when    texts_is_eligible_texts_                = 1 then    texts_is_proposed_texts_                end)::number(18,0)  as texts_is_proposed_texts

        from        pool_mutate
        group by    1,2
        order by    1,2
    )
    , letters as
    (
        with sums_wide as
        (
            select      pl_group,
                        execute_time,
                        'Letters'                               as hermes_funnel,
                        letters_n_total                         as n_total,
                        letters_pass_client_allowed_letters     as pass_client_allowed_letters,
                        letters_pass_debtor_status              as pass_debtor_status,
                        letters_pass_address_letters            as pass_address_letters,
                        letters_pass_validation_requirement     as pass_validation_requirement,
                        letters_pass_letters_cooldown           as pass_letters_cooldown,
                        letters_pass_letters_warmup             as pass_letters_warmup,
                        letters_pass_debtor_age_packet          as pass_debtor_age_packet,
                        letters_pass_packet_balance             as pass_packet_balance,
                        letters_is_eligible_letters             as is_eligible_letters,
                        letters_is_proposed_letters             as is_proposed_letters
            from        sums
        )
        , sums_long as
        (
            select      *
            from        sums_wide
                        unpivot(
                            metric_value for metric_name in (
                                n_total,
                                pass_client_allowed_letters,
                                pass_debtor_status,
                                pass_address_letters,
                                pass_validation_requirement,
                                pass_letters_cooldown,
                                pass_letters_warmup,
                                pass_debtor_age_packet,
                                pass_packet_balance,
                                is_eligible_letters,
                                is_proposed_letters
                            )
                        )
        )
        select      *
        from        sums_long
    )
    , voapps as
    (
        with sums_wide as
        (
            select      pl_group,
                        execute_time,
                        'VoApps'                                as hermes_funnel,
                        voapps_n_total                          as n_total,
                        voapps_pass_client_allowed_voapps       as pass_client_allowed_voapps,
                        voapps_pass_debtor_status               as pass_debtor_status,
                        voapps_pass_phone_voapps                as pass_phone_voapps,
                        voapps_pass_validation_requirement      as pass_validation_requirement,
                        voapps_pass_debtor_balance              as pass_debtor_balance,
                        voapps_pass_voapps_cooldown             as pass_voapps_cooldown,
                        voapps_pass_debtor_age_packet           as pass_debtor_age_packet,
                        voapps_pass_packet_balance              as pass_packet_balance,
                        voapps_is_eligible_voapps               as is_eligible_voapps,
                        voapps_is_proposed_voapps               as is_proposed_voapps
            from        sums
        )
        , sums_long as
        (
            select      *
            from        sums_wide
                        unpivot(
                            metric_value for metric_name in (
                                n_total,
                                pass_client_allowed_voapps,
                                pass_debtor_status,
                                pass_phone_voapps,
                                pass_validation_requirement,
                                pass_debtor_balance,
                                pass_voapps_cooldown,
                                pass_debtor_age_packet,
                                pass_packet_balance,
                                is_eligible_voapps,
                                is_proposed_voapps
                            )
                        )
        )
        select      *
        from        sums_long
    )
    , texts as
    (
        with sums_wide as
        (
            select      pl_group,
                        execute_time,
                        'Texts'                                 as hermes_funnel,
                        texts_n_total                           as n_total,
                        texts_pass_client_allowed_texts         as pass_client_allowed_texts,
                        texts_pass_debtor_status                as pass_debtor_status,
                        texts_pass_phone_texts                  as pass_phone_texts,
                        texts_pass_validation_requirement       as pass_validation_requirement,
                        texts_pass_debtor_balance               as pass_debtor_balance,
                        texts_pass_texts_cooldown               as pass_texts_cooldown,
                        texts_pass_debtor_age_packet            as pass_debtor_age_packet,
                        texts_pass_packet_balance               as pass_packet_balance,
                        texts_is_eligible_texts                 as is_eligible_texts,
                        texts_is_proposed_texts                 as is_proposed_texts
            from        sums
        )
        , sums_long as
        (
            select      *
            from        sums_wide
                        unpivot(
                            metric_value for metric_name in (
                                n_total,
                                pass_client_allowed_texts,
                                pass_debtor_status,
                                pass_phone_texts,
                                pass_validation_requirement,
                                pass_debtor_balance,
                                pass_texts_cooldown,
                                pass_debtor_age_packet,
                                pass_packet_balance,
                                is_eligible_texts,
                                is_proposed_texts
                            )
                        )
        )
        select      *
        from        sums_long
    )
    , unioned as
    (
        with unioned_ as
        (
            select      *
            from        letters
            union all
            select      *
            from        voapps
            union all
            select      *
            from        texts
        )
        select      *,

                    case    when    hermes_funnel = 'Letters'                                           then    1
                            when    hermes_funnel = 'VoApps'                                            then    2
                            when    hermes_funnel = 'Texts'                                             then    3
                            end     as sorter_channel,

                    case    when    hermes_funnel = 'Letters'
                            then    case    when    metric_name = 'N_TOTAL'                             then    1
                                            when    metric_name = 'PASS_CLIENT_ALLOWED_LETTERS'         then    2
                                            when    metric_name = 'PASS_DEBTOR_STATUS'                  then    3
                                            when    metric_name = 'PASS_ADDRESS_LETTERS'                then    4
                                            when    metric_name = 'PASS_VALIDATION_REQUIREMENT'         then    5
                                            when    metric_name = 'PASS_LETTERS_COOLDOWN'               then    6
                                            when    metric_name = 'PASS_LETTERS_WARMUP'                 then    7
                                            when    metric_name = 'PASS_DEBTOR_AGE_PACKET'              then    8
                                            when    metric_name = 'PASS_PACKET_BALANCE'                 then    9
                                            when    metric_name = 'IS_ELIGIBLE_LETTERS'                 then    10
                                            when    metric_name = 'IS_PROPOSED_LETTERS'                 then    11
                                            end
                            when    hermes_funnel = 'VoApps'
                            then    case    when    metric_name = 'N_TOTAL'                             then    1
                                            when    metric_name = 'PASS_CLIENT_ALLOWED_VOAPPS'          then    2
                                            when    metric_name = 'PASS_DEBTOR_STATUS'                  then    3
                                            when    metric_name = 'PASS_PHONE_VOAPPS'                   then    4
                                            when    metric_name = 'PASS_VALIDATION_REQUIREMENT'         then    5
                                            when    metric_name = 'PASS_DEBTOR_BALANCE'                 then    6
                                            when    metric_name = 'PASS_VOAPPS_COOLDOWN'                then    7
                                            when    metric_name = 'PASS_DEBTOR_AGE_PACKET'              then    8
                                            when    metric_name = 'PASS_PACKET_BALANCE'                 then    9
                                            when    metric_name = 'IS_ELIGIBLE_VOAPPS'                  then    10
                                            when    metric_name = 'IS_PROPOSED_VOAPPS'                  then    11
                                            end
                            when    hermes_funnel = 'Texts'
                            then    case    when    metric_name = 'N_TOTAL'                             then    1
                                            when    metric_name = 'PASS_CLIENT_ALLOWED_TEXTS'           then    2
                                            when    metric_name = 'PASS_DEBTOR_STATUS'                  then    3
                                            when    metric_name = 'PASS_PHONE_TEXTS'                    then    4
                                            when    metric_name = 'PASS_VALIDATION_REQUIREMENT'         then    5
                                            when    metric_name = 'PASS_DEBTOR_BALANCE'                 then    6
                                            when    metric_name = 'PASS_TEXTS_COOLDOWN'                 then    7
                                            when    metric_name = 'PASS_DEBTOR_AGE_PACKET'              then    8
                                            when    metric_name = 'PASS_PACKET_BALANCE'                 then    9
                                            when    metric_name = 'IS_ELIGIBLE_TEXTS'                   then    10
                                            when    metric_name = 'IS_PROPOSED_TEXTS'                   then    11
                                            end
                            end     as sorter_funnel

        from        unioned_
        where       case    when    hermes_funnel = 'Letters'   then    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_letters)
                            when    hermes_funnel = 'VoApps'    then    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_voapps)
                            when    hermes_funnel = 'Texts'     then    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_texts)
                            end
    )
    select      *
    from        unioned
    order by    1,2,6,7
)
, joined as
(
    select      coalesce(total.pl_group,                            previous.pl_group)                                              as pl_group_,
                coalesce(total.execute_time,                        previous.execute_time)                                          as execute_time_,
                coalesce(total.hermes_funnel,                       previous.hermes_funnel)                                         as hermes_funnel_,
                coalesce(total.metric_name,                         previous.metric_name)                                           as metric_name_,
                coalesce(total.sorter_channel,                      previous.sorter_channel)                                        as sorter_channel_,
                coalesce(total.sorter_funnel,                       previous.sorter_funnel)                                         as sorter_funnel_,

                coalesce(total.n_total,                             0)                                                              as n_total_,
                coalesce(total.metric_value,                        0)                                                              as metric_value_total_,
                coalesce(previous.metric_value,                     0)                                                              as metric_value_prev_,

                edwprodhh.pub_jchang.divide(metric_value_total_,    n_total_)                                                       as perc_of_total_,
                edwprodhh.pub_jchang.divide(metric_value_prev_,     lag(metric_value_prev_, 1) over (
                                                                        partition by    pl_group_, execute_time_, sorter_channel_
                                                                        order by        sorter_funnel_ asc
                                                                    ))                                                              as perc_of_previous_


    from        perc_of_total as total
                full outer join
                    perc_of_previous as previous
                    on  total.pl_group          = previous.pl_group
                    and total.execute_time      = previous.execute_time
                    and total.hermes_funnel     = previous.hermes_funnel
                    and total.metric_name       = previous.metric_name

    order by    1,2,5,6
)
, reformat as
(
    select      pl_group_                                                           as pl_group,
                execute_time_::date                                                 as execute_time,
                hermes_funnel_                                                      as hermes_funnel,
                metric_name_                                                        as metric_name,
                sorter_channel_                                                     as sorter_channel,
                sorter_funnel_                                                      as sorter_funnel,
                n_total_                                                            as n_total,
                metric_value_total_                                                 as metric_value_total,
                metric_value_prev_                                                  as metric_value_prev,
                perc_of_total_                                                      as perc_of_total,
                perc_of_previous_                                                   as perc_of_previous,
                exp(
                    sum(case    when    sorter_funnel = 1       then    0
                                when    perc_of_previous = 0    then    -1000   --need to make effectively 0 when power-ed against e.
                                else    ln(perc_of_previous)
                                end     ) over (
                                            partition by    pl_group, execute_time, sorter_channel
                                            order by        sorter_funnel
                                        )
                )                                                                   as perc_of_previous_cumu

    from        joined
    order by    1,2,5,6
)
, tableau_reformat as
(
    select      *,
                'abc' as tableau_relation
    from        reformat
    where       metric_name != 'N_TOTAL'
    order by    1,2,5,6
)
select      *
from        tableau_reformat
order by    1,2,5,6
;



create or replace task
    edwprodhh.pub_jchang.replace_report_conversion_funnel
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.merge_master_debtor
as
create or replace table
    edwprodhh.hermes.report_conversion_funnel
as
with perc_of_total as
(
    with sums as
    (
        select      pool.pl_group,
                    pool.execute_time,

                    count(*)                                                                    ::number(18,0)  as n_total,
                    sum(pool.pass_client_allowed_letters)                                       ::number(18,0)  as pass_client_allowed_letters,
                    sum(pool.pass_debtor_status)                                                ::number(18,0)  as pass_debtor_status,
                    sum(pool.pass_address_letters)                                              ::number(18,0)  as pass_address_letters,
                    sum(pool.pass_validation_requirement)                                       ::number(18,0)  as pass_validation_requirement,
                    sum(pool.pass_letters_cooldown)                                             ::number(18,0)  as pass_letters_cooldown,
                    sum(pool.pass_letters_warmup)                                               ::number(18,0)  as pass_letters_warmup,
                    sum(pool.pass_debtor_age_packet)                                            ::number(18,0)  as pass_debtor_age_packet,
                    sum(pool.pass_packet_balance)                                               ::number(18,0)  as pass_packet_balance,
                    sum(pool.is_eligible_letters)                                               ::number(18,0)  as is_eligible_letters,
                    sum(case when proposed.proposed_channel = 'Letter' then 1 else 0 end)       ::number(18,0)  as is_proposed_letters,
                    
                    sum(pool.pass_client_allowed_voapps)                                        ::number(18,0)  as pass_client_allowed_voapps,
                    sum(pool.pass_phone_voapps)                                                 ::number(18,0)  as pass_phone_voapps,
                    sum(pool.pass_debtor_balance)                                               ::number(18,0)  as pass_debtor_balance,
                    sum(pool.pass_voapps_cooldown)                                              ::number(18,0)  as pass_voapps_cooldown,
                    sum(pool.is_eligible_voapps)                                                ::number(18,0)  as is_eligible_voapps,
                    sum(case when proposed.proposed_channel = 'VoApp' then 1 else 0 end)        ::number(18,0)  as is_proposed_voapps,
                    
                    sum(pool.pass_client_allowed_texts)                                         ::number(18,0)  as pass_client_allowed_texts,
                    sum(pool.pass_phone_texts)                                                  ::number(18,0)  as pass_phone_texts,
                    sum(pool.pass_texts_cooldown)                                               ::number(18,0)  as pass_texts_cooldown,
                    sum(pool.is_eligible_texts)                                                 ::number(18,0)  as is_eligible_texts,
                    sum(case when proposed.proposed_channel = 'Text Message' then 1 else 0 end) ::number(18,0)  as is_proposed_texts


        from        edwprodhh.hermes.master_prediction_pool_log as pool
                    left join
                        edwprodhh.hermes.master_prediction_proposal_log as proposed
                        on  pool.debtor_idx     = proposed.debtor_idx
                        and pool.execute_time   = proposed.execute_time
                        and proposed.is_proposed_contact = 1
        group by    1,2
        order by    1,2
    )
    , letters as
    (
        with sums_wide as
        (
            select      pl_group,
                        execute_time,
                        'Letters'                       as hermes_funnel,
                        n_total,
                        pass_client_allowed_letters,
                        pass_debtor_status,
                        pass_address_letters,
                        pass_validation_requirement,
                        pass_letters_cooldown,
                        pass_letters_warmup,
                        pass_debtor_age_packet,
                        pass_packet_balance,
                        is_eligible_letters,
                        is_proposed_letters
            from        sums
        )
        , sums_long as
        (
            select      *
            from        sums_wide
                        unpivot(
                            metric_value for metric_name in (
                                -- n_total,
                                pass_client_allowed_letters,
                                pass_debtor_status,
                                pass_address_letters,
                                pass_validation_requirement,
                                pass_letters_cooldown,
                                pass_letters_warmup,
                                pass_debtor_age_packet,
                                pass_packet_balance,
                                is_eligible_letters,
                                is_proposed_letters
                            )
                        )
        )
        select      *
        from        sums_long
    )
    , voapps as
    (
        with sums_wide as
        (
            select      pl_group,
                        execute_time,
                        'VoApps'                        as hermes_funnel,
                        n_total,
                        pass_client_allowed_voapps,
                        pass_debtor_status,
                        pass_phone_voapps,
                        pass_validation_requirement,
                        pass_debtor_balance,
                        pass_voapps_cooldown,
                        pass_debtor_age_packet,
                        pass_packet_balance,
                        is_eligible_voapps,
                        is_proposed_voapps
            from        sums
        )
        , sums_long as
        (
            select      *
            from        sums_wide
                        unpivot(
                            metric_value for metric_name in (
                                -- n_total,
                                pass_client_allowed_voapps,
                                pass_debtor_status,
                                pass_phone_voapps,
                                pass_validation_requirement,
                                pass_debtor_balance,
                                pass_voapps_cooldown,
                                pass_debtor_age_packet,
                                pass_packet_balance,
                                is_eligible_voapps,
                                is_proposed_voapps
                            )
                        )
        )
        select      *
        from        sums_long
    )
    , texts as
    (
        with sums_wide as
        (
            select      pl_group,
                        execute_time,
                        'Texts'                         as hermes_funnel,
                        n_total,
                        pass_client_allowed_texts,
                        pass_debtor_status,
                        pass_phone_texts,
                        pass_validation_requirement,
                        pass_debtor_balance,
                        pass_texts_cooldown,
                        pass_debtor_age_packet,
                        pass_packet_balance,
                        is_eligible_texts,
                        is_proposed_texts
            from        sums
        )
        , sums_long as
        (
            select      *
            from        sums_wide
                        unpivot(
                            metric_value for metric_name in (
                                -- n_total,
                                pass_client_allowed_texts,
                                pass_debtor_status,
                                pass_phone_texts,
                                pass_validation_requirement,
                                pass_debtor_balance,
                                pass_texts_cooldown,
                                pass_debtor_age_packet,
                                pass_packet_balance,
                                is_eligible_texts,
                                is_proposed_texts
                            )
                        )
        )
        select      *
        from        sums_long
    )
    , unioned as
    (
        with unioned_ as
        (
            select      *
            from        letters
            union all
            select      *
            from        voapps
            union all
            select      *
            from        texts
        )
        select      *,

                    case    when    hermes_funnel = 'Letters'                                           then    1
                            when    hermes_funnel = 'VoApps'                                            then    2
                            when    hermes_funnel = 'Texts'                                             then    3
                            end     as sorter_channel,

                    case    when    hermes_funnel = 'Letters'
                            then    case    when    metric_name = 'N_TOTAL'                             then    1
                                            when    metric_name = 'PASS_CLIENT_ALLOWED_LETTERS'         then    2
                                            when    metric_name = 'PASS_DEBTOR_STATUS'                  then    3
                                            when    metric_name = 'PASS_ADDRESS_LETTERS'                then    4
                                            when    metric_name = 'PASS_VALIDATION_REQUIREMENT'         then    5
                                            when    metric_name = 'PASS_LETTERS_COOLDOWN'               then    6
                                            when    metric_name = 'PASS_LETTERS_WARMUP'                 then    7
                                            when    metric_name = 'PASS_DEBTOR_AGE_PACKET'              then    8
                                            when    metric_name = 'PASS_PACKET_BALANCE'                 then    9
                                            when    metric_name = 'IS_ELIGIBLE_LETTERS'                 then    10
                                            when    metric_name = 'IS_PROPOSED_LETTERS'                 then    11
                                            end
                            when    hermes_funnel = 'VoApps'
                            then    case    when    metric_name = 'N_TOTAL'                             then    1
                                            when    metric_name = 'PASS_CLIENT_ALLOWED_VOAPPS'          then    2
                                            when    metric_name = 'PASS_DEBTOR_STATUS'                  then    3
                                            when    metric_name = 'PASS_PHONE_VOAPPS'                   then    4
                                            when    metric_name = 'PASS_VALIDATION_REQUIREMENT'         then    5
                                            when    metric_name = 'PASS_DEBTOR_BALANCE'                 then    6
                                            when    metric_name = 'PASS_VOAPPS_COOLDOWN'                then    7
                                            when    metric_name = 'PASS_DEBTOR_AGE_PACKET'              then    8
                                            when    metric_name = 'PASS_PACKET_BALANCE'                 then    9
                                            when    metric_name = 'IS_ELIGIBLE_VOAPPS'                  then    10
                                            when    metric_name = 'IS_PROPOSED_VOAPPS'                  then    11
                                            end
                            when    hermes_funnel = 'Texts'
                            then    case    when    metric_name = 'N_TOTAL'                             then    1
                                            when    metric_name = 'PASS_CLIENT_ALLOWED_TEXTS'           then    2
                                            when    metric_name = 'PASS_DEBTOR_STATUS'                  then    3
                                            when    metric_name = 'PASS_PHONE_TEXTS'                    then    4
                                            when    metric_name = 'PASS_VALIDATION_REQUIREMENT'         then    5
                                            when    metric_name = 'PASS_DEBTOR_BALANCE'                 then    6
                                            when    metric_name = 'PASS_TEXTS_COOLDOWN'                 then    7
                                            when    metric_name = 'PASS_DEBTOR_AGE_PACKET'              then    8
                                            when    metric_name = 'PASS_PACKET_BALANCE'                 then    9
                                            when    metric_name = 'IS_ELIGIBLE_TEXTS'                   then    10
                                            when    metric_name = 'IS_PROPOSED_TEXTS'                   then    11
                                            end
                            end     as sorter_funnel

        from        unioned_
        where       case    when    hermes_funnel = 'Letters'   then    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_letters)
                            when    hermes_funnel = 'VoApps'    then    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_voapps)
                            when    hermes_funnel = 'Texts'     then    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_texts)
                            end
    )
    select      *
    from        unioned
    order by    1,2,7,8
)
, perc_of_previous as
(
    with pool_mutate as
    (
        select      pool.debtor_idx,
                    pool.pl_group,
                    pool.execute_time,

                                                                                        pool.pass_client_allowed_letters                                                    as letters_pass_client_allowed_letters_,
                    case    when    letters_pass_client_allowed_letters_    = 1 then    pool.pass_debtor_status                                                 else 0 end  as letters_pass_debtor_status_,
                    case    when    letters_pass_debtor_status_             = 1 then    pool.pass_address_letters                                               else 0 end  as letters_pass_address_letters_,
                    case    when    letters_pass_address_letters_           = 1 then    pool.pass_validation_requirement                                        else 0 end  as letters_pass_validation_requirement_,
                    case    when    letters_pass_validation_requirement_    = 1 then    pool.pass_letters_cooldown                                              else 0 end  as letters_pass_letters_cooldown_,
                    case    when    letters_pass_letters_cooldown_          = 1 then    pool.pass_letters_warmup                                                else 0 end  as letters_pass_letters_warmup_,
                    case    when    letters_pass_letters_warmup_            = 1 then    pool.pass_debtor_age_packet                                             else 0 end  as letters_pass_debtor_age_packet_,
                    case    when    letters_pass_debtor_age_packet_         = 1 then    pool.pass_packet_balance                                                else 0 end  as letters_pass_packet_balance_,
                    case    when    letters_pass_packet_balance_            = 1 then    pool.is_eligible_letters                                                else 0 end  as letters_is_eligible_letters_,
                    case    when    letters_is_eligible_letters_            = 1 then    case when proposed.proposed_channel = 'Letter' then 1 else 0 end        else 0 end  as letters_is_proposed_letters_,
 
                                                                                        pool.pass_client_allowed_voapps                                                     as voapps_pass_client_allowed_voapps_,
                    case    when    voapps_pass_client_allowed_voapps_      = 1 then    pool.pass_debtor_status                                                 else 0 end  as voapps_pass_debtor_status_,
                    case    when    voapps_pass_debtor_status_              = 1 then    pool.pass_phone_voapps                                                  else 0 end  as voapps_pass_phone_voapps_,
                    case    when    voapps_pass_phone_voapps_               = 1 then    pool.pass_validation_requirement                                        else 0 end  as voapps_pass_validation_requirement_,
                    case    when    voapps_pass_validation_requirement_     = 1 then    pool.pass_debtor_balance                                                else 0 end  as voapps_pass_debtor_balance_,
                    case    when    voapps_pass_debtor_balance_             = 1 then    pool.pass_voapps_cooldown                                               else 0 end  as voapps_pass_voapps_cooldown_,
                    case    when    voapps_pass_voapps_cooldown_            = 1 then    pool.pass_debtor_age_packet                                             else 0 end  as voapps_pass_debtor_age_packet_,
                    case    when    voapps_pass_debtor_age_packet_          = 1 then    pool.pass_packet_balance                                                else 0 end  as voapps_pass_packet_balance_,
                    case    when    voapps_pass_packet_balance_             = 1 then    pool.is_eligible_voapps                                                 else 0 end  as voapps_is_eligible_voapps_,
                    case    when    voapps_is_eligible_voapps_              = 1 then    case when proposed.proposed_channel = 'VoApp' then 1 else 0 end         else 0 end  as voapps_is_proposed_voapps_,

                                                                                        pool.pass_client_allowed_texts                                                      as texts_pass_client_allowed_texts_,
                    case    when    texts_pass_client_allowed_texts_        = 1 then    pool.pass_debtor_status                                                 else 0 end  as texts_pass_debtor_status_,
                    case    when    texts_pass_debtor_status_               = 1 then    pool.pass_phone_texts                                                   else 0 end  as texts_pass_phone_texts_,
                    case    when    texts_pass_phone_texts_                 = 1 then    pool.pass_validation_requirement                                        else 0 end  as texts_pass_validation_requirement_,
                    case    when    texts_pass_validation_requirement_      = 1 then    pool.pass_debtor_balance                                                else 0 end  as texts_pass_debtor_balance_,
                    case    when    texts_pass_debtor_balance_              = 1 then    pool.pass_texts_cooldown                                                else 0 end  as texts_pass_texts_cooldown_,
                    case    when    texts_pass_texts_cooldown_              = 1 then    pool.pass_debtor_age_packet                                             else 0 end  as texts_pass_debtor_age_packet_,
                    case    when    texts_pass_debtor_age_packet_           = 1 then    pool.pass_packet_balance                                                else 0 end  as texts_pass_packet_balance_,
                    case    when    texts_pass_packet_balance_              = 1 then    pool.is_eligible_texts                                                  else 0 end  as texts_is_eligible_texts_,
                    case    when    texts_is_eligible_texts_                = 1 then    case when proposed.proposed_channel = 'Text Message' then 1 else 0 end  else 0 end  as texts_is_proposed_texts_

                    
        from        edwprodhh.hermes.master_prediction_pool_log as pool
                    left join
                        edwprodhh.hermes.master_prediction_proposal_log as proposed
                        on  pool.debtor_idx     = proposed.debtor_idx
                        and pool.execute_time   = proposed.execute_time
                        and proposed.is_proposed_contact = 1
    )
    , sums as
    (
        select      pl_group,
                    execute_time,

                    count(*)                                                                                                            ::number(18,0)  as letters_n_total,
                    sum(                                                                    letters_pass_client_allowed_letters_       )::number(18,0)  as letters_pass_client_allowed_letters,
                    sum(case    when    letters_pass_client_allowed_letters_    = 1 then    letters_pass_debtor_status_             end)::number(18,0)  as letters_pass_debtor_status,
                    sum(case    when    letters_pass_debtor_status_             = 1 then    letters_pass_address_letters_           end)::number(18,0)  as letters_pass_address_letters,
                    sum(case    when    letters_pass_address_letters_           = 1 then    letters_pass_validation_requirement_    end)::number(18,0)  as letters_pass_validation_requirement,
                    sum(case    when    letters_pass_validation_requirement_    = 1 then    letters_pass_letters_cooldown_          end)::number(18,0)  as letters_pass_letters_cooldown,
                    sum(case    when    letters_pass_letters_cooldown_          = 1 then    letters_pass_letters_warmup_            end)::number(18,0)  as letters_pass_letters_warmup,
                    sum(case    when    letters_pass_letters_warmup_            = 1 then    letters_pass_debtor_age_packet_         end)::number(18,0)  as letters_pass_debtor_age_packet,
                    sum(case    when    letters_pass_debtor_age_packet_         = 1 then    letters_pass_packet_balance_            end)::number(18,0)  as letters_pass_packet_balance,
                    sum(case    when    letters_pass_packet_balance_            = 1 then    letters_is_eligible_letters_            end)::number(18,0)  as letters_is_eligible_letters,
                    sum(case    when    letters_is_eligible_letters_            = 1 then    letters_is_proposed_letters_            end)::number(18,0)  as letters_is_proposed_letters,


                    count(*)                                                                                                            ::number(18,0)  as voapps_n_total,
                    sum(                                                                    voapps_pass_client_allowed_voapps_         )::number(18,0)  as voapps_pass_client_allowed_voapps,
                    sum(case    when    voapps_pass_client_allowed_voapps_      = 1 then    voapps_pass_debtor_status_              end)::number(18,0)  as voapps_pass_debtor_status,
                    sum(case    when    voapps_pass_debtor_status_              = 1 then    voapps_pass_phone_voapps_               end)::number(18,0)  as voapps_pass_phone_voapps,
                    sum(case    when    voapps_pass_phone_voapps_               = 1 then    voapps_pass_validation_requirement_     end)::number(18,0)  as voapps_pass_validation_requirement,
                    sum(case    when    voapps_pass_validation_requirement_     = 1 then    voapps_pass_debtor_balance_             end)::number(18,0)  as voapps_pass_debtor_balance,
                    sum(case    when    voapps_pass_debtor_balance_             = 1 then    voapps_pass_voapps_cooldown_            end)::number(18,0)  as voapps_pass_voapps_cooldown,
                    sum(case    when    voapps_pass_voapps_cooldown_            = 1 then    voapps_pass_debtor_age_packet_          end)::number(18,0)  as voapps_pass_debtor_age_packet,
                    sum(case    when    voapps_pass_debtor_age_packet_          = 1 then    voapps_pass_packet_balance_             end)::number(18,0)  as voapps_pass_packet_balance,
                    sum(case    when    voapps_pass_packet_balance_             = 1 then    voapps_is_eligible_voapps_              end)::number(18,0)  as voapps_is_eligible_voapps,
                    sum(case    when    voapps_is_eligible_voapps_              = 1 then    voapps_is_proposed_voapps_              end)::number(18,0)  as voapps_is_proposed_voapps,


                    count(*)                                                                                                            ::number(18,0)  as texts_n_total,
                    sum(                                                                    texts_pass_client_allowed_texts_           )::number(18,0)  as texts_pass_client_allowed_texts,
                    sum(case    when    texts_pass_client_allowed_texts_        = 1 then    texts_pass_debtor_status_               end)::number(18,0)  as texts_pass_debtor_status,
                    sum(case    when    texts_pass_debtor_status_               = 1 then    texts_pass_phone_texts_                 end)::number(18,0)  as texts_pass_phone_texts,
                    sum(case    when    texts_pass_phone_texts_                 = 1 then    texts_pass_validation_requirement_      end)::number(18,0)  as texts_pass_validation_requirement,
                    sum(case    when    texts_pass_validation_requirement_      = 1 then    texts_pass_debtor_balance_              end)::number(18,0)  as texts_pass_debtor_balance,
                    sum(case    when    texts_pass_debtor_balance_              = 1 then    texts_pass_texts_cooldown_              end)::number(18,0)  as texts_pass_texts_cooldown,
                    sum(case    when    texts_pass_texts_cooldown_              = 1 then    texts_pass_debtor_age_packet_           end)::number(18,0)  as texts_pass_debtor_age_packet,
                    sum(case    when    texts_pass_debtor_age_packet_           = 1 then    texts_pass_packet_balance_              end)::number(18,0)  as texts_pass_packet_balance,
                    sum(case    when    texts_pass_packet_balance_              = 1 then    texts_is_eligible_texts_                end)::number(18,0)  as texts_is_eligible_texts,
                    sum(case    when    texts_is_eligible_texts_                = 1 then    texts_is_proposed_texts_                end)::number(18,0)  as texts_is_proposed_texts

        from        pool_mutate
        group by    1,2
        order by    1,2
    )
    , letters as
    (
        with sums_wide as
        (
            select      pl_group,
                        execute_time,
                        'Letters'                               as hermes_funnel,
                        letters_n_total                         as n_total,
                        letters_pass_client_allowed_letters     as pass_client_allowed_letters,
                        letters_pass_debtor_status              as pass_debtor_status,
                        letters_pass_address_letters            as pass_address_letters,
                        letters_pass_validation_requirement     as pass_validation_requirement,
                        letters_pass_letters_cooldown           as pass_letters_cooldown,
                        letters_pass_letters_warmup             as pass_letters_warmup,
                        letters_pass_debtor_age_packet          as pass_debtor_age_packet,
                        letters_pass_packet_balance             as pass_packet_balance,
                        letters_is_eligible_letters             as is_eligible_letters,
                        letters_is_proposed_letters             as is_proposed_letters
            from        sums
        )
        , sums_long as
        (
            select      *
            from        sums_wide
                        unpivot(
                            metric_value for metric_name in (
                                n_total,
                                pass_client_allowed_letters,
                                pass_debtor_status,
                                pass_address_letters,
                                pass_validation_requirement,
                                pass_letters_cooldown,
                                pass_letters_warmup,
                                pass_debtor_age_packet,
                                pass_packet_balance,
                                is_eligible_letters,
                                is_proposed_letters
                            )
                        )
        )
        select      *
        from        sums_long
    )
    , voapps as
    (
        with sums_wide as
        (
            select      pl_group,
                        execute_time,
                        'VoApps'                                as hermes_funnel,
                        voapps_n_total                          as n_total,
                        voapps_pass_client_allowed_voapps       as pass_client_allowed_voapps,
                        voapps_pass_debtor_status               as pass_debtor_status,
                        voapps_pass_phone_voapps                as pass_phone_voapps,
                        voapps_pass_validation_requirement      as pass_validation_requirement,
                        voapps_pass_debtor_balance              as pass_debtor_balance,
                        voapps_pass_voapps_cooldown             as pass_voapps_cooldown,
                        voapps_pass_debtor_age_packet           as pass_debtor_age_packet,
                        voapps_pass_packet_balance              as pass_packet_balance,
                        voapps_is_eligible_voapps               as is_eligible_voapps,
                        voapps_is_proposed_voapps               as is_proposed_voapps
            from        sums
        )
        , sums_long as
        (
            select      *
            from        sums_wide
                        unpivot(
                            metric_value for metric_name in (
                                n_total,
                                pass_client_allowed_voapps,
                                pass_debtor_status,
                                pass_phone_voapps,
                                pass_validation_requirement,
                                pass_debtor_balance,
                                pass_voapps_cooldown,
                                pass_debtor_age_packet,
                                pass_packet_balance,
                                is_eligible_voapps,
                                is_proposed_voapps
                            )
                        )
        )
        select      *
        from        sums_long
    )
    , texts as
    (
        with sums_wide as
        (
            select      pl_group,
                        execute_time,
                        'Texts'                                 as hermes_funnel,
                        texts_n_total                           as n_total,
                        texts_pass_client_allowed_texts         as pass_client_allowed_texts,
                        texts_pass_debtor_status                as pass_debtor_status,
                        texts_pass_phone_texts                  as pass_phone_texts,
                        texts_pass_validation_requirement       as pass_validation_requirement,
                        texts_pass_debtor_balance               as pass_debtor_balance,
                        texts_pass_texts_cooldown               as pass_texts_cooldown,
                        texts_pass_debtor_age_packet            as pass_debtor_age_packet,
                        texts_pass_packet_balance               as pass_packet_balance,
                        texts_is_eligible_texts                 as is_eligible_texts,
                        texts_is_proposed_texts                 as is_proposed_texts
            from        sums
        )
        , sums_long as
        (
            select      *
            from        sums_wide
                        unpivot(
                            metric_value for metric_name in (
                                n_total,
                                pass_client_allowed_texts,
                                pass_debtor_status,
                                pass_phone_texts,
                                pass_validation_requirement,
                                pass_debtor_balance,
                                pass_texts_cooldown,
                                pass_debtor_age_packet,
                                pass_packet_balance,
                                is_eligible_texts,
                                is_proposed_texts
                            )
                        )
        )
        select      *
        from        sums_long
    )
    , unioned as
    (
        with unioned_ as
        (
            select      *
            from        letters
            union all
            select      *
            from        voapps
            union all
            select      *
            from        texts
        )
        select      *,

                    case    when    hermes_funnel = 'Letters'                                           then    1
                            when    hermes_funnel = 'VoApps'                                            then    2
                            when    hermes_funnel = 'Texts'                                             then    3
                            end     as sorter_channel,

                    case    when    hermes_funnel = 'Letters'
                            then    case    when    metric_name = 'N_TOTAL'                             then    1
                                            when    metric_name = 'PASS_CLIENT_ALLOWED_LETTERS'         then    2
                                            when    metric_name = 'PASS_DEBTOR_STATUS'                  then    3
                                            when    metric_name = 'PASS_ADDRESS_LETTERS'                then    4
                                            when    metric_name = 'PASS_VALIDATION_REQUIREMENT'         then    5
                                            when    metric_name = 'PASS_LETTERS_COOLDOWN'               then    6
                                            when    metric_name = 'PASS_LETTERS_WARMUP'                 then    7
                                            when    metric_name = 'PASS_DEBTOR_AGE_PACKET'              then    8
                                            when    metric_name = 'PASS_PACKET_BALANCE'                 then    9
                                            when    metric_name = 'IS_ELIGIBLE_LETTERS'                 then    10
                                            when    metric_name = 'IS_PROPOSED_LETTERS'                 then    11
                                            end
                            when    hermes_funnel = 'VoApps'
                            then    case    when    metric_name = 'N_TOTAL'                             then    1
                                            when    metric_name = 'PASS_CLIENT_ALLOWED_VOAPPS'          then    2
                                            when    metric_name = 'PASS_DEBTOR_STATUS'                  then    3
                                            when    metric_name = 'PASS_PHONE_VOAPPS'                   then    4
                                            when    metric_name = 'PASS_VALIDATION_REQUIREMENT'         then    5
                                            when    metric_name = 'PASS_DEBTOR_BALANCE'                 then    6
                                            when    metric_name = 'PASS_VOAPPS_COOLDOWN'                then    7
                                            when    metric_name = 'PASS_DEBTOR_AGE_PACKET'              then    8
                                            when    metric_name = 'PASS_PACKET_BALANCE'                 then    9
                                            when    metric_name = 'IS_ELIGIBLE_VOAPPS'                  then    10
                                            when    metric_name = 'IS_PROPOSED_VOAPPS'                  then    11
                                            end
                            when    hermes_funnel = 'Texts'
                            then    case    when    metric_name = 'N_TOTAL'                             then    1
                                            when    metric_name = 'PASS_CLIENT_ALLOWED_TEXTS'           then    2
                                            when    metric_name = 'PASS_DEBTOR_STATUS'                  then    3
                                            when    metric_name = 'PASS_PHONE_TEXTS'                    then    4
                                            when    metric_name = 'PASS_VALIDATION_REQUIREMENT'         then    5
                                            when    metric_name = 'PASS_DEBTOR_BALANCE'                 then    6
                                            when    metric_name = 'PASS_TEXTS_COOLDOWN'                 then    7
                                            when    metric_name = 'PASS_DEBTOR_AGE_PACKET'              then    8
                                            when    metric_name = 'PASS_PACKET_BALANCE'                 then    9
                                            when    metric_name = 'IS_ELIGIBLE_TEXTS'                   then    10
                                            when    metric_name = 'IS_PROPOSED_TEXTS'                   then    11
                                            end
                            end     as sorter_funnel

        from        unioned_
        where       case    when    hermes_funnel = 'Letters'   then    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_letters)
                            when    hermes_funnel = 'VoApps'    then    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_voapps)
                            when    hermes_funnel = 'Texts'     then    pl_group in (select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_texts)
                            end
    )
    select      *
    from        unioned
    order by    1,2,6,7
)
, joined as
(
    select      coalesce(total.pl_group,                            previous.pl_group)                                              as pl_group_,
                coalesce(total.execute_time,                        previous.execute_time)                                          as execute_time_,
                coalesce(total.hermes_funnel,                       previous.hermes_funnel)                                         as hermes_funnel_,
                coalesce(total.metric_name,                         previous.metric_name)                                           as metric_name_,
                coalesce(total.sorter_channel,                      previous.sorter_channel)                                        as sorter_channel_,
                coalesce(total.sorter_funnel,                       previous.sorter_funnel)                                         as sorter_funnel_,

                coalesce(total.n_total,                             0)                                                              as n_total_,
                coalesce(total.metric_value,                        0)                                                              as metric_value_total_,
                coalesce(previous.metric_value,                     0)                                                              as metric_value_prev_,

                edwprodhh.pub_jchang.divide(metric_value_total_,    n_total_)                                                       as perc_of_total_,
                edwprodhh.pub_jchang.divide(metric_value_prev_,     lag(metric_value_prev_, 1) over (
                                                                        partition by    pl_group_, execute_time_, sorter_channel_
                                                                        order by        sorter_funnel_ asc
                                                                    ))                                                              as perc_of_previous_


    from        perc_of_total as total
                full outer join
                    perc_of_previous as previous
                    on  total.pl_group          = previous.pl_group
                    and total.execute_time      = previous.execute_time
                    and total.hermes_funnel     = previous.hermes_funnel
                    and total.metric_name       = previous.metric_name

    order by    1,2,5,6
)
, reformat as
(
    select      pl_group_                                                           as pl_group,
                execute_time_::date                                                 as execute_time,
                hermes_funnel_                                                      as hermes_funnel,
                metric_name_                                                        as metric_name,
                sorter_channel_                                                     as sorter_channel,
                sorter_funnel_                                                      as sorter_funnel,
                n_total_                                                            as n_total,
                metric_value_total_                                                 as metric_value_total,
                metric_value_prev_                                                  as metric_value_prev,
                perc_of_total_                                                      as perc_of_total,
                perc_of_previous_                                                   as perc_of_previous,
                exp(
                    sum(case    when    sorter_funnel = 1       then    0
                                when    perc_of_previous = 0    then    -1000   --need to make effectively 0 when power-ed against e.
                                else    ln(perc_of_previous)
                                end     ) over (
                                            partition by    pl_group, execute_time, sorter_channel
                                            order by        sorter_funnel
                                        )
                )                                                                   as perc_of_previous_cumu

    from        joined
    order by    1,2,5,6
)
, tableau_reformat as
(
    select      *,
                'abc' as tableau_relation
    from        reformat
    where       metric_name != 'N_TOTAL'
    order by    1,2,5,6
)
select      *
from        tableau_reformat
order by    1,2,5,6
;