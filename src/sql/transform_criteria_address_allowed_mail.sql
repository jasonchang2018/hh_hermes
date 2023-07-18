create or replace table
    edwprodhh.hermes.transform_criteria_address_allowed_mail
as
select      debtor_idx,
            address_1       as mailing_address,
            city            as mailing_city,
            state           as mailing_state,
            zip_code        as mailing_zip_code,

            edwprodhh.pub_jchang.contact_address_valid_mail(address_1, city, state, zip_code) as pass_address_letters

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

            edwprodhh.pub_jchang.contact_address_valid_mail(address_1, city, state, zip_code) as pass_address_letters
            
from        edwprodhh.pub_jchang.master_debtor
;