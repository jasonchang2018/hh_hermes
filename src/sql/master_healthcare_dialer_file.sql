

create or replace table edwprodhh.pub_mbutler.master_healthcare_dialer_file as ( 

    with dialable as ( 

            select 

                    md.packet_idx, 
                    mpp.debtor_idx,  
                    phone_number_1                                  as phone_number,
                    phone_number_2                                  as phone_number2,  
                    score_debtor                                    as score, 
                    ntile(10) over (order by score asc)             as score_rank 

            from edwprodhh.hermes.master_prediction_pool as mpp 
                inner join edwprodhh.hermes.master_prediction_scores as mps 
                    on mpp.debtor_idx = mps.debtor_idx 
                inner join edwprodhh.pub_mbutler.master_best_phone_number as mbpn 
                    on mpp.debtor_idx = mbpn.debtor_idx  
                inner join edwprodhh.pub_jchang.master_debtor as md 
                    on md.debtor_idx = mpp.debtor_idx
            where is_eligible_dialer_agent = 1 
            and md.industry = 'HC'
            and phone_number_1 is not null 
            qualify row_number() over (partition by md.packet_idx order by score_debtor desc) = 1

    )
    , adtl_scores as ( 

        select 

                debtor_idx, 
                phone_number, 
                phone_number2, 
                score, 
                score_rank, 
                ten_score, 
                ntile(5) over (partition by score_rank, ten_score order by score asc) as nine_score

        from (  select 
                
                        debtor_idx, 
                        phone_number,
                        phone_number2, 
                        score, 
                        score_rank, 
                        ntile(5) over (partition by score_rank order by score asc) as ten_score
                
                from dialable  ) 




    )
    , schedule as ( 

        select 

                debtor_idx, 
                phone_number,
                phone_number2,  
                score, 
                score_rank, 
                ten_score, 
                nine_score, 



                case when (score_rank = 10 and ten_score = 1) or 
                                    (score_rank = 10 and ten_score = 5) or 
                                            (score_rank = 9 and ten_score = 1 and nine_score = 1) or 
                                                (score_rank = 9 and ten_score = 2 and nine_score = 1) or 
                                                    (score_rank = 9 and ten_score = 3 and nine_score = 1) or 
                                                        (score_rank = 9 and ten_score = 4 and nine_score = 1) or 
                                                            (score_rank = 9 and ten_score = 5 and nine_score = 1) 
                                                                then 1


                when (score_rank = 10 and ten_score = 2) or 
                                (score_rank = 10 and ten_score = 4) or 
                                        (score_rank = 9 and ten_score = 1 and nine_score = 2) or 
                                            (score_rank = 9 and ten_score = 2 and nine_score = 2) or 
                                                (score_rank = 9 and ten_score = 3 and nine_score = 2) or 
                                                    (score_rank = 9 and ten_score = 4 and nine_score = 2) or 
                                                        (score_rank = 9 and ten_score = 5 and nine_score = 2) 
                                                            then 2

                when (score_rank = 10 and ten_score = 3) or 
                                    (score_rank = 10 and ten_score = 1) or 
                                            (score_rank = 9 and ten_score = 1 and nine_score = 3) or 
                                                (score_rank = 9 and ten_score = 2 and nine_score = 3) or 
                                                    (score_rank = 9 and ten_score = 3 and nine_score = 3) or 
                                                        (score_rank = 9 and ten_score = 4 and nine_score = 3) or 
                                                            (score_rank = 9 and ten_score = 5 and nine_score = 3) 
                                                                then 3 


                when (score_rank = 10 and ten_score = 4) or 
                                    (score_rank = 10 and ten_score = 2) or 
                                            (score_rank = 9 and ten_score = 1 and nine_score = 4) or 
                                                (score_rank = 9 and ten_score = 2 and nine_score = 4) or 
                                                    (score_rank = 9 and ten_score = 3 and nine_score = 4) or 
                                                        (score_rank = 9 and ten_score = 4 and nine_score = 4) or 
                                                            (score_rank = 9 and ten_score = 5 and nine_score = 4) 
                                                                    then 4


                when (score_rank = 10 and ten_score = 5) or 
                                    (score_rank = 10 and ten_score = 3) or 
                                            (score_rank = 9 and ten_score = 1 and nine_score = 5) or 
                                                (score_rank = 9 and ten_score = 2 and nine_score = 5) or 
                                                    (score_rank = 9 and ten_score = 3 and nine_score = 5) or 
                                                        (score_rank = 9 and ten_score = 4 and nine_score = 5) or 
                                                            (score_rank = 9 and ten_score = 5 and nine_score = 5) 
                                                                then 5 end as day_file 


        from adtl_scores

    ) 
    , day_times as ( 

        select 

                time_rank_local as time_rank, 
                call_day, 
                hour_interval as call_time

        from edwprodhh.pub_mbutler.master_best_times 

    ) 
    , schedule_time as ( 

        select  

                debtor_idx, 
                case 
                    when day_file = 1 and 
                            ((score_rank = 10 and ten_score = 1) or 
                                (score_rank = 10 and ten_score = 5)) or 
                        day_file = 2 and
                            ((score_rank = 10 and ten_score = 2) or 
                                (score_rank = 10 and ten_score = 4)) or 
                        day_file = 3 and 
                            (score_rank = 10 and ten_score = 3) 
                    then phone_number

                    when day_file = 3 and 
                            (score_rank = 10 and ten_score = 1) or    
                        day_file = 4 and
                            ((score_rank = 10 and ten_score = 2) or 
                                (score_rank = 10 and ten_score = 4)) or
                        day_file = 5 and 
                            ((score_rank = 10 and ten_score = 3) or 
                                (score_rank = 10 and ten_score = 5)) 
                    then 
                        
                        (case 
                            when phone_number2 is not null 
                                then phone_number2 else phone_number end)  

                    else phone_number 
                end as phone_number, 
                day_file, 
                ntile(12) over (partition by day_file order by score) as time_place_score 

        from schedule 

    ) 

    , joined as ( 

        select 

                debtor_idx, 
                phone_number, 
                call_day, 
                call_time 

        from schedule_time as st inner join day_times as dt 
        on st.time_place_score = dt.time_rank 
        and st.day_file = dt.call_day 

    ) 

        select 
            
            debtor_idx, 
            phone_number, 
            call_day, 
            call_time as call_hour 

        from joined order by call_day asc, call_hour asc

    ) 
; 