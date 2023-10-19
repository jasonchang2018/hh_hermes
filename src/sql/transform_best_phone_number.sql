create or replace table edwprodhh.pub_mbutler.transform_phone_number_phone_numbers as ( 

with phone_numbers as ( 

    
    select      
    
                packet_idx, 
                mpn.debtor_idx, 
                replace(phone_format::string, '+1', '')                                                                                         as phone_format, 
                phone_is_valid, 
                row_number() over (partition by mpn.debtor_idx, replace(phone_format::string, '+1', '') order by random())                          as rn 

    from edwprodhh.pub_jchang.master_phone_number as mpn
        inner join edwprodhh.pub_jchang.master_debtor as md 
            on mpn.debtor_idx = md.debtor_idx 
    where replace(phone_format::string, '+1', '') rlike '^[0-9]{10}$'
        qualify rn = 1

)

select * from phone_numbers 
) 
; 

create or replace table edwprodhh.pub_mbutler.transform_phone_number_call_logic as ( 

with call_logic as 
( 
    select  
            packet_idx,
            debtor_idx, 
            replace(phonenumber::string, '+1', '')                                                                                              as phonenumber, 
            
            case when sum(is_answered) >= 1 then 1 else 0 end                                                                                   as is_answered,  
            
            case when sum(talktime) >= 60 then 1 else 0 end                                                                                     as successful_call
    
    from edwprodhh.pub_jchang.master_calls as mc 
        
        where calldirection = 'Outbound'
     
        and replace(phonenumber::string, '+1', '') rlike '^[0-9]{10}$'
    
    group by 1, 2, 3

)

select * from call_logic 

) 

; 

create or replace table edwprodhh.pub_mbutler.transform_phone_number_text_logic as  (

with text_logic as 
( 
    select  
            
            packet_idx, 
            debtor_idx, 
            contact, 
            status_type, 
            frequence, 
            orig_status, 
            0 as texts_bounced

    from edwprodhh.pub_jchang.master_texts 
 

union all 

    select 

            packet_idx,
            debtor_idx, 
            contact, 
            status_type, 
            frequence, 
            orig_status, 
            1 as texts_bounced

    from edwprodhh.pub_jchang.master_texts_bounced 
  
    where replace(contact::string, '+1', '') rlike '^[0-9]{10}$'

)

, addon_texts as 
( 
    select  packet_idx, 
            debtor_idx, 
            replace(contact::string, '+1', '')                                                                                                      as contact, 
            
            case 
            when sum(texts_bounced) > 0 
            then 0 
            else 1 
            end                                                                                                                                     as text_ready

    from text_logic 
    where replace(contact::string, '+1', '') rlike '^[0-9]{10}$'
    group by 1, 2, 3

)


select * from addon_texts 

)


; 


create or replace table edwprodhh.pub_mbutler.transform_phone_number_voapp_logic as ( 

with voapp_logic as 
( 
    select  
            packet_idx, 
            debtor_idx, 
            contact, 
            0 as voapps_bounced

    from edwprodhh.pub_jchang.master_voapps
  

union all 

    select 

            packet_idx, 
            debtor_idx, 
            contact, 
            1 as voapps_bounced

    from edwprodhh.pub_jchang.master_voapps_bounced 

    where replace(contact::string, '+1', '') rlike '^[0-9]{10}$'

) 
, addon_voapps as 
( 
    select  
            packet_idx, 
            debtor_idx, 
            replace(contact::string, '+1', '')                                                                                                      as contact, 
            
            case 
            when sum(voapps_bounced) > 0 
            then 0 
            else 1 
            end                                                                                                                                     as voapp_ready

    from voapp_logic 
    where replace(contact::string, '+1', '') rlike '^[0-9]{10}$'
    group by 1, 2,3 

) 

select * from addon_voapps 
) 
; 


create or replace table edwprodhh.pub_mbutler.transform_phone_number_prediction_pool as ( 



with prediction_pool_logic as 
(
    select  
    
            md.packet_idx,
            pp.debtor_idx, 
            replace(valid_phone_number_dialer::string, '+1', '')                                                                             as valid_phone, 
            pass_client_allowed_texts, 
            pass_client_allowed_calls 

    from edwprodhh.hermes.master_prediction_pool as pp inner join edwprodhh.pub_jchang.master_debtor as md
    on md.debtor_idx = pp.debtor_idx
    where replace(valid_phone_number_dialer::string, '+1', '') rlike '^[0-9]{10}$'

)


select * from prediction_pool_logic 

) 


; 


 
-- create task phone_number_processing_task 
--   warehouse ANALYSIS_WH
--   schedule '0 3 * * SUN'
-- as


