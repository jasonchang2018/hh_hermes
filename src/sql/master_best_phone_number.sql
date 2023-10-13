create or replace table as edwprodprodhh.pub_mbutler.master_best_phone_number as ( 

    with total_file as ( 

        select 
        
                phone.packet_idx, 
                phone.debtor_idx, 
                phone.phone_format                                                                                                                  as phone_number, 
                coalesce(phone.phone_is_valid, 0)                                                                                                   as phone_valid, 
                coalesce(case 
                            when outbound.is_answered = 1
                                then 1 
                            when outbound.is_answered = 0
                                then -0.5
                            else 0 
                        end  
                , 0)                                                                                                                        as outbound_answered, 
                coalesce(case 
                            when outbound.successful_call = 1 and outbound.is_answered = 1 
                                then 1 
                            when outbound.successful_call = 0 and outbound.is_answered = 1 
                                then 0
                            else 0.5 
                        end
                , 0)                                                                                                                            as outbound_success, 
                coalesce(case 
                            when texts.text_ready = 1 
                                then 0.5 
                            when texts.text_ready = 0 
                                then -0.5
                        else 0 
                            end
                , 0)                                                                                                                             as text_passed,
                coalesce(case 
                            when voapps.voapp_ready = 1 
                            then 0.5 
                            when voapps.voapp_ready = 0 
                            then -0.5
                            else 0 
                        end
                , 0)                                                                                                                             as voapp_passed,  
                coalesce(pool.pass_client_allowed_texts, 0)                                                                                         as elligible_texts, 
                coalesce(pool.pass_client_allowed_calls, 0)                                                                                         as elligible_calls 
                                                                                                                
                


        from edwprodhh.pub_mbutler.transform_phone_number_phone_numbers as phone 
            left join edwprodhh.pub_mbutler.transform_phone_number_call_logic as outbound 
                on outbound.debtor_idx = phone.debtor_idx and outbound.phonenumber = phone.phone_format
            left join edwprodhh.pub_mbutler.transform_phone_number_text_logic as texts 
                on texts.debtor_idx = phone.debtor_idx and texts.contact = phone.phone_format
            left join edwprodhh.pub_mbutler.transform_phone_number_voapp_logic as voapps 
                on voapps.debtor_idx = phone.debtor_idx and voapps.contact = phone.phone_format
            left join edwprodhh.pub_mbutler.transform_phone_number_prediction_pool as pool 
                on pool.debtor_idx = phone.debtor_idx and pool.valid_phone = phone.phone_format
        

    ) 
    , prim_and_proper as ( 


        select      
        
                total_file.packet_idx, 
                total_file.debtor_idx, 
                phone_number, 
                coalesce(
                    (phone_valid + 
                    outbound_answered + 
                    outbound_success + 
                    text_passed +
                    voapp_passed + 
                    elligible_texts + 
                    elligible_calls)
                        , 0) as number_score 

        from total_file

    )
    , rankedphonenumbers as (
        
        select 
            
                pp.packet_idx,
                pp.debtor_idx, 
                pp.phone_number,
                case 
                    when row_number() over (partition by pp.packet_idx order by number_score desc) = 1 
                        then 'phone_number_1'
                    when row_number() over (partition by pp.packet_idx order by number_score desc) = 2 
                        then 'phone_number_2'
                    when row_number() over (partition by pp.packet_idx order by number_score desc) = 3 
                        then 'phone_number_3'
                    else null
                end as phone_rank
        
        from prim_and_proper as pp 
    
    )

        select 
        
                packet_idx, 
                max(case when phone_rank = 'phone_number_1' then phone_number else null end) as phone_number_1,
                max(case when phone_rank = 'phone_number_2' then phone_number else null end) as phone_number_2,
                max(case when phone_rank = 'phone_number_3' then phone_number else null end) as phone_number_3

        from rankedphonenumbers
        where phone_rank is not null
        group by packet_idx

) 

;