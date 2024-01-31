with migration as 
(
    select      client_idx
    from        edwprodhh.pub_jchang.master_client
    where       pl_group in (
                    'STATE OF IL - DOR - 3P',
                    'STATE OF IL - DOR - 3P-2',
                    'STATE OF VA - DOT - 3P',
                    'STATE OF VA - DOT - 3P-2',
                    'STATE OF VA - DOT - ACCESS - 3P',
                    'STATE OF VA - DOT - BK'
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


--  Check Volumes.
select      date_trunc('month', letters.print_date) as send_month,
            count(*) as n,
            count(case when debtor.pl_group = 'STATE OF OK - TAX COMMISSION - 3P' then 1 end) as otc,
            count(case when debtor.pl_group = 'STATE OF PA - TURNPIKE COMMISSION - 3P' then 1 end) as turnpike
from        edwprodhh.pub_jchang.master_letters as letters
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on letters.debtor_idx = debtor.debtor_idx
where       letters.print_date >= '2023-01-01'
            and letters.print_date < '2024-01-01'
group by    1
order by    1 desc
;