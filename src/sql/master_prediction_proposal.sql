create or replace table
    edwprodhh.hermes.master_prediction_proposal
as
with scores as
(
    with scores_long as
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
                        'Letter',
                        'Text Message',
                        'VoApp',
                        'Email'
                    )
    )
    select      scores_long.*,

                case    when    scores_long.proposed_channel = 'Letter'         then    pool.is_priority_minimum_letters
                        when    scores_long.proposed_channel = 'Text Message'   then    pool.is_priority_minimum_texts
                        when    scores_long.proposed_channel = 'VoApp'          then    pool.is_priority_minimum_voapps
                        when    scores_long.proposed_channel = 'Email'          then    pool.is_priority_minimum_emails
                        else    0
                        end     as is_priority_minimum

    from        scores_long
                left join
                    edwprodhh.hermes.master_prediction_pool as pool
                    on  scores_long.debtor_idx = pool.debtor_idx
)
, calculate_marginal_wide as
(
    select      scores.debtor_idx,
                scores.client_idx,
                scores.pl_group,
                scores.proposed_channel,
                scores.is_priority_minimum,
                scores.score_value                                                                                                  as marginal_fee,
                channel_costs.unit_cost                                                                                             as marginal_cost,
                (marginal_fee - marginal_cost)                                                                                      as marginal_profit,
                edwprodhh.pub_jchang.divide(marginal_fee - marginal_cost, marginal_fee)                                             as marginal_margin,

                row_number() over (order by scores.is_priority_minimum desc, marginal_profit desc)                                  as rank_profit,     -- 1 is best
                row_number() over (order by scores.is_priority_minimum desc, marginal_margin desc)                                  as rank_margin,     -- 1 is best
                
                (rank_profit    * (select weight from edwprodhh.hermes.master_config_objectives where metric_name = 'Profit')) +
                (rank_margin    * (select weight from edwprodhh.hermes.master_config_objectives where metric_name = 'Margin'))
                                                                                                                                    as rank_weighted    -- 1 is best

    from        scores
                left join
                    edwprodhh.hermes.master_config_channel_costs as channel_costs
                    on scores.proposed_channel = channel_costs.contact_channel
)

-- --  ENSURING CONTACTS IN LOWER BUCKETS -->
-- ,deciles as 
-- ( 
--     select      debtor_idx,
--                 rank_weighted, 
                
--                 ntile(10) over (order by rank_weighted)                                                                             as decile 
    
--     from        calculate_marginal_wide 

-- ) 
-- , boundary_value as 
-- ( 
--     select      max(rank_weighted)                                                                                                as max_value_8

--     from        deciles 
--     where       decile = 8 

-- ) , decileweights as
-- (
--     select      decile, 
--                 decile / 28.0 as weight_fraction,
--                 count(*) as decile_count,
--                 ceil(0.07 * count(*) * (decile / 28.0)) as rows_to_take  
    
--     from        deciles
--     where       decile between 1 and 7
--     group by    decile

-- )
-- ,  random_selection as 
-- (
--     select      deciles.*,
--                 (select max_value_8 from boundary_value) - 1                                                                       as adjusted_rank_weighted, 
--                 row_number() over (partition by deciles.decile order by random()) as rn
    
--     from        deciles 
--                 inner join decileweights on deciles.decile = decileweights.decile
--     where       d.decile between 1 and 7
--     qualify     row_number() over (partition by d.decile order by random()) <= dw.rows_to_take  

-- )
-- , calculate_marginal_wide2 as 
-- (
--     select      calculate_marginal_wide.debtor_idx,
--                 calculate_marginal_wide.client_idx,
--                 calculate_marginal_wide.pl_group,
--                 calculate_marginal_wide.proposed_channel,
--                 calculate_marginal_wide.marginal_fee,
--                 calculate_marginal_wide.marginal_cost,
--                 calculate_marginal_wide.marginal_profit,
--                 calculate_marginal_wide.marginal_margin,
--                 calculate_marginal_wide.rank_profit,
--                 calculate_marginal_wide.rank_margin,
--                 case 
--                         when random_selection.debtor_idx is not null then random_selection.adjusted_rank_weighted
--                         else calculate_marginal_wide.rank_weighted 
--                 end                                                                                                                                 as adjusted_rank_weighted

--             from calculate_marginal_wide
--                 left join random_selection on random_selection.debtor_idx = calculate_marginal_wide.debtor_idx 
--             order by adjusted_rank_weighted

-- ) 


