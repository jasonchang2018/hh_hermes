
create or replace table edwprodhh.pub_mbutler.temp_debtor_metrics as ( 
    
    
with debtor_metrics as (
    
    select
            
            debtor_idx,
            packet_idx,
            batch_date,
            industry,
            assigned,
            min(batch_date) over (partition by packet_idx) as min_batch_date,
            count(*) over (partition by packet_idx) as packet_size_final,
            count(*) over (partition by packet_idx order by batch_date asc) as packet_size_running,
            commission
    
    from edwprodhh.pub_jchang.master_debtor

)
,call_codes as (

    select debtor_idx, 
            
            case when cell = 'A' then 1 else 0 end as is_phone_code_A,
            case when cell = 'B' then 1 else 0 end as is_phone_code_B,
            case when cell = 'C' then 1 else 0 end as is_phone_code_C,
            case when cell = 'L' then 1 else 0 end as is_phone_code_L,
            case when cell = 'M' then 1 else 0 end as is_phone_code_M,
            case when cell = 'N' then 1 else 0 end as is_phone_code_N,
            case when cell = 'T' then 1 else 0 end as is_phone_code_T,
            case when cell = 'X' then 1 else 0 end as is_phone_code_X,
            case when cell = 'Z' then 1 else 0 end as is_phone_code_Z

    from edwprodhh.pub_jchang.master_phone_number_code_debtor

) 
,has_previous_payment as (
    
    select 
    
            distinct debtor_metrics.debtor_idx
    
    from debtor_metrics
    inner join edwprodhh.pub_jchang.master_transactions as trans
    on debtor_metrics.packet_idx = trans.packet_idx
    and trans.is_payment = 1
    and trans.post_date < debtor_metrics.batch_date

)
, only_debtor_in_packet as (
    
    select 
            
            packet_idx, 
            count(distinct debtor_idx) as distinct_debtor_count
    
    from debtor_metrics
    group by packet_idx
    having count(distinct debtor_idx) = 1

)
, prev_payments as ( 
    
    select
        
            debtor_metrics.debtor_idx,
            case when has_previous_payment.debtor_idx is not null then 1 else 0 end as has_previous_payment,
            case when only_debtor_in_packet.packet_idx is not null then 1 else 0 end as is_only_debtor_in_packet
        
    from debtor_metrics
    left join has_previous_payment on debtor_metrics.debtor_idx = has_previous_payment.debtor_idx
    left join only_debtor_in_packet on debtor_metrics.packet_idx = only_debtor_in_packet.packet_idx

) 
, client_zip as  ( 
    
    select 
            
            client_idx, 
            avg(longitude) as client_longitude, 
            avg(latitude) as client_latitude 
    
    from edwprodhh.dw.dimclient as dc 
    inner join edwprodhh.pub_mbutler.zip_long_lat as zll 
    on zll.zip_code = dc.zip
    group by client_idx

)
    select 
        
            md.debtor_idx, 
            assigned_amount as assigned_amt, 
            batch_date, 
            experian_score, 
            equabli_score, 
            has_previous_payment, 
            is_only_debtor_in_packet, 
            case when debt_type = 'PARKING' then 1 else 0 end as  PARKING,
            case when debt_type = 'TOLL' then 1 else 0 end as  TOLL,
            case when debt_type = 'AI' then 1 else 0 end as  AI,
            case when debt_type = 'SP' then 1 else 0 end as  SP,
            case when email_address is not null then 1 else 0 end as has_email, 
            median_household_income,
            latitude as debtor_lat,
            longitude as debtor_long, 
            client_latitude as client_lat, 
            client_longitude as client_long,
            is_phone_code_A, 
            is_phone_code_B, 
            is_phone_code_C, 
            is_phone_code_L, 
            is_phone_code_M, 
            is_phone_code_N, 
            is_phone_code_T, 
            is_phone_code_X, 
            is_phone_code_Z

    from edwprodhh.pub_jchang.master_debtor as md 
    inner join edwprodhh.pub_mbutler.master_zip_code_stats as zcs 
    on zcs.zip_code = md.zip_code
    inner join prev_payments as pp
    on md.debtor_idx = pp.debtor_idx 
    left join edwprodhh.dw.email_addresses as em
    on em.debtor_idx = md.debtor_idx 
    left join edwprodhh.pub_mbutler.zip_long_lat as zll
    on md.zip_code = zll.zip_code
    left join client_zip as cz on cz.client_idx = md.client_idx
    left join CALL_CODES as cc on cc.debtor_idx = md.debtor_idx
    

) 