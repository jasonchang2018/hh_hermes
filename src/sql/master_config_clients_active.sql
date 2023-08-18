create or replace view
    edwprodhh.hermes.master_config_clients_active
as
select      client_idx,
            logon,
            pl_group
from        edwprodhh.pub_jchang.master_client
where       (
                pl_group in (
                    'ADVOCATE HC - 3P',
                    'ASPEN DENTAL - 3P',
                    'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P',
                    'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P-2',
                    'BROWARD HEALTH - 3P',
                    'CARLE HEALTHCARE - 3P',
                    'CARLE HEALTHCARE - 3P-2',
                    'CHILDRENS HOSP OF ATLANTA - 3P',
                    'CHOP - 3P',
                    'CITY OF CLEVELAND OH - CONDUENT - 3P',
                    'CITY OF DETROIT MI - PARKING CONDUENT - 3P',
                    'CITY OF LA CA - PARKING CONDUENT - 3P',
                    'CITY OF PHILADELPHIA PA - PARKING - 3P',
                    'CITY OF SEATTLE WA - MUNI COURT - 3P',
                    'COLUMBIA DOCTORS - 3P',
                    'ELIZABETH RIVER CROSSINGS - 3P',
                    'EVERGY - 3P',
                    'EVERGY - 3P-2',
                    'FRANCISCAN HEALTH - 3P',
                    'INTEGRIS HEALTH - 3P-2',
                    'IU HEALTH - 3P',
                    'IU SURGICAL CARE AFF - 3P',
                    'LOYOLA UNIV HEALTH SYSTEM - 3P',
                    'MCLEOD HEALTH - 3P',
                    'MOUNT SINAI - 3P',
                    'NORTHSHORE UNIV HEALTH - 3P',
                    'NORTHWESTERN MEDICINE - 3P',
                    'NW COMM HOSP - 3P',
                    'NW COMM HOSP - 3P-2',
                    'PALOS HEALTH - 3P',
                    'PRISMA HEALTH - 3P',
                    'PRISMA HEALTH - 3P-2',
                    'PRISMA HEALTH UNIVERSITY - 3P',
                    'PROMEDICA HS - 3P-2',
                    'PROVIDENCE ST JOSEPH HEALTH - 3P',
                    'SHIRLEY RYAN ABILITY LABS - 3P',
                    'SILVER CROSS - 3P',
                    'SILVER CROSS - HEALTH SYSTEM SERVICES INC - 3P',
                    'ST ELIZABETH HEALTHCARE - 3P',
                    'STATE OF IL - DOR - 3P',
                    'STATE OF IL - DOR - 3P-2',
                    'STATE OF KS - DOR - 3P',
                    'STATE OF OK - TAX COMMISSION - 3P',
                    'STATE OF PA - TURNPIKE COMMISSION - 3P',
                    'STATE OF VA - DOT - 3P',
                    'STATE OF VA - DOT - 3P-2',
                    'SWEDISH HOSPITAL - 3P',
                    'TPC - SHANNON - HOSP - 3P-2',
                    'TPC - SHANNON - PHY - 3P-2',
                    'TPC - UNITED REGIONAL - 3P',
                    'U OF CHICAGO MEDICAL - 3P',
                    'U OF CINCINNATI HEALTH SYSTEM - 3P',
                    'U OF IL AT CHICAGO - 3P',
                    'UNITED REGIONAL - 3P-2',
                    'UNIVERSAL HEALTH SERVICES - 3P'

                )
                -- or client_idx in (
                --     -- 'CO-ERCTB',         --'ELIZABETH RIVER CROSSINGS - 3P'
                --     'CO-VATBL',         --'STATE OF VA - DOT - 3P-2'
                --     'CO-VATCBL'         --'STATE OF VA - DOT - 3P-2'
                -- )
            )
            and client_idx not in (
                'CO-SMPLF'
            )
order by    2,3,1
;