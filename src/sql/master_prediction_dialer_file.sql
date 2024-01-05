create or replace table
    edwprodhh.hermes.master_prediction_dialer_file
as
with list_rankings as
(
    with calculate_list_summary as
    (
        select      client.department_name as department,

                    case    when    extract(dow from calls.callplacedtime)    = 1     then    '1MON'
                            when    extract(dow from calls.callplacedtime)    = 2     then    '2TUE'
                            when    extract(dow from calls.callplacedtime)    = 3     then    '3WED'
                            when    extract(dow from calls.callplacedtime)    = 4     then    '4THU'
                            when    extract(dow from calls.callplacedtime)    = 5     then    '5FRI'
                            end     as dow,

                    case    when    extract(hour from calls.callplacedtime) >= 7
                            and     extract(hour from calls.callplacedtime) <= 9
                            then    '0700'
                            when    extract(hour from calls.callplacedtime) >= 10
                            and     extract(hour from calls.callplacedtime) <= 11
                            then    '1000'
                            when    extract(hour from calls.callplacedtime) >= 12
                            and     extract(hour from calls.callplacedtime) <= 12
                            then    '1200'
                            when    extract(hour from calls.callplacedtime) >= 13
                            and     extract(hour from calls.callplacedtime) <= 15
                            then    '1300'
                            when    extract(hour from calls.callplacedtime) >= 16
                            and     extract(hour from calls.callplacedtime) <= 19
                            then    '1600'
                            end     as hod,

                    dow || '-' || hod                   as list_name,
        
                    
                    edwprodhh.pub_jchang.divide(sum(calls.rpc), count(*)) as rpc_rate,
                    count(*)                                        as n

        from        edwprodhh.pub_jchang.master_calls as calls
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on calls.debtor_idx = debtor.debtor_idx
                    inner join
                        edwprodhh.pub_jchang.master_client as client
                        on debtor.client_idx = client.client_idx

        where       calls.calldirection_detail = 'Dialer-Agent'
                    and calls.callplacedtime >= dateadd(month, -3, date_trunc('month', current_date()))
                    and calls.callplacedtime <  date_trunc('month', current_date())
                    and extract(hour from calls.callplacedtime) between 7 and 19
                    and extract(dow  from calls.callplacedtime) between 1 and 5
        group by    1,2,3,4
        order by    1,2,3,4
    )
    , calculate_list_priority as
    (
        select      *,
                    n / sum(n) over (partition by department)                               as p,
                    row_number() over (partition by department order by rpc_rate desc)     as list_priority
        from        calculate_list_summary
    )
    , calculate_list_jitter as
    (
        select      *,
                    row_number() over (partition by department order by list_priority + uniform(-3, 3, random()) asc, rpc_rate desc) as list_priority_jitter
        from        calculate_list_priority

    )
    , calculate_list_cdf as
    (
        select      *,
                    sum(p) over (partition by department order by list_priority_jitter asc) as p_cdf
        from        calculate_list_jitter
    )
    , calculate_list_percentiles as
    (
        select      *,
                    coalesce(lag(p_cdf, 1) over (partition by department order by list_priority_jitter asc), 0) as percentile_min,
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
                client.department_name as department,
                scores.score_dialer_agent,
                phones.phone,
                phones.dialer_file_label,
                coalesce(pool.is_priority_minimum_dialeragent, 0) as is_priority_minimum

    from        edwprodhh.hermes.master_prediction_scores as scores
                inner join
                    edwprodhh.hermes.master_prediction_pool as pool
                    on scores.debtor_idx = pool.debtor_idx
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on scores.debtor_idx = debtor.debtor_idx
                inner join
                    edwprodhh.pub_jchang.master_client as client
                    on debtor.client_idx = client.client_idx
                    and client.department_name is not null
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
    with param_global_dials as
    (
        select  700000 as param_n_dials --* Param: Total dials for the period we are generating for (currently, weekly.)
    )
    , param_department_dials as
    (
        select      *,
                    n_total / sum(n_total) over () as p_total,
                    round(p_total * (select param_n_dials from param_global_dials), 0) as n_dials
        from        (
                        select      department,
                                    sum(n) as n_total
                        from        list_rankings
                        group by    1
                    ) as x
        order by    1
    )
    , primary_dials as
    (
        select      filter_best_per_packet.*
        from        filter_best_per_packet
                    left join
                        param_department_dials
                        on filter_best_per_packet.department = param_department_dials.department
        qualify     row_number() over (
                        partition by    filter_best_per_packet.department
                        order by        filter_best_per_packet.is_priority_minimum desc,
                                        filter_best_per_packet.score_dialer_agent desc
                    )   <= param_department_dials.n_dials
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
                    row_number() over (partition by department order by is_primary_dial desc, is_priority_minimum desc, score_dialer_agent desc)    as packet_priority,
                    packet_priority / count(*) over (partition by department)                                                                      as packet_percentile
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
                        on  packets.department          =   lists.department
                        and packets.packet_percentile   >   lists.percentile_min
                        and packets.packet_percentile   <=  lists.percentile_max
    )
    select      *
    from        calculate_packet_list

    --          Risk missing the total dial mark when re-dial % of total is large relative to % size of each list.
    qualify     row_number() over (partition by packet_idx, list_name order by is_primary_dial desc, is_priority_minimum desc, score_dialer_agent desc) = 1
)
, calculate_upload_date as
(
    select      *,

                --  Assuming running on Friday evening w/ the rest of Hermes.
                case    regexp_substr(list_name, '^\\d(\\w{3})', 1, 1, 'e')
                        when    'MON'   then    date_trunc('week', current_date()) + 7
                        when    'TUE'   then    date_trunc('week', current_date()) + 8
                        when    'WED'   then    date_trunc('week', current_date()) + 9
                        when    'THU'   then    date_trunc('week', current_date()) + 10
                        when    'FRI'   then    date_trunc('week', current_date()) + 11
                        end     as upload_date,

                upper(regexp_replace(department, '/', '')) || '_' || list_name  || '_' || dialer_file_label as export_name

    from        calculate_dialer_list
)
select      *
from        calculate_upload_date
;



create or replace task
    edwprodhh.pub_jchang.replace_master_prediction_dialer_file
    warehouse = analysis_wh
    after   edwprodhh.pub_jchang.replace_master_prediction_phone_selection,
            edwprodhh.pub_jchang.insert_master_prediction_scores_dialeragent
as
create or replace table
    edwprodhh.hermes.master_prediction_dialer_file
as
with list_rankings as
(
    with calculate_list_summary as
    (
        select      client.department_name as department,

                    case    when    extract(dow from calls.callplacedtime)    = 1     then    '1MON'
                            when    extract(dow from calls.callplacedtime)    = 2     then    '2TUE'
                            when    extract(dow from calls.callplacedtime)    = 3     then    '3WED'
                            when    extract(dow from calls.callplacedtime)    = 4     then    '4THU'
                            when    extract(dow from calls.callplacedtime)    = 5     then    '5FRI'
                            end     as dow,

                    case    when    extract(hour from calls.callplacedtime) >= 7
                            and     extract(hour from calls.callplacedtime) <= 9
                            then    '0700'
                            when    extract(hour from calls.callplacedtime) >= 10
                            and     extract(hour from calls.callplacedtime) <= 11
                            then    '1000'
                            when    extract(hour from calls.callplacedtime) >= 12
                            and     extract(hour from calls.callplacedtime) <= 12
                            then    '1200'
                            when    extract(hour from calls.callplacedtime) >= 13
                            and     extract(hour from calls.callplacedtime) <= 15
                            then    '1300'
                            when    extract(hour from calls.callplacedtime) >= 16
                            and     extract(hour from calls.callplacedtime) <= 19
                            then    '1600'
                            end     as hod,

                    dow || '-' || hod                   as list_name,
        
                    
                    edwprodhh.pub_jchang.divide(sum(calls.rpc), count(*)) as rpc_rate,
                    count(*)                                        as n

        from        edwprodhh.pub_jchang.master_calls as calls
                    inner join
                        edwprodhh.pub_jchang.master_debtor as debtor
                        on calls.debtor_idx = debtor.debtor_idx
                    inner join
                        edwprodhh.pub_jchang.master_client as client
                        on debtor.client_idx = client.client_idx

        where       calls.calldirection_detail = 'Dialer-Agent'
                    and calls.callplacedtime >= dateadd(month, -3, date_trunc('month', current_date()))
                    and calls.callplacedtime <  date_trunc('month', current_date())
                    and extract(hour from calls.callplacedtime) between 7 and 19
                    and extract(dow  from calls.callplacedtime) between 1 and 5
        group by    1,2,3,4
        order by    1,2,3,4
    )
    , calculate_list_priority as
    (
        select      *,
                    n / sum(n) over (partition by department)                               as p,
                    row_number() over (partition by department order by rpc_rate desc)     as list_priority
        from        calculate_list_summary
    )
    , calculate_list_jitter as
    (
        select      *,
                    row_number() over (partition by department order by list_priority + uniform(-3, 3, random()) asc, rpc_rate desc) as list_priority_jitter
        from        calculate_list_priority

    )
    , calculate_list_cdf as
    (
        select      *,
                    sum(p) over (partition by department order by list_priority_jitter asc) as p_cdf
        from        calculate_list_jitter
    )
    , calculate_list_percentiles as
    (
        select      *,
                    coalesce(lag(p_cdf, 1) over (partition by department order by list_priority_jitter asc), 0) as percentile_min,
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
                client.department_name as department,
                scores.score_dialer_agent,
                phones.phone,
                phones.dialer_file_label,
                coalesce(pool.is_priority_minimum_dialeragent, 0) as is_priority_minimum

    from        edwprodhh.hermes.master_prediction_scores as scores
                inner join
                    edwprodhh.hermes.master_prediction_pool as pool
                    on scores.debtor_idx = pool.debtor_idx
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on scores.debtor_idx = debtor.debtor_idx
                inner join
                    edwprodhh.pub_jchang.master_client as client
                    on debtor.client_idx = client.client_idx
                    and client.department_name is not null
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
    with param_global_dials as
    (
        select  700000 as param_n_dials --* Param: Total dials for the period we are generating for (currently, weekly.)
    )
    , param_department_dials as
    (
        select      *,
                    n_total / sum(n_total) over () as p_total,
                    round(p_total * (select param_n_dials from param_global_dials), 0) as n_dials
        from        (
                        select      department,
                                    sum(n) as n_total
                        from        list_rankings
                        group by    1
                    ) as x
        order by    1
    )
    , primary_dials as
    (
        select      filter_best_per_packet.*
        from        filter_best_per_packet
                    left join
                        param_department_dials
                        on filter_best_per_packet.department = param_department_dials.department
        qualify     row_number() over (
                        partition by    filter_best_per_packet.department
                        order by        filter_best_per_packet.is_priority_minimum desc,
                                        filter_best_per_packet.score_dialer_agent desc
                    )   <= param_department_dials.n_dials
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
                    row_number() over (partition by department order by is_primary_dial desc, is_priority_minimum desc, score_dialer_agent desc)    as packet_priority,
                    packet_priority / count(*) over (partition by department)                                                                      as packet_percentile
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
                        on  packets.department          =   lists.department
                        and packets.packet_percentile   >   lists.percentile_min
                        and packets.packet_percentile   <=  lists.percentile_max
    )
    select      *
    from        calculate_packet_list

    --          Risk missing the total dial mark when re-dial % of total is large relative to % size of each list.
    qualify     row_number() over (partition by packet_idx, list_name order by is_primary_dial desc, is_priority_minimum desc, score_dialer_agent desc) = 1
)
, calculate_upload_date as
(
    select      *,

                --  Assuming running on Friday evening w/ the rest of Hermes.
                case    regexp_substr(list_name, '^\\d(\\w{3})', 1, 1, 'e')
                        when    'MON'   then    date_trunc('week', current_date()) + 7
                        when    'TUE'   then    date_trunc('week', current_date()) + 8
                        when    'WED'   then    date_trunc('week', current_date()) + 9
                        when    'THU'   then    date_trunc('week', current_date()) + 10
                        when    'FRI'   then    date_trunc('week', current_date()) + 11
                        end     as upload_date,

                upper(regexp_replace(department, '/', '')) || '_' || list_name  || '_' || dialer_file_label as export_name

    from        calculate_dialer_list
)
select      *
from        calculate_upload_date
;