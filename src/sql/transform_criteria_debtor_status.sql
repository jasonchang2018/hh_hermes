create or replace table
    edwprodhh.hermes.transform_criteria_debtor_status
as
select      debtor_idx,
            status,
            cancel_dt,
            balance_dimdebtor,

            case    when    status in  ('ACT','AEX','INC','LEG','LNA','NLT','PAA','PDC','PPA','PPD','PTP','RSD')
                    then    1
                    else    0
                    end     as pass_debtor_status,

            case    when    cancel_dt   is null
                    and     balance_dimdebtor > 0
                    and     batch_date is not null
                    then    1
                    else    0
                    end     as pass_debtor_active

from        edwprodhh.pub_jchang.master_debtor
;



create or replace task
    edwprodhh.pub_jchang.replace_transform_criteria_debtor_status
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_criteria_debtor_status
as
select      debtor_idx,
            status,
            cancel_dt,
            balance_dimdebtor,

            case    when    status in  ('ACT','AEX','INC','LEG','LNA','NLT','PAA','PDC','PPA','PPD','PTP','RSD')
                    then    1
                    else    0
                    end     as pass_debtor_status,

            case    when    cancel_dt   is null
                    and     balance_dimdebtor > 0
                    and     batch_date is not null
                    then    1
                    else    0
                    end     as pass_debtor_active

from        edwprodhh.pub_jchang.master_debtor
;