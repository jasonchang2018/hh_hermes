with migration as 
(
    select      pl_group
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
select      migration.pl_group,
            letters.letter_code,
            letters.collection_type,
            count(*) as n,
            max(letters.print_date) as last_letter_date
from        edwprodhh.pub_jchang.master_letters as letters
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on letters.debtor_idx = debtor.debtor_idx
            inner join
                migration
                on debtor.pl_group = migration.pl_group
where       letters.collection_type = 'Dun'
            and letters.print_date >= '2019-01-01'
            and letters.print_date <  '2024-01-01'
group by    1,2,3
order by    1,4 desc
;