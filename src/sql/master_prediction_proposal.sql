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
                        end     as is_priority_minimum,

                pool.treatment_group,
                case when pool.treatment_group is not null then uniform(0, 9, random()) else NULL end as stratum,
                pool.batch_date,
                constraints_artificial.artificial_group,
                coalesce(constraints_artificial.artificial_group, scores_long.pl_group) as hermes_group

    from        scores_long
                left join
                    edwprodhh.hermes.master_prediction_pool as pool
                    on  scores_long.debtor_idx = pool.debtor_idx

                left join
                    edwprodhh.hermes.transform_config_artificialgroup_associations as associations
                    on scores_long.client_idx = associations.client_idx
                left join
                    edwprodhh.hermes.master_config_artificialgroup as constraints_artificial
                    on associations.artificial_group = constraints_artificial.artificial_group
)
, calculate_marginal_wide as
(
    select      scores.debtor_idx,
                scores.client_idx,
                scores.pl_group,
                scores.artificial_group,
                scores.hermes_group,
                scores.proposed_channel,
                scores.is_priority_minimum,
                scores.score_value                                                                                                  as marginal_fee,
                channel_costs.unit_cost                                                                                             as marginal_cost,
                (marginal_fee - marginal_cost)                                                                                      as marginal_profit,
                edwprodhh.pub_jchang.divide(marginal_fee - marginal_cost, marginal_fee)                                             as marginal_margin,

                -- row_number() over (order by scores.is_priority_minimum desc, case when scores.treatment_group is not null then 1 else 0 end desc, scores.stratum desc, marginal_profit desc)                                  as rank_profit,     -- 1 is best
                -- row_number() over (order by scores.is_priority_minimum desc, case when scores.treatment_group is not null then 1 else 0 end desc, scores.stratum desc, marginal_margin desc)                                  as rank_margin,     -- 1 is best
                row_number() over (order by     scores.is_priority_minimum desc,

                                                --  Prioritize hitting SOI contractual requirement for Priority Minimums.
                                                case    when    scores.is_priority_minimum = 1
                                                        then    case    when    scores.pl_group in ('STATE OF IL - DOR - 3P', 'STATE OF IL - DOR - 3P-2')
                                                                        then    1
                                                                        else    0
                                                                        end
                                                        else    0
                                                        end     desc,
                                                case    when    scores.is_priority_minimum = 1
                                                        then    case    when    scores.pl_group in ('STATE OF IL - DOR - 3P', 'STATE OF IL - DOR - 3P-2')
                                                                        then    scores.batch_date
                                                                        else    current_date()
                                                                        end
                                                        else    current_date()
                                                        end     desc,

                                                marginal_profit desc
                                                                                                                ) as rank_profit,     -- stratum introduces jitter and increases equitable allocation to experiment groups
                row_number() over (order by     scores.is_priority_minimum desc,

                                                --  Prioritize hitting SOI contractual requirement for Priority Minimums.
                                                case    when    scores.is_priority_minimum = 1
                                                        then    case    when    scores.pl_group in ('STATE OF IL - DOR - 3P', 'STATE OF IL - DOR - 3P-2')
                                                                        then    1
                                                                        else    0
                                                                        end
                                                        else    0
                                                        end     desc,
                                                case    when    scores.is_priority_minimum = 1
                                                        then    case    when    scores.pl_group in ('STATE OF IL - DOR - 3P', 'STATE OF IL - DOR - 3P-2')
                                                                        then    scores.batch_date
                                                                        else    current_date()
                                                                        end
                                                        else    current_date()
                                                        end     desc,

                                                marginal_margin desc
                                                                                                                ) as rank_margin,     -- stratum introduces jitter and increases equitable allocation to experiment groups

                
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
                                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_letters,
                                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_texts,
                                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_voapps,
                                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_emails,

                                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                                    running_cost_letters        <= coalesce(constraints_artificial.max_cost_running_letters,    constraints_plgroup.max_cost_running_letters)   / 5 as is_eligible_cost_letters,
                                    running_cost_texts          <= coalesce(constraints_artificial.max_cost_running_texts,      constraints_plgroup.max_cost_running_texts)     / 5 as is_eligible_cost_texts,
                                    running_cost_voapps         <= coalesce(constraints_artificial.max_cost_running_voapps,     constraints_plgroup.max_cost_running_voapps)    / 5 as is_eligible_cost_voapps,
                                    running_cost_emails         <= coalesce(constraints_artificial.max_cost_running_emails,     constraints_plgroup.max_cost_running_emails)    / 5 as is_eligible_cost_emails

                        from        calculate_packet_rankings

                                    left join
                                        edwprodhh.hermes.transform_config_artificialgroup_associations as associations
                                        on calculate_packet_rankings.client_idx = associations.client_idx
                                    left join
                                        edwprodhh.hermes.master_config_artificialgroup as constraints_artificial
                                        on associations.artificial_group = constraints_artificial.artificial_group

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
                                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_letters,
                                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_texts,
                                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_voapps,
                                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_emails,

                                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                                    running_cost_letters        <= ((coalesce(constraints_artificial.max_cost_running_letters,   constraints_plgroup.max_cost_running_letters)   / 5) - (select max(running_cost_letters)     from iteration_1))     as is_eligible_cost_letters,
                                    running_cost_texts          <= ((coalesce(constraints_artificial.max_cost_running_texts,     constraints_plgroup.max_cost_running_texts)     / 5) - (select max(running_cost_texts)       from iteration_1))     as is_eligible_cost_texts,
                                    running_cost_voapps         <= ((coalesce(constraints_artificial.max_cost_running_voapps,    constraints_plgroup.max_cost_running_voapps)    / 5) - (select max(running_cost_voapps)      from iteration_1))     as is_eligible_cost_voapps,
                                    running_cost_emails         <= ((coalesce(constraints_artificial.max_cost_running_emails,    constraints_plgroup.max_cost_running_emails)    / 5) - (select max(running_cost_emails)      from iteration_1))     as is_eligible_cost_emails

                        from        calculate_packet_rankings

                                    left join
                                        edwprodhh.hermes.transform_config_artificialgroup_associations as associations
                                        on calculate_packet_rankings.client_idx = associations.client_idx
                                    left join
                                        edwprodhh.hermes.master_config_artificialgroup as constraints_artificial
                                        on associations.artificial_group = constraints_artificial.artificial_group

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
                                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_letters,
                                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_texts,
                                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_voapps,
                                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_emails,

                                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                                    running_cost_letters        <= ((coalesce(constraints_artificial.max_cost_running_letters,   constraints_plgroup.max_cost_running_letters)   / 5) - (select max(running_cost_letters)     from iteration_1)  - (select max(running_cost_letters)     from iteration_2))  as is_eligible_cost_letters,
                                    running_cost_texts          <= ((coalesce(constraints_artificial.max_cost_running_texts,     constraints_plgroup.max_cost_running_texts)     / 5) - (select max(running_cost_texts)       from iteration_1)  - (select max(running_cost_texts)       from iteration_2))  as is_eligible_cost_texts,
                                    running_cost_voapps         <= ((coalesce(constraints_artificial.max_cost_running_voapps,    constraints_plgroup.max_cost_running_voapps)    / 5) - (select max(running_cost_voapps)      from iteration_1)  - (select max(running_cost_voapps)      from iteration_2))  as is_eligible_cost_voapps,
                                    running_cost_emails         <= ((coalesce(constraints_artificial.max_cost_running_emails,    constraints_plgroup.max_cost_running_emails)    / 5) - (select max(running_cost_emails)      from iteration_1)  - (select max(running_cost_emails)      from iteration_2))  as is_eligible_cost_emails

                        from        calculate_packet_rankings

                                    left join
                                        edwprodhh.hermes.transform_config_artificialgroup_associations as associations
                                        on calculate_packet_rankings.client_idx = associations.client_idx
                                    left join
                                        edwprodhh.hermes.master_config_artificialgroup as constraints_artificial
                                        on associations.artificial_group = constraints_artificial.artificial_group

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
                artificial_group,
                hermes_group,
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

                sum(marginal_cost) over (partition by filter_running_cost_channels.hermes_group order by rank_weighted asc)                                                                         as running_cost_client,
                case    when    running_cost_client <= coalesce(constraints_artificial.max_cost_running_client, constraints_plgroup.max_cost_running_client) / 5
                        then    1
                        else    0
                        end                                                                                                                                                                     as is_below_cost_client,
                

                -- count(*) over (partition by proposed_channel, filter_running_cost_channels.hermes_group order by rank_weighted asc)                                                                as running_count_channel_client,
                sum(marginal_cost) over (partition by proposed_channel, filter_running_cost_channels.hermes_group order by rank_weighted asc)                                                                as running_cost_channel_client,

                case    when    proposed_channel = 'Letter'         then  case when running_cost_channel_client <= coalesce(constraints_artificial.min_cost_running_letters,    constraints_plgroup.min_cost_running_letters)   / 5 then 1 else 0 end
                        when    proposed_channel = 'Text Message'   then  case when running_cost_channel_client <= coalesce(constraints_artificial.min_cost_running_texts,      constraints_plgroup.min_cost_running_texts)     / 5 then 1 else 0 end
                        when    proposed_channel = 'VoApp'          then  case when running_cost_channel_client <= coalesce(constraints_artificial.min_cost_running_voapps,     constraints_plgroup.min_cost_running_voapps)    / 5 then 1 else 0 end
                        when    proposed_channel = 'Email'          then  case when running_cost_channel_client <= coalesce(constraints_artificial.min_cost_running_emails,     constraints_plgroup.min_cost_running_emails)    / 5 then 1 else 0 end
                        else    0
                        end                                                                                                                                                                     as has_not_reached_min_cost_channel_client

    from        filter_running_cost_channels

                left join
                    edwprodhh.hermes.transform_config_artificialgroup_associations as associations
                    on filter_running_cost_channels.client_idx = associations.client_idx
                left join
                    edwprodhh.hermes.master_config_artificialgroup as constraints_artificial
                    on associations.artificial_group = constraints_artificial.artificial_group

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
                                        has_not_reached_min_cost_channel_client         desc,
                                        rank_weighted                                   asc
                    )               as running_cost_channel_global,

                    case    when    proposed_channel = 'Letter'         then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_LETTERS')   / 5
                            when    proposed_channel = 'Text Message'   then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_TEXTS')     / 5
                            when    proposed_channel = 'VoApp'          then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_VOAPPS')    / 5
                            when    proposed_channel = 'Email'          then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_EMAILS')    / 5
                            else    FALSE
                            end     as is_eligible_cost_channel_global

        from        calculate_running_cost_activity_client
    )
    select      debtor_idx,
                client_idx,
                pl_group,
                artificial_group,
                hermes_group,
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
                    running_cost            <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_TOTAL')   / 5     as is_eligible_cost,
                    running_margin          >= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MIN_MARGIN_RUNNING_TOTAL')         as is_eligible_margin

        from        filter_running_cost_channels_global
    )
    select      debtor_idx,
                client_idx,
                pl_group,
                artificial_group,
                hermes_group,
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
    select      *,
                case    when    extract(dow from current_date()) in (1,2,3,4)
                        then    current_date() + 1
                        when    extract(dow from current_date()) in (5,6,0)
                        then    dateadd(week, 1, date_trunc('week', current_date()))
                        end     as upload_date
    from        filter_cost_global
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
                pool.artificial_group,
                pool.hermes_group,
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
, calculate_template as
(
    select      calculate_filtered.*,

                calculate_filtered.marginal_fee + uniform(-0.0001::decimal(9,9), 0.0001::decimal(9,9), random()) as marginal_fee_jitter,


                case    when    calculate_filtered.is_proposed_contact  = 1
                        and     calculate_filtered.proposed_channel     = 'Text Message'
                        and     pool.pass_validation_requirement_offer  = 1
                        then    case    when    calculate_filtered.pl_group = 'CITY OF WASHINGTON DC - DMV - 3P'
                                        then    case    when    pool.balance_dimdebtor_packet >= 350
                                                        then    1
                                                        else    0
                                                        end
                                        when    calculate_filtered.pl_group = 'MOUNT SINAI - 3P'
                                        then    case    when    pool.batch_date < current_date() - 60
                                                        then    1
                                                        else    0
                                                        end
                                        when    calculate_filtered.pl_group = 'ST ELIZABETH HEALTHCARE - 3P'
                                        then    case    when    pool.batch_date < '2024-01-01'
                                                        then    1
                                                        else    0
                                                        end
                                        when    calculate_filtered.pl_group in (
                                                    'COLUMBIA DOCTORS - 3P',                        --
                                                    'COUNTY OF MCHENRY IL - 3P',                    --
                                                    'COUNTY OF WINNEBAGO IL - 3P',                  --
                                                    'FRANCISCAN HEALTH - 3P',                       --
                                                    'IU HEALTH - 3P',                               --
                                                    'NORTHSHORE UNIV HEALTH - 3P',                  --
                                                    'NORTHWESTERN MEDICINE - 3P',                   --
                                                    'NW COMM HOSP - 3P-2',                          --
                                                    'NW COMM HOSP - 3P',                            --
                                                    'PROVIDENCE ST JOSEPH HEALTH - 3P-2',           --
                                                    'PROVIDENCE ST JOSEPH HEALTH - 3P',             --
                                                    -- 'STATE OF KS - DOR - 3P',                       --
                                                    'SWEDISH HOSPITAL - 3P',                        --
                                                    'U OF CHICAGO MEDICAL - 3P',                    --
                                                    'U OF CINCINNATI HEALTH SYSTEM - 3P',           --
                                                    'UNIVERSAL HEALTH SERVICES - 3P',               --
                                                    'WEILL CORNELL PHY - 3P'                        --
                                                )
                                        then    1
                                        else    0
                                        end
                        else    0
                        end     as is_eligible_sif,

                
                case    when    calculate_filtered.is_proposed_contact  = 1
                        and     calculate_filtered.proposed_channel     = 'Text Message'
                        and     pool.pass_validation_requirement_offer  = 1
                        then    case    when    calculate_filtered.pl_group in (
                                                    'CITY OF LA CA - FINANCE - 3P',
                                                    'CITY OF PHILADELPHIA PA - MISC - 3P',
                                                    'CITY OF PHILADELPHIA PA - PARKING - 3P',
                                                    'CITY OF SEATTLE WA - MUNI COURT - 3P',
                                                    'CITY OF SEATTLE WA - MUNI COURT - 3P-2',
                                                    'COUNTY OF CHAMPAIGN IL - 3P',
                                                    'COUNTY OF DEKALB IL - 3P',
                                                    'COUNTY OF DUPAGE IL - 3P',
                                                    'COUNTY OF DUVAL FL - 3P',
                                                    'COUNTY OF KANE IL - 3P',
                                                    'COUNTY OF KANKAKEE IL - 3P',
                                                    'COUNTY OF KENDALL IL - 3P',
                                                    'COUNTY OF LAKE IL - 3P',
                                                    'COUNTY OF LASALLE IL - 3P',
                                                    'COUNTY OF LEE IL - 3P',
                                                    'COUNTY OF MADISON IL - 3P',
                                                    'COUNTY OF MCHENRY IL - 3P',
                                                    'COUNTY OF POLK FL - 3P',
                                                    'COUNTY OF SANGAMON IL - 3P',
                                                    'COUNTY OF SARASOTA FL - 3P',
                                                    'COUNTY OF VENTURA CA - 3P',
                                                    'COUNTY OF WINNEBAGO IL - 3P',
                                                    'ELIZABETH RIVER CROSSINGS - 3P',
                                                    'STATE OF IL - DOR - 3P',
                                                    'STATE OF IL - DOR - 3P-2',
                                                    'STATE OF KS - DOR - 3P',
                                                    'STATE OF OK - TAX COMMISSION - 3P',
                                                    'STATE OF PA - TURNPIKE COMMISSION - 3P',
                                                    'CARLE HEALTHCARE - 3P',
                                                    'CARLE HEALTHCARE - 3P-2',
                                                    'FRANCISCAN HEALTH - 3P',
                                                    'IU HEALTH - 3P',
                                                    'MCLEOD HEALTH - 3P',
                                                    'NORTHSHORE UNIV HEALTH - 3P',
                                                    'NORTHWESTERN MEDICINE - 3P',
                                                    'NW COMM HOSP - 3P',
                                                    'NW COMM HOSP - 3P-2',
                                                    'PALOS HEALTH - 3P',
                                                    'PRISMA HEALTH - 3P',
                                                    'PRISMA HEALTH - 3P-2',
                                                    'PRISMA HEALTH UNIVERSITY - 3P',
                                                    'PROVIDENCE ST JOSEPH HEALTH - 3P',
                                                    'PROVIDENCE ST JOSEPH HEALTH - 3P-2',
                                                    'SWEDISH HOSPITAL - 3P',
                                                    'U OF CHICAGO MEDICAL - 3P'
                                                )
                                        then    1
                                        else    0
                                        end
                        else    0
                        end     as is_eligible_tax,



                count(case when is_eligible_sif = 1 then 1 end) over (partition by calculate_filtered.pl_group order by marginal_fee_jitter desc)   as rn,

                edwprodhh.pub_jchang.divide(rn, count(case when is_eligible_sif = 1 then 1 end) over (partition by calculate_filtered.pl_group))    as percentile,

                case    when    is_proposed_contact = 1
                        then    case    when    calculate_filtered.proposed_channel = 'Text Message'
                                        then    case    when    is_eligible_sif = 1
                                                        then    case    when    percentile >= 0.50
                                                                        then    case    when    mod(rn, 2) = 1
                                                                                        then    'SIF-SIF'
                                                                                        else    case    when    is_eligible_tax = 1
                                                                                                        then    'SIF-TAX'
                                                                                                        else    'MAIN'
                                                                                                        end
                                                                                        end
                                                                        else    case    when    is_eligible_tax = 1
                                                                                        then    'TAX'
                                                                                        else    'MAIN'
                                                                                        end
                                                                        end
                                                        when    is_eligible_tax = 1
                                                        then    'TAX'
                                                        else    'MAIN'
                                                        end
                                        else    NULL
                                        end
                        else    NULL
                        end     as template

    from        calculate_filtered
                left join
                    edwprodhh.hermes.master_prediction_pool as pool
                    on calculate_filtered.debtor_idx = pool.debtor_idx
)
select      *
            exclude (rn, percentile, marginal_fee_jitter, is_eligible_sif)
