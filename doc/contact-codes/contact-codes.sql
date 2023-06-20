select      debtor.pl_group,
            letters.collection_type,
            letters.letter_code,
            count(*) as n
from        edwprodhh.pub_jchang.master_letters as letters
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on letters.debtor_idx = debtor.debtor_idx
            inner join
                edwprodhh.hermes.master_config_clients_active as active_clients_hermes
                on debtor.client_idx = active_clients_hermes.client_idx

where       letters.letter_code >= '2022-10-01'
            and letters.attribution_valid = 1
            and not regexp_like(letters.collection_type, '.*(Validation|Pay Plan|Tax).*')
            and debtor.pl_group in (
                'ADVOCATE HC - 3P',
                'ASPEN DENTAL - 3P',
                'BROWARD HEALTH - 3P',
                'EVERGY - 3P',
                'EVERGY - 3P-2',
                'IU SURGICAL CARE AFF - 3P',
                'NW COMM HOSP - 3P-2',
                'PALOS HEALTH - 3P',
                'PRISMA HEALTH UNIVERSITY - 3P',
                'SHIRLEY RYAN ABILITY LABS - 3P',
                'SILVER CROSS - 3P',
                'SILVER CROSS - HEALTH SYSTEM SERVICES INC - 3P',
                'ST ELIZABETH HEALTHCARE - 3P',
                'STATE OF IL - DOR - 3P-2',
                'SWEDISH HOSPITAL - 3P',
                'TPC - SHANNON - HOSP - 3P-2',
                'TPC - UNITED REGIONAL - 3P',
                'U OF CINCINNATI HEALTH SYSTEM - 3P',
                'UNITED REGIONAL - 3P-2'
            )

group by    1,2,3
order by    1,4 desc
;


select      debtor.pl_group,
            nullif(texts.letter_name, '') as letter_name,
            count(*) as n
from        edwprodhh.pub_jchang.master_texts as texts
            inner join
                edwprodhh.pub_jchang.master_debtor as debtor
                on texts.debtor_idx = debtor.debtor_idx
            inner join
                edwprodhh.hermes.master_config_clients_active as active_clients_hermes
                on debtor.client_idx = active_clients_hermes.client_idx

where       texts.status_date >= '2022-10-01'
            and debtor.pl_group in (
                'ADVOCATE HC - 3P',
                'ASPEN DENTAL - 3P',
                'BROWARD HEALTH - 3P',
                'EVERGY - 3P',
                'EVERGY - 3P-2',
                'IU SURGICAL CARE AFF - 3P',
                'NW COMM HOSP - 3P-2',
                'PALOS HEALTH - 3P',
                'PRISMA HEALTH UNIVERSITY - 3P',
                'SHIRLEY RYAN ABILITY LABS - 3P',
                'SILVER CROSS - 3P',
                'SILVER CROSS - HEALTH SYSTEM SERVICES INC - 3P',
                'ST ELIZABETH HEALTHCARE - 3P',
                'STATE OF IL - DOR - 3P-2',
                'SWEDISH HOSPITAL - 3P',
                'TPC - SHANNON - HOSP - 3P-2',
                'TPC - UNITED REGIONAL - 3P',
                'U OF CINCINNATI HEALTH SYSTEM - 3P',
                'UNITED REGIONAL - 3P-2'
            )

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
            and debtor.pl_group in (
                'ADVOCATE HC - 3P',
                'ASPEN DENTAL - 3P',
                'BROWARD HEALTH - 3P',
                'EVERGY - 3P',
                'EVERGY - 3P-2',
                'IU SURGICAL CARE AFF - 3P',
                'NW COMM HOSP - 3P-2',
                'PALOS HEALTH - 3P',
                'PRISMA HEALTH UNIVERSITY - 3P',
                'SHIRLEY RYAN ABILITY LABS - 3P',
                'SILVER CROSS - 3P',
                'SILVER CROSS - HEALTH SYSTEM SERVICES INC - 3P',
                'ST ELIZABETH HEALTHCARE - 3P',
                'STATE OF IL - DOR - 3P-2',
                'SWEDISH HOSPITAL - 3P',
                'TPC - SHANNON - HOSP - 3P-2',
                'TPC - UNITED REGIONAL - 3P',
                'U OF CINCINNATI HEALTH SYSTEM - 3P',
                'UNITED REGIONAL - 3P-2'
            )
group by    1,2
order by    1,3 desc
;


select * from edwprodhh.hermes.transform_criteria_client_allowed_letters;
select * from edwprodhh.hermes.transform_criteria_client_allowed_texts;
select * from edwprodhh.hermes.transform_criteria_client_allowed_voapps;