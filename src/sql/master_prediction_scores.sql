create or replace table
    edwprodhh.hermes.master_prediction_scores
as
with cached_scores as
(
    select      *
    from        edwprodhh.hermes.master_prediction_scores_log
    where       execute_time >= current_date() - 4
    qualify     row_number() over (partition by debtor_idx order by execute_time desc) = 1
)
select      pool.debtor_idx,
            pool.client_idx,
            pool.pl_group,

            case    when    pool.is_eligible_debtor = 1
                    then    case    when    cached_scores.debtor_idx is not null
                                    and     cached_scores.score_debtor is not null
                                    then    cached_scores.score_debtor
                                    else    EDWPRODHH.HERMES.PROD_PREDICT_V1_DEBTOR(
                                                [
                                                    POOL.ASSIGNED,                          -- ASSIGNED_AMT
                                                    POOL.AGE_PLACEMENT,                     -- DEBT_AGE
                                                    POOL.EXPERIAN_SCORE,                    -- EXPERIAN_SCORE
                                                    POOL.MEDIAN_HOUSEHOLD_INCOME,           -- MEDIAN_HOUSEHOLD_INCOME
                                                    POOL.PACKET_HAS_PREVIOUS_PAYMENT,       -- HAS_PREVIOUS_PAYMENT
                                                    POOL.DEBTOR_IS_FIRST_IN_PACKET,         -- IS_ONLY_DEBTOR_IN_PACKET
                                                    POOL.IS_DEBTTYPE_GOV_PARKING,           -- PARKING
                                                    POOL.IS_DEBTTYPE_GOV_TOLL,              -- TOLL
                                                    POOL.IS_DEBTTYPE_HC_AI,                 -- AI
                                                    POOL.IS_DEBTTYPE_HC_SP,                 -- SP
                                                    POOL.PASS_ADDRESS_EMAILS                -- HAS_EMAIL
                                                ]
                                            )
                                    end
                    else    null
                    end     ::float     as score_debtor,

            case    when    pool.is_eligible_letters = 1
                    then    case    when    cached_scores.debtor_idx is not null
                                    and     cached_scores.score_letters is not null
                                    then    cached_scores.score_letters
                                    else    EDWPRODHH.HERMES.PROD_PREDICT_V1_LETTERS(
                                                [
                                                    POOL.ASSIGNED,                          -- ASSIGNED_AMT,
                                                    POOL.AGE_PLACEMENT,                     -- DEBT_AGE,
                                                    POOL.PREV_N_CONTACTS,                   -- PREVIOUS_CONTACTS,
                                                    0,                                      -- DIALER_AGENT_CALL,
                                                    0,                                      -- OUTBOUND_MANUAL_CALL,
                                                    0,                                      -- TEXT_MESSAGE,
                                                    0,                                      -- VOAPP,
                                                    0,                                      -- DIALER_AGENTLESS_CALL,
                                                    POOL.PREV_N_LETTERS,                    -- LETTER,
                                                    0,                                      -- INBOUND_AGENT_CALL,
                                                    0,                                      -- EMAIL,
                                                    POOL.MEDIAN_HOUSEHOLD_INCOME,           -- MEDIAN_HOUSEHOLD_INCOME,
                                                    POOL.EXPERIAN_SCORE                     -- EXPERIAN_SCORE
                                                ]
                                            )
                                    end
                    else    null
                    end     ::float     as score_letters,


            case    when    pool.is_eligible_texts = 1
                    then    case    when    cached_scores.debtor_idx is not null
                                    and     cached_scores.score_texts is not null
                                    then    cached_scores.score_texts
                                    else    EDWPRODHH.HERMES.PROD_PREDICT_V1_TEXTS(
                                                [
                                                    POOL.ASSIGNED,                          -- ASSIGNED_AMT,
                                                    POOL.AGE_PLACEMENT,                     -- DEBT_AGE,
                                                    POOL.PREV_N_CONTACTS,                   -- PREVIOUS_CONTACTS,
                                                    0,                                      -- DIALER_AGENT_CALL,
                                                    0,                                      -- OUTBOUND_MANUAL_CALL,
                                                    POOL.PREV_N_TEXTS,                      -- TEXT_MESSAGE,
                                                    0,                                      -- VOAPP,
                                                    0,                                      -- DIALER_AGENTLESS_CALL,
                                                    0,                                      -- LETTER,
                                                    0,                                      -- INBOUND_AGENT_CALL,
                                                    0,                                      -- EMAIL,
                                                    POOL.MEDIAN_HOUSEHOLD_INCOME,           -- MEDIAN_HOUSEHOLD_INCOME,
                                                    POOL.EXPERIAN_SCORE                     -- EXPERIAN_SCORE
                                                ]
                                            )
                                    end
                    else    null
                    end     ::float     as score_texts,


            case    when    pool.is_eligible_voapps = 1
                    then    case    when    cached_scores.debtor_idx is not null
                                    and     cached_scores.score_voapps is not null
                                    then    cached_scores.score_voapps
                                    else    EDWPRODHH.HERMES.PROD_PREDICT_V1_VOAPPS(
                                                [
                                                    POOL.ASSIGNED,                          -- ASSIGNED_AMT,
                                                    POOL.AGE_PLACEMENT,                     -- DEBT_AGE,
                                                    POOL.PREV_N_CONTACTS,                   -- PREVIOUS_CONTACTS,
                                                    0,                                      -- DIALER_AGENT_CALL,
                                                    0,                                      -- OUTBOUND_MANUAL_CALL,
                                                    0,                                      -- TEXT_MESSAGE,
                                                    POOL.PREV_N_VOAPPS,                     -- VOAPP,
                                                    0,                                      -- DIALER_AGENTLESS_CALL,
                                                    0,                                      -- LETTER,
                                                    0,                                      -- INBOUND_AGENT_CALL,
                                                    0,                                      -- EMAIL,
                                                    POOL.MEDIAN_HOUSEHOLD_INCOME,           -- MEDIAN_HOUSEHOLD_INCOME,
                                                    POOL.EXPERIAN_SCORE                     -- EXPERIAN_SCORE
                                                ]
                                            )
                                    end
                    else    null
                    end     ::float     as score_voapps,
                    

            NULL::float                 as score_emails,

            case    when    pool.is_eligible_dialer_agent = 1
                    then    score_debtor
                    else    NULL
                    end     ::float     as score_dialer_agent,

            NULL::float                 as score_dialer_agentless


