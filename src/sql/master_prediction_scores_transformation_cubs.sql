create or replace view
    edwprodhh.hermes.master_prediction_scores_transformation_cubs
as
-- with dialergrp_lookup as
-- (
--     select      *
--     from        edwprodhh.equabli.dialergrp_master_lookup_eqbscore
-- )
select      
            --  In existing files for both NORMAL and VALIDATION EQB Score
            debtor.logon,
            dimdebtor.packet,
            debtor.debtornumber,
            debtor.pl_group,
            scores.decile_local                                 as local,
            scores.decile_global                                as global,
            
            'TEST'                                              as equabli_treatment_group,
            case    when    round(median(scores.decile_local) over (partition by debtor.packet_idx), 0) in (9,10)
                    then    'GRP4'
                    when    round(median(scores.decile_local) over (partition by debtor.packet_idx), 0) in (7,8)
                    then    'GRP3'
                    when    round(median(scores.decile_local) over (partition by debtor.packet_idx), 0) in (4,5,6)
                    then    'GRP2'
                    when    round(median(scores.decile_local) over (partition by debtor.packet_idx), 0) in (1,2,3)
                    then    'GRP1'
                    else    'GRP1'
                    end     as dialergrp,
            -- dialergrp_lookup.dialergrp as dialergrp,
            
            'TEST'                                              as equabli_validation_treatment_group,
            debtor.batch_date::date + 10                        as equabli_validation_expiration_date

from        edwprodhh.hermes.master_prediction_scores_transformation as scores
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on scores.debtor_idx = debtor.debtor_idx
            inner join
                edwprodhh.dw.dimdebtor as dimdebtor
                on debtor.debtor_idx = dimdebtor.debtor_idx
            -- left join
            --     dialergrp_lookup
            --     on scores.pl_group      = dialergrp_lookup.pl_group
            --     and scores.decile_local = dialergrp_lookup.eqbscore
;




create or replace view edwprodhh.hermes.master_prediction_scores_transformation_cubs_debtor_hh      as select logon, packet, debtornumber, pl_group, local, global, equabli_treatment_group, dialergrp                                      from edwprodhh.hermes.master_prediction_scores_transformation_cubs where logon = 'HH';
create or replace view edwprodhh.hermes.master_prediction_scores_transformation_cubs_debtor_co      as select logon, packet, debtornumber, pl_group, local, global, equabli_treatment_group, dialergrp                                      from edwprodhh.hermes.master_prediction_scores_transformation_cubs where logon = 'CO';
create or replace view edwprodhh.hermes.master_prediction_scores_transformation_cubs_debtor_dc      as select logon, packet, debtornumber, pl_group, local, global, equabli_treatment_group, dialergrp                                      from edwprodhh.hermes.master_prediction_scores_transformation_cubs where logon = 'DC';
create or replace view edwprodhh.hermes.master_prediction_scores_transformation_cubs_debtor_chi     as select logon, packet, debtornumber, pl_group, local, global, equabli_treatment_group, dialergrp                                      from edwprodhh.hermes.master_prediction_scores_transformation_cubs where logon = 'CHI';
create or replace view edwprodhh.hermes.master_prediction_scores_transformation_cubs_debtor_pre     as select logon, packet, debtornumber, pl_group, local, global, equabli_treatment_group, dialergrp                                      from edwprodhh.hermes.master_prediction_scores_transformation_cubs where logon = 'PRE';

create or replace view edwprodhh.hermes.master_prediction_scores_transformation_cubs_debtorval_hh   as select logon, packet, debtornumber, pl_group, local, global, equabli_validation_treatment_group, equabli_validation_expiration_date  from edwprodhh.hermes.master_prediction_scores_transformation_cubs where logon = 'HH';
-- create or replace view edwprodhh.hermes.master_prediction_scores_transformation_cubs_debtorval_co   as select logon, packet, debtornumber, pl_group, local, global, equabli_validation_treatment_group, equabli_validation_expiration_date  from edwprodhh.hermes.master_prediction_scores_transformation_cubs where logon = 'CO';
-- create or replace view edwprodhh.hermes.master_prediction_scores_transformation_cubs_debtorval_dc   as select logon, packet, debtornumber, pl_group, local, global, equabli_validation_treatment_group, equabli_validation_expiration_date  from edwprodhh.hermes.master_prediction_scores_transformation_cubs where logon = 'DC';
-- create or replace view edwprodhh.hermes.master_prediction_scores_transformation_cubs_debtorval_chi  as select logon, packet, debtornumber, pl_group, local, global, equabli_validation_treatment_group, equabli_validation_expiration_date  from edwprodhh.hermes.master_prediction_scores_transformation_cubs where logon = 'CHI';
-- create or replace view edwprodhh.hermes.master_prediction_scores_transformation_cubs_debtorval_pre  as select logon, packet, debtornumber, pl_group, local, global, equabli_validation_treatment_group, equabli_validation_expiration_date  from edwprodhh.hermes.master_prediction_scores_transformation_cubs where logon = 'PRE';