--  FILTER ON SET PARAMETERS  -->
, filter_marginals as
(
    select      *
    from        calculate_marginal_wide
    where       (
                    marginal_profit         >= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MIN_PROFIT_MARGINAL')
                    and marginal_margin     >= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MIN_MARGIN_MARGINAL')
                )
                or is_priority_minimum = 1
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

, filter_running_cost_channels as
(   
    -- THERE NEED TO BE AS MANY ITERATIONS HERE AS THERE ARE POTENTIAL & SCORED CONTACT CHANNEL OPTIONS.
    -- THIS EXISTS BECAUSE ONCE A PACKET IS SELECTED FOR ONE CONTACT CHANNEL, WE DON'T WANT TO COUNT IT FOR OTHER CONTACT CHANNEL(S).
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
                                        edwprodhh.hermes.master_config_plgroup as constraints_plgroup
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
                                        edwprodhh.hermes.master_config_plgroup as constraints_plgroup
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
                                        edwprodhh.hermes.master_config_plgroup as constraints_plgroup
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
                is_priority_minimum,
                marginal_fee,
                marginal_cost,
                marginal_profit,
                marginal_margin,
                rank_profit,
                rank_margin,
                rank_weighted
    from        unioned
)
, calculate_running_cost_activity_client as
(
    select      filter_running_cost_channels.*,

                sum(marginal_cost) over (partition by filter_running_cost_channels.pl_group order by rank_weighted asc)                                                                         as running_cost_client,
                case    when    running_cost_client <= constraints_plgroup.max_cost_running_client
                        then    1
                        else    0
                        end                                                                                                                                                                     as is_below_cost_client,
                

                count(*) over (partition by proposed_channel, filter_running_cost_channels.pl_group order by rank_weighted asc)                                                                as running_count_channel_client,

                case    when    proposed_channel = 'Letter'         then  case when running_count_channel_client <= constraints_plgroup.min_activity_running_letters    then 1 else 0 end
                        when    proposed_channel = 'Text Message'   then  case when running_count_channel_client <= constraints_plgroup.min_activity_running_texts      then 1 else 0 end
                        when    proposed_channel = 'VoApp'          then  case when running_count_channel_client <= constraints_plgroup.min_activity_running_voapps     then 1 else 0 end
                        when    proposed_channel = 'Email'          then  case when running_count_channel_client <= constraints_plgroup.min_activity_running_emails     then 1 else 0 end
                        else    0
                        end                                                                                                                                                                     as has_not_reached_min_activity_channel_client

    from        filter_running_cost_channels
                left join
                    edwprodhh.hermes.master_config_plgroup as constraints_plgroup
                    on filter_running_cost_channels.pl_group = constraints_plgroup.pl_group
                        
)
, filter_running_cost_channels_global as
(
    with with_flags as
    (
        select      *,
                    sum(marginal_cost) over (
                        partition by    proposed_channel
                        order by        is_below_cost_client                            desc,
                                        has_not_reached_min_activity_channel_client     desc,
                                        rank_weighted                                   asc
                    )               as running_cost_channel_global,

                    case    when    proposed_channel = 'Letter'         then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_LETTERS')
                            when    proposed_channel = 'Text Message'   then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_TEXTS')
                            when    proposed_channel = 'VoApp'          then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_VOAPPS')
                            when    proposed_channel = 'Email'          then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_EMAILS')
                            else    FALSE
                            end     as is_eligible_cost_channel_global

        from        calculate_running_cost_activity_client
    )
    select      debtor_idx,
                client_idx,
                pl_group,
                proposed_channel,
                is_priority_minimum,
                marginal_fee,
                marginal_cost,
                marginal_profit,
                marginal_margin,
                rank_profit,
                rank_margin,
                rank_weighted

    from        with_flags
    where       is_eligible_cost_channel_global
)
, filter_cost_global as
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

        from        filter_running_cost_channels_global
    )
    select      debtor_idx,
                client_idx,
                pl_group,
                proposed_channel,
                is_priority_minimum,
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
, calculate_upload_date as
(
    --  SCORE AND PROPOSE WEEKLY, SPACE OUT (FOR NOW, JUST TEXTS) VIA THROTTLED UPLOADS DAILY
    with percentiles as
    (
        select      debtor_idx,
                    edwprodhh.pub_jchang.divide(
                        row_number() over (partition by proposed_channel, pl_group order by rank_weighted asc),
                        count(*) over (partition by proposed_channel, pl_group)
                    )   as ntile
        from        filter_cost_global
    )
    --  ASSUMES RUN ON FRIDAY EVENING -> UPLOAD MONDAY THRU NEXT FRIDAY
    --  HOWEVER, UNSURE WHETHER CURRENT_DATE() WILL BE FRIDAY OR SATURDAY, SO CAUTIOUSLY TRUNCATE TO WEEK FOR CALCULATION
    select      filter_cost_global.*,
                case    when    proposed_channel in  ('Text Message', 'Letter')
                        then    case    when    percentiles.ntile >= 0
                                        and     percentiles.ntile <= 0.20
                                        then    date_trunc('week', current_date()) + 7
                                        when    percentiles.ntile >  0.20
                                        and     percentiles.ntile <= 0.40
                                        then    date_trunc('week', current_date()) + 8
                                        when    percentiles.ntile >  0.40
                                        and     percentiles.ntile <= 0.60
                                        then    date_trunc('week', current_date()) + 9
                                        when    percentiles.ntile >  0.60
                                        and     percentiles.ntile <= 0.80
                                        then    date_trunc('week', current_date()) + 10
                                        when    percentiles.ntile >  0.80
                                        and     percentiles.ntile <= 1.00
                                        then    date_trunc('week', current_date()) + 11
                                        else    date_trunc('week', current_date()) + 11
                                        end
                        when    proposed_channel in ('VoApp', 'Email')
                        then    date_trunc('week', current_date()) + 7
                        else    date_trunc('week', current_date()) + 7
                        end     as upload_date

    from        filter_cost_global
                inner join
                    percentiles
                    on filter_cost_global.debtor_idx = percentiles.debtor_idx
)
--  <--  FILTER ON SET PARAMETERS

