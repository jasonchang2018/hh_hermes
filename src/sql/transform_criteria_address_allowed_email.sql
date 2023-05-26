create or replace table
    edwprodhh.hermes.transform_criteria_address_allowed_email
as
with emails as
(
    select      debtor_idx,
                email_address
    from        edwprodhh.pub_jchang.transform_directory_email_active
    qualify     row_number() over (partition by debtor_idx order by auth_date desc) = 1
)
select      debtor.debtor_idx,
            emails.email_address,

            case    when    emails.debtor_idx is not null 
                    then    1
                    else    0
                    end     as pass_address_emails

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                emails
                on debtor.debtor_idx = emails.debtor_idx
;



create task
    edwprodhh.pub_jchang.replace_transform_criteria_address_allowed_email
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_criteria_address_allowed_email
as
with emails as
(
    select      debtor_idx,
                email_address
    from        edwprodhh.pub_jchang.transform_directory_email_active
    qualify     row_number() over (partition by debtor_idx order by auth_date desc) = 1
)
select      debtor.debtor_idx,
            emails.email_address,

            case    when    emails.debtor_idx is not null 
                    then    1
                    else    0
                    end     as pass_address_emails

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                emails
                on debtor.debtor_idx = emails.debtor_idx
;