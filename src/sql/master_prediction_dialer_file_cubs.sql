create or replace view
    edwprodhh.hermes.master_prediction_dialer_file_cubs
as
with proposal as
(
    select      *
    from        edwprodhh.hermes.master_prediction_dialer_file_log
    qualify     execute_time = max(execute_time) over ()
)
select      debtor.logon,               --needs to be separated
            debtor.debtornumber,
            debtor.packet,
            debtor.client,
            debtor.pl_group,
            proposal.phone,
            proposal.list_name,         --needs to be separated?
            proposal.upload_date
from        proposal
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on proposal.debtor_idx = debtor.debtor_idx
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