--  FAST TRACK  -->
, fast_track as
(
    -- need to exclude debtors where a fellow packet-member is already proposed above
    with packets_already_proposed as
    (
        select      debtor.packet_idx
        from        calculate_upload_date as proposed
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on proposed.debtor_idx = debtor.debtor_idx
    )
    select      fasttrack.debtor_idx,
                fasttrack.packet_idx,
                fasttrack.proposed_channel,

                debtor.client_idx,
                debtor.pl_group

    from        edwprodhh.hermes.master_prediction_fasttrack as fasttrack
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on fasttrack.debtor_idx = debtor.debtor_idx
    where       fasttrack.packet_idx not in (select packet_idx from packets_already_proposed)
)
--  <--  FAST TRACK


, calculate_filtered as
(
    select      coalesce(pool.debtor_idx,           fast_track.debtor_idx)          as debtor_idx,

                coalesce(pool.client_idx,           fast_track.client_idx)          as client_idx,
                coalesce(pool.pl_group,             fast_track.pl_group)            as pl_group,
                coalesce(pool.proposed_channel,     fast_track.proposed_channel)    as proposed_channel,
                pool.is_priority_minimum,
                pool.marginal_fee,
                pool.marginal_cost,
                pool.marginal_profit,
                pool.marginal_margin,
                pool.rank_profit,
                pool.rank_margin,
                pool.rank_weighted,

                case    when    proposed.debtor_idx is not null
                        then    1
                        when    fast_track.debtor_idx is not null
                        then    1
                        else    0
                        end     as is_proposed_contact,
                        
                case    when    fast_track.debtor_idx is not null
                        then    1
                        else    0
                        end     as is_fasttrack,

                proposed.upload_date

    from        calculate_marginal_wide as pool
                full outer join
                    fast_track
                    on  pool.debtor_idx         = fast_track.debtor_idx
                    and pool.proposed_channel   = fast_track.proposed_channel
                left join
                    calculate_upload_date as proposed
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
    with scores_long as
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
                        'Letter',
                        'Text Message',
                        'VoApp',
                        'Email'
                    )
    )
    select      scores_long.*,

                case    when    scores_long.proposed_channel = 'Letter'         then    pool.is_priority_minimum_letters
                        when    scores_long.proposed_channel = 'Text Message'   then    pool.is_priority_minimum_texts
                        when    scores_long.proposed_channel = 'VoApp'          then    pool.is_priority_minimum_voapps
                        when    scores_long.proposed_channel = 'Email'          then    pool.is_priority_minimum_emails
                        else    0
                        end     as is_priority_minimum

    from        scores_long
                left join
                    edwprodhh.hermes.master_prediction_pool as pool
                    on  scores_long.debtor_idx = pool.debtor_idx
)
, calculate_marginal_wide as
(
    select      scores.debtor_idx,
                scores.client_idx,
                scores.pl_group,
                scores.proposed_channel,
                scores.is_priority_minimum,
                scores.score_value                                                                                                  as marginal_fee,
                channel_costs.unit_cost                                                                                             as marginal_cost,
                (marginal_fee - marginal_cost)                                                                                      as marginal_profit,
                edwprodhh.pub_jchang.divide(marginal_fee - marginal_cost, marginal_fee)                                             as marginal_margin,

                row_number() over (order by scores.is_priority_minimum desc, marginal_profit desc)                                  as rank_profit,     -- 1 is best
                row_number() over (order by scores.is_priority_minimum desc, marginal_margin desc)                                  as rank_margin,     -- 1 is best
                
                (rank_profit    * (select weight from edwprodhh.hermes.master_config_objectives where metric_name = 'Profit')) +
                (rank_margin    * (select weight from edwprodhh.hermes.master_config_objectives where metric_name = 'Margin'))
                                                                                                                                    as rank_weighted    -- 1 is best

    from        scores
                left join
                    edwprodhh.hermes.master_config_channel_costs as channel_costs
                    on scores.proposed_channel = channel_costs.contact_channel
)

