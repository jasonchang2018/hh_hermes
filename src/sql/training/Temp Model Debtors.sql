create or replace table edwprodhh.pub_mbutler.temp_model_debtors as ( 

select 

debtor_idx,
dt_resolved

from edwprodhh.pub_jchang.master_debtor 
where batch_date between '2022-01-01' and current_date()

) 