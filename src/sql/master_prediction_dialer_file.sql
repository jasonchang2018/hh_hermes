with list_rankings as
(
    with calculate_list_summary as
    (
        select      case    when    extract(hour from callplacedtime) >= 7
                            and     extract(hour from callplacedtime) <= 9
                            then    'A'
                            when    extract(hour from callplacedtime) >= 10
                            and     extract(hour from callplacedtime) <= 11
                            then    'B'
                            when    extract(hour from callplacedtime) >= 12
                            and     extract(hour from callplacedtime) <= 12
                            then    'C'
                            when    extract(hour from callplacedtime) >= 13
                            and     extract(hour from callplacedtime) <= 15
                            then    'D'
                            when    extract(hour from callplacedtime) >= 16
                            and     extract(hour from callplacedtime) <= 19
                            then    'E'
                            end     as list_name,
                    edwprodhh.pub_jchang.divide(sum(rpc), count(*)) as rpc_rate,
                    count(*)                                        as n
        from        edwprodhh.pub_jchang.master_calls
        where       calldirection_detail = 'Dialer-Agent'
                    and callplacedtime >= dateadd(month, -3, date_trunc('month', current_date()))
                    and callplacedtime <  date_trunc('month', current_date())
                    and extract(hour from callplacedtime) between 7 and 19
        group by    1
        order by    1
    )
    , calculate_list_priority as
    (
        select      *,
                    n / sum(n) over ()                          as p,
                    row_number() over (order by rpc_rate desc)  as list_priority
        from        calculate_list_summary
    )
    , calculate_list_jitter as
    (
        select      *,
                    row_number() over (order by list_priority + uniform(-1, 1, random()) asc, rpc_rate desc) as list_priority_jitter
        from        calculate_list_priority

    )
    , calculate_list_cdf as
    (
        select      *,
                    sum(p) over (order by list_priority_jitter asc) as p_cdf
        from        calculate_list_jitter
    )
    , calculate_list_percentiles as
    (
        select      *,
                    coalesce(lag(p_cdf, 1) over (order by list_priority_jitter asc), 0) as percentile_min,
                    p_cdf as percentile_max
        from        calculate_list_cdf
    )
    select      *
    from        calculate_list_percentiles
)

, scores as
(
    --  1. Determine phone number.
    select      scores.debtor_idx,
                debtor.packet_idx,
                scores.client_idx,
                scores.pl_group,
                scores.score_dialer_agent,
                phones.phone,
                coalesce(pool.is_priority_minimum_dialeragent, 0) as is_priority_minimum

    from        edwprodhh.hermes.master_prediction_scores as scores
                inner join
                    edwprodhh.hermes.master_prediction_pool as pool
                    on scores.debtor_idx = pool.debtor_idx
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on scores.debtor_idx = debtor.debtor_idx
                inner join
                    edwprodhh.hermes.master_prediction_phone_selection as phones
                    on debtor.packet_idx = phones.packet_idx
    where       scores.score_dialer_agent is not null
)
, filter_best_per_packet as
(
    select      *
    from        scores
    qualify     row_number() over (partition by packet_idx order by is_priority_minimum desc, score_dialer_agent desc) = 1
)



, filter_best_packets as
(
    --  2. Determine packets.
    with primary_dials as
    (
        select      *
        from        filter_best_per_packet
        qualify     row_number() over (order by is_priority_minimum desc, score_dialer_agent desc) <= 700000 --* Param: Total dials
    )
    -- , depth_dials as
    -- (
    --     select      *
    --     from        filter_best_per_packet
    --     qualify     row_number() over (order by score_dialer_agent desc) <= 50000  --* Param: Of that, Re-dials (for now, assuming 0) --need to ensure that they would still satisfy 7-in-7. Blocked until we do daily eval.
    -- )
    select      *,
                1 as is_primary_dial
    from        primary_dials
    -- union all
    -- select      *,
    --             0 as is_primary_dial
    -- from        depth_dials

)

, calculate_dialer_list as
(
    --  3. Determine list.
    with calculate_packet_priority as
    (
        select      *,
                    row_number() over (order by is_primary_dial desc, is_priority_minimum desc, score_dialer_agent desc)    as packet_priority,
                    packet_priority / count(*) over ()                                                                      as packet_percentile
        from        filter_best_packets
    )
    , calculate_packet_list as
    (
        select      packets.*,
                    lists.list_name,
                    lists.percentile_min,
                    lists.percentile_max
        from        calculate_packet_priority as packets
                    left join
                        list_rankings as lists
                        on  packets.packet_percentile >  lists.percentile_min
                        and packets.packet_percentile <= lists.percentile_max
    )
    select      *
    from        calculate_packet_list

    --          Risk missing the total dial mark when re-dial % of total is large relative to % size of each list.
    qualify     row_number() over (partition by packet_idx, list_name order by is_primary_dial desc, is_priority_minimum desc, score_dialer_agent desc) = 1
)
select      *
from        calculate_dialer_list
;