from        (select * from edwprodhh.hermes.master_prediction_pool order by random()) as pool
            left join
                cached_scores
                on pool.debtor_idx = cached_scores.debtor_idx
where       (
                pool.is_eligible_letters         =   1   or
                pool.is_eligible_texts           =   1   or
                pool.is_eligible_voapps          =   1   or
                pool.is_eligible_dialer_agent    =   1   or
                pool.is_eligible_debtor          =   1
            )
;

-- alter task edwprodhh.pub_jchang.replace_master_prediction_scores set USER_TASK_TIMEOUT_MS = 57600000;
-- show parameters for task edwprodhh.pub_jchang.replace_master_prediction_scores;

create or replace task
    edwprodhh.pub_jchang.replace_master_prediction_scores
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.replace_master_prediction_pool
as
create or replace table
    edwprodhh.hermes.master_prediction_scores
as
with cached_scores as
(
    select      *
    from        edwprodhh.hermes.master_prediction_scores_log
    where       execute_time >= current_date() - 4
    qualify     row_number() over (partition by debtor_idx order by execute_time desc) = 1
)
select      pool.debtor_idx,
            pool.client_idx,
            pool.pl_group,

            case    when    pool.is_eligible_debtor = 1
                    then    case    when    cached_scores.debtor_idx is not null
                                    and     cached_scores.score_debtor is not null
                                    then    cached_scores.score_debtor
                                    else    EDWPRODHH.HERMES.PROD_PREDICT_V1_DEBTOR(
                                                [
                                                    POOL.ASSIGNED,                          -- ASSIGNED_AMT
                                                    POOL.AGE_PLACEMENT,                     -- DEBT_AGE
                                                    POOL.EXPERIAN_SCORE,                    -- EXPERIAN_SCORE
                                                    POOL.MEDIAN_HOUSEHOLD_INCOME,           -- MEDIAN_HOUSEHOLD_INCOME
                                                    POOL.PACKET_HAS_PREVIOUS_PAYMENT,       -- HAS_PREVIOUS_PAYMENT
                                                    POOL.DEBTOR_IS_FIRST_IN_PACKET,         -- IS_ONLY_DEBTOR_IN_PACKET
                                                    POOL.IS_DEBTTYPE_GOV_PARKING,           -- PARKING
                                                    POOL.IS_DEBTTYPE_GOV_TOLL,              -- TOLL
                                                    POOL.IS_DEBTTYPE_HC_AI,                 -- AI
                                                    POOL.IS_DEBTTYPE_HC_SP,                 -- SP
                                                    POOL.PASS_ADDRESS_EMAILS                -- HAS_EMAIL
                                                ]
                                            )
                                    end
                    else    null
                    end     ::float     as score_debtor,

            case    when    pool.is_eligible_letters = 1
                    then    case    when    cached_scores.debtor_idx is not null
                                    and     cached_scores.score_letters is not null
                                    then    cached_scores.score_letters
                                    else    EDWPRODHH.HERMES.PROD_PREDICT_V1_LETTERS(
                                                [
                                                    POOL.ASSIGNED,                          -- ASSIGNED_AMT,
                                                    POOL.AGE_PLACEMENT,                     -- DEBT_AGE,
                                                    POOL.PREV_N_CONTACTS,                   -- PREVIOUS_CONTACTS,
                                                    0,                                      -- DIALER_AGENT_CALL,
                                                    0,                                      -- OUTBOUND_MANUAL_CALL,
                                                    0,                                      -- TEXT_MESSAGE,
                                                    0,                                      -- VOAPP,
                                                    0,                                      -- DIALER_AGENTLESS_CALL,
                                                    POOL.PREV_N_LETTERS,                    -- LETTER,
                                                    0,                                      -- INBOUND_AGENT_CALL,
                                                    0,                                      -- EMAIL,
                                                    POOL.MEDIAN_HOUSEHOLD_INCOME,           -- MEDIAN_HOUSEHOLD_INCOME,
                                                    POOL.EXPERIAN_SCORE                     -- EXPERIAN_SCORE
                                                ]
                                            )
                                    end
                    else    null
                    end     ::float     as score_letters,


            case    when    pool.is_eligible_texts = 1
                    then    case    when    cached_scores.debtor_idx is not null
                                    and     cached_scores.score_texts is not null
                                    then    cached_scores.score_texts
                                    else    EDWPRODHH.HERMES.PROD_PREDICT_V1_TEXTS(
                                                [
                                                    POOL.ASSIGNED,                          -- ASSIGNED_AMT,
                                                    POOL.AGE_PLACEMENT,                     -- DEBT_AGE,
                                                    POOL.PREV_N_CONTACTS,                   -- PREVIOUS_CONTACTS,
                                                    0,                                      -- DIALER_AGENT_CALL,
                                                    0,                                      -- OUTBOUND_MANUAL_CALL,
                                                    POOL.PREV_N_TEXTS,                      -- TEXT_MESSAGE,
                                                    0,                                      -- VOAPP,
                                                    0,                                      -- DIALER_AGENTLESS_CALL,
                                                    0,                                      -- LETTER,
                                                    0,                                      -- INBOUND_AGENT_CALL,
                                                    0,                                      -- EMAIL,
                                                    POOL.MEDIAN_HOUSEHOLD_INCOME,           -- MEDIAN_HOUSEHOLD_INCOME,
                                                    POOL.EXPERIAN_SCORE                     -- EXPERIAN_SCORE
                                                ]
                                            )
                                    end
                    else    null
                    end     ::float     as score_texts,


            case    when    pool.is_eligible_voapps = 1
                    then    case    when    cached_scores.debtor_idx is not null
                                    and     cached_scores.score_voapps is not null
                                    then    cached_scores.score_voapps
                                    else    EDWPRODHH.HERMES.PROD_PREDICT_V1_VOAPPS(
                                                [
                                                    POOL.ASSIGNED,                          -- ASSIGNED_AMT,
                                                    POOL.AGE_PLACEMENT,                     -- DEBT_AGE,
                                                    POOL.PREV_N_CONTACTS,                   -- PREVIOUS_CONTACTS,
                                                    0,                                      -- DIALER_AGENT_CALL,
                                                    0,                                      -- OUTBOUND_MANUAL_CALL,
                                                    0,                                      -- TEXT_MESSAGE,
                                                    POOL.PREV_N_VOAPPS,                     -- VOAPP,
                                                    0,                                      -- DIALER_AGENTLESS_CALL,
                                                    0,                                      -- LETTER,
                                                    0,                                      -- INBOUND_AGENT_CALL,
                                                    0,                                      -- EMAIL,
                                                    POOL.MEDIAN_HOUSEHOLD_INCOME,           -- MEDIAN_HOUSEHOLD_INCOME,
                                                    POOL.EXPERIAN_SCORE                     -- EXPERIAN_SCORE
                                                ]
                                            )
                                    end
                    else    null
                    end     ::float     as score_voapps,
                    

            NULL::float                 as score_emails,

            case    when    pool.is_eligible_dialer_agent = 1
                    then    score_debtor
                    else    NULL
                    end     ::float     as score_dialer_agent,

            NULL::float                 as score_dialer_agentless


from        (select * from edwprodhh.hermes.master_prediction_pool order by random()) as pool
            left join
                cached_scores
                on pool.debtor_idx = cached_scores.debtor_idx
where       (
                pool.is_eligible_letters         =   1   or
                pool.is_eligible_texts           =   1   or
                pool.is_eligible_voapps          =   1   or
                pool.is_eligible_dialer_agent    =   1   or
                pool.is_eligible_debtor          =   1
            )
;