with migration as 
(
    select      client_idx
    from        edwprodhh.pub_jchang.master_client
    where       pl_group in (
                    'CITY OF WASHINGTON DC - ABRA - 3P',
                    'CITY OF WASHINGTON DC - BEGA - 3P',
                    'CITY OF WASHINGTON DC - DHCD - 3P',
                    'CITY OF WASHINGTON DC - DLCP - 3P',
                    'CITY OF WASHINGTON DC - DMV - 3P',
                    'CITY OF WASHINGTON DC - DMV AMNESTY - 3P',
                    'CITY OF WASHINGTON DC - DOB - 3P',
                    'CITY OF WASHINGTON DC - DOC - 3P',
                    'CITY OF WASHINGTON DC - DOEE - 3P',
                    'CITY OF WASHINGTON DC - MPD - 3P',
                    'CITY OF WASHINGTON DC - OAG - 3P',
                    'CITY OF WASHINGTON DC - OLG - 3P',
                    'CITY OF WASHINGTON DC - OP - 3P',
                    'CITY OF WASHINGTON DC - OSSE - 3P',
                    'COUNTY OF LOS ANGELES CA - 3P',
                    'STATE OF PA - TURNPIKE COMMISSION - 3P',
                    'COC - BUILDINGS',
                    'COC - PARKING',
                    'COC - WATER',
                    'COC - OTHER',
                    'COC - TAX'
                )
                and is_fdcpa = 0
    order by    1
)
, sums as
(
    select      case when migration.client_idx is not null then debtor.pl_group else 'ELSE' end as pl_group_,
                count(*)                                                                        as n_letters
    from        edwprodhh.pub_jchang.master_letters as letters
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on letters.debtor_idx = debtor.debtor_idx
                left join
                    migration
                    on letters.client_idx = migration.client_idx
    where       letters.print_date >= '2023-07-01'
                and letters.print_date < '2024-01-01'
    group by    1
    order by    2 desc
)
select      *,
            n_letters / sum(n_letters) over () as p_letters,
            round(p_letters * (600000/4.3), 0) as dol_letters_target
from        sums
order by    2 desc
;