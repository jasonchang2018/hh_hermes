
create or replace temporary table edwprodhh.pub_mbutler.temporary_full_table as (

with zip as (
    
    select 
        
            debtor_idx,
            case 
                
                when length(zip_code) = 5 
                then zip_code 
                when length(zip_code) > 5 
                then left(zip_code, 5) 
                else null 
            
            end as zip_code

    from edwprodhh.pub_jchang.master_debtor 

)   
, dd as 
(
    select
         
            md.debtor_idx,  
            md.zip_code,  
            md.assigned_amount,
            md.batch_date as assigned_date, 
            md.payment
            

    from edwprodhh.pub_jchang.master_debtor as md
    left join zip as zp
    on zp.debtor_idx = md.debtor_idx
    where batch_date between '2022-01-01' and current_date()
    and md.debtor_idx is not null and md.assigned_amount is not null 
) 
, mhh as 
(
    select 
            
            dd.assigned_date,  
            debtor_idx, 
            median_household_income

    from dd
    left join edwprodhh.pub_mbutler.master_zip_code_stats as cs
    on dd.zip_code = cs.zip_code

)  
, exp_score as 
(
    select 
            
            debtor_idx, 
            sc.experian_score 

    from edwprodhh.pub_jchang.master_debtor as dt 
    left join edwprodhh.dw.dimscore as sc 
    on sc.dimscore_idx = dt.debtor_idx
    where batch_date between '2022-01-01' and current_date()
    
    and dt.debtor_idx is not null and assigned is not null 
) 
, eqb_join as 
(
    
    select 
            
            md.debtor_idx,
            equabli_score as eqb_score, 
            sum(assigned) as assigned_amt, 
            sum(payment) as payment
            
    from edwprodhh.pub_jchang.master_debtor as md
   	where 
    batch_date between '2022-01-01' and current_date() 
	and assigned > 0 
    and assigned is not null and md.debtor_idx is not null 
    group by 1, 2
    order by 1

)
, complete_debtor as 
(
    select 
            
            mh.assigned_date, 
            mh.debtor_idx,
            eqb_score, 
            assigned_amt, 
            mh.median_household_income, 
            experian_score
            
    from mhh as mh 
    left join eqb_join as eq
    on eq.debtor_idx = mh.debtor_idx 
    left join exp_score as ex 
    on ex.debtor_idx = eq.debtor_idx 
    
)
   select * 
   from complete_debtor 
   ); 





; 
select * 
from edwprodhh.pub_jchang.master_debtor limit 10 
; 

/* Tempoary Table for VoApp Attributes */ 

