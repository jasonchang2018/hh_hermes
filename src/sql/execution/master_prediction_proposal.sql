create or replace table
    edwprodhh.hermes.master_prediction_proposal
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
)
, calculate_marginal_wide as
(
    select      scores.debtor_idx,
                scores.client_idx,
                scores.pl_group,
                scores.proposed_channel,
                scores.score_value                                                                                                  as marginal_fee,
                channel_costs.unit_cost                                                                                             as marginal_cost,
                (marginal_fee - marginal_cost)                                                                                      as marginal_profit,
                edwprodhh.pub_jchang.divide(marginal_fee - marginal_cost, marginal_fee)                                             as marginal_margin,

                row_number() over (order by marginal_profit desc)                                                                   as rank_profit,     -- 1 is best
                row_number() over (order by marginal_margin desc)                                                                   as rank_margin,     -- 1 is best
                
                (rank_profit    * (select weight from edwprodhh.hermes.master_config_objectives where metric_name = 'Profit')) +
                (rank_margin    * (select weight from edwprodhh.hermes.master_config_objectives where metric_name = 'Margin'))
                                                                                                                                    as rank_weighted    -- 1 is best

    from        scores
                left join
                    edwprodhh.hermes.master_config_channel_costs as channel_costs
                    on scores.proposed_channel = channel_costs.contact_channel
)