-- --  ENSURING CONTACTS IN LOWER BUCKETS -->
-- ,deciles as 
-- ( 
--     select      debtor_idx,
--                 rank_weighted, 
                
--                 ntile(10) over (order by rank_weighted)                                                                             as decile 
    
--     from        calculate_marginal_wide 

-- ) 
-- , boundary_value as 
-- ( 
--     select      max(rank_weighted)                                                                                                as max_value_8

--     from        deciles 
--     where       decile = 8 

-- ) , decileweights as
-- (
--     select      decile, 
--                 decile / 28.0 as weight_fraction,
--                 count(*) as decile_count,
--                 ceil(0.07 * count(*) * (decile / 28.0)) as rows_to_take  
    
--     from        deciles
--     where       decile between 1 and 7
--     group by    decile

-- )
-- ,  random_selection as 
-- (
--     select      deciles.*,
--                 (select max_value_8 from boundary_value) - 1                                                                       as adjusted_rank_weighted, 
--                 row_number() over (partition by deciles.decile order by random()) as rn
    
--     from        deciles 
--                 inner join decileweights on deciles.decile = decileweights.decile
--     where       d.decile between 1 and 7
--     qualify     row_number() over (partition by d.decile order by random()) <= dw.rows_to_take  

-- )
-- , calculate_marginal_wide2 as 
-- (
--     select      calculate_marginal_wide.debtor_idx,
--                 calculate_marginal_wide.client_idx,
--                 calculate_marginal_wide.pl_group,
--                 calculate_marginal_wide.proposed_channel,
--                 calculate_marginal_wide.marginal_fee,
--                 calculate_marginal_wide.marginal_cost,
--                 calculate_marginal_wide.marginal_profit,
--                 calculate_marginal_wide.marginal_margin,
--                 calculate_marginal_wide.rank_profit,
--                 calculate_marginal_wide.rank_margin,
--                 case 
--                         when random_selection.debtor_idx is not null then random_selection.adjusted_rank_weighted
--                         else calculate_marginal_wide.rank_weighted 
--                 end                                                                                                                                 as adjusted_rank_weighted

--             from calculate_marginal_wide
--                 left join random_selection on random_selection.debtor_idx = calculate_marginal_wide.debtor_idx 
--             order by adjusted_rank_weighted

-- ) 


