create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_payplan
as
select      debtor.debtor_idx,

            desk.desk_idx,
            nullif(trim(desk.team_name), '') as desk_team_name,
            case    when    desk_team_name = 'PROMISE'
                    then    0
                    else    1
                    end     as pass_existing_payplan

from        edwprodhh.pub_jchang.master_debtor as debtor
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on debtor.debtor_idx = dimdebtor.debtor_idx
            left join
                edwprodhh.dw.dimdeskinfo as desk
                on dimdebtor.logon || '-' || dimdebtor.desk = desk.desk_idx
            left join
                edwprodhh.hermes.master_config_treatment_router as router
                on debtor.debtor_idx = router.debtor_idx
;



create or replace task
    edwprodhh.pub_jchang.replace_transform_businessrules_debtor_payplan
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_payplan
as
select      debtor.debtor_idx,

            desk.desk_idx,
            nullif(trim(desk.team_name), '') as desk_team_name,
            case    when    desk_team_name = 'PROMISE'
                    then    0
                    else    1
                    end     as pass_existing_payplan

from        edwprodhh.pub_jchang.master_debtor as debtor
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on debtor.debtor_idx = dimdebtor.debtor_idx
            left join
                edwprodhh.dw.dimdeskinfo as desk
                on dimdebtor.logon || '-' || dimdebtor.desk = desk.desk_idx
            left join
                edwprodhh.hermes.master_config_treatment_router as router
                on debtor.debtor_idx = router.debtor_idx
;