create or replace temporary table edwprodhh.pub_mbutler.temp_raw_dataset_1
as (

with attr as 
(
    
    select      
    
            contact_id,
            sum(attribution_weight * sig_comm_amt) as dol_commission_attr
    
    from edwprodhh.pub_jchang.transform_payment_attribution_contact_weights
    where contact_type = 'VoApp'
    group by 1

) 
    , previous_contacts as 
( 
    
    select 
        
            debtor_idx,
            contact_time, 
            contact_id, 
            row_number() over (partition by debtor_idx order by contact_time) as previous_contacts
    
    from edwprodhh.pub_jchang.master_contacts 
    where contact_time between '2022-01-01' and current_date()

)

, prev_contacts as 

(
    
    select 
        
            debtor_idx,     
            contact_id, 
            previous_contacts - 1 as previous_contacts
        
    from previous_contacts

)

, voapps as 
(
    
    select 
        
            emid_idx as voapp_idx, 
            status_date,
            row_number() over (partition by vo.debtor_idx order by status_date) as frequency, 
            vo.debtor_idx, 
            previous_contacts, 
            dol_commission_attr

    from edwprodhh.pub_jchang.master_voapps as vo
    inner join prev_contacts as co 
    on vo.debtor_idx = co.debtor_idx 
    and vo.emid_idx = co.contact_id
    left join attr 
    on vo.emid_idx = attr.contact_id

)  
,  contacts as 
(

    select 

        debtor_idx,
        contact_id,
        contact_type, 
        contact_time, 
        row_number() over (partition by debtor_idx, contact_type order by contact_time) as contact_num

    from edwprodhh.pub_jchang.master_contacts 
    where contact_time between '2022-01-01' and current_date()

)
, previous as 
(
    select 
            debtor_idx, 
            contact_id,  
            case 
                when contact_type = 'Dialer-Agent Call' 
                    then contact_num - 1 
                else 0 
            end as dialer_agent_call, 
            case 
                when contact_type = 'Outbound-Manual Call' 
                    then contact_num - 1 
                else 0 
            end as outbound_manual_call, 
            case 
                when contact_type = 'Text Message' 
                    then contact_num - 1 
                else 0 
            end as text_message,
            case 
                when contact_type = 'Letter' 
                    then contact_num - 1 
                else 0 
            end as letter,
            case 
                when contact_type = 'Dialer-Agentless Call' 
                    then contact_num - 1 
                else 0 
            end as dialer_agentless_call,
            case 
                when contact_type = 'VoApp' 
                    then contact_num - 1 
                else 0 
            end as voapp,
            case 
                when contact_type = 'Inbound-Agent Call' 
                    then contact_num - 1 
                else 0 
            end as inbound_agent_call,
            case 
                when contact_type = 'Email' 
                    then contact_num - 1 
                else 0 
            end as email
    from contacts
) 
, total as 
(

    select      
            debtor.debtor_idx, 
            voapp_idx, 
            pr.contact_id, 
            dialer_agent_call, 
            outbound_manual_call, 
            text_message,
            voapp, 
            dialer_agentless_call,
            letter,
            inbound_agent_call,
            email, 
            assigned_date,  
            status_date - assigned_date as debt_age, 
            p.previous_contacts,
            eqb_score, 
            assigned_amt, 
            median_household_income, 
            experian_score,
            coalesce(dol_commission_Attr, 0) as dol_commission_Attr
    
    from 
    voapps as vo 
    inner join edwprodhh.pub_mbutler.temporary_full_table as debtor
    on vo.debtor_idx = debtor.debtor_idx
    inner join prev_contacts as p 
    on p.debtor_idx = vo.debtor_idx 
    and p.contact_id = vo.voapp_idx 
    inner join previous as pr 
    on pr.debtor_idx = vo.debtor_idx 
    and pr.contact_id = vo.voapp_idx
    
    
    
  
)

    
    select * 
    from total 
    
) 

; 
select 
            
            *
    
    from edwprodhh.pub_mbutler.temp_raw_dataset_1

;


// tables for regression analysis 


