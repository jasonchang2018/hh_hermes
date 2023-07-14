create or replace view
    edwprodhh.hermes.master_prediction_proposal_cubs
as
select      debtor.logon, --needs to be separated
            debtor.debtornumber,
            proposal.proposed_channel --does not need to be separated

from        edwprodhh.hermes.master_prediction_proposal as proposal
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on proposal.debtor_idx = debtor.debtor_idx
                
where       proposal.is_proposed_contact = 1
            and proposal.upload_date = current_date()
;




create or replace view
    edwprodhh.hermes.master_prediction_proposal_cubs_hh
as
select      *
from        edwprodhh.hermes.master_prediction_proposal_cubs
where       logon = 'HH'
;

create or replace view
    edwprodhh.hermes.master_prediction_proposal_cubs_co
as
select      *
from        edwprodhh.hermes.master_prediction_proposal_cubs
where       logon = 'CO'
;

create or replace view
    edwprodhh.hermes.master_prediction_proposal_cubs_dc
as
select      *
from        edwprodhh.hermes.master_prediction_proposal_cubs
where       logon = 'DC'
;

create or replace view
    edwprodhh.hermes.master_prediction_proposal_cubs_chi
as
select      *
from        edwprodhh.hermes.master_prediction_proposal_cubs
where       logon = 'CHI'
;

create or replace view
    edwprodhh.hermes.master_prediction_proposal_cubs_pre
as
select      *
from        edwprodhh.hermes.master_prediction_proposal_cubs
where       logon = 'PRE'
;