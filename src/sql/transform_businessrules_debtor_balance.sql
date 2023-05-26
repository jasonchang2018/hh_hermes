create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_balance
as
select      debtor_idx,
            assigned,
            balance_dimdebtor,
            -- sum(case when cancel_dt is not null then balance_dimdebtor else 0 end) over (partition by packet_idx) as balance_dimdebtor_packet_,
            sum(balance_dimdebtor) over (partition by packet_idx) as balance_dimdebtor_packet_,

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
                            -- then    case    when    balance_dimdebtor >= 25
                            then    case    when    balance_dimdebtor > 25
                                            then    1
                                            else    0
                                            end
                            when    pl_group in ('ELIZABETH RIVER CROSSINGS - 3P')
                            -- then    case    when    balance_dimdebtor >= 5
                            then    case    when    balance_dimdebtor > 25
                                            then    1
                                            else    0
                                            end
                            -- else    case    when    balance_dimdebtor >= 50
                            else    case    when    balance_dimdebtor > 25
                                            then    1
                                            else    0
                                            end
                            end     as pass_debtor_balance,

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
                            -- then    case    when    balance_dimdebtor_packet_ >= 50
                            then    case    when    balance_dimdebtor_packet_ > 25
                            -- then    case    when    balance_dimdebtor_packet_ > 50
                                            then    1
                                            else    0
                                            end
                            when    pl_group in ('ELIZABETH RIVER CROSSINGS - 3P')
                            -- then    case    when    balance_dimdebtor_packet_ >= 25
                            then    case    when    balance_dimdebtor_packet_ > 25
                            -- then    case    when    balance_dimdebtor_packet_ > 50
                                            then    1
                                            else    0
                                            end
                            -- else    case    when    balance_dimdebtor_packet_ >= 75
                            else    case    when    balance_dimdebtor_packet_ > 25
                            -- else    case    when    balance_dimdebtor_packet_ > 50
                                            then    1
                                            else    0
                                            end
                            end     as pass_packet_balance,



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
                            -- then    case    when    assigned >= 50
                            then    case    when    assigned > 0
                                            then    1
                                            else    0
                                            end
                            when    pl_group in ('ELIZABETH RIVER CROSSINGS - 3P')
                            -- then    case    when    assigned >= 25CROSSINGS - 3P')
                            then    case    when    assigned > 0
                                            then    1
                                            else    0
                                            end
                            -- else    case    when    assigned >= 75
                            else    case    when    assigned > 0
                                            then    1
                                            else    0
                                            end
                            end     as pass_debtor_assigned

from        edwprodhh.pub_jchang.master_debtor
;



create task
    edwprodhh.pub_jchang.replace_transform_businessrules_debtor_balance
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_balance
as
select      debtor_idx,
            assigned,
            balance_dimdebtor,
            -- sum(case when cancel_dt is not null then balance_dimdebtor else 0 end) over (partition by packet_idx) as balance_dimdebtor_packet_,
            sum(balance_dimdebtor) over (partition by packet_idx) as balance_dimdebtor_packet_,

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
                            -- then    case    when    balance_dimdebtor >= 25
                            then    case    when    balance_dimdebtor > 25
                                            then    1
                                            else    0
                                            end
                            when    pl_group in ('ELIZABETH RIVER CROSSINGS - 3P')
                            -- then    case    when    balance_dimdebtor >= 5
                            then    case    when    balance_dimdebtor > 25
                                            then    1
                                            else    0
                                            end
                            -- else    case    when    balance_dimdebtor >= 50
                            else    case    when    balance_dimdebtor > 25
                                            then    1
                                            else    0
                                            end
                            end     as pass_debtor_balance,

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
                            -- then    case    when    balance_dimdebtor_packet_ >= 50
                            then    case    when    balance_dimdebtor_packet_ > 25
                            -- then    case    when    balance_dimdebtor_packet_ > 50
                                            then    1
                                            else    0
                                            end
                            when    pl_group in ('ELIZABETH RIVER CROSSINGS - 3P')
                            -- then    case    when    balance_dimdebtor_packet_ >= 25
                            then    case    when    balance_dimdebtor_packet_ > 25
                            -- then    case    when    balance_dimdebtor_packet_ > 50
                                            then    1
                                            else    0
                                            end
                            -- else    case    when    balance_dimdebtor_packet_ >= 75
                            else    case    when    balance_dimdebtor_packet_ > 25
                            -- else    case    when    balance_dimdebtor_packet_ > 50
                                            then    1
                                            else    0
                                            end
                            end     as pass_packet_balance,



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
                            -- then    case    when    assigned >= 50
                            then    case    when    assigned > 0
                                            then    1
                                            else    0
                                            end
                            when    pl_group in ('ELIZABETH RIVER CROSSINGS - 3P')
                            -- then    case    when    assigned >= 25CROSSINGS - 3P')
                            then    case    when    assigned > 0
                                            then    1
                                            else    0
                                            end
                            -- else    case    when    assigned >= 75
                            else    case    when    assigned > 0
                                            then    1
                                            else    0
                                            end
                            end     as pass_debtor_assigned

from        edwprodhh.pub_jchang.master_debtor
;