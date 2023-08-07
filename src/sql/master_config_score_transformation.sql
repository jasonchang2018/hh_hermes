--These cutoffs were based on the population of active debtors that are < 730 days in placement.
--Volume distribution may differ depending on the specific subset of the population analyzed.

create table
    edwprodhh.hermes.master_config_score_transformation
as
select 1    as segment,     -9999   as segment_lo,  0.180   as segment_hi union all
select 2    as segment,     0.180   as segment_lo,  0.180   as segment_hi union all
select 3    as segment,     0.180   as segment_lo,  0.299   as segment_hi union all
select 4    as segment,     0.299   as segment_lo,  0.679   as segment_hi union all
select 5    as segment,     0.679   as segment_lo,  1.035   as segment_hi union all
select 6    as segment,     1.035   as segment_lo,  1.491   as segment_hi union all
select 7    as segment,     1.491   as segment_lo,  2.165   as segment_hi union all
select 8    as segment,     2.165   as segment_lo,  3.150   as segment_hi union all
select 9    as segment,     3.150   as segment_lo,  5.724   as segment_hi union all
select 10   as segment,     5.724   as segment_lo,  99999   as segment_hi
;