select      clients.pl_group,
            letters.letter_code,
            letters.collection_type,
            count(*) as n
from        edwprodhh.pub_jchang.master_letters as letters
            inner join
                edwprodhh.hermes.master_config_clients_active as clients
                on letters.client_idx = clients.client_idx
where       letters.print_date >= '2023-01-01'
            and letters.collection_type != 'Validation'
group by    1,2,3
order by    1,4 desc
;


select      clients.pl_group,
            texts.letter_name,
            count(*) as n
from        edwprodhh.pub_jchang.master_texts as texts
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on texts.debtor_idx = debtor.debtor_idx
            inner join
                edwprodhh.hermes.master_config_clients_active as clients
                on debtor.client_idx = clients.client_idx
where       texts.status_date >= '2023-01-01'
group by    1,2
order by    1,3 desc
;


select      clients.pl_group,
            voapps.letter_name,
            count(*) as n
from        edwprodhh.pub_jchang.master_voapps as voapps
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on voapps.debtor_idx = debtor.debtor_idx
            inner join
                edwprodhh.hermes.master_config_clients_active as clients
                on debtor.client_idx = clients.client_idx
where       voapps.status_date >= '2023-01-01'
group by    1,2
order by    1,3 desc
;