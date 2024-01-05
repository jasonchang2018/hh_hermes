create or replace view
    edwprodhh.hermes.master_config_client_exclude
as
select 'CO-SMPLF'   as client_idx union all     --CITY OF SEATTLE WA - MUNI COURT - 3P
select 'CO-LA040MC' as client_idx union all     --COUNTY OF LOS ANGELES CA - 3P
select 'CO-LA050MC' as client_idx union all     --COUNTY OF LOS ANGELES CA - 3P
select 'CO-LA090MC' as client_idx union all     --COUNTY OF LOS ANGELES CA - 3P
select 'CO-LA120MC' as client_idx union all     --COUNTY OF LOS ANGELES CA - 3P
select 'CO-LA170MC' as client_idx union all     --COUNTY OF LOS ANGELES CA - 3P
select 'CO-LA180MC' as client_idx union all     --COUNTY OF LOS ANGELES CA - 3P
select 'CO-LASCFL'  as client_idx               --COUNTY OF LOS ANGELES CA - 3P
;