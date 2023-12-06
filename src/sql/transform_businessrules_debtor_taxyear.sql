create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_taxyear
as
select      debtor.debtor_idx,
            extract(year from dimfiscal_co_c.tax_pd) as tax_year,

            case    when    coalesce(tax_year, 3000) >= 2010
                    then    1
                    else    0
                    end     as pass_debtor_tax_year

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                edwprodhh.dw.dimfiscal_co_c as dimfiscal_co_c
                on debtor.debtor_idx = dimfiscal_co_c.debtor_idx
            left join
                edwprodhh.hermes.master_config_treatment_router as router
                on debtor.debtor_idx = router.debtor_idx
;



create or replace task
    edwprodhh.pub_jchang.replace_transform_businessrules_debtor_taxyear
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_taxyear
as
select      debtor.debtor_idx,
            extract(year from dimfiscal_co_c.tax_pd) as tax_year,

            case    when    coalesce(tax_year, 3000) >= 2010
                    then    1
                    else    0
                    end     as pass_debtor_tax_year

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                edwprodhh.dw.dimfiscal_co_c as dimfiscal_co_c
                on debtor.debtor_idx = dimfiscal_co_c.debtor_idx
            left join
                edwprodhh.hermes.master_config_treatment_router as router
                on debtor.debtor_idx = router.debtor_idx
;