--  FILTER ON SET PARAMETERS  -->
, filter_marginals as
(
    select      *
    from        calculate_marginal_wide
    where       marginal_profit         >= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MIN_PROFIT_MARGINAL')
                and marginal_margin     >= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MIN_MARGIN_MARGINAL')
)
, filter_one_debtor as
(
    select      *
    from        filter_marginals
    qualify     row_number() over (partition by debtor_idx order by rank_weighted asc) = 1
)
, filter_one_packet_member as
(
    select      filter_one_debtor.*
    from        filter_one_debtor
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on filter_one_debtor.debtor_idx = debtor.debtor_idx
    qualify     row_number() over (partition by debtor.packet_idx order by filter_one_debtor.rank_weighted asc) = 1
)
, filter_runnings_channels as
(
    with with_flags as
    (
        select      filter_one_packet_member.*,

                    --  RUNNING COST
                    sum(                                                     marginal_cost                    ) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_cost_client,
                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_cost_letters,
                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_cost_texts,
                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_cost_voapps,
                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_cost_emails,

                    --  RUNNING FEE
                    sum(                                                     marginal_fee                     ) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_fee_client,
                    sum(case when proposed_channel = 'Letter'           then marginal_fee           else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_fee_letters,
                    sum(case when proposed_channel = 'Text Message'     then marginal_fee           else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_fee_texts,
                    sum(case when proposed_channel = 'VoApp'            then marginal_fee           else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_fee_voapps,
                    sum(case when proposed_channel = 'Email'            then marginal_fee           else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_fee_emails,

                    --  RUNNING MARGIN = F(RUNNING COST, RUNNING FEE)
                    edwprodhh.pub_jchang.divide(running_fee_client      - running_cost_client,      running_fee_client)                                                                             as running_margin_client,
                    edwprodhh.pub_jchang.divide(running_fee_letters     - running_cost_letters,     running_fee_letters)                                                                            as running_margin_letters,
                    edwprodhh.pub_jchang.divide(running_fee_texts       - running_cost_texts,       running_fee_texts)                                                                              as running_margin_texts,
                    edwprodhh.pub_jchang.divide(running_fee_voapps      - running_cost_voapps,      running_fee_voapps)                                                                             as running_margin_voapps,
                    edwprodhh.pub_jchang.divide(running_fee_emails      - running_cost_emails,      running_fee_emails)                                                                             as running_margin_emails,

                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                    running_cost_client         <= constraints_plgroup.max_cost_running_client      as is_eligible_cost_client,
                    running_cost_letters        <= constraints_plgroup.max_cost_running_letters     as is_eligible_cost_letters,
                    running_cost_texts          <= constraints_plgroup.max_cost_running_texts       as is_eligible_cost_texts,
                    running_cost_voapps         <= constraints_plgroup.max_cost_running_voapps      as is_eligible_cost_voapps,
                    running_cost_emails         <= constraints_plgroup.max_cost_running_emails      as is_eligible_cost_emails,
                    running_margin_client       >= constraints_plgroup.min_margin_running_client    as is_eligible_margin_client,
                    running_margin_letters      >= constraints_plgroup.min_margin_running_letters   as is_eligible_margin_letters,
                    running_margin_texts        >= constraints_plgroup.min_margin_running_texts     as is_eligible_margin_texts,
                    running_margin_voapps       >= constraints_plgroup.min_margin_running_voapps    as is_eligible_margin_voapps,
                    running_margin_emails       >= constraints_plgroup.min_margin_running_emails    as is_eligible_margin_emails

        from        filter_one_packet_member
                    left join
                        edwprodhh.hermes.master_config_constraints_plgroup as constraints_plgroup
                        on filter_one_packet_member.pl_group = constraints_plgroup.pl_group
    )
    select      debtor_idx,
                client_idx,
                pl_group,
                proposed_channel,
                marginal_fee,
                marginal_cost,
                marginal_profit,
                marginal_margin,
                rank_profit,
                rank_margin,
                rank_weighted

    from        with_flags
    where       case    when    proposed_channel = 'Letter'         then (is_eligible_cost_letters  and is_eligible_margin_letters  and is_eligible_cost_client     and is_eligible_margin_client)
                        when    proposed_channel = 'Text Message'   then (is_eligible_cost_texts    and is_eligible_margin_texts    and is_eligible_cost_client     and is_eligible_margin_client)
                        when    proposed_channel = 'VoApp'          then (is_eligible_cost_voapps   and is_eligible_margin_voapps   and is_eligible_cost_client     and is_eligible_margin_client)
                        when    proposed_channel = 'Email'          then (is_eligible_cost_emails   and is_eligible_margin_emails   and is_eligible_cost_client     and is_eligible_margin_client)
                        end
)
, filter_runnings_total as
(
    with with_flags as
    (
        select      *,

                    sum(marginal_cost)  over (order by rank_weighted asc)                   as running_cost,
                    sum(marginal_fee)   over (order by rank_weighted asc)                   as running_fee,
                    edwprodhh.pub_jchang.divide(running_fee - running_cost,  running_fee)   as running_margin,

                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                    running_cost            <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_TOTAL')           as is_eligible_cost,
                    running_margin          >= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MIN_MARGIN_RUNNING_TOTAL')         as is_eligible_margin

        from        filter_runnings_channels
    )
    select      debtor_idx,
                client_idx,
                pl_group,
                proposed_channel,
                marginal_fee,
                marginal_cost,
                marginal_profit,
                marginal_margin,
                rank_profit,
                rank_margin,
                rank_weighted

    from        with_flags
    where       is_eligible_cost
                and is_eligible_margin
)
--  <--  FILTER ON SET PARAMETERS

, calculate_filtered as
(
    select      pool.*,
                case    when    proposed.debtor_idx is not null
                        then    1
                        else    0
                        end     as is_proposed_contact

    from        calculate_marginal_wide as pool
                left join
                    filter_runnings_total as proposed
                    on  pool.debtor_idx         = proposed.debtor_idx
                    and pool.proposed_channel   = proposed.proposed_channel
)
select      *
from        calculate_filtered
;



create task
    edwprodhh.pub_jchang.replace_master_prediction_proposal
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.replace_master_prediction_scores
as
create or replace table
    edwprodhh.hermes.master_prediction_proposal
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
)
, calculate_marginal_wide as
(
    select      scores.debtor_idx,
                scores.client_idx,
                scores.pl_group,
                scores.proposed_channel,
                scores.score_value                                                                                                  as marginal_fee,
                channel_costs.unit_cost                                                                                             as marginal_cost,
                (marginal_fee - marginal_cost)                                                                                      as marginal_profit,
                edwprodhh.pub_jchang.divide(marginal_fee - marginal_cost, marginal_fee)                                             as marginal_margin,

                row_number() over (order by marginal_profit desc)                                                                   as rank_profit,     -- 1 is best
                row_number() over (order by marginal_margin desc)                                                                   as rank_margin,     -- 1 is best
                
                (rank_profit    * (select weight from edwprodhh.hermes.master_config_objectives where metric_name = 'Profit')) +
                (rank_margin    * (select weight from edwprodhh.hermes.master_config_objectives where metric_name = 'Margin'))
                                                                                                                                    as rank_weighted    -- 1 is best

    from        scores
                left join
                    edwprodhh.hermes.master_config_channel_costs as channel_costs
                    on scores.proposed_channel = channel_costs.contact_channel
)

--  FILTER ON SET PARAMETERS  -->
, filter_marginals as
(
    select      *
    from        calculate_marginal_wide
    where       marginal_profit         >= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MIN_PROFIT_MARGINAL')
                and marginal_margin     >= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MIN_MARGIN_MARGINAL')
)
, filter_one_debtor as
(
    select      *
    from        filter_marginals
    qualify     row_number() over (partition by debtor_idx order by rank_weighted asc) = 1
)
, filter_one_packet_member as
(
    select      filter_one_debtor.*
    from        filter_one_debtor
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on filter_one_debtor.debtor_idx = debtor.debtor_idx
    qualify     row_number() over (partition by debtor.packet_idx order by filter_one_debtor.rank_weighted asc) = 1
)
, filter_runnings_channels as
(
    with with_flags as
    (
        select      filter_one_packet_member.*,

                    --  RUNNING COST
                    sum(                                                     marginal_cost                    ) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_cost_client,
                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_cost_letters,
                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_cost_texts,
                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_cost_voapps,
                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_cost_emails,

                    --  RUNNING FEE
                    sum(                                                     marginal_fee                     ) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_fee_client,
                    sum(case when proposed_channel = 'Letter'           then marginal_fee           else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_fee_letters,
                    sum(case when proposed_channel = 'Text Message'     then marginal_fee           else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_fee_texts,
                    sum(case when proposed_channel = 'VoApp'            then marginal_fee           else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_fee_voapps,
                    sum(case when proposed_channel = 'Email'            then marginal_fee           else 0 end) over (partition by filter_one_packet_member.pl_group order by rank_weighted asc)    as running_fee_emails,

                    --  RUNNING MARGIN = F(RUNNING COST, RUNNING FEE)
                    edwprodhh.pub_jchang.divide(running_fee_client      - running_cost_client,      running_fee_client)                                                                             as running_margin_client,
                    edwprodhh.pub_jchang.divide(running_fee_letters     - running_cost_letters,     running_fee_letters)                                                                            as running_margin_letters,
                    edwprodhh.pub_jchang.divide(running_fee_texts       - running_cost_texts,       running_fee_texts)                                                                              as running_margin_texts,
                    edwprodhh.pub_jchang.divide(running_fee_voapps      - running_cost_voapps,      running_fee_voapps)                                                                             as running_margin_voapps,
                    edwprodhh.pub_jchang.divide(running_fee_emails      - running_cost_emails,      running_fee_emails)                                                                             as running_margin_emails,

                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                    running_cost_client         <= constraints_plgroup.max_cost_running_client      as is_eligible_cost_client,
                    running_cost_letters        <= constraints_plgroup.max_cost_running_letters     as is_eligible_cost_letters,
                    running_cost_texts          <= constraints_plgroup.max_cost_running_texts       as is_eligible_cost_texts,
                    running_cost_voapps         <= constraints_plgroup.max_cost_running_voapps      as is_eligible_cost_voapps,
                    running_cost_emails         <= constraints_plgroup.max_cost_running_emails      as is_eligible_cost_emails,
                    running_margin_client       >= constraints_plgroup.min_margin_running_client    as is_eligible_margin_client,
                    running_margin_letters      >= constraints_plgroup.min_margin_running_letters   as is_eligible_margin_letters,
                    running_margin_texts        >= constraints_plgroup.min_margin_running_texts     as is_eligible_margin_texts,
                    running_margin_voapps       >= constraints_plgroup.min_margin_running_voapps    as is_eligible_margin_voapps,
                    running_margin_emails       >= constraints_plgroup.min_margin_running_emails    as is_eligible_margin_emails

        from        filter_one_packet_member
                    left join
                        edwprodhh.hermes.master_config_constraints_plgroup as constraints_plgroup
                        on filter_one_packet_member.pl_group = constraints_plgroup.pl_group
    )
    select      debtor_idx,
                client_idx,
                pl_group,
                proposed_channel,
                marginal_fee,
                marginal_cost,
                marginal_profit,
                marginal_margin,
                rank_profit,
                rank_margin,
                rank_weighted

    from        with_flags
    where       case    when    proposed_channel = 'Letter'         then (is_eligible_cost_letters  and is_eligible_margin_letters  and is_eligible_cost_client     and is_eligible_margin_client)
                        when    proposed_channel = 'Text Message'   then (is_eligible_cost_texts    and is_eligible_margin_texts    and is_eligible_cost_client     and is_eligible_margin_client)
                        when    proposed_channel = 'VoApp'          then (is_eligible_cost_voapps   and is_eligible_margin_voapps   and is_eligible_cost_client     and is_eligible_margin_client)
                        when    proposed_channel = 'Email'          then (is_eligible_cost_emails   and is_eligible_margin_emails   and is_eligible_cost_client     and is_eligible_margin_client)
                        end
)
, filter_runnings_total as
(
    with with_flags as
    (
        select      *,

                    sum(marginal_cost)  over (order by rank_weighted asc)                   as running_cost,
                    sum(marginal_fee)   over (order by rank_weighted asc)                   as running_fee,
                    edwprodhh.pub_jchang.divide(running_fee - running_cost,  running_fee)   as running_margin,

                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                    running_cost            <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_TOTAL')           as is_eligible_cost,
                    running_margin          >= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MIN_MARGIN_RUNNING_TOTAL')         as is_eligible_margin

        from        filter_runnings_channels
    )
    select      debtor_idx,
                client_idx,
                pl_group,
                proposed_channel,
                marginal_fee,
                marginal_cost,
                marginal_profit,
                marginal_margin,
                rank_profit,
                rank_margin,
                rank_weighted

    from        with_flags
    where       is_eligible_cost
                and is_eligible_margin
)
--  <--  FILTER ON SET PARAMETERS

, calculate_filtered as
(
    select      pool.*,
                case    when    proposed.debtor_idx is not null
                        then    1
                        else    0
                        end     as is_proposed_contact

    from        calculate_marginal_wide as pool
                left join
                    filter_runnings_total as proposed
                    on  pool.debtor_idx         = proposed.debtor_idx
                    and pool.proposed_channel   = proposed.proposed_channel
)
select      *
from        calculate_filtered
;