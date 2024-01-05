--  LETTERS
--  Multiply this average (23%) by Monthly Letters Budget ($600k) then divide by weeks (4.3) = $33k
with hermes as
(
    select      distinct
                pl_group
    from        edwprodhh.hermes.master_config_plgroup
    where       is_client_active_hermes_contacts = 1
    and         is_client_allowed_letters = 1
    order by    1
)
select      date_trunc('month', letters.print_date) as month,
            count(*) as n,
            count(case when letters.collection_type = 'Dun' and hermes.pl_group is not null then 1 end) as n_migrated,
            edwprodhh.pub_jchang.divide(n_migrated, n) as p_migrated
from        edwprodhh.pub_jchang.master_letters as letters
            inner join 
                edwprodhh.pub_jchang.master_debtor as debtor
                on letters.debtor_idx = debtor.debtor_idx
            left join
                hermes
                on debtor.pl_group = hermes.pl_group
where       letters.print_date >= '2023-01-01'
            and letters.print_date < '2024-01-01'
group by    1
order by    1 desc
;


--  TEXTS
--  Divide Monthly Text Budget ($60k) by weeks (4.3) = $14k


--  VOAPPS
--  Divide Monthly Text Budget ($40k) by weeks (4.3) = $9.3k