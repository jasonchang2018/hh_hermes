with df as
(
    select      *
    from        edwprodhh.hermes.master_prediction_scores_transformation_cubs_log
    qualify     execute_time = max(execute_time) over ()
)
select      pl_group,
            local,

            count(case when dialergrp = 'GRP1'                                  then 1 end) as n_grp_1,
            count(case when dialergrp = 'GRP2'                                  then 1 end) as n_grp_2,
            count(case when dialergrp = 'GRP3'                                  then 1 end) as n_grp_3,
            count(case when dialergrp = 'GRP4'                                  then 1 end) as n_grp_4,
            count(case when dialergrp not in ('GRP1', 'GRP2', 'GRP3', 'GRP4')   then 1 end) as n_grp_other

from        df
group by    1,2
order by    1,2
;