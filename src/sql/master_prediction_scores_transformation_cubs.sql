create or replace view
    edwprodhh.hermes.master_prediction_scores_transformation_cubs
as
with dialergrp_lookup as
(
    select      *
    from        edwprodhh.equabli.dialergrp_master_lookup_eqbscore
)
select      debtor.logon,
            dimdebtor.packet,
            debtor.debtornumber,
            debtor.pl_group,
            scores.decile_global    as local,
            scores.decile_local     as global,
            'TEST' as equibli_treatment_group,
            dialergrp_lookup.dialergrp as dialergrp
from        edwprodhh.hermes.master_prediction_scores_transformation as scores
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on scores.debtor_idx = debtor.debtor_idx
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on debtor.debtor_idx = dimdebtor.debtor_idx
            left join
                dialergrp_lookup
                on scores.pl_group      = dialergrp_lookup.pl_group
                and scores.decile_local = dialergrp_lookup.eqbscore
;




create or replace view
    edwprodhh.hermes.master_prediction_scores_transformation_cubs_hh
as
select      *
from        edwprodhh.hermes.master_prediction_scores_transformation_cubs
where       logon = 'HH'
;

create or replace view
    edwprodhh.hermes.master_prediction_scores_transformation_cubs_co
as
select      *
from        edwprodhh.hermes.master_prediction_scores_transformation_cubs
where       logon = 'CO'
;

create or replace view
    edwprodhh.hermes.master_prediction_scores_transformation_cubs_dc
as
select      *
from        edwprodhh.hermes.master_prediction_scores_transformation_cubs
where       logon = 'DC'
;

create or replace view
    edwprodhh.hermes.master_prediction_scores_transformation_cubs_chi
as
select      *
from        edwprodhh.hermes.master_prediction_scores_transformation_cubs
where       logon = 'CHI'
;

create or replace view
    edwprodhh.hermes.master_prediction_scores_transformation_cubs_pre
as
select      *
from        edwprodhh.hermes.master_prediction_scores_transformation_cubs
where       logon = 'PRE'
;