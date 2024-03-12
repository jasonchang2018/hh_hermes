create or replace table
    edwprodhh.hermes.master_prediction_scores
as
select      debtor_idx,
            client_idx,
            pl_group,

            case    when    source.is_eligible_debtor = 1
                    then    EDWPRODHH.HERMES.PROD_PREDICT_V1_DEBTOR(
                                [
                                    source.assigned,                       -- assigned_amt
                                    source.age_placement,                  -- debt_age
                                    source.experian_score,                 -- experian_score
                                    source.median_household_income,        -- median_household_income
                                    source.packet_has_previous_payment,    -- has_previous_payment
                                    source.debtor_is_first_in_packet,      -- is_only_debtor_in_packet
                                    source.is_debttype_gov_parking,        -- parking
                                    source.is_debttype_gov_toll,           -- toll
                                    source.is_debttype_hc_ai,              -- ai
                                    source.is_debttype_hc_sp,              -- sp
                                    source.pass_address_emails             -- has_email
                                ]
                            )
                    else    null
                    end     ::float     as score_debtor,

            case    when    is_eligible_letters = 1
                    then    EDWPRODHH.HERMES.PROD_PREDICT_V1_LETTERS(
                                [
                                    ASSIGNED,                   -- ASSIGNED_AMT,
                                    AGE_PLACEMENT,              -- DEBT_AGE,
                                    PREV_N_CONTACTS,            -- PREVIOUS_CONTACTS,
                                    0,                          -- DIALER_AGENT_CALL,
                                    0,                          -- OUTBOUND_MANUAL_CALL,
                                    0,                          -- TEXT_MESSAGE,
                                    0,                          -- VOAPP,
                                    0,                          -- DIALER_AGENTLESS_CALL,
                                    PREV_N_LETTERS,             -- LETTER,
                                    0,                          -- INBOUND_AGENT_CALL,
                                    0,                          -- EMAIL,
                                    MEDIAN_HOUSEHOLD_INCOME,    -- MEDIAN_HOUSEHOLD_INCOME,
                                    EXPERIAN_SCORE              -- EXPERIAN_SCORE
                                ]
                            )
                    else    null
                    end     ::float     as score_letters,


            case    when    is_eligible_texts = 1
                    then    EDWPRODHH.HERMES.PROD_PREDICT_V1_TEXTS(
                                [
                                    assigned,                   -- assigned_amt,
                                    age_placement,              -- debt_age,
                                    prev_n_contacts,            -- previous_contacts,
                                    0,                          -- dialer_agent_call,
                                    0,                          -- outbound_manual_call,
                                    prev_n_texts,               -- text_message,
                                    0,                          -- voapp,
                                    0,                          -- dialer_agentless_call,
                                    0,                          -- letter,
                                    0,                          -- inbound_agent_call,
                                    0,                          -- email,
                                    median_household_income,    -- median_household_income,
                                    experian_score              -- experian_score
                                ]
                            )
                    else    null
                    end     ::float     as score_texts,


            case    when    is_eligible_voapps = 1
                    then    EDWPRODHH.HERMES.PROD_PREDICT_V1_VOAPPS(
                                [
                                    assigned,                   -- assigned_amt,
                                    age_placement,              -- debt_age,
                                    prev_n_contacts,            -- previous_contacts,
                                    0,                          -- dialer_agent_call,
                                    0,                          -- outbound_manual_call,
                                    0,                          -- text_message,
                                    prev_n_voapps,              -- voapp,
                                    0,                          -- dialer_agentless_call,
                                    0,                          -- letter,
                                    0,                          -- inbound_agent_call,
                                    0,                          -- email,
                                    median_household_income,    -- median_household_income,
                                    experian_score              -- experian_score
                                ]
                            )
                    else    null
                    end     ::float     as score_voapps,




            NULL::float                 as score_emails,

            case    when    is_eligible_dialer_agent = 1
                    then    score_debtor
                    else    NULL
                    end     ::float     as score_dialer_agent,

            NULL::float                 as score_dialer_agentless


from        (select * from edwprodhh.hermes.master_prediction_pool order by random()) as pool_with_rand
where       (
                is_eligible_letters         =   1   or
                is_eligible_texts           =   1   or
                is_eligible_voapps          =   1   or
                is_eligible_dialer_agent    =   1   or
                is_eligible_debtor          =   1
            )
;

-- alter task edwprodhh.pub_jchang.replace_master_prediction_scores set USER_TASK_TIMEOUT_MS = 57600000;
-- show parameters for task edwprodhh.pub_jchang.replace_master_prediction_scores;

create or replace task
    edwprodhh.pub_jchang.replace_master_prediction_scores
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.replace_master_prediction_pool
as



-- --DELETE TASKS & CHECK PREDECESSORS
-- edwprodhh.pub_jchang.insert_master_prediction_scores_debtor
    --INSERT_MASTER_PREDICTION_SCORES_DIALERAGENT
    --REPLACE_MASTER_PREDICTION_SCORES_TRANSFORMATION
-- edwprodhh.pub_jchang.insert_master_prediction_scores_dialeragent
    --REPLACE_MASTER_PREDICTION_DIALER_FILE