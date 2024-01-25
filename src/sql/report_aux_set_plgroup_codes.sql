with migration as 
(
    select      pl_group
    from        edwprodhh.pub_jchang.master_client
    where       pl_group in (
                    'CITY OF PHILADELPHIA PA - PARKING - 3P',
                    'CITY OF LA CA - FINANCE - 3P'
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