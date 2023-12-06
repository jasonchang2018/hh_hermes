create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_debttype
as
select      debtor.debtor_idx,

            debtor.debt_type,

            case when debtor.debt_type = 'PARKING'     then 1 else 0 end as is_debttype_gov_parking,
            case when debtor.debt_type = 'TOLL'        then 1 else 0 end as is_debttype_gov_toll,
            case when debtor.debt_type = 'AI'          then 1 else 0 end as is_debttype_hc_ai,
            case when debtor.debt_type = 'SP'          then 1 else 0 end as is_debttype_hc_sp

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                edwprodhh.hermes.master_config_treatment_router as router
                on debtor.debtor_idx = router.debtor_idx
;



create or replace task
    edwprodhh.pub_jchang.replace_transform_businessrules_debtor_debttype
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_debttype
as
select      debtor.debtor_idx,

            debtor.debt_type,

            case when debtor.debt_type = 'PARKING'     then 1 else 0 end as is_debttype_gov_parking,
            case when debtor.debt_type = 'TOLL'        then 1 else 0 end as is_debttype_gov_toll,
            case when debtor.debt_type = 'AI'          then 1 else 0 end as is_debttype_hc_ai,
            case when debtor.debt_type = 'SP'          then 1 else 0 end as is_debttype_hc_sp

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                edwprodhh.hermes.master_config_treatment_router as router
                on debtor.debtor_idx = router.debtor_idx
;