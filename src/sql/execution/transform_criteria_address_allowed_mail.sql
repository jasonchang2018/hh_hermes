create or replace table
    edwprodhh.hermes.transform_criteria_address_allowed_mail
as
select      debtor_idx,
            address_1 as mailing_address,

            case    when    address_1 is not null
                    and     left(address_1, 3) != 'MR-'
                    then    1
                    else    0
                    end     as pass_address_letters

from        edwprodhh.pub_jchang.master_debtor
;



create task
    edwprodhh.pub_jchang.replace_transform_criteria_address_allowed_mail
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_criteria_address_allowed_mail
as
select      debtor_idx,
            address_1 as mailing_address,

            case    when    address_1 is not null
                    and     left(address_1, 3) != 'MR-'
                    then    1
                    else    0
                    end     as pass_address_letters

from        edwprodhh.pub_jchang.master_debtor
;