create or replace table edwprodhh.pub_mbutler.voapp_contact_strategy_12 as (


with star as ( 
    
    select 
            
            * 
    
    from edwprodhh.pub_mbutler.temp_raw_dataset_1

) 
, trimming as 
(
    
    select 
            contact_id, 
			debtor_idx, 
            voapp_idx, 
            previous_contacts, 
            debt_age, 
            eqb_score, 
            median_household_income, 
            dialer_agent_call, 
            outbound_manual_call, 
            text_message,
            voapp, 
            dialer_agentless_call,
            letter,
            inbound_agent_call,
            email, 
            case when experian_score = 0 then null else experian_score end as experian_score,
            assigned_amt,         
            dol_commission_attr, 
            percentile_cont(0.10) within group (order by previous_contacts) over () as previous_contacts_lower,
            percentile_cont(0.70) within group (order by previous_contacts) over () as previous_contacts_upper,
            percentile_cont(0.05) within group (order by assigned_amt) over () as assigned_amt_lower,
            percentile_cont(0.70) within group (order by assigned_amt) over () as assigned_amt_upper,
            percentile_cont(0.10) within group (order by debt_age) over () as debt_age_lower,
            percentile_cont(0.70) within group (order by debt_age) over () as debt_age_upper, 
            percentile_cont(0.10) within group (order by median_household_income) over () as median_household_income_lower
            
    from star 
    where 
    dol_commission_attr >= 0 
    and  dol_commission_attr <= 50 
    and ((experian_score between 400 and 800) or experian_score is null) 

) 
, applying_trim as 
(
 
    select 
            contact_id, 
			debtor_idx, 
            voapp_idx, 
            assigned_amt, 
            dialer_agent_call, 
            outbound_manual_call, 
            text_message,
            voapp, 
            dialer_agentless_call,
            letter,
            inbound_agent_call,
            email, 
            debt_age, 
            previous_contacts, 
            eqb_score, 
            median_household_income, 
            experian_score,
            dol_commission_attr, 
            case when dol_commission_attr > 0 then 1 else 0 end as is_success, 
            row_number() over (partition by is_success order by random()) as row_num 
        
        from trimming
        -- where 
        -- (frequency is null or
        -- (frequency between frequency_lower and frequency_upper)) and 
        -- (previous_contacts is null or 
        -- (previous_contacts between previous_contacts_lower and previous_contacts_upper)) and 
        -- (assigned_amt is null or 
        -- (assigned_amt between assigned_amt_lower and assigned_amt_upper)) and
        -- (debt_age is null or 
        -- (debt_age between debt_age_lower and debt_age_upper)) and
        -- (median_household_income is null or 
        -- (median_household_income >= median_household_income_lower)) 
        
        
    
) 
, cleaned_table as 
(
    select 
            contact_id, 
            debtor_idx, 
            voapp_idx, 
            assigned_amt, 
            debt_age, 
            previous_contacts, 
            dialer_agent_call, 
            outbound_manual_call, 
            text_message,
            voapp, 
            dialer_agentless_call,
            letter,
            inbound_agent_call,
            email, eqb_score, 
            median_household_income, 
            experian_score, 
            dol_commission_attr
    
    from applying_trim
    
) 
, normalizing_target AS 
(
 
    select 
        	debtor_idx, 
            contact_id, 
            assigned_amt, 
            debt_age, 
            previous_contacts, 
             dialer_agent_call, 
            outbound_manual_call, 
            text_message,
            voapp, 
            dialer_agentless_call,
            letter,
            inbound_agent_call,
            email, 
            eqb_score, 
            median_household_income, 
            experian_score,
            dol_commission_attr
  
    from cleaned_table

) 
, success_metric as 
( 
   
    select 
            
            *, 
            case when dol_commission_attr = 0 then 0 else 1 end as is_success

    from normalizing_target

) 
, success as 
(
SELECT *
FROM success_metric 
where is_success = 1 
)
, oversample as
(
SELECT *
FROM success  
union all 
select * 
from success 
union all 
select * 
from success 
union all 
select * 
from success 

) 
, join_up as 
(select * 
from oversample 
union all
select * 
from success_metric 
where is_success = 0
) 

, success_partition as
(

   select 
            
            *, 
            percent_rank() over (partition by is_success order by random(4)) as pn, 
            row_number() over (partition by is_success order by random(4)) as rn
        
    from join_up

) 
, final as
(


    
    select 
            contact_id, 
            debtor_idx, 
            assigned_amt, 
            debt_age, 
            previous_contacts, 
             dialer_agent_call, 
            outbound_manual_call, 
            text_message,
            voapp, 
            dialer_agentless_call,
            letter,
            inbound_agent_call,
            email,   
            median_household_income, 
            experian_score,
            dol_commission_attr
            
    
    from success_partition 
    where rn <= (select max(rn) from success_partition where is_success = 0 and pn <= 0.30) 
	
) 




, stored_observations AS
  (select *, 
  percent_rank() over (order by random(4)) as pn 
  from final 
) 
select       
            assigned_amt, 
            debt_age, 
            previous_contacts, 
            dialer_agent_call, 
            outbound_manual_call, 
            text_message,
            voapp, 
            dialer_agentless_call,
            letter,
            inbound_agent_call,
            email, 
            median_household_income, 
            experian_score,
            dol_commission_attr
from stored_observations
where pn < .97
)  
; 