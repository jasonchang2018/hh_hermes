create or replace view
    edwprodhh.hermes.master_prediction_dialer_file_cubs
as
with proposal as
(
    select      *
    from        edwprodhh.hermes.master_prediction_dialer_file_log
    qualify     execute_time = max(execute_time) over ()
)
, name_mutate as
(
    select      debtor_idx,

                regexp_substr(upper(name1), '^(.*)\\,\\s?', 1, 1, 'e')                                  as last_name,
                regexp_replace(upper(name1), '^.*\\,\\s?', '')                                          as first_name_raw,
                coalesce(regexp_substr(first_name_raw, '\\b(JR\\.?|SR\\.?|I{3,})$', 1, 1, 'e'), '')     as suffix,
                trim(regexp_replace(first_name_raw, '\\b' || suffix || '$', ''))                        as first_name,

                case    when    regexp_like(name1, '^.*\\,.*$')
                        then    trim(first_name || ' ' || last_name || ' ' || suffix)
                        else    name1
                        end     as name_format

    from        edwprodhh.dw.dimdebtor
    where       debtor_idx in (select debtor_idx from proposal)
)
select      debtor.debtornumber         as "ACCOUNT#",
            debtor.logon                as "LOGON",
            names.name_format           as "ACCOUNT",
            debtor.address_1            as "ADDRESS",
            debtor.city                 as "CITY",
            debtor.state                as "ST",
            debtor.zip_code             as "ZIP",
            dimclient.name              as "CLIENT-NAME",
            debtor.balance_dimdebtor    as "BALANCE",
            debtor.status               as "ST-CD",
            proposal.phone,
            proposal.list_name,
            proposal.dialer_file_label, --*HERE, READ IN THE DIALER FILE LABEL
            proposal.upload_date
from        proposal
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on proposal.debtor_idx = debtor.debtor_idx
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on proposal.debtor_idx = dimdebtor.debtor_idx
            inner join
                edwprodhh.pub_jchang.master_client as client
                on debtor.client_idx = client.client_idx
            inner join
                edwprodhh.dw.dimclient as dimclient
                on debtor.client_idx = dimclient.client_idx
            left join
                name_mutate as names
                on proposal.debtor_idx = names.debtor_idx

;





create or replace view
    edwprodhh.hermes.master_prediction_dialer_file_cubs_hh
as
select      *
from        edwprodhh.hermes.master_prediction_dialer_file_cubs
where       logon = 'HH'
            and upload_date = current_date()
;

create or replace view
    edwprodhh.hermes.master_prediction_dialer_file_cubs_co
as
select      *
from        edwprodhh.hermes.master_prediction_dialer_file_cubs
where       logon = 'CO'
            and upload_date = current_date()
;

create or replace view
    edwprodhh.hermes.master_prediction_dialer_file_cubs_dc
as
select      *
from        edwprodhh.hermes.master_prediction_dialer_file_cubs
where       logon = 'DC'
            and upload_date = current_date()
;

create or replace view
    edwprodhh.hermes.master_prediction_dialer_file_cubs_chi
as
select      *
from        edwprodhh.hermes.master_prediction_dialer_file_cubs
where       logon = 'CHI'
            and upload_date = current_date()
;

create or replace view
    edwprodhh.hermes.master_prediction_dialer_file_cubs_pre
as
select      *
from        edwprodhh.hermes.master_prediction_dialer_file_cubs
where       logon = 'PRE'
            and upload_date = current_date()
;