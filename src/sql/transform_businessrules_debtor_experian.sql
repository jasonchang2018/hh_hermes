create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_experian
as
select      debtor.debtor_idx,
            dimscore.experian_score,

            case    when    debtor.pl_group in (
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
                            then    case    when    coalesce(dimscore.experian_score, 1000) >= 430
                                            then    1
                                            else    0
                                            end
                            else    case    when    coalesce(dimscore.experian_score, 1000) >= 440
                                            then    1
                                            else    0
                                            end
                            end     as pass_debtor_experian

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                edwprodhh.dw.dimscore as dimscore
                on debtor.debtor_idx = dimscore.dimscore_idx
;



create task
    edwprodhh.pub_jchang.replace_transform_businessrules_debtor_experian
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_experian
as
select      debtor.debtor_idx,
            dimscore.experian_score,

            case    when    debtor.pl_group in (
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
                            then    case    when    coalesce(dimscore.experian_score, 1000) >= 430
                                            then    1
                                            else    0
                                            end
                            else    case    when    coalesce(dimscore.experian_score, 1000) >= 440
                                            then    1
                                            else    0
                                            end
                            end     as pass_debtor_experian

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                edwprodhh.dw.dimscore as dimscore
                on debtor.debtor_idx = dimscore.dimscore_idx
;