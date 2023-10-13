create or replace table edwprodhh.pub_mbutler.transform_best_times as ( 

    with call_timing as ( 
  
        select 
    
                dayofweek(callplacedtime) as call_day,
                to_char(time_slice(callplacedtime, 60, 'minute'), 'HH24:MI') as half_hour_interval, 
                count(*) as total_calls, 
                sum(rpc) as rpc, 
                sum(rpc) / count(*) as rpc_success_ratio

        from edwprodhh.pub_jchang.master_calls as mc 
            inner join edwprodhh.pub_jchang.master_debtor as md
                on md.debtor_idx = mc.debtor_idx 
        where calldirection_detail = 'Dialer-Agent'
        and industry = 'HC'
        and dayofweek(callplacedtime) not in (6, 0) 
        and 
        group by 1,2 
        order by 1,2


    ) 
    , call_pairs as ( 

        select 
  
                call_day,   
                half_hour_interval as hour_interval, 
                rpc_success_ratio, 
                total_calls, 
                row_number() over (partition by call_day order by rpc_success_ratio desc) as time_rank_local, 
                row_number() over (order by rpc_success_ratio desc) as time_rank_global
        
        from call_timing
        where hour_interval not in ('19:00' , '20:00', '21:00', '22:00', '23:00', '00:00', '01:00', '02:00', '03:00', '04:00', '5:00','6:00')
        order by 1, 2 asc

    )

    select 

            * 

    from call_pairs

)  
 ;


