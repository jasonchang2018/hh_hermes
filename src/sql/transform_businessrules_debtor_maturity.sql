create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_maturity
as
select      debtor_idx,
            datediff(day, batch_date,                                       current_date()) as age_placement,
            datediff(day, lst_chg_dt,                                       current_date()) as age_debt,
            datediff(day, max(batch_date) over (partition by packet_idx),   current_date()) as age_packet,


            case    when    pl_group in (
                                'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P-2', 'CHILDRENS HOSP OF ATLANTA - 3P',
                                'FRANCISCAN HEALTH - 3P', 'PROMEDICA HS - 3P-2', 'COUNTY OF LAKE IL - 3P',
                                'STATE OF IL - DOR - 3P', 'STATE OF KS - DOR - 3P',
                                'STATE OF OK - TAX COMMISSION - 3P', 'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P',
                                'NORTHSHORE UNIV HEALTH - 3P', 'NW COMM HOSP - 3P', 'NW COMM HOSP - 3P-2',
                                'UNIVERSAL HEALTH SERVICES - 3P', 'U OF CINCINNATI HEALTH SYSTEM - 3P',
                                'ST ELIZABETH HEALTHCARE - 3P', 'STATE OF VA - DOT - 3P',
                                'STATE OF VA - DOT - 3P-2', 'CITY OF PHILADELPHIA PA - WATER - 3P',
                                'COC - WATER', 'CITY OF WASHINGTON DC - DMV AMNESTY - 3P',
                                'WEILL CORNELL PHY - 3P', 'MD ANDERSON - 3P', 'PALOS HEALTH - 3P',
                                'NICOR - 3P',  'SILVER CROSS - 3P', 'IU SURGICAL CARE AFF - 3P',
                                'EVERSOURCE ENERGY - 3P', 'EVERGY - 3P', 'ASPEN DENTAL - 3P',
                                'PRISMA HEALTH UNIVERSITY - 3P', 'U OF CINCINNATI HEALTH SYSTEM - 3P',
                                'PRISMA HEALTH - 3P', 'PROVIDENCE ST JOSEPH HEALTH - 3P', 'IU HEALTH - 3P'
                            )
                    then    case    when    coalesce(age_debt, 0) <= 1095
                                    then    1
                                    else    0
                                    end
                    else    case    when    coalesce(age_debt, 0) <= 540
                                    then    1
                                    else    0
                                    end
                    end     as pass_debtor_age_debt,



            case    when    pl_group in (
                                'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P-2', 'CHILDRENS HOSP OF ATLANTA - 3P',
                                'FRANCISCAN HEALTH - 3P', 'PROMEDICA HS - 3P-2', 'COUNTY OF LAKE IL - 3P',
                                'STATE OF IL - DOR - 3P', 'STATE OF KS - DOR - 3P',
                                'STATE OF OK - TAX COMMISSION - 3P', 'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P',
                                'NORTHSHORE UNIV HEALTH - 3P', 'NW COMM HOSP - 3P', 'NW COMM HOSP - 3P-2',
                                'UNIVERSAL HEALTH SERVICES - 3P', 'U OF CINCINNATI HEALTH SYSTEM - 3P',
                                'ST ELIZABETH HEALTHCARE - 3P', 'STATE OF VA - DOT - 3P',
                                'STATE OF VA - DOT - 3P-2', 'CITY OF PHILADELPHIA PA - WATER - 3P',
                                'COC - WATER', 'CITY OF WASHINGTON DC - DMV AMNESTY - 3P',
                                'WEILL CORNELL PHY - 3P', 'MD ANDERSON - 3P', 'PALOS HEALTH - 3P',
                                'NICOR - 3P',  'SILVER CROSS - 3P', 'IU SURGICAL CARE AFF - 3P',
                                'EVERSOURCE ENERGY - 3P', 'EVERGY - 3P', 'ASPEN DENTAL - 3P',
                                'PRISMA HEALTH UNIVERSITY - 3P', 'U OF CINCINNATI HEALTH SYSTEM - 3P',
                                'PRISMA HEALTH - 3P', 'PROVIDENCE ST JOSEPH HEALTH - 3P', 'IU HEALTH - 3P'
                            )
                    then    case    when    coalesce(age_placement, 0) <= 540
                                    then    1
                                    else    0
                                    end
                    else    case    when    coalesce(age_placement, 0) <= 270
                                    then    1
                                    else    0
                                    end
                    end     as pass_debtor_age_placement,



            case    when    logon = 'HH'
                    then    case    when    coalesce(age_packet, 0) <= 366
                                    then    1
                                    else    0
                                    end
                    when    logon = 'CO'
                    then    case    when    coalesce(age_packet, 0) <= 731
                                    then    1
                                    else    0
                                    end
                    else    case    when    coalesce(age_packet, 0) <= 366
                                    then    1
                                    else    0
                                    end
                    end     as pass_debtor_age_packet

from        edwprodhh.pub_jchang.master_debtor
;