-- with phone_numbers as ( 

    
--     select      
    
--                 packet_idx,
--                 debtor_idx, 
--                 replace(phone_format::string, '+1', '')                                                                                         as phone_format, 
--                 phone_is_valid, 
--                 row_number() over (partition by debtor_idx, replace(phone_format::string, '+1', '') order by random())                          as rn 

--     from edwprodhh.pub_jchang.master_phone_number as mpn 
--         inner join edwprodhh.pub_jchang.master_debtor as md 
--             on md.debtor_idx = mpn.debtor_idx 
--     where replace(phone_format::string, '+1', '') rlike '^[0-9]{10}$'
--         qualify rn = 1

-- )
-- , call_logic as 
-- ( 
--     select  
--             packet_idx, 
--             debtor_idx, 
--             replace(phonenumber::string, '+1', '')                                                                                              as phonenumber, 
            
--             case when sum(is_answered) >= 1 then 1 else 0 end                                                                                   as is_answered,  
            
--             case when sum(talktime) >= 60 then 1 else 0 end                                                                                     as successful_call
    
--     from edwprodhh.pub_jchang.master_calls as mc 
        
--         where calldirection = 'Outbound'
     
--         and replace(phonenumber::string, '+1', '') rlike '^[0-9]{10}$'
    
--     group by 1, 2

-- )
-- , text_logic as 
-- ( 
--     select  
    
--             packet_idx, 
--             debtor_idx, 
--             contact, 
--             status_type, 
--             frequence, 
--             orig_status, 
--             0 as texts_bounced

--     from edwprodhh.pub_jchang.master_texts 
 

-- union all 

--     select 

--             packet_idx,
--             debtor_idx, 
--             contact, 
--             status_type, 
--             frequence, 
--             orig_status, 
--             1 as texts_bounced

--     from edwprodhh.pub_jchang.master_texts_bounced 
  
--     where replace(contact::string, '+1', '') rlike '^[0-9]{10}$'

-- )

-- , addon_texts as 
-- ( 
--     select  
    
--             packet_idx, 
--             debtor_idx, 
--             replace(contact::string, '+1', '')                                                                                                      as contact, 
            
--             case 
--             when sum(texts_bounced) > 0 
--             then 0 
--             else 1 
--             end                                                                                                                                     as text_ready

--     from text_logic 
--     where replace(contact::string, '+1', '') rlike '^[0-9]{10}$'
--     group by 1, 2 

-- )
-- , voapp_logic as 
-- ( 
--     select  
    
--             packet_idx, 
--             debtor_idx, 
--             contact, 
--             0 as voapps_bounced

--     from edwprodhh.pub_jchang.master_voapps
  

-- union all 

--     select 

--             packet_idx, 
--             debtor_idx, 
--             contact, 
--             1 as voapps_bounced

--     from edwprodhh.pub_jchang.master_voapps_bounced 

--     where replace(contact::string, '+1', '') rlike '^[0-9]{10}$'

-- ) 
-- , addon_voapps as 
-- ( 
--     select  
            
--             packet_idx, 
--             debtor_idx, 
--             replace(contact::string, '+1', '')                                                                                                      as contact, 
            
--             case 
--             when sum(voapps_bounced) > 0 
--             then 0 
--             else 1 
--             end                                                                                                                                     as voapp_ready

--     from voapp_logic 
--     where replace(contact::string, '+1', '') rlike '^[0-9]{10}$'
--     group by 1, 2, 3

-- ) 
-- , prediction_pool_logic as 
-- (
--     select  
--             packet_idx,
--             debtor_idx, 
--             replace(valid_phone_number_dialer::string, '+1', '')                                                                             as valid_phone, 
--             pass_client_allowed_texts, 
--             pass_client_allowed_calls 

--     from edwprodhh.hermes.master_prediction_pool as pp inner join edwprodhh.pub_jchang.master_debtor as md 
--     on pp.debtor_idx = md.debtor_idx 
--     where replace(valid_phone_number_dialer::string, '+1', '') rlike '^[0-9]{10}$'

-- )

-- select * into edwprodhh.pub_mbutler.transform_phone_number_phone_numbers from phone_numbers;
-- select * into edwprodhh.pub_mbutler.transform_phone_number_call_logic from call_logic;
-- select * into edwprodhh.pub_mbutler.transform_phone_number_text_logic  from text_logic;
-- select * into edwprodhh.pub_mbutler.transform_phone_number_voapp_logic  from voapp_logic; 
-- select * into edwprodhh.pub_mbutler.transform_phone_number_prediction_pool_logic  from prediction_pool_logic; 