--  FILTER ON SET PARAMETERS  -->
, filter_marginals as
(
    select      *
    from        calculate_marginal_wide
    where       (
                    marginal_profit         >= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MIN_PROFIT_MARGINAL')
                    and marginal_margin     >= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MIN_MARGIN_MARGINAL')
                )
                or is_priority_minimum = 1
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

, filter_running_cost_channels as
(   
    -- THERE NEED TO BE AS MANY ITERATIONS HERE AS THERE ARE POTENTIAL & SCORED CONTACT CHANNEL OPTIONS.
    -- THIS EXISTS BECAUSE ONCE A PACKET IS SELECTED FOR ONE CONTACT CHANNEL, WE DON'T WANT TO COUNT IT FOR OTHER CONTACT CHANNEL(S).
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
                                        edwprodhh.hermes.master_config_plgroup as constraints_plgroup
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
                                        edwprodhh.hermes.master_config_plgroup as constraints_plgroup
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
                                        edwprodhh.hermes.master_config_plgroup as constraints_plgroup
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
                is_priority_minimum,
                marginal_fee,
                marginal_cost,
                marginal_profit,
                marginal_margin,
                rank_profit,
                rank_margin,
                rank_weighted
    from        unioned
)
, calculate_running_cost_activity_client as
(
    select      filter_running_cost_channels.*,

                sum(marginal_cost) over (partition by filter_running_cost_channels.pl_group order by rank_weighted asc)                                                                         as running_cost_client,
                case    when    running_cost_client <= constraints_plgroup.max_cost_running_client
                        then    1
                        else    0
                        end                                                                                                                                                                     as is_below_cost_client,
                

                count(*) over (partition by proposed_channel, filter_running_cost_channels.pl_group order by rank_weighted asc)                                                                as running_count_channel_client,

                case    when    proposed_channel = 'Letter'         then  case when running_count_channel_client <= constraints_plgroup.min_activity_running_letters    then 1 else 0 end
                        when    proposed_channel = 'Text Message'   then  case when running_count_channel_client <= constraints_plgroup.min_activity_running_texts      then 1 else 0 end
                        when    proposed_channel = 'VoApp'          then  case when running_count_channel_client <= constraints_plgroup.min_activity_running_voapps     then 1 else 0 end
                        when    proposed_channel = 'Email'          then  case when running_count_channel_client <= constraints_plgroup.min_activity_running_emails     then 1 else 0 end
                        else    0
                        end                                                                                                                                                                     as has_not_reached_min_activity_channel_client

    from        filter_running_cost_channels
                left join
                    edwprodhh.hermes.master_config_plgroup as constraints_plgroup
                    on filter_running_cost_channels.pl_group = constraints_plgroup.pl_group
                        
)
, filter_running_cost_channels_global as
(
    with with_flags as
    (
        select      *,
                    sum(marginal_cost) over (
                        partition by    proposed_channel
                        order by        is_below_cost_client                            desc,
                                        has_not_reached_min_activity_channel_client     desc,
                                        rank_weighted                                   asc
                    )               as running_cost_channel_global,

                    case    when    proposed_channel = 'Letter'         then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_LETTERS')
                            when    proposed_channel = 'Text Message'   then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_TEXTS')
                            when    proposed_channel = 'VoApp'          then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_VOAPPS')
                            when    proposed_channel = 'Email'          then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_EMAILS')
                            else    FALSE
                            end     as is_eligible_cost_channel_global

        from        calculate_running_cost_activity_client
    )
    select      debtor_idx,
                client_idx,
                pl_group,
                proposed_channel,
                is_priority_minimum,
                marginal_fee,
                marginal_cost,
                marginal_profit,
                marginal_margin,
                rank_profit,
                rank_margin,
                rank_weighted

    from        with_flags
    where       is_eligible_cost_channel_global
)
, filter_cost_global as
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

        from        filter_running_cost_channels_global
    )
    select      debtor_idx,
                client_idx,
                pl_group,
                proposed_channel,
                is_priority_minimum,
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
, calculate_upload_date as
(
    --  SCORE AND PROPOSE WEEKLY, SPACE OUT (FOR NOW, JUST TEXTS) VIA THROTTLED UPLOADS DAILY
    with percentiles as
    (
        select      debtor_idx,
                    edwprodhh.pub_jchang.divide(
                        row_number() over (partition by proposed_channel, pl_group order by rank_weighted asc),
                        count(*) over (partition by proposed_channel, pl_group)
                    )   as ntile
        from        filter_cost_global
    )
    --  ASSUMES RUN ON FRIDAY EVENING -> UPLOAD MONDAY THRU NEXT FRIDAY
    --  HOWEVER, UNSURE WHETHER CURRENT_DATE() WILL BE FRIDAY OR SATURDAY, SO CAUTIOUSLY TRUNCATE TO WEEK FOR CALCULATION
    select      filter_cost_global.*,
                case    when    proposed_channel in  ('Text Message', 'Letter')
                        then    case    when    percentiles.ntile >= 0
                                        and     percentiles.ntile <= 0.20
                                        then    date_trunc('week', current_date()) + 7
                                        when    percentiles.ntile >  0.20
                                        and     percentiles.ntile <= 0.40
                                        then    date_trunc('week', current_date()) + 8
                                        when    percentiles.ntile >  0.40
                                        and     percentiles.ntile <= 0.60
                                        then    date_trunc('week', current_date()) + 9
                                        when    percentiles.ntile >  0.60
                                        and     percentiles.ntile <= 0.80
                                        then    date_trunc('week', current_date()) + 10
                                        when    percentiles.ntile >  0.80
                                        and     percentiles.ntile <= 1.00
                                        then    date_trunc('week', current_date()) + 11
                                        else    date_trunc('week', current_date()) + 11
                                        end
                        when    proposed_channel in ('VoApp', 'Email')
                        then    date_trunc('week', current_date()) + 7
                        else    date_trunc('week', current_date()) + 7
                        end     as upload_date

    from        filter_cost_global
                inner join
                    percentiles
                    on filter_cost_global.debtor_idx = percentiles.debtor_idx
)
--  <--  FILTER ON SET PARAMETERS