create task
    edwprodhh.pub_jchang.replace_transform_businessrules_debtor_maturity
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_maturity
as
select      debtor_idx,
            datediff(day, batch_date,                                       current_date()) as age_placement,
            datediff(day, lst_chg_dt,                                       current_date()) as age_debt,
            datediff(day, max(batch_date) over (partition by packet_idx),   current_date()) as age_packet,


            case    when    pl_group in (
                                'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P-2', 'CHILDRENS HOSP OF ATLANTA - 3P',
                                'FRANCISCAN HEALTH - 3P', 'PROMEDICA HS - 3P-2', 'COUNTY OF LAKE IL - 3P',
                                'STATE OF IL - DOR - 3P', 'STATE OF KS - DOR - 3P',
                                'STATE OF OK - TAX COMMISSION - 3P', 'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P',
                                'NORTHSHORE UNIV HEALTH - 3P', 'NW COMM HOSP - 3P', 'NW COMM HOSP - 3P-2',
                                'UNIVERSAL HEALTH SERVICES - 3P', 'U OF CINCINNATI HEALTH SYSTEM - 3P',
                                'ST ELIZABETH HEALTHCARE - 3P', 'STATE OF VA - DOT - 3P',
                                'STATE OF VA - DOT - 3P-2', 'CITY OF PHILADELPHIA PA - WATER - 3P',
                                'COC - WATER', 'CITY OF WASHINGTON DC - DMV AMNESTY - 3P',
                                'WEILL CORNELL PHY - 3P', 'MD ANDERSON - 3P', 'PALOS HEALTH - 3P',
                                'NICOR - 3P',  'SILVER CROSS - 3P', 'IU SURGICAL CARE AFF - 3P',
                                'EVERSOURCE ENERGY - 3P', 'EVERGY - 3P', 'ASPEN DENTAL - 3P',
                                'PRISMA HEALTH UNIVERSITY - 3P', 'U OF CINCINNATI HEALTH SYSTEM - 3P',
                                'PRISMA HEALTH - 3P', 'PROVIDENCE ST JOSEPH HEALTH - 3P', 'IU HEALTH - 3P'
                            )
                    then    case    when    coalesce(age_debt, 0) <= 1095
                                    then    1
                                    else    0
                                    end
                    else    case    when    coalesce(age_debt, 0) <= 540
                                    then    1
                                    else    0
                                    end
                    end     as pass_debtor_age_debt,



            case    when    pl_group in (
                                'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P-2', 'CHILDRENS HOSP OF ATLANTA - 3P',
                                'FRANCISCAN HEALTH - 3P', 'PROMEDICA HS - 3P-2', 'COUNTY OF LAKE IL - 3P',
                                'STATE OF IL - DOR - 3P', 'STATE OF KS - DOR - 3P',
                                'STATE OF OK - TAX COMMISSION - 3P', 'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P',
                                'NORTHSHORE UNIV HEALTH - 3P', 'NW COMM HOSP - 3P', 'NW COMM HOSP - 3P-2',
                                'UNIVERSAL HEALTH SERVICES - 3P', 'U OF CINCINNATI HEALTH SYSTEM - 3P',
                                'ST ELIZABETH HEALTHCARE - 3P', 'STATE OF VA - DOT - 3P',
                                'STATE OF VA - DOT - 3P-2', 'CITY OF PHILADELPHIA PA - WATER - 3P',
                                'COC - WATER', 'CITY OF WASHINGTON DC - DMV AMNESTY - 3P',
                                'WEILL CORNELL PHY - 3P', 'MD ANDERSON - 3P', 'PALOS HEALTH - 3P',
                                'NICOR - 3P',  'SILVER CROSS - 3P', 'IU SURGICAL CARE AFF - 3P',
                                'EVERSOURCE ENERGY - 3P', 'EVERGY - 3P', 'ASPEN DENTAL - 3P',
                                'PRISMA HEALTH UNIVERSITY - 3P', 'U OF CINCINNATI HEALTH SYSTEM - 3P',
                                'PRISMA HEALTH - 3P', 'PROVIDENCE ST JOSEPH HEALTH - 3P', 'IU HEALTH - 3P'
                            )
                    then    case    when    coalesce(age_placement, 0) <= 540
                                    then    1
                                    else    0
                                    end
                    else    case    when    coalesce(age_placement, 0) <= 270
                                    then    1
                                    else    0
                                    end
                    end     as pass_debtor_age_placement,



            case    when    logon = 'HH'
                    then    case    when    coalesce(age_packet, 0) <= 366
                                    then    1
                                    else    0
                                    end
                    when    logon = 'CO'
                    then    case    when    coalesce(age_packet, 0) <= 731
                                    then    1
                                    else    0
                                    end
                    else    case    when    coalesce(age_packet, 0) <= 366
                                    then    1
                                    else    0
                                    end
                    end     as pass_debtor_age_packet

from        edwprodhh.pub_jchang.master_debtor
;