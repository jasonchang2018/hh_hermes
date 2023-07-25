create or replace temporary table edwprodhh.pub_mbutler.temporary_dialer_model_debtor as (


with base_cte as (
select 

   
            debtor.assigned_amt, 
            case when dt_resolved is not null then dt_resolved - debtor.batch_date else current_date() - debtor.batch_date end as debt_age, 
            debtor.experian_score, 
            debtor.median_household_income, 
            debtor.has_previous_payment, 
            debtor.is_only_debtor_in_packet,
            debtor.PARKING,
            debtor.TOLL,
            debtor.AI,
            debtor.SP,
            debtor.has_email, 
-- coalesce(debtor_lat, 0 ) as debtor_lat,  
-- coalesce(debtor_long, 0 ) as debtor_long,  
-- coalesce(client_lat, 0 ) as client_lat,  
-- coalesce(client_long, 0 ) as client_long,  
-- is_phone_code_A, 
-- is_phone_code_B, 
-- is_phone_code_C, 
-- is_phone_code_L, 
-- is_phone_code_M, 
-- is_phone_code_N, 
-- is_phone_code_T, 
-- is_phone_code_X, 
-- is_phone_code_Z, 
            debtor.equabli_score, 
            coalesce(attributions.dol_commission_attr, 0) as dol_commission_attr, 
            case when attributions.dol_commission_attr <> 0 then 1 else 0 end as attribution_flag 

            

    from edwprodhh.pub_mbutler.temp_model_debtors as debtors 
    inner join edwprodhh.pub_mbutler.temp_debtor_metrics as debtor
    on debtor.debtor_idx = debtors.debtor_idx
    left join edwprodhh.pub_mbutler.temp_attribution_metrics_debtor as attributions
    on attributions.debtor_idx = debtor.debtor_idx


) 
, downsample as ( 
    
    select 
        
                assigned_amt,
                debt_age,
                experian_score,
                median_household_income,
                has_previous_payment, 
                is_only_debtor_in_packet,
                PARKING,
                TOLL,
                AI,
                SP,
                has_email,
-- is_phone_code_A, 
-- is_phone_code_B, 
-- is_phone_code_C, 
-- is_phone_code_L, 
-- is_phone_code_M, 
-- is_phone_code_N, 
-- is_phone_code_T, 
-- is_phone_code_X, 
-- is_phone_code_Z, 
-- debtor_lat, 
-- debtor_long, 
-- client_lat, 
-- client_long, 
                equabli_score, 
                dol_commission_attr, 
                row_number() over (partition by attribution_flag  order by random(42)) as rn, 
                case when dol_commission_attr <> 0 then 1 else 0 end as attribution_flag 
    
    from base_cte

) 

    select 

                assigned_amt,
                debt_age,
                experian_score,
                median_household_income,
                has_previous_payment, 
                is_only_debtor_in_packet,
                PARKING,
                TOLL,
                AI,
                SP,
                has_email, 
-- is_phone_code_A, 
-- is_phone_code_B, 
-- is_phone_code_C, 
-- is_phone_code_L, 
-- is_phone_code_M, 
-- is_phone_code_N, 
-- is_phone_code_T, 
-- is_phone_code_X, 
-- is_phone_code_Z, 
-- debtor_lat, 
-- debtor_long, 
-- client_lat, 
-- client_long,      
                equabli_score, 
                dol_commission_attr, 
                percent_rank() over (partition by attribution_flag order by random(42)) as percent_
    
    from downsample 
    where dol_commission_attr <= 100 
    and debt_age <= 365
) 

; 

create or replace table edwprodhh.pub_mbutler.master_dialer_model_debtor as (

   select 

                assigned_amt,
                debt_age,
                experian_score,
                median_household_income,
                has_previous_payment, 
                is_only_debtor_in_packet,
                PARKING,
                TOLL,
                AI,
                SP,
                has_email, 
--      is_phone_code_A, 
-- is_phone_code_B, 
-- is_phone_code_C, 
-- is_phone_code_L, 
-- is_phone_code_M, 
-- is_phone_code_N, 
-- is_phone_code_T, 
-- is_phone_code_X, 
-- is_phone_code_Z, 
-- debtor_lat, 
-- debtor_long, 
-- client_lat, 
-- client_long, 
                dol_commission_attr
                
    from edwprodhh.pub_mbutler.temporary_dialer_model_debtor
    where dol_commission_attr > 0 and percent_ <= .50

    union all
    
    select 

                assigned_amt,
                debt_age,
                experian_score,
                median_household_income,
                has_previous_payment, 
                is_only_debtor_in_packet, 
                PARKING,
                TOLL,
                AI,
                SP,
                has_email, 
-- is_phone_code_A, 
-- is_phone_code_B, 
-- is_phone_code_C, 
-- is_phone_code_L, 
-- is_phone_code_M, 
-- is_phone_code_N, 
-- is_phone_code_T, 
-- is_phone_code_X, 
-- is_phone_code_Z, 
-- debtor_lat, 
-- debtor_long, 
-- client_lat, 
-- client_long, 
                dol_commission_attr as commission
                
    from edwprodhh.pub_mbutler.temporary_dialer_model_debtor
    where dol_commission_attr = 0 and percent_ <= .10
)



; 

create or replace table edwprodhh.pub_mbutler.master_dialer_model_holdout as (

   select 

            assigned_amt,
            debt_age,
            experian_score,
            median_household_income,
            has_previous_payment, 
            is_only_debtor_in_packet, 
            PARKING,
            TOLL,
            AI,
            SP,
            has_email, 
-- is_phone_code_A, 
-- is_phone_code_B, 
-- is_phone_code_C, 
-- is_phone_code_L, 
-- is_phone_code_M, 
-- is_phone_code_N, 
-- is_phone_code_T, 
-- is_phone_code_X, 
-- is_phone_code_Z, 
-- debtor_lat, 
-- debtor_long, 
-- client_lat, 
-- client_long, 
                equabli_score, 
                dol_commission_attr
                
    from edwprodhh.pub_mbutler.temporary_dialer_model_debtor
    where dol_commission_attr > 0 and percent_ >= .90


    union all
    
    select 

                assigned_amt,
                debt_age,
                experian_score,
                median_household_income,
                has_previous_payment, 
                is_only_debtor_in_packet, 
                PARKING,
                TOLL,
                AI,
                SP,
                has_email, 
--  is_phone_code_A, 
-- is_phone_code_B, 
-- is_phone_code_C, 
-- is_phone_code_L, 
-- is_phone_code_M, 
-- is_phone_code_N, 
-- is_phone_code_T, 
-- is_phone_code_X, 
-- is_phone_code_Z, 
-- debtor_lat, 
-- debtor_long, 
-- client_lat, 
-- client_long, 
                equabli_score, 
                dol_commission_attr as commission
                
    from edwprodhh.pub_mbutler.temporary_dialer_model_debtor
    where dol_commission_attr = 0 and percent_ >= .95  

    )


; 