from        calculate_template
;



create or replace task
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
                        end     as is_priority_minimum,

                pool.treatment_group,
                case when pool.treatment_group is not null then uniform(0, 9, random()) else NULL end as stratum,
                pool.batch_date,
                constraints_artificial.artificial_group,
                coalesce(constraints_artificial.artificial_group, scores_long.pl_group) as hermes_group

    from        scores_long
                left join
                    edwprodhh.hermes.master_prediction_pool as pool
                    on  scores_long.debtor_idx = pool.debtor_idx

                left join
                    edwprodhh.hermes.transform_config_artificialgroup_associations as associations
                    on scores_long.client_idx = associations.client_idx
                left join
                    edwprodhh.hermes.master_config_artificialgroup as constraints_artificial
                    on associations.artificial_group = constraints_artificial.artificial_group
)
, calculate_marginal_wide as
(
    select      scores.debtor_idx,
                scores.client_idx,
                scores.pl_group,
                scores.artificial_group,
                scores.hermes_group,
                scores.proposed_channel,
                scores.is_priority_minimum,
                scores.score_value                                                                                                  as marginal_fee,
                channel_costs.unit_cost                                                                                             as marginal_cost,
                (marginal_fee - marginal_cost)                                                                                      as marginal_profit,
                edwprodhh.pub_jchang.divide(marginal_fee - marginal_cost, marginal_fee)                                             as marginal_margin,

                -- row_number() over (order by scores.is_priority_minimum desc, case when scores.treatment_group is not null then 1 else 0 end desc, scores.stratum desc, marginal_profit desc)                                  as rank_profit,     -- 1 is best
                -- row_number() over (order by scores.is_priority_minimum desc, case when scores.treatment_group is not null then 1 else 0 end desc, scores.stratum desc, marginal_margin desc)                                  as rank_margin,     -- 1 is best
                row_number() over (order by     scores.is_priority_minimum desc,

                                                --  Prioritize hitting SOI contractual requirement for Priority Minimums.
                                                case    when    scores.is_priority_minimum = 1
                                                        then    case    when    scores.pl_group in ('STATE OF IL - DOR - 3P', 'STATE OF IL - DOR - 3P-2')
                                                                        then    1
                                                                        else    0
                                                                        end
                                                        else    0
                                                        end     desc,
                                                case    when    scores.is_priority_minimum = 1
                                                        then    case    when    scores.pl_group in ('STATE OF IL - DOR - 3P', 'STATE OF IL - DOR - 3P-2')
                                                                        then    scores.batch_date
                                                                        else    current_date()
                                                                        end
                                                        else    current_date()
                                                        end     desc,

                                                marginal_profit desc
                                                                                                                ) as rank_profit,     -- stratum introduces jitter and increases equitable allocation to experiment groups
                row_number() over (order by     scores.is_priority_minimum desc,

                                                --  Prioritize hitting SOI contractual requirement for Priority Minimums.
                                                case    when    scores.is_priority_minimum = 1
                                                        then    case    when    scores.pl_group in ('STATE OF IL - DOR - 3P', 'STATE OF IL - DOR - 3P-2')
                                                                        then    1
                                                                        else    0
                                                                        end
                                                        else    0
                                                        end     desc,
                                                case    when    scores.is_priority_minimum = 1
                                                        then    case    when    scores.pl_group in ('STATE OF IL - DOR - 3P', 'STATE OF IL - DOR - 3P-2')
                                                                        then    scores.batch_date
                                                                        else    current_date()
                                                                        end
                                                        else    current_date()
                                                        end     desc,

                                                marginal_margin desc
                                                                                                                ) as rank_margin,     -- stratum introduces jitter and increases equitable allocation to experiment groups

                
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
                                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_letters,
                                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_texts,
                                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_voapps,
                                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_emails,

                                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                                    running_cost_letters        <= coalesce(constraints_artificial.max_cost_running_letters,    constraints_plgroup.max_cost_running_letters)   / 5 as is_eligible_cost_letters,
                                    running_cost_texts          <= coalesce(constraints_artificial.max_cost_running_texts,      constraints_plgroup.max_cost_running_texts)     / 5 as is_eligible_cost_texts,
                                    running_cost_voapps         <= coalesce(constraints_artificial.max_cost_running_voapps,     constraints_plgroup.max_cost_running_voapps)    / 5 as is_eligible_cost_voapps,
                                    running_cost_emails         <= coalesce(constraints_artificial.max_cost_running_emails,     constraints_plgroup.max_cost_running_emails)    / 5 as is_eligible_cost_emails

                        from        calculate_packet_rankings

                                    left join
                                        edwprodhh.hermes.transform_config_artificialgroup_associations as associations
                                        on calculate_packet_rankings.client_idx = associations.client_idx
                                    left join
                                        edwprodhh.hermes.master_config_artificialgroup as constraints_artificial
                                        on associations.artificial_group = constraints_artificial.artificial_group

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
                                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_letters,
                                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_texts,
                                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_voapps,
                                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_emails,

                                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                                    running_cost_letters        <= ((coalesce(constraints_artificial.max_cost_running_letters,   constraints_plgroup.max_cost_running_letters)   / 5) - (select max(running_cost_letters)     from iteration_1))     as is_eligible_cost_letters,
                                    running_cost_texts          <= ((coalesce(constraints_artificial.max_cost_running_texts,     constraints_plgroup.max_cost_running_texts)     / 5) - (select max(running_cost_texts)       from iteration_1))     as is_eligible_cost_texts,
                                    running_cost_voapps         <= ((coalesce(constraints_artificial.max_cost_running_voapps,    constraints_plgroup.max_cost_running_voapps)    / 5) - (select max(running_cost_voapps)      from iteration_1))     as is_eligible_cost_voapps,
                                    running_cost_emails         <= ((coalesce(constraints_artificial.max_cost_running_emails,    constraints_plgroup.max_cost_running_emails)    / 5) - (select max(running_cost_emails)      from iteration_1))     as is_eligible_cost_emails

                        from        calculate_packet_rankings

                                    left join
                                        edwprodhh.hermes.transform_config_artificialgroup_associations as associations
                                        on calculate_packet_rankings.client_idx = associations.client_idx
                                    left join
                                        edwprodhh.hermes.master_config_artificialgroup as constraints_artificial
                                        on associations.artificial_group = constraints_artificial.artificial_group

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
                                    sum(case when proposed_channel = 'Letter'           then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_letters,
                                    sum(case when proposed_channel = 'Text Message'     then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_texts,
                                    sum(case when proposed_channel = 'VoApp'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_voapps,
                                    sum(case when proposed_channel = 'Email'            then marginal_cost          else 0 end) over (partition by calculate_packet_rankings.hermes_group order by rank_weighted asc)    as running_cost_emails,

                                    --  ELIGIBILITY FLAGS = F(RUNNING COST, RUNNING MARGIN)
                                    running_cost_letters        <= ((coalesce(constraints_artificial.max_cost_running_letters,   constraints_plgroup.max_cost_running_letters)   / 5) - (select max(running_cost_letters)     from iteration_1)  - (select max(running_cost_letters)     from iteration_2))  as is_eligible_cost_letters,
                                    running_cost_texts          <= ((coalesce(constraints_artificial.max_cost_running_texts,     constraints_plgroup.max_cost_running_texts)     / 5) - (select max(running_cost_texts)       from iteration_1)  - (select max(running_cost_texts)       from iteration_2))  as is_eligible_cost_texts,
                                    running_cost_voapps         <= ((coalesce(constraints_artificial.max_cost_running_voapps,    constraints_plgroup.max_cost_running_voapps)    / 5) - (select max(running_cost_voapps)      from iteration_1)  - (select max(running_cost_voapps)      from iteration_2))  as is_eligible_cost_voapps,
                                    running_cost_emails         <= ((coalesce(constraints_artificial.max_cost_running_emails,    constraints_plgroup.max_cost_running_emails)    / 5) - (select max(running_cost_emails)      from iteration_1)  - (select max(running_cost_emails)      from iteration_2))  as is_eligible_cost_emails

                        from        calculate_packet_rankings

                                    left join
                                        edwprodhh.hermes.transform_config_artificialgroup_associations as associations
                                        on calculate_packet_rankings.client_idx = associations.client_idx
                                    left join
                                        edwprodhh.hermes.master_config_artificialgroup as constraints_artificial
                                        on associations.artificial_group = constraints_artificial.artificial_group

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
                artificial_group,
                hermes_group,
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

                sum(marginal_cost) over (partition by filter_running_cost_channels.hermes_group order by rank_weighted asc)                                                                         as running_cost_client,
                case    when    running_cost_client <= coalesce(constraints_artificial.max_cost_running_client, constraints_plgroup.max_cost_running_client) / 5
                        then    1
                        else    0
                        end                                                                                                                                                                     as is_below_cost_client,
                

                -- count(*) over (partition by proposed_channel, filter_running_cost_channels.hermes_group order by rank_weighted asc)                                                                as running_count_channel_client,
                sum(marginal_cost) over (partition by proposed_channel, filter_running_cost_channels.hermes_group order by rank_weighted asc)                                                                as running_cost_channel_client,

                case    when    proposed_channel = 'Letter'         then  case when running_cost_channel_client <= coalesce(constraints_artificial.min_cost_running_letters,    constraints_plgroup.min_cost_running_letters)   / 5 then 1 else 0 end
                        when    proposed_channel = 'Text Message'   then  case when running_cost_channel_client <= coalesce(constraints_artificial.min_cost_running_texts,      constraints_plgroup.min_cost_running_texts)     / 5 then 1 else 0 end
                        when    proposed_channel = 'VoApp'          then  case when running_cost_channel_client <= coalesce(constraints_artificial.min_cost_running_voapps,     constraints_plgroup.min_cost_running_voapps)    / 5 then 1 else 0 end
                        when    proposed_channel = 'Email'          then  case when running_cost_channel_client <= coalesce(constraints_artificial.min_cost_running_emails,     constraints_plgroup.min_cost_running_emails)    / 5 then 1 else 0 end
                        else    0
                        end                                                                                                                                                                     as has_not_reached_min_cost_channel_client

    from        filter_running_cost_channels

                left join
                    edwprodhh.hermes.transform_config_artificialgroup_associations as associations
                    on filter_running_cost_channels.client_idx = associations.client_idx
                left join
                    edwprodhh.hermes.master_config_artificialgroup as constraints_artificial
                    on associations.artificial_group = constraints_artificial.artificial_group

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
                                        has_not_reached_min_cost_channel_client         desc,
                                        rank_weighted                                   asc
                    )               as running_cost_channel_global,

                    case    when    proposed_channel = 'Letter'         then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_LETTERS')   / 5
                            when    proposed_channel = 'Text Message'   then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_TEXTS')     / 5
                            when    proposed_channel = 'VoApp'          then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_VOAPPS')    / 5
                            when    proposed_channel = 'Email'          then  running_cost_channel_global <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_EMAILS')    / 5
                            else    FALSE
                            end     as is_eligible_cost_channel_global

        from        calculate_running_cost_activity_client
    )
    select      debtor_idx,
                client_idx,
                pl_group,
                artificial_group,
                hermes_group,
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
                    running_cost            <= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MAX_COST_RUNNING_TOTAL')   / 5     as is_eligible_cost,
                    running_margin          >= (select value from edwprodhh.hermes.master_config_constraints_global where constraint_name = 'MIN_MARGIN_RUNNING_TOTAL')         as is_eligible_margin

        from        filter_running_cost_channels_global
    )
    select      debtor_idx,
                client_idx,
                pl_group,
                artificial_group,
                hermes_group,
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
    select      *,
                case    when    extract(dow from current_date()) in (1,2,3,4)
                        then    current_date() + 1
                        when    extract(dow from current_date()) in (5,6,0)
                        then    dateadd(week, 1, date_trunc('week', current_date()))
                        end     as upload_date
    from        filter_cost_global
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
                pool.artificial_group,
                pool.hermes_group,
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
, calculate_template as
(
    select      calculate_filtered.*,

                calculate_filtered.marginal_fee + uniform(-0.0001::decimal(9,9), 0.0001::decimal(9,9), random()) as marginal_fee_jitter,


                case    when    calculate_filtered.is_proposed_contact  = 1
                        and     calculate_filtered.proposed_channel     = 'Text Message'
                        and     pool.pass_validation_requirement_offer  = 1
                        then    case    when    calculate_filtered.pl_group = 'CITY OF WASHINGTON DC - DMV - 3P'
                                        then    case    when    pool.balance_dimdebtor_packet >= 350
                                                        then    1
                                                        else    0
                                                        end
                                        when    calculate_filtered.pl_group = 'MOUNT SINAI - 3P'
                                        then    case    when    pool.batch_date < current_date() - 60
                                                        then    1
                                                        else    0
                                                        end
                                        when    calculate_filtered.pl_group = 'ST ELIZABETH HEALTHCARE - 3P'
                                        then    case    when    pool.batch_date < '2024-01-01'
                                                        then    1
                                                        else    0
                                                        end
                                        when    calculate_filtered.pl_group in (
                                                    'COLUMBIA DOCTORS - 3P',                        --
                                                    'COUNTY OF MCHENRY IL - 3P',                    --
                                                    'COUNTY OF WINNEBAGO IL - 3P',                  --
                                                    'FRANCISCAN HEALTH - 3P',                       --
                                                    'IU HEALTH - 3P',                               --
                                                    'NORTHSHORE UNIV HEALTH - 3P',                  --
                                                    'NORTHWESTERN MEDICINE - 3P',                   --
                                                    'NW COMM HOSP - 3P-2',                          --
                                                    'NW COMM HOSP - 3P',                            --
                                                    'PROVIDENCE ST JOSEPH HEALTH - 3P-2',           --
                                                    'PROVIDENCE ST JOSEPH HEALTH - 3P',             --
                                                    -- 'STATE OF KS - DOR - 3P',                       --
                                                    'SWEDISH HOSPITAL - 3P',                        --
                                                    'U OF CHICAGO MEDICAL - 3P',                    --
                                                    'U OF CINCINNATI HEALTH SYSTEM - 3P',           --
                                                    'UNIVERSAL HEALTH SERVICES - 3P',               --
                                                    'WEILL CORNELL PHY - 3P'                        --
                                                )
                                        then    1
                                        else    0
                                        end
                        else    0
                        end     as is_eligible_sif,

                
                case    when    calculate_filtered.is_proposed_contact  = 1
                        and     calculate_filtered.proposed_channel     = 'Text Message'
                        and     pool.pass_validation_requirement_offer  = 1
                        then    case    when    calculate_filtered.pl_group in (
                                                    'CITY OF LA CA - FINANCE - 3P',
                                                    'CITY OF PHILADELPHIA PA - MISC - 3P',
                                                    'CITY OF PHILADELPHIA PA - PARKING - 3P',
                                                    'CITY OF SEATTLE WA - MUNI COURT - 3P',
                                                    'CITY OF SEATTLE WA - MUNI COURT - 3P-2',
                                                    'COUNTY OF CHAMPAIGN IL - 3P',
                                                    'COUNTY OF DEKALB IL - 3P',
                                                    'COUNTY OF DUPAGE IL - 3P',
                                                    'COUNTY OF DUVAL FL - 3P',
                                                    'COUNTY OF KANE IL - 3P',
                                                    'COUNTY OF KANKAKEE IL - 3P',
                                                    'COUNTY OF KENDALL IL - 3P',
                                                    'COUNTY OF LAKE IL - 3P',
                                                    'COUNTY OF LASALLE IL - 3P',
                                                    'COUNTY OF LEE IL - 3P',
                                                    'COUNTY OF MADISON IL - 3P',
                                                    'COUNTY OF MCHENRY IL - 3P',
                                                    'COUNTY OF POLK FL - 3P',
                                                    'COUNTY OF SANGAMON IL - 3P',
                                                    'COUNTY OF SARASOTA FL - 3P',
                                                    'COUNTY OF VENTURA CA - 3P',
                                                    'COUNTY OF WINNEBAGO IL - 3P',
                                                    'ELIZABETH RIVER CROSSINGS - 3P',
                                                    'STATE OF IL - DOR - 3P',
                                                    'STATE OF IL - DOR - 3P-2',
                                                    'STATE OF KS - DOR - 3P',
                                                    'STATE OF OK - TAX COMMISSION - 3P',
                                                    'STATE OF PA - TURNPIKE COMMISSION - 3P',
                                                    'CARLE HEALTHCARE - 3P',
                                                    'CARLE HEALTHCARE - 3P-2',
                                                    'FRANCISCAN HEALTH - 3P',
                                                    'IU HEALTH - 3P',
                                                    'MCLEOD HEALTH - 3P',
                                                    'NORTHSHORE UNIV HEALTH - 3P',
                                                    'NORTHWESTERN MEDICINE - 3P',
                                                    'NW COMM HOSP - 3P',
                                                    'NW COMM HOSP - 3P-2',
                                                    'PALOS HEALTH - 3P',
                                                    'PRISMA HEALTH - 3P',
                                                    'PRISMA HEALTH - 3P-2',
                                                    'PRISMA HEALTH UNIVERSITY - 3P',
                                                    'PROVIDENCE ST JOSEPH HEALTH - 3P',
                                                    'PROVIDENCE ST JOSEPH HEALTH - 3P-2',
                                                    'SWEDISH HOSPITAL - 3P',
                                                    'U OF CHICAGO MEDICAL - 3P'
                                                )
                                        then    1
                                        else    0
                                        end
                        else    0
                        end     as is_eligible_tax,



                count(case when is_eligible_sif = 1 then 1 end) over (partition by calculate_filtered.pl_group order by marginal_fee_jitter desc)   as rn,

                edwprodhh.pub_jchang.divide(rn, count(case when is_eligible_sif = 1 then 1 end) over (partition by calculate_filtered.pl_group))    as percentile,

                case    when    is_proposed_contact = 1
                        then    case    when    calculate_filtered.proposed_channel = 'Text Message'
                                        then    case    when    is_eligible_sif = 1
                                                        then    case    when    percentile >= 0.50
                                                                        then    case    when    mod(rn, 2) = 1
                                                                                        then    'SIF-SIF'
                                                                                        else    case    when    is_eligible_tax = 1
                                                                                                        then    'SIF-TAX'
                                                                                                        else    'MAIN'
                                                                                                        end
                                                                                        end
                                                                        else    case    when    is_eligible_tax = 1
                                                                                        then    'TAX'
                                                                                        else    'MAIN'
                                                                                        end
                                                                        end
                                                        when    is_eligible_tax = 1
                                                        then    'TAX'
                                                        else    'MAIN'
                                                        end
                                        else    NULL
                                        end
                        else    NULL
                        end     as template

    from        calculate_filtered
                left join
                    edwprodhh.hermes.master_prediction_pool as pool
                    on calculate_filtered.debtor_idx = pool.debtor_idx
)
select      *
            exclude (rn, percentile, marginal_fee_jitter, is_eligible_sif)
from        calculate_template
;