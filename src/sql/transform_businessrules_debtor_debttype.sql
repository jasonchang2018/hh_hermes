create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_debttype
as
select      debtor_idx,

            debt_type,

            case when debt_type = 'PARKING'     then 1 else 0 end as is_debttype_gov_parking,
            case when debt_type = 'TOLL'        then 1 else 0 end as is_debttype_gov_toll,
            case when debt_type = 'AI'          then 1 else 0 end as is_debttype_hc_ai,
            case when debt_type = 'SP'          then 1 else 0 end as is_debttype_hc_sp

from        edwprodhh.pub_jchang.master_debtor
;



create task
    edwprodhh.pub_jchang.replace_transform_businessrules_debtor_debttype
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_debttype
as
select      debtor_idx,

            debt_type,

            case when debt_type = 'PARKING'     then 1 else 0 end as is_debttype_gov_parking,
            case when debt_type = 'TOLL'        then 1 else 0 end as is_debttype_gov_toll,
            case when debt_type = 'AI'          then 1 else 0 end as is_debttype_hc_ai,
            case when debt_type = 'SP'          then 1 else 0 end as is_debttype_hc_sp

from        edwprodhh.pub_jchang.master_debtor
;