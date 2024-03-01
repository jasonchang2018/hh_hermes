create or replace view
    edwprodhh.hermes.master_prediction_proposal_cubs
as
with proposal as
(
    select      debtor_idx,
                case    when    proposed_channel = 'Text Message'
                        then    case    when    template = 'SIF-SIF'
                                        then    'Texts-SIF'
                                        when    template = 'SIF-TAX'
                                        then    'Texts-TAX'
                                        when    template = 'TAX'
                                        then    'Texts-TAX'
                                        else    'Texts'
                                        end
                        else    proposed_channel
                        end     as proposed_channel
    from        edwprodhh.hermes.master_prediction_proposal_log
    where       is_proposed_contact = 1
                and upload_date = current_date()
    qualify     execute_time = max(execute_time) over ()
)
select      debtor.logon,               --needs to be separated
            debtor.debtornumber,
            proposal.proposed_channel   --does not need to be separated
from        proposal
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on proposal.debtor_idx = debtor.debtor_idx
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