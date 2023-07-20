create or replace table
    edwprodhh.hermes.master_prediction_dialer_rank_global
as
with scores as
(
    select      debtor_idx,
                client_idx,
                pl_group,
                case    upper(proposed_channel_)
                        when    'SCORE_LETTERS'             then    'Letter'
                        when    'SCORE_TEXTS'               then    'Text Message'
                        when    'SCORE_VOAPPS'              then    'VoApp'
                        when    'SCORE_EMAILS'              then    'Email'
                        when    'SCORE_DIALER_AGENT'        then    'Dialer-Agent Call'
                        when    'SCORE_DIALER_AGENTLESS'    then    'Dialer-Agentless Call'
                        end     as proposed_channel,
                score_value

    from        edwprodhh.hermes.master_prediction_scores
                unpivot(
                    score_value for proposed_channel_ in (
                        score_letters,
                        score_texts,
                        score_voapps,
                        score_emails,
                        score_dialer_agent,
                        score_dialer_agentless
                    )
                )   as unpvt

    where       score_value is not null
                and proposed_channel in (
                    'Dialer-Agent Call',
                    'Dialer-Agentless Call'
                )
)
select      debtor_idx,
            client_idx,
            pl_group,
            proposed_channel,
            score_value,
            row_number() over (partition by 1 order by score_value desc) as rank_global
from        scores
order by    rank_global asc
;



create task
    edwprodhh.pub_jchang.replace_master_prediction_dialer_rank_global
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.insert_master_prediction_scores_dialeragent
as
create or replace table
    edwprodhh.hermes.master_prediction_dialer_rank_global
as
with scores as
(
    select      debtor_idx,
                client_idx,
                pl_group,
                case    upper(proposed_channel_)
                        when    'SCORE_LETTERS'             then    'Letter'
                        when    'SCORE_TEXTS'               then    'Text Message'
                        when    'SCORE_VOAPPS'              then    'VoApp'
                        when    'SCORE_EMAILS'              then    'Email'
                        when    'SCORE_DIALER_AGENT'        then    'Dialer-Agent Call'
                        when    'SCORE_DIALER_AGENTLESS'    then    'Dialer-Agentless Call'
                        end     as proposed_channel,
                score_value

    from        edwprodhh.hermes.master_prediction_scores
                unpivot(
                    score_value for proposed_channel_ in (
                        score_letters,
                        score_texts,
                        score_voapps,
                        score_emails,
                        score_dialer_agent,
                        score_dialer_agentless
                    )
                )   as unpvt

    where       score_value is not null
                and proposed_channel in (
                    'Dialer-Agent Call',
                    'Dialer-Agentless Call'
                )
)
select      debtor_idx,
            client_idx,
            pl_group,
            proposed_channel,
            score_value,
            row_number() over (partition by 1 order by score_value desc) as rank_global
from        scores
order by    rank_global asc
;