--  FAST TRACK  -->
, fast_track as
(
    -- need to exclude debtors where a fellow packet-member is already proposed above
    with packets_already_proposed as
    (
        select      debtor.packet_idx
        from        calculate_upload_date as proposed
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on proposed.debtor_idx = debtor.debtor_idx
    )
    select      fasttrack.debtor_idx,
                fasttrack.packet_idx,
                fasttrack.proposed_channel,

                debtor.client_idx,
                debtor.pl_group

    from        edwprodhh.hermes.master_prediction_fasttrack as fasttrack
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on fasttrack.debtor_idx = debtor.debtor_idx
    where       fasttrack.packet_idx not in (select packet_idx from packets_already_proposed)
)
--  <--  FAST TRACK


, calculate_filtered as
(
    select      coalesce(pool.debtor_idx,           fast_track.debtor_idx)          as debtor_idx,

                coalesce(pool.client_idx,           fast_track.client_idx)          as client_idx,
                coalesce(pool.pl_group,             fast_track.pl_group)            as pl_group,
                coalesce(pool.proposed_channel,     fast_track.proposed_channel)    as proposed_channel,
                pool.is_priority_minimum,
                pool.marginal_fee,
                pool.marginal_cost,
                pool.marginal_profit,
                pool.marginal_margin,
                pool.rank_profit,
                pool.rank_margin,
                pool.rank_weighted,

                case    when    proposed.debtor_idx is not null
                        then    1
                        when    fast_track.debtor_idx is not null
                        then    1
                        else    0
                        end     as is_proposed_contact,
                        
                case    when    fast_track.debtor_idx is not null
                        then    1
                        else    0
                        end     as is_fasttrack,

                proposed.upload_date

    from        calculate_marginal_wide as pool
                full outer join
                    fast_track
                    on  pool.debtor_idx         = fast_track.debtor_idx
                    and pool.proposed_channel   = fast_track.proposed_channel
                left join
                    calculate_upload_date as proposed
                    on  pool.debtor_idx         = proposed.debtor_idx
                    and pool.proposed_channel   = proposed.proposed_channel
)
select      *
from        calculate_filtered
;