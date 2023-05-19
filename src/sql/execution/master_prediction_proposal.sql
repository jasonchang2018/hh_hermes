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
, filter_best_contact_options_per_packet as
(
    select      filter_marginals.*,
                debtor.packet_idx

    from        filter_marginals
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on filter_marginals.debtor_idx = debtor.debtor_idx

    qualify     row_number() over (partition by debtor.packet_idx, filter_marginals.proposed_channel order by filter_marginals.rank_weighted asc) = 1
)
, calculate_packet_rankings as
(
    select      *,
                row_number() over (partition by packet_idx order by rank_weighted asc)  as rank_within_packet
    from        filter_best_contact_options_per_packet
)

, filter_runnings_channels as
(   
    -- THERE NEED TO BE AS MANY ITERATIONS HERE AS THERE ARE POTENTIAL & SCORED CONTACT CHANNEL OPTIONS.
    with iteration_1 as
    (
        select      *
        from        (
                        select      calculate_packet_rankings.*,

                                    --  RUNNING COST
                                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_letters,
                                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_texts,
                                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_voapps,
                                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_emails,

                                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                                    running_cost_letters        <= constraints_plgroup.max_cost_running_letters     as is_eligible_cost_letters,
                                    running_cost_texts          <= constraints_plgroup.max_cost_running_texts       as is_eligible_cost_texts,
                                    running_cost_voapps         <= constraints_plgroup.max_cost_running_voapps      as is_eligible_cost_voapps,
                                    running_cost_emails         <= constraints_plgroup.max_cost_running_emails      as is_eligible_cost_emails

                        from        calculate_packet_rankings
                                    left join
                                        edwprodhh.hermes.master_config_constraints_plgroup as constraints_plgroup
                                        on calculate_packet_rankings.pl_group = constraints_plgroup.pl_group

                        where       calculate_packet_rankings.rank_within_packet = 1
                    )

        where       case    when    proposed_channel = 'Letter'         then is_eligible_cost_letters
                            when    proposed_channel = 'Text Message'   then is_eligible_cost_texts
                            when    proposed_channel = 'VoApp'          then is_eligible_cost_voapps
                            when    proposed_channel = 'Email'          then is_eligible_cost_emails
                            end
    )
    , iteration_2 as
    (
        select      *
        from        (
                        select      calculate_packet_rankings.*,

                                    --  RUNNING COST
                                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_letters,
                                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_texts,
                                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_voapps,
                                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_emails,

                                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                                    running_cost_letters        <= (constraints_plgroup.max_cost_running_letters     - (select max(running_cost_letters)     from iteration_1))     as is_eligible_cost_letters,
                                    running_cost_texts          <= (constraints_plgroup.max_cost_running_texts       - (select max(running_cost_texts)       from iteration_1))     as is_eligible_cost_texts,
                                    running_cost_voapps         <= (constraints_plgroup.max_cost_running_voapps      - (select max(running_cost_voapps)      from iteration_1))     as is_eligible_cost_voapps,
                                    running_cost_emails         <= (constraints_plgroup.max_cost_running_emails      - (select max(running_cost_emails)      from iteration_1))     as is_eligible_cost_emails

                        from        calculate_packet_rankings
                                    left join
                                        edwprodhh.hermes.master_config_constraints_plgroup as constraints_plgroup
                                        on calculate_packet_rankings.pl_group = constraints_plgroup.pl_group

                        where       calculate_packet_rankings.rank_within_packet = 2
                                    and calculate_packet_rankings.packet_idx not in (select packet_idx from iteration_1)
                    )

        where       case    when    proposed_channel = 'Letter'         then is_eligible_cost_letters
                            when    proposed_channel = 'Text Message'   then is_eligible_cost_texts
                            when    proposed_channel = 'VoApp'          then is_eligible_cost_voapps
                            when    proposed_channel = 'Email'          then is_eligible_cost_emails
                            end
    )
    , iteration_3 as
    (
        select      *
        from        (
                        select      calculate_packet_rankings.*,

                                    --  RUNNING COST
                                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_letters,
                                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_texts,
                                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_voapps,
                                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_emails,

                                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                                    running_cost_letters        <= (constraints_plgroup.max_cost_running_letters     - (select max(running_cost_letters)     from iteration_1)  - (select max(running_cost_letters)     from iteration_2))  as is_eligible_cost_letters,
                                    running_cost_texts          <= (constraints_plgroup.max_cost_running_texts       - (select max(running_cost_texts)       from iteration_1)  - (select max(running_cost_texts)       from iteration_2))  as is_eligible_cost_texts,
                                    running_cost_voapps         <= (constraints_plgroup.max_cost_running_voapps      - (select max(running_cost_voapps)      from iteration_1)  - (select max(running_cost_voapps)      from iteration_2))  as is_eligible_cost_voapps,
                                    running_cost_emails         <= (constraints_plgroup.max_cost_running_emails      - (select max(running_cost_emails)      from iteration_1)  - (select max(running_cost_emails)      from iteration_2))  as is_eligible_cost_emails

                        from        calculate_packet_rankings
                                    left join
                                        edwprodhh.hermes.master_config_constraints_plgroup as constraints_plgroup
                                        on calculate_packet_rankings.pl_group = constraints_plgroup.pl_group

                        where       calculate_packet_rankings.rank_within_packet = 3
                                    and calculate_packet_rankings.packet_idx not in (select packet_idx from iteration_1)
                                    and calculate_packet_rankings.packet_idx not in (select packet_idx from iteration_2)
                    )

        where       case    when    proposed_channel = 'Letter'         then is_eligible_cost_letters
                            when    proposed_channel = 'Text Message'   then is_eligible_cost_texts
                            when    proposed_channel = 'VoApp'          then is_eligible_cost_voapps
                            when    proposed_channel = 'Email'          then is_eligible_cost_emails
                            end
    )
    , unioned as
    (
        select      *
        from        iteration_1
        union all
        select      *
        from        iteration_2
        union all
        select      *
        from        iteration_3
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
    from        unioned
)
, filter_runnings_client as
(
    with with_flags as
    (
        select      filter_runnings_channels.*,
                    sum(marginal_cost) over (partition by filter_runnings_channels.pl_group order by rank_weighted asc)     as running_cost_client,
                    running_cost_client <= constraints_plgroup.max_cost_running_client                                      as is_eligible_cost_client

        from        filter_runnings_channels
                    left join
                        edwprodhh.hermes.master_config_constraints_plgroup as constraints_plgroup
                        on filter_runnings_channels.pl_group = constraints_plgroup.pl_group
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
    where       is_eligible_cost_client
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

        from        filter_runnings_client
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
    -- schedule = 'USING CRON 0 5 * * FRI America/Chicago'
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
, filter_best_contact_options_per_packet as
(
    select      filter_marginals.*,
                debtor.packet_idx

    from        filter_marginals
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on filter_marginals.debtor_idx = debtor.debtor_idx

    qualify     row_number() over (partition by debtor.packet_idx, filter_marginals.proposed_channel order by filter_marginals.rank_weighted asc) = 1
)
, calculate_packet_rankings as
(
    select      *,
                row_number() over (partition by packet_idx order by rank_weighted asc)  as rank_within_packet
    from        filter_best_contact_options_per_packet
)

, filter_runnings_channels as
(   
    -- THERE NEED TO BE AS MANY ITERATIONS HERE AS THERE ARE POTENTIAL & SCORED CONTACT CHANNEL OPTIONS.
    with iteration_1 as
    (
        select      *
        from        (
                        select      calculate_packet_rankings.*,

                                    --  RUNNING COST
                                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_letters,
                                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_texts,
                                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_voapps,
                                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_emails,

                                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                                    running_cost_letters        <= constraints_plgroup.max_cost_running_letters     as is_eligible_cost_letters,
                                    running_cost_texts          <= constraints_plgroup.max_cost_running_texts       as is_eligible_cost_texts,
                                    running_cost_voapps         <= constraints_plgroup.max_cost_running_voapps      as is_eligible_cost_voapps,
                                    running_cost_emails         <= constraints_plgroup.max_cost_running_emails      as is_eligible_cost_emails

                        from        calculate_packet_rankings
                                    left join
                                        edwprodhh.hermes.master_config_constraints_plgroup as constraints_plgroup
                                        on calculate_packet_rankings.pl_group = constraints_plgroup.pl_group

                        where       calculate_packet_rankings.rank_within_packet = 1
                    )

        where       case    when    proposed_channel = 'Letter'         then is_eligible_cost_letters
                            when    proposed_channel = 'Text Message'   then is_eligible_cost_texts
                            when    proposed_channel = 'VoApp'          then is_eligible_cost_voapps
                            when    proposed_channel = 'Email'          then is_eligible_cost_emails
                            end
    )
    , iteration_2 as
    (
        select      *
        from        (
                        select      calculate_packet_rankings.*,

                                    --  RUNNING COST
                                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_letters,
                                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_texts,
                                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_voapps,
                                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_emails,

                                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                                    running_cost_letters        <= (constraints_plgroup.max_cost_running_letters     - (select max(running_cost_letters)     from iteration_1))     as is_eligible_cost_letters,
                                    running_cost_texts          <= (constraints_plgroup.max_cost_running_texts       - (select max(running_cost_texts)       from iteration_1))     as is_eligible_cost_texts,
                                    running_cost_voapps         <= (constraints_plgroup.max_cost_running_voapps      - (select max(running_cost_voapps)      from iteration_1))     as is_eligible_cost_voapps,
                                    running_cost_emails         <= (constraints_plgroup.max_cost_running_emails      - (select max(running_cost_emails)      from iteration_1))     as is_eligible_cost_emails

                        from        calculate_packet_rankings
                                    left join
                                        edwprodhh.hermes.master_config_constraints_plgroup as constraints_plgroup
                                        on calculate_packet_rankings.pl_group = constraints_plgroup.pl_group

                        where       calculate_packet_rankings.rank_within_packet = 2
                                    and calculate_packet_rankings.packet_idx not in (select packet_idx from iteration_1)
                    )

        where       case    when    proposed_channel = 'Letter'         then is_eligible_cost_letters
                            when    proposed_channel = 'Text Message'   then is_eligible_cost_texts
                            when    proposed_channel = 'VoApp'          then is_eligible_cost_voapps
                            when    proposed_channel = 'Email'          then is_eligible_cost_emails
                            end
    )
    , iteration_3 as
    (
        select      *
        from        (
                        select      calculate_packet_rankings.*,

                                    --  RUNNING COST
                                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_letters,
                                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_texts,
                                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_voapps,
                                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.pl_group order by rank_weighted asc)    as running_cost_emails,

                                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                                    running_cost_letters        <= (constraints_plgroup.max_cost_running_letters     - (select max(running_cost_letters)     from iteration_1)  - (select max(running_cost_letters)     from iteration_2))  as is_eligible_cost_letters,
                                    running_cost_texts          <= (constraints_plgroup.max_cost_running_texts       - (select max(running_cost_texts)       from iteration_1)  - (select max(running_cost_texts)       from iteration_2))  as is_eligible_cost_texts,
                                    running_cost_voapps         <= (constraints_plgroup.max_cost_running_voapps      - (select max(running_cost_voapps)      from iteration_1)  - (select max(running_cost_voapps)      from iteration_2))  as is_eligible_cost_voapps,
                                    running_cost_emails         <= (constraints_plgroup.max_cost_running_emails      - (select max(running_cost_emails)      from iteration_1)  - (select max(running_cost_emails)      from iteration_2))  as is_eligible_cost_emails

                        from        calculate_packet_rankings
                                    left join
                                        edwprodhh.hermes.master_config_constraints_plgroup as constraints_plgroup
                                        on calculate_packet_rankings.pl_group = constraints_plgroup.pl_group

                        where       calculate_packet_rankings.rank_within_packet = 3
                                    and calculate_packet_rankings.packet_idx not in (select packet_idx from iteration_1)
                                    and calculate_packet_rankings.packet_idx not in (select packet_idx from iteration_2)
                    )

        where       case    when    proposed_channel = 'Letter'         then is_eligible_cost_letters
                            when    proposed_channel = 'Text Message'   then is_eligible_cost_texts
                            when    proposed_channel = 'VoApp'          then is_eligible_cost_voapps
                            when    proposed_channel = 'Email'          then is_eligible_cost_emails
                            end
    )
    , unioned as
    (
        select      *
        from        iteration_1
        union all
        select      *
        from        iteration_2
        union all
        select      *
        from        iteration_3
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
    from        unioned
)
, filter_runnings_client as
(
    with with_flags as
    (
        select      filter_runnings_channels.*,
                    sum(marginal_cost) over (partition by filter_runnings_channels.pl_group order by rank_weighted asc)     as running_cost_client,
                    running_cost_client <= constraints_plgroup.max_cost_running_client                                      as is_eligible_cost_client

        from        filter_runnings_channels
                    left join
                        edwprodhh.hermes.master_config_constraints_plgroup as constraints_plgroup
                        on filter_runnings_channels.pl_group = constraints_plgroup.pl_group
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
    where       is_eligible_cost_client
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

        from        filter_runnings_client
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