create or replace table edwprodhh.pub_mbutler.temp_attribution_metrics_debtor as ( 
    
    select      
    
            md.debtor_idx,
            sum(commission) as dol_commission_attr
    
    from edwprodhh.pub_jchang.master_debtor as md
    where batch_date between '2022-01-01' and current_date()
    group by 1 
    
) 
;