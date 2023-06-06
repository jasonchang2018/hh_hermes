create or replace view
    edwprodhh.hermes.master_config_clients_active
as
select      client_idx,
            logon,
            pl_group
from        edwprodhh.pub_jchang.master_client
where       pl_group in (
                -- 'FRANCISCAN HEALTH - 3P',
                -- 'PRISMA HEALTH - 3P',
                -- 'PRISMA HEALTH - 3P-2',
                -- 'STATE OF KS - DOR - 3P',
                -- 'STATE OF OK - TAX COMMISSION - 3P',
                -- 'UNIVERSAL HEALTH SERVICES - 3P',

                'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P',
                'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P-2',
                'CARLE HEALTHCARE - 3P',
                'CARLE HEALTHCARE - 3P-2',
                'CHILDRENS HOSP OF ATLANTA - 3P',
                'CHOP - 3P',
                'CITY OF LA CA - PARKING CONDUENT - 3P',
                'CITY OF PHILADELPHIA PA - PARKING - 3P',
                'CITY OF SEATTLE WA - MUNI COURT - 3P',
                -- 'ELIZABETH RIVER CROSSINGS - 3P',
                'FRANCISCAN HEALTH - 3P',
                'IU HEALTH - 3P',
                'LOYOLA UNIV HEALTH SYSTEM - 3P',
                'MCLEOD HEALTH - 3P',
                'MOUNT SINAI - 3P',
                'NORTHSHORE UNIV HEALTH - 3P',
                'NORTHWESTERN MEDICINE - 3P',
                'NW COMM HOSP - 3P',
                'PRISMA HEALTH - 3P',
                'PRISMA HEALTH - 3P-2',
                'PROVIDENCE ST JOSEPH HEALTH - 3P',
                'STATE OF IL - DOR - 3P',
                'STATE OF KS - DOR - 3P',
                'STATE OF OK - TAX COMMISSION - 3P',
                'STATE OF PA - TURNPIKE COMMISSION - 3P',
                'STATE OF VA - DOT - 3P',
                'STATE OF VA - DOT - 3P-2',
                'U OF CHICAGO MEDICAL - 3P',
                'U OF IL AT CHICAGO - 3P',
                'UNIVERSAL HEALTH SERVICES - 3P'

            )
            or client_idx in (
                -- 'CO-ERCTB',         --'ELIZABETH RIVER CROSSINGS - 3P'
                'CO-VATBL',         --'STATE OF VA - DOT - 3P-2'
                'CO-VATCBL'         --'STATE OF VA - DOT - 3P-2'
            )
order by    2,3,1
;