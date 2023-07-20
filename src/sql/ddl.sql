create schema edwprodhh.hermes;


create table
    edwprodhh.hermes.master_prediction_pool_log
(
    DEBTOR_IDX                                  VARCHAR(50),
    CLIENT_IDX                                  VARCHAR(16),
    PL_GROUP                                    VARCHAR(16777216),
    STATUS                                      VARCHAR(16777216),
    PASS_DEBTOR_STATUS                          NUMBER(1,0),
    PASS_CLIENT_ALLOWED_LETTERS                 NUMBER(1,0),
    PASS_CLIENT_ALLOWED_TEXTS                   NUMBER(1,0),
    PASS_CLIENT_ALLOWED_VOAPPS                  NUMBER(1,0),
    PASS_CLIENT_ALLOWED_CALLS                   NUMBER(1,0),
    REQUIRES_VALIDATION                         NUMBER(1,0),
    PASS_RECEIVED_VALIDATION                    NUMBER(1,0),
    PASS_AGE_VALIDATION                         NUMBER(1,0),
    PASS_VALIDATION_REQUIREMENT_DEBTOR          NUMBER(1,0),
    PASS_VALIDATION_REQUIREMENT                 NUMBER(1,0),
    VALIDATION_LETTER_DATE                      DATE,
    EMAIL_ADDRESS                               VARCHAR(50),
    PASS_ADDRESS_EMAILS                         NUMBER(1,0),
    MAILING_ADDRESS                             VARCHAR(100),
    MAILING_CITY                                VARCHAR(50),
    MAILING_STATE                               VARCHAR(20),
    MAILING_ZIP_CODE                            VARCHAR(16777216),
    PASS_ADDRESS_LETTERS                        NUMBER(1,0),
    VALID_PHONE_NUMBER                          VARCHAR(16777216),
    CELL_CODE_DEBTOR                            VARCHAR(150),
    CELL_CODE_PACKET_AGG                        VARCHAR(16777216),
    CELL_CODE_PACKET_FACTORIZED                 VARCHAR(16777216),
    CELL_CODE_PACKET                            VARCHAR(16777216),
    PHONE_NUMBER_SOURCE                         VARCHAR(20),
    COMMERCIAL_CODE                             VARCHAR(50),
    STATE                                       VARCHAR(20),
    PASS_PHONE_VOAPPS                           NUMBER(1,0),
    PASS_PHONE_TEXTS                            NUMBER(1,0),
    PASS_PHONE_CALLS                            NUMBER(1,0),
    NEXT_DATE_LETTERS                           DATE,
    PREV_N_CONTACTS                             NUMBER(18,0),
    PREV_N_LETTERS                              NUMBER(18,0),
    PREV_N_VOAPPS                               NUMBER(18,0),
    PREV_N_TEXTS                                NUMBER(18,0),
    PREV_N_EMAILS                               NUMBER(18,0),
    PREV_N_INBOUNDS                             NUMBER(18,0),
    PREV_N_DIALER_AGENT                         NUMBER(18,0),
    PREV_N_DIALER_AGENTLESS                     NUMBER(18,0),
    PREV_N_OUTBOUND_MANUAL                      NUMBER(18,0),
    PREV_N_VOAPPS_7                             NUMBER(18,0),
    PREV_N_DIALER_AGENT_7                       NUMBER(18,0),
    PREV_N_DIALER_AGENTLESS_7                   NUMBER(18,0),
    PREV_N_OUTBOUND_MANUAL_7                    NUMBER(18,0),
    PREV_DATE_CONTACTS                          DATE,
    PREV_DATE_LETTERS                           DATE,
    PREV_DATE_VOAPPS                            DATE,
    PREV_DATE_TEXTS                             DATE,
    PREV_DATE_EMAILS                            DATE,
    PREV_DATE_INBOUNDS                          DATE,
    PREV_DATE_DIALER_AGENT                      DATE,
    PREV_DATE_DIALER_AGENTLESS                  DATE,
    PREV_DATE_OUTBOUND_MANUAL                   DATE,
    PREV_DATE_RPC                               DATE,
    PASS_LETTERS_WARMUP                         NUMBER(1,0),
    PASS_LETTERS_COOLDOWN                       NUMBER(1,0),
    PASS_VOAPPS_COOLDOWN                        NUMBER(1,0),
    PASS_TEXTS_COOLDOWN                         NUMBER(1,0),
    PASS_7IN7                                   NUMBER(1,0),
    ASSIGNED                                    NUMBER(30,2),
    BALANCE_DIMDEBTOR                           NUMBER(16,2),
    BALANCE_DIMDEBTOR_PACKET                    NUMBER(28,2),
    PASS_DEBTOR_BALANCE                         NUMBER(1,0),
    PASS_PACKET_BALANCE                         NUMBER(1,0),
    PASS_DEBTOR_ASSIGNED                        NUMBER(1,0),
    EXPERIAN_SCORE                              NUMBER(38,0),
    PASS_DEBTOR_EXPERIAN                        NUMBER(1,0),
    MEDIAN_HOUSEHOLD_INCOME                     FLOAT,
    PASS_DEBTOR_INCOME                          NUMBER(1,0),
    PACKET_HAS_PREVIOUS_PAYMENT                 NUMBER(1,0),
    DEBTOR_IS_FIRST_IN_PACKET                   NUMBER(1,0),
    LAST_PAYMENT_DATE                           DATE,
    PASS_CONTRAINTS_PACKET_LAST_PAYMENT         NUMBER(1,0),
    DESK_TEAM_NAME                              VARCHAR(50),
    PASS_EXISTING_PAYPLAN                       NUMBER(1,0),
    AGE_PLACEMENT                               NUMBER(9,0),
    AGE_DEBT                                    NUMBER(9,0),
    AGE_PACKET                                  NUMBER(9,0),
    PASS_DEBTOR_AGE_DEBT                        NUMBER(1,0),
    PASS_DEBTOR_AGE_PLACEMENT                   NUMBER(1,0),
    PASS_DEBTOR_AGE_PACKET                      NUMBER(1,0),
    TAX_YEAR                                    NUMBER(4,0),
    PASS_DEBTOR_TAX_YEAR                        NUMBER(1,0),
    IS_DEBTTYPE_GOV_PARKING                     NUMBER(1,0),
    IS_DEBTTYPE_GOV_TOLL                        NUMBER(1,0),
    IS_DEBTTYPE_HC_AI                           NUMBER(1,0),
    IS_DEBTTYPE_HC_SP                           NUMBER(1,0),
    PASS_DEBTOR_FIRST_SCORE_DIALER_AGENT        NUMBER(1,0),
    IS_ELIGIBLE_LETTERS                         NUMBER(1,0),
    IS_ELIGIBLE_TEXTS                           NUMBER(1,0),
    IS_ELIGIBLE_VOAPPS                          NUMBER(1,0),
    IS_ELIGIBLE_EMAILS                          VARCHAR(16777216),
    IS_ELIGIBLE_DIALER_AGENT                    NUMBER(1,0),
    IS_ELIGIBLE_DIALER_AGENTLESS                VARCHAR(16777216),
    execute_time                                TIMESTAMP_LTZ(9)
)
;


create table
    edwprodhh.hermes.master_prediction_scores_log
(
    DEBTOR_IDX                      VARCHAR(50),
    CLIENT_IDX                      VARCHAR(16),
    PL_GROUP                        VARCHAR(16777216),
    SCORE_LETTERS                   FLOAT,
    SCORE_TEXTS                     FLOAT,
    SCORE_VOAPPS                    FLOAT,
    SCORE_EMAILS                    FLOAT,
    SCORE_DIALER_AGENT              FLOAT,
    SCORE_DIALER_AGENTLESS          FLOAT,
    execute_time                    TIMESTAMP_LTZ(9)
)
;


create table
    edwprodhh.hermes.master_prediction_proposal_log
(
    DEBTOR_IDX                      VARCHAR(50),
    CLIENT_IDX                      VARCHAR(16),
    PL_GROUP                        VARCHAR(16777216),
    PROPOSED_CHANNEL                VARCHAR(16777216),
    MARGINAL_FEE                    FLOAT,
    MARGINAL_COST                   NUMBER(9,2),
    MARGINAL_PROFIT                 FLOAT,
    MARGINAL_MARGIN                 FLOAT,
    RANK_PROFIT                     NUMBER(18,0),
    RANK_MARGIN                     NUMBER(18,0),
    RANK_WEIGHTED                   NUMBER(28,2),
    IS_PROPOSED_CONTACT             NUMBER(1,0),
    IS_FASTTRACK                    NUMBER(1,0),
    UPLOAD_DATE                     DATE,
    execute_time                    TIMESTAMP_LTZ(9)
)
;


create table
    edwprodhh.hermes.master_prediction_dialer_rank_global_log
(
    DEBTOR_IDX                      VARCHAR(50),
    CLIENT_IDX                      VARCHAR(16),
    PL_GROUP                        VARCHAR(16777216),
    PROPOSED_CHANNEL                VARCHAR(16777216),
    MARGINAL_FEE                    FLOAT,
    RANK_GLOBAL                     NUMBER(18,0),
    EXECUTE_TIME                    TIMESTAMP_LTZ(9)
)
;


create table
    edwprodhh.hermes.master_prediction_execution_log
(
    execute_time                    TIMESTAMP_LTZ(9),
    N_PROPOSED_LETTERS              NUMBER(18,0),
    N_PROPOSED_TEXTS                NUMBER(18,0),
    N_PROPOSED_VOAPPS               NUMBER(18,0),
    N_PROPOSED_EMAILS               NUMBER(18,0),
    N_PROPOSED_DIALER_AGENT         NUMBER(18,0),
    N_PROPOSED_DIALER_AGENTLESS     NUMBER(18,0)
)
;


create task
    edwprodhh.pub_jchang.hermes_root
    warehouse = analysis_wh
    schedule = 'USING CRON 30 12 * * THU America/Chicago'
as
select      1 as val
;