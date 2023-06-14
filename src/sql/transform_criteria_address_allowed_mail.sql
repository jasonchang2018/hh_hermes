create or replace table
    edwprodhh.hermes.transform_criteria_address_allowed_mail
as
select      debtor_idx,
            address_1       as mailing_address,
            city            as mailing_city,
            state           as mailing_state,
            zip_code        as mailing_zip_code,

            case    when    city                is not null
                    and     state               is not null
                    and     zip_code            is not null
                    and     address_1           is not null
                    and     not regexp_like(address_1, '^(MR\\-|UNK|NEED ADDR|NO ADDR|UPDATE|XX|RETURNED MAIL|UNABLE TO CONF|HOMELESS).*', 'i')
                    and     not regexp_like(address_1, '.*(MAIL RETURN).*', 'i')
                    and     state not in ('BC', 'ZZ')
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
            address_1       as mailing_address,
            city            as mailing_city,
            state           as mailing_state,
            zip_code        as mailing_zip_code,

            case    when    city                is not null
                    and     state               is not null
                    and     zip_code            is not null
                    and     address_1           is not null
                    and     not regexp_like(address_1, '^(MR\\-|UNK|NEED ADDR|NO ADDR|UPDATE|XX|RETURNED MAIL|UNABLE TO CONF|HOMELESS).*', 'i')
                    and     not regexp_like(address_1, '.*(MAIL RETURN).*', 'i')
                    and     state not in ('BC', 'ZZ')
                    then    1
                    else    0
                    end     as pass_address_letters

from        edwprodhh.pub_jchang.master_debtor