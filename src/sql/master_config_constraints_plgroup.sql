create table
    edwprodhh.hermes.master_config_constraints_plgroup
(
    pl_group                        varchar,
    max_cost_running_client         number(18,2),
    max_cost_running_letters        number(18,2),
    max_cost_running_texts          number(18,2),
    max_cost_running_voapps         number(18,2),
    max_cost_running_emails         number(18,2),
    min_activity_running_client     number(18,2),
    min_activity_running_letters    number(18,2),
    min_activity_running_texts      number(18,2),
    min_activity_running_voapps     number(18,2),
    min_activity_running_emails     number(18,2),
    min_margin_running_client       number(18,2),
    min_margin_running_letters      number(18,2),
    min_margin_running_texts        number(18,2),
    min_margin_running_voapps       number(18,2),
    min_margin_running_emails       number(18,2)
)
;


truncate table edwprodhh.hermes.master_config_constraints_plgroup;

insert into
    edwprodhh.hermes.master_config_constraints_plgroup
select      distinct
            pl_group,
            case    when    pl_group = 'ADVOCATE HC - 3P'                                       then    0
                    when    pl_group = 'ASPEN DENTAL - 3P'                                      then    200
                    when    pl_group = 'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P'                then    550
                    when    pl_group = 'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P-2'              then    550
                    when    pl_group = 'BROWARD HEALTH - 3P'                                    then    450
                    when    pl_group = 'CARLE HEALTHCARE - 3P'                                  then    462
                    when    pl_group = 'CARLE HEALTHCARE - 3P-2'                                then    110
                    when    pl_group = 'CHILDRENS HOSP OF ATLANTA - 3P'                         then    220
                    when    pl_group = 'CHOP - 3P'                                              then    220
                    when    pl_group = 'CITY OF CLEVELAND OH - CONDUENT - 3P'                   then    420
                    when    pl_group = 'CITY OF DETROIT MI - PARKING CONDUENT - 3P'             then    420
                    when    pl_group = 'CITY OF LA CA - PARKING CONDUENT - 3P'                  then    420
                    when    pl_group = 'CITY OF PHILADELPHIA PA - PARKING - 3P'                 then    700
                    when    pl_group = 'CITY OF SEATTLE WA - MUNI COURT - 3P'                   then    560
                    when    pl_group = 'CITY OF WASHINGTON DC - ABRA - 3P'                      then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - BEGA - 3P'                      then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - CCU - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - DHCD - 3P'                      then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - DLCP - 3P'                      then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - DMV - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - DOB - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - DOC - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - DOEE - 3P'                      then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - FEMS - 3P'                      then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - MPD - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - OAG - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - OLG - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - OP - 3P'                        then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - OSSE - 3P'                      then    1500
                    when    pl_group = 'COLUMBIA DOCTORS - 3P'                                  then    1120
                    when    pl_group = 'COUNTY OF CHAMPAIGN IL - 3P'                            then    206
                    when    pl_group = 'COUNTY OF DEKALB IL - 3P'                               then    230
                    when    pl_group = 'COUNTY OF DUPAGE IL - 3P'                               then    186
                    when    pl_group = 'COUNTY OF DUVAL FL - 3P'                                then    150
                    when    pl_group = 'COUNTY OF KANE IL - 3P'                                 then    169
                    when    pl_group = 'COUNTY OF KANKAKEE IL - 3P'                             then    150
                    when    pl_group = 'COUNTY OF KENDALL IL - 3P'                              then    150
                    when    pl_group = 'COUNTY OF LAKE IL - 3P'                                 then    150
                    when    pl_group = 'COUNTY OF LASALLE IL - 3P'                              then    198
                    when    pl_group = 'COUNTY OF LEE IL - 3P'                                  then    251
                    when    pl_group = 'COUNTY OF MADISON IL - 3P'                              then    150
                    when    pl_group = 'COUNTY OF MCHENRY IL - 3P'                              then    180
                    when    pl_group = 'COUNTY OF POLK FL - 3P'                                 then    150
                    when    pl_group = 'COUNTY OF SANGAMON IL - 3P'                             then    150
                    when    pl_group = 'COUNTY OF SARASOTA FL - 3P'                             then    150
                    when    pl_group = 'COUNTY OF VENTURA CA - 3P'                              then    150
                    when    pl_group = 'COUNTY OF WILL IL - 3P'                                 then    178
                    when    pl_group = 'COUNTY OF WINNEBAGO IL - 3P'                            then    206
                    when    pl_group = 'ELIZABETH RIVER CROSSINGS - 3P'                         then    1940
                    when    pl_group = 'EVERGY - 3P'                                            then    150
                    when    pl_group = 'EVERGY - 3P-2'                                          then    100
                    when    pl_group = 'FRANCISCAN HEALTH - 3P'                                 then    4410
                    when    pl_group = 'INTEGRIS HEALTH - 3P-2'                                 then    0
                    when    pl_group = 'IU HEALTH - 3P'                                         then    550
                    when    pl_group = 'IU SURGICAL CARE AFF - 3P'                              then    100
                    when    pl_group = 'LOYOLA UNIV HEALTH SYSTEM - 3P'                         then    220
                    when    pl_group = 'MCLEOD HEALTH - 3P'                                     then    700
                    when    pl_group = 'MOUNT SINAI - 3P'                                       then    110
                    when    pl_group = 'NORTHSHORE UNIV HEALTH - 3P'                            then    840
                    when    pl_group = 'NORTHWESTERN MEDICINE - 3P'                             then    330
                    when    pl_group = 'NW COMM HOSP - 3P'                                      then    110
                    when    pl_group = 'NW COMM HOSP - 3P-2'                                    then    100
                    when    pl_group = 'PALOS HEALTH - 3P'                                      then    50
                    when    pl_group = 'PRISMA HEALTH - 3P'                                     then    880
                    when    pl_group = 'PRISMA HEALTH - 3P-2'                                   then    880
                    when    pl_group = 'PRISMA HEALTH UNIVERSITY - 3P'                          then    490
                    when    pl_group = 'PROMEDICA HS - 3P-2'                                    then    950
                    when    pl_group = 'PROVIDENCE ST JOSEPH HEALTH - 3P'                       then    550
                    when    pl_group = 'PROVIDENCE ST JOSEPH HEALTH - 3P-2'                     then    550
                    when    pl_group = 'SHIRLEY RYAN ABILITY LABS - 3P'                         then    50
                    when    pl_group = 'SILVER CROSS - 3P'                                      then    150
                    when    pl_group = 'SILVER CROSS - HEALTH SYSTEM SERVICES INC - 3P'         then    0
                    when    pl_group = 'ST ELIZABETH HEALTHCARE - 3P'                           then    300
                    when    pl_group = 'STATE OF IL - DOR - 3P'                                 then    464
                    when    pl_group = 'STATE OF IL - DOR - 3P-2'                               then    557
                    when    pl_group = 'STATE OF KS - DOR - 3P'                                 then    1354
                    when    pl_group = 'STATE OF OK - TAX COMMISSION - 3P'                      then    2042
                    when    pl_group = 'STATE OF PA - TURNPIKE COMMISSION - 3P'                 then    970
                    when    pl_group = 'STATE OF VA - DOT - 3P'                                 then    220
                    when    pl_group = 'STATE OF VA - DOT - 3P-2'                               then    1760
                    when    pl_group = 'SWEDISH HOSPITAL - 3P'                                  then    0
                    when    pl_group = 'TPC - SHANNON - HOSP - 3P-2'                            then    600
                    when    pl_group = 'TPC - SHANNON - PHY - 3P-2'                             then    650
                    when    pl_group = 'TPC - UNITED REGIONAL - 3P'                             then    150
                    when    pl_group = 'U OF CHICAGO MEDICAL - 3P'                              then    420
                    when    pl_group = 'U OF CINCINNATI HEALTH SYSTEM - 3P'                     then    420
                    when    pl_group = 'U OF IL AT CHICAGO - 3P'                                then    110
                    when    pl_group = 'UNITED REGIONAL - 3P-2'                                 then    150
                    when    pl_group = 'UNIVERSAL HEALTH SERVICES - 3P'                         then    1320
                    when    pl_group = 'WEILL CORNELL PHY - 3P'                                 then    150
                    else    0
                    end     as  max_cost_running_client,

            case    when    pl_group = 'ADVOCATE HC - 3P'                                       then    0
                    when    pl_group = 'ASPEN DENTAL - 3P'                                      then    0
                    when    pl_group = 'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P'                then    0
                    when    pl_group = 'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P-2'              then    0
                    when    pl_group = 'BROWARD HEALTH - 3P'                                    then    0
                    when    pl_group = 'CARLE HEALTHCARE - 3P'                                  then    0
                    when    pl_group = 'CARLE HEALTHCARE - 3P-2'                                then    0
                    when    pl_group = 'CARLE HEALTHCARE - PHY - 1P'                            then    0
                    when    pl_group = 'CHILDRENS HOSP OF ATLANTA - 3P'                         then    0
                    when    pl_group = 'CHOP - 3P'                                              then    0
                    when    pl_group = 'CITY OF CHICAGO IL - EMS - 3P'                          then    0
                    when    pl_group = 'CITY OF CLEVELAND OH - CONDUENT - 3P'                   then    0
                    when    pl_group = 'CITY OF DALLAS TX - CONDUENT - 3P'                      then    0
                    when    pl_group = 'CITY OF DENVER CO - CONDUENT - 3P'                      then    0
                    when    pl_group = 'CITY OF DETROIT MI - EMS - 3P'                          then    0
                    when    pl_group = 'CITY OF DETROIT MI - PARKING CONDUENT - 3P'             then    0
                    when    pl_group = 'CITY OF EAST LANSING MI - 54-B DISTRICT COURT - 3P'     then    0
                    when    pl_group = 'CITY OF LA CA - EMS - 3P'                               then    0
                    when    pl_group = 'CITY OF LA CA - FINANCE - 3P'                           then    0
                    when    pl_group = 'CITY OF LA CA - PARKING CONDUENT - 3P'                  then    0
                    when    pl_group = 'CITY OF LV NV - MUNI COURT - 1P'                        then    0
                    when    pl_group = 'CITY OF LV NV - MUNI COURT - 3P'                        then    0
                    when    pl_group = 'CITY OF MILWAUKEE WI - 3P'                              then    0
                    when    pl_group = 'CITY OF N LV NV - 3P'                                   then    0
                    when    pl_group = 'CITY OF OKLAHOMA CITY OK - 3P'                          then    0
                    when    pl_group = 'CITY OF OKLAHOMA CITY OK - PARKING - 3P'                then    0
                    when    pl_group = 'CITY OF PHILADELPHIA PA - MISC - 3P'                    then    0
                    when    pl_group = 'CITY OF PHILADELPHIA PA - PARKING - 3P'                 then    0
                    when    pl_group = 'CITY OF PHILADELPHIA PA - WATER - 3P'                   then    0
                    when    pl_group = 'CITY OF SAN FRANCISCO CA - EMS - 3P'                    then    0
                    when    pl_group = 'CITY OF SAN FRANCISCO CA - MTA - 3P'                    then    0
                    when    pl_group = 'CITY OF SEATTLE WA - MUNI COURT - 3P'                   then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - ABRA - 3P'                      then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - BEGA - 3P'                      then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - CCU - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - DHCD - 3P'                      then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - DLCP - 3P'                      then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - DMV - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - DOB - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - DOC - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - DOEE - 3P'                      then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - FEMS - 3P'                      then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - MPD - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - OAG - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - OLG - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - OP - 3P'                        then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - OSSE - 3P'                      then    0
                    when    pl_group = 'COC - BUILDINGS'                                        then    0
                    when    pl_group = 'COC - WATER'                                            then    0
                    when    pl_group = 'COLUMBIA DENTAL - 3P'                                   then    0
                    when    pl_group = 'COLUMBIA DOCTORS - 3P'                                  then    0
                    when    pl_group = 'CONSUMERS ENERGY - 3P'                                  then    0
                    when    pl_group = 'COUNTY OF CHAMPAIGN IL - 3P'                            then    0
                    when    pl_group = 'COUNTY OF DEKALB IL - 3P'                               then    0
                    when    pl_group = 'COUNTY OF DUPAGE IL - 3P'                               then    0
                    when    pl_group = 'COUNTY OF DUVAL FL - 3P'                                then    0
                    when    pl_group = 'COUNTY OF KANE IL - 3P'                                 then    0
                    when    pl_group = 'COUNTY OF KANKAKEE IL - 3P'                             then    0
                    when    pl_group = 'COUNTY OF LAKE IL - 3P'                                 then    0
                    when    pl_group = 'COUNTY OF LASALLE IL - 3P'                              then    0
                    when    pl_group = 'COUNTY OF LEE IL - 3P'                                  then    0
                    when    pl_group = 'COUNTY OF LOS ANGELES CA - 3P'                          then    0
                    when    pl_group = 'COUNTY OF MADISON IL - 3P'                              then    0
                    when    pl_group = 'COUNTY OF MCHENRY IL - 3P'                              then    0
                    when    pl_group = 'COUNTY OF SANGAMON IL - 3P'                             then    0
                    when    pl_group = 'COUNTY OF SARASOTA FL - 3P'                             then    0
                    when    pl_group = 'COUNTY OF TIPPECANOE IN - 3P'                           then    0
                    when    pl_group = 'COUNTY OF VENTURA CA - 3P'                              then    0
                    when    pl_group = 'COUNTY OF WILL IL - 3P'                                 then    0
                    when    pl_group = 'COUNTY OF WINNEBAGO IL - 3P'                            then    0
                    when    pl_group = 'DTE - 3P'                                               then    0
                    when    pl_group = 'DTE - EOP - 1P'                                         then    0
                    when    pl_group = 'ELIZABETH RIVER CROSSINGS - 3P'                         then    0
                    when    pl_group = 'EVERGY - 3P'                                            then    0
                    when    pl_group = 'EVERGY - 3P-2'                                          then    0
                    when    pl_group = 'EVERSOURCE ENERGY - 3P'                                 then    0
                    when    pl_group = 'EVERSOURCE ENERGY - 3P-2'                               then    0
                    when    pl_group = 'EXELON - 3P'                                            then    0
                    when    pl_group = 'FRANCISCAN HEALTH - 3P'                                 then    0
                    when    pl_group = 'FRANCISCAN HEALTH PPLAN - 3P'                           then    0
                    when    pl_group = 'HUDSON UTILITY - 3P'                                    then    0
                    when    pl_group = 'INTEGRIS HEALTH - 3P-2'                                 then    0
                    when    pl_group = 'IU HEALTH - 3P'                                         then    0
                    when    pl_group = 'IU SURGICAL CARE AFF - 3P'                              then    0
                    when    pl_group = 'JUST ENERGY - 3P'                                       then    0
                    when    pl_group = 'LOYOLA UNIV HEALTH SYSTEM - 3P'                         then    0
                    when    pl_group = 'LURIE CHILDRENS - 1P'                                   then    0
                    when    pl_group = 'MCLEOD HEALTH - 3P'                                     then    0
                    when    pl_group = 'MD ANDERSON - 3P'                                       then    0
                    when    pl_group = 'MD ANDERSON - 3P-2'                                     then    0
                    when    pl_group = 'MOUNT SINAI - 3P'                                       then    0
                    when    pl_group = 'NICOR - 3P'                                             then    0
                    when    pl_group = 'NORTHSHORE UNIV HEALTH - 3P'                            then    0
                    when    pl_group = 'NORTHWESTERN MEDICINE - 3P'                             then    0
                    when    pl_group = 'NW COMM HOSP - 3P'                                      then    0
                    when    pl_group = 'NW COMM HOSP - 3P-2'                                    then    0
                    when    pl_group = 'ONE GAS - 3P'                                           then    0
                    when    pl_group = 'PALOS HEALTH - 3P'                                      then    0
                    when    pl_group = 'PRISMA HEALTH - 3P'                                     then    0
                    when    pl_group = 'PRISMA HEALTH - 3P-2'                                   then    0
                    when    pl_group = 'PRISMA HEALTH UNIVERSITY - 3P'                          then    0
                    when    pl_group = 'PROMEDICA HS - 3P-2'                                    then    0
                    when    pl_group = 'PROVIDENCE ST JOSEPH HEALTH - 3P'                       then    0
                    when    pl_group = 'SHIRLEY RYAN ABILITY LABS - 3P'                         then    0
                    when    pl_group = 'SILVER CROSS - 3P'                                      then    0
                    when    pl_group = 'SILVER CROSS - HEALTH SYSTEM SERVICES INC - 3P'         then    0
                    when    pl_group = 'SILVER CROSS - PSMG - 3P'                               then    0
                    when    pl_group = 'ST ELIZABETH HEALTHCARE - 3P'                           then    0
                    when    pl_group = 'STATE OF CO - JUDICIAL DEPT - 3P'                       then    0
                    when    pl_group = 'STATE OF IL - DOR - 3P'                                 then    0
                    when    pl_group = 'STATE OF IL - DOR - 3P-2'                               then    0
                    when    pl_group = 'STATE OF KS - DOR - 3P'                                 then    0
                    when    pl_group = 'STATE OF LA - DOR - 3P'                                 then    0
                    when    pl_group = 'STATE OF MD - DBM CCU - 3P'                             then    0
                    when    pl_group = 'STATE OF OK - TAX COMMISSION - 3P'                      then    0
                    when    pl_group = 'STATE OF PA - TURNPIKE COMMISSION - 3P'                 then    0
                    when    pl_group = 'STATE OF UT - OSDC - 3P'                                then    0
                    when    pl_group = 'STATE OF UT - OSDC - 3P-2'                              then    0
                    when    pl_group = 'STATE OF VA - DOT - 3P'                                 then    0
                    when    pl_group = 'STATE OF VA - DOT - 3P-2'                               then    0
                    when    pl_group = 'SWEDISH HOSPITAL - 3P'                                  then    0
                    when    pl_group = 'TOWER HEALTH HOSP - 3P -2'                              then    0
                    when    pl_group = 'TOWER HEALTH PHYS - 3P -2'                              then    0
                    when    pl_group = 'TPC - SHANNON - HOSP - 3P-2'                            then    0
                    when    pl_group = 'TPC - SHANNON - PHY - 3P-2'                             then    0
                    when    pl_group = 'TPC - UNITED REGIONAL - 3P'                             then    0
                    when    pl_group = 'U OF CHICAGO MEDICAL - 3P'                              then    0
                    when    pl_group = 'U OF CINCINNATI HEALTH SYSTEM - 3P'                     then    0
                    when    pl_group = 'U OF IL AT CHICAGO - 3P'                                then    0
                    when    pl_group = 'UNITED REGIONAL - 3P-2'                                 then    0
                    when    pl_group = 'UNIVERSAL HEALTH SERVICES - 3P'                         then    0
                    when    pl_group = 'WEILL CORNELL PHY - 3P'                                 then    0
                    else    0
                    end     as  max_cost_running_letters,

            case    when    pl_group = 'ADVOCATE HC - 3P'                                       then    0
                    when    pl_group = 'ASPEN DENTAL - 3P'                                      then    0
                    when    pl_group = 'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P'                then    0
                    when    pl_group = 'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P-2'              then    0
                    when    pl_group = 'BROWARD HEALTH - 3P'                                    then    0
                    when    pl_group = 'CARLE HEALTHCARE - 3P'                                  then    462
                    when    pl_group = 'CARLE HEALTHCARE - 3P-2'                                then    110
                    when    pl_group = 'CHILDRENS HOSP OF ATLANTA - 3P'                         then    0
                    when    pl_group = 'CHOP - 3P'                                              then    0
                    when    pl_group = 'CITY OF CLEVELAND OH - CONDUENT - 3P'                   then    420
                    when    pl_group = 'CITY OF DETROIT MI - PARKING CONDUENT - 3P'             then    420
                    when    pl_group = 'CITY OF LA CA - PARKING CONDUENT - 3P'                  then    420
                    when    pl_group = 'CITY OF PHILADELPHIA PA - PARKING - 3P'                 then    700
                    when    pl_group = 'CITY OF SEATTLE WA - MUNI COURT - 3P'                   then    560
                    when    pl_group = 'CITY OF WASHINGTON DC - ABRA - 3P'                      then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - BEGA - 3P'                      then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - CCU - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - DHCD - 3P'                      then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - DLCP - 3P'                      then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - DMV - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - DOB - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - DOC - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - DOEE - 3P'                      then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - FEMS - 3P'                      then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - MPD - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - OAG - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - OLG - 3P'                       then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - OP - 3P'                        then    1500
                    when    pl_group = 'CITY OF WASHINGTON DC - OSSE - 3P'                      then    1500
                    when    pl_group = 'COLUMBIA DOCTORS - 3P'                                  then    1120
                    when    pl_group = 'COUNTY OF CHAMPAIGN IL - 3P'                            then    150
                    when    pl_group = 'COUNTY OF DEKALB IL - 3P'                               then    150
                    when    pl_group = 'COUNTY OF DUPAGE IL - 3P'                               then    150
                    when    pl_group = 'COUNTY OF DUVAL FL - 3P'                                then    150
                    when    pl_group = 'COUNTY OF KANE IL - 3P'                                 then    150
                    when    pl_group = 'COUNTY OF KANKAKEE IL - 3P'                             then    164
                    when    pl_group = 'COUNTY OF KENDALL IL - 3P'                              then    150
                    when    pl_group = 'COUNTY OF LAKE IL - 3P'                                 then    150
                    when    pl_group = 'COUNTY OF LASALLE IL - 3P'                              then    150
                    when    pl_group = 'COUNTY OF LEE IL - 3P'                                  then    150
                    when    pl_group = 'COUNTY OF MADISON IL - 3P'                              then    150
                    when    pl_group = 'COUNTY OF MCHENRY IL - 3P'                              then    150
                    when    pl_group = 'COUNTY OF POLK FL - 3P'                                 then    150
                    when    pl_group = 'COUNTY OF SANGAMON IL - 3P'                             then    163
                    when    pl_group = 'COUNTY OF SARASOTA FL - 3P'                             then    150
                    when    pl_group = 'COUNTY OF VENTURA CA - 3P'                              then    150
                    when    pl_group = 'COUNTY OF WILL IL - 3P'                                 then    150
                    when    pl_group = 'COUNTY OF WINNEBAGO IL - 3P'                            then    150
                    when    pl_group = 'ELIZABETH RIVER CROSSINGS - 3P'                         then    1940
                    when    pl_group = 'EVERGY - 3P'                                            then    150
                    when    pl_group = 'EVERGY - 3P-2'                                          then    100
                    when    pl_group = 'FRANCISCAN HEALTH - 3P'                                 then    3000
                    when    pl_group = 'INTEGRIS HEALTH - 3P-2'                                 then    0
                    when    pl_group = 'IU HEALTH - 3P'                                         then    0
                    when    pl_group = 'IU SURGICAL CARE AFF - 3P'                              then    0
                    when    pl_group = 'LOYOLA UNIV HEALTH SYSTEM - 3P'                         then    0
                    when    pl_group = 'MCLEOD HEALTH - 3P'                                     then    700
                    when    pl_group = 'MOUNT SINAI - 3P'                                       then    110
                    when    pl_group = 'NORTHSHORE UNIV HEALTH - 3P'                            then    840
                    when    pl_group = 'NORTHWESTERN MEDICINE - 3P'                             then    280
                    when    pl_group = 'NW COMM HOSP - 3P'                                      then    110
                    when    pl_group = 'NW COMM HOSP - 3P-2'                                    then    100
                    when    pl_group = 'PALOS HEALTH - 3P'                                      then    50
                    when    pl_group = 'PRISMA HEALTH - 3P'                                     then    840
                    when    pl_group = 'PRISMA HEALTH - 3P-2'                                   then    840
                    when    pl_group = 'PRISMA HEALTH UNIVERSITY - 3P'                          then    490
                    when    pl_group = 'PROMEDICA HS - 3P-2'                                    then    0
                    when    pl_group = 'PROVIDENCE ST JOSEPH HEALTH - 3P'                       then    420
                    when    pl_group = 'PROVIDENCE ST JOSEPH HEALTH - 3P-2'                     then    420
                    when    pl_group = 'SHIRLEY RYAN ABILITY LABS - 3P'                         then    0
                    when    pl_group = 'SILVER CROSS - 3P'                                      then    0
                    when    pl_group = 'SILVER CROSS - HEALTH SYSTEM SERVICES INC - 3P'         then    0
                    when    pl_group = 'ST ELIZABETH HEALTHCARE - 3P'                           then    0
                    when    pl_group = 'STATE OF IL - DOR - 3P'                                 then    1054
                    when    pl_group = 'STATE OF IL - DOR - 3P-2'                               then    1114
                    when    pl_group = 'STATE OF KS - DOR - 3P'                                 then    1968
                    when    pl_group = 'STATE OF OK - TAX COMMISSION - 3P'                      then    1393
                    when    pl_group = 'STATE OF PA - TURNPIKE COMMISSION - 3P'                 then    1200
                    when    pl_group = 'STATE OF VA - DOT - 3P'                                 then    0
                    when    pl_group = 'STATE OF VA - DOT - 3P-2'                               then    0
                    when    pl_group = 'SWEDISH HOSPITAL - 3P'                                  then    0
                    when    pl_group = 'TPC - SHANNON - HOSP - 3P-2'                            then    0
                    when    pl_group = 'TPC - SHANNON - PHY - 3P-2'                             then    0
                    when    pl_group = 'TPC - UNITED REGIONAL - 3P'                             then    0
                    when    pl_group = 'U OF CHICAGO MEDICAL - 3P'                              then    420
                    when    pl_group = 'U OF CINCINNATI HEALTH SYSTEM - 3P'                     then    420
                    when    pl_group = 'U OF IL AT CHICAGO - 3P'                                then    0
                    when    pl_group = 'UNITED REGIONAL - 3P-2'                                 then    0
                    when    pl_group = 'UNIVERSAL HEALTH SERVICES - 3P'                         then    1078
                    when    pl_group = 'WEILL CORNELL PHY - 3P'                                 then    150
                    else    0
                    end     as  max_cost_running_texts,

            case    when    pl_group = 'ADVOCATE HC - 3P'                                       then    0
                    when    pl_group = 'ASPEN DENTAL - 3P'                                      then    200
                    when    pl_group = 'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P'                then    1100
                    when    pl_group = 'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P-2'              then    770
                    when    pl_group = 'BROWARD HEALTH - 3P'                                    then    450
                    when    pl_group = 'CARLE HEALTHCARE - 3P'                                  then    330
                    when    pl_group = 'CARLE HEALTHCARE - 3P-2'                                then    110
                    when    pl_group = 'CARLE HEALTHCARE - PHY - 1P'                            then    0
                    when    pl_group = 'CHILDRENS HOSP OF ATLANTA - 3P'                         then    220
                    when    pl_group = 'CHOP - 3P'                                              then    220
                    when    pl_group = 'CITY OF CHICAGO IL - EMS - 3P'                          then    0
                    when    pl_group = 'CITY OF CLEVELAND OH - CONDUENT - 3P'                   then    0
                    when    pl_group = 'CITY OF DALLAS TX - CONDUENT - 3P'                      then    0
                    when    pl_group = 'CITY OF DENVER CO - CONDUENT - 3P'                      then    0
                    when    pl_group = 'CITY OF DETROIT MI - EMS - 3P'                          then    0
                    when    pl_group = 'CITY OF DETROIT MI - PARKING CONDUENT - 3P'             then    0
                    when    pl_group = 'CITY OF EAST LANSING MI - 54-B DISTRICT COURT - 3P'     then    0
                    when    pl_group = 'CITY OF LA CA - EMS - 3P'                               then    0
                    when    pl_group = 'CITY OF LA CA - FINANCE - 3P'                           then    0
                    when    pl_group = 'CITY OF LA CA - PARKING CONDUENT - 3P'                  then    0
                    when    pl_group = 'CITY OF LV NV - MUNI COURT - 1P'                        then    0
                    when    pl_group = 'CITY OF LV NV - MUNI COURT - 3P'                        then    0
                    when    pl_group = 'CITY OF MILWAUKEE WI - 3P'                              then    0
                    when    pl_group = 'CITY OF N LV NV - 3P'                                   then    0
                    when    pl_group = 'CITY OF OKLAHOMA CITY OK - 3P'                          then    0
                    when    pl_group = 'CITY OF OKLAHOMA CITY OK - PARKING - 3P'                then    0
                    when    pl_group = 'CITY OF PHILADELPHIA PA - MISC - 3P'                    then    0
                    when    pl_group = 'CITY OF PHILADELPHIA PA - PARKING - 3P'                 then    0
                    when    pl_group = 'CITY OF PHILADELPHIA PA - WATER - 3P'                   then    0
                    when    pl_group = 'CITY OF SAN FRANCISCO CA - EMS - 3P'                    then    0
                    when    pl_group = 'CITY OF SAN FRANCISCO CA - MTA - 3P'                    then    0
                    when    pl_group = 'CITY OF SEATTLE WA - MUNI COURT - 3P'                   then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - ABRA - 3P'                      then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - BEGA - 3P'                      then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - CCU - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - DHCD - 3P'                      then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - DLCP - 3P'                      then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - DMV - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - DOB - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - DOC - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - DOEE - 3P'                      then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - FEMS - 3P'                      then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - MPD - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - OAG - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - OLG - 3P'                       then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - OP - 3P'                        then    0
                    when    pl_group = 'CITY OF WASHINGTON DC - OSSE - 3P'                      then    0
                    when    pl_group = 'COC - BUILDINGS'                                        then    0
                    when    pl_group = 'COC - WATER'                                            then    0
                    when    pl_group = 'COLUMBIA DENTAL - 3P'                                   then    0
                    when    pl_group = 'COLUMBIA DOCTORS - 3P'                                  then    0
                    when    pl_group = 'CONSUMERS ENERGY - 3P'                                  then    0
                    when    pl_group = 'COUNTY OF CHAMPAIGN IL - 3P'                            then    0
                    when    pl_group = 'COUNTY OF DEKALB IL - 3P'                               then    0
                    when    pl_group = 'COUNTY OF DUPAGE IL - 3P'                               then    0
                    when    pl_group = 'COUNTY OF DUVAL FL - 3P'                                then    0
                    when    pl_group = 'COUNTY OF KANE IL - 3P'                                 then    0
                    when    pl_group = 'COUNTY OF KANKAKEE IL - 3P'                             then    0
                    when    pl_group = 'COUNTY OF LAKE IL - 3P'                                 then    0
                    when    pl_group = 'COUNTY OF LASALLE IL - 3P'                              then    0
                    when    pl_group = 'COUNTY OF LEE IL - 3P'                                  then    0
                    when    pl_group = 'COUNTY OF LOS ANGELES CA - 3P'                          then    0
                    when    pl_group = 'COUNTY OF MADISON IL - 3P'                              then    0
                    when    pl_group = 'COUNTY OF MCHENRY IL - 3P'                              then    0
                    when    pl_group = 'COUNTY OF SANGAMON IL - 3P'                             then    0
                    when    pl_group = 'COUNTY OF SARASOTA FL - 3P'                             then    0
                    when    pl_group = 'COUNTY OF TIPPECANOE IN - 3P'                           then    0
                    when    pl_group = 'COUNTY OF VENTURA CA - 3P'                              then    0
                    when    pl_group = 'COUNTY OF WILL IL - 3P'                                 then    0
                    when    pl_group = 'COUNTY OF WINNEBAGO IL - 3P'                            then    0
                    when    pl_group = 'DTE - 3P'                                               then    0
                    when    pl_group = 'DTE - EOP - 1P'                                         then    0
                    when    pl_group = 'ELIZABETH RIVER CROSSINGS - 3P'                         then    0
                    when    pl_group = 'EVERGY - 3P'                                            then    150
                    when    pl_group = 'EVERGY - 3P-2'                                          then    100
                    when    pl_group = 'EVERSOURCE ENERGY - 3P'                                 then    0
                    when    pl_group = 'EVERSOURCE ENERGY - 3P-2'                               then    0
                    when    pl_group = 'EXELON - 3P'                                            then    0
                    when    pl_group = 'FRANCISCAN HEALTH - 3P'                                 then    5520
                    when    pl_group = 'FRANCISCAN HEALTH PPLAN - 3P'                           then    0
                    when    pl_group = 'HUDSON UTILITY - 3P'                                    then    0
                    when    pl_group = 'INTEGRIS HEALTH - 3P-2'                                 then    0
                    when    pl_group = 'IU HEALTH - 3P'                                         then    1980
                    when    pl_group = 'IU SURGICAL CARE AFF - 3P'                              then    100
                    when    pl_group = 'JUST ENERGY - 3P'                                       then    0
                    when    pl_group = 'LOYOLA UNIV HEALTH SYSTEM - 3P'                         then    220
                    when    pl_group = 'LURIE CHILDRENS - 1P'                                   then    0
                    when    pl_group = 'MCLEOD HEALTH - 3P'                                     then    440
                    when    pl_group = 'MD ANDERSON - 3P'                                       then    0
                    when    pl_group = 'MD ANDERSON - 3P-2'                                     then    0
                    when    pl_group = 'MOUNT SINAI - 3P'                                       then    0
                    when    pl_group = 'NICOR - 3P'                                             then    0
                    when    pl_group = 'NORTHSHORE UNIV HEALTH - 3P'                            then    880
                    when    pl_group = 'NORTHWESTERN MEDICINE - 3P'                             then    1100
                    when    pl_group = 'NW COMM HOSP - 3P'                                      then    110
                    when    pl_group = 'NW COMM HOSP - 3P-2'                                    then    100
                    when    pl_group = 'ONE GAS - 3P'                                           then    0
                    when    pl_group = 'PALOS HEALTH - 3P'                                      then    50
                    when    pl_group = 'PRISMA HEALTH - 3P'                                     then    1100
                    when    pl_group = 'PRISMA HEALTH - 3P-2'                                   then    1100
                    when    pl_group = 'PRISMA HEALTH UNIVERSITY - 3P'                          then    450
                    when    pl_group = 'PROMEDICA HS - 3P-2'                                    then    950
                    when    pl_group = 'PROVIDENCE ST JOSEPH HEALTH - 3P'                       then    2200
                    when    pl_group = 'SHIRLEY RYAN ABILITY LABS - 3P'                         then    50
                    when    pl_group = 'SILVER CROSS - 3P'                                      then    150
                    when    pl_group = 'SILVER CROSS - HEALTH SYSTEM SERVICES INC - 3P'         then    0
                    when    pl_group = 'SILVER CROSS - PSMG - 3P'                               then    0
                    when    pl_group = 'ST ELIZABETH HEALTHCARE - 3P'                           then    300
                    when    pl_group = 'STATE OF CO - JUDICIAL DEPT - 3P'                       then    0
                    when    pl_group = 'STATE OF IL - DOR - 3P'                                 then    220
                    when    pl_group = 'STATE OF IL - DOR - 3P-2'                               then    200
                    when    pl_group = 'STATE OF KS - DOR - 3P'                                 then    1540
                    when    pl_group = 'STATE OF LA - DOR - 3P'                                 then    0
                    when    pl_group = 'STATE OF MD - DBM CCU - 3P'                             then    0
                    when    pl_group = 'STATE OF OK - TAX COMMISSION - 3P'                      then    1100
                    when    pl_group = 'STATE OF PA - TURNPIKE COMMISSION - 3P'                 then    0
                    when    pl_group = 'STATE OF UT - OSDC - 3P'                                then    0
                    when    pl_group = 'STATE OF UT - OSDC - 3P-2'                              then    0
                    when    pl_group = 'STATE OF VA - DOT - 3P'                                 then    330
                    when    pl_group = 'STATE OF VA - DOT - 3P-2'                               then    2200
                    when    pl_group = 'SWEDISH HOSPITAL - 3P'                                  then    0
                    when    pl_group = 'TOWER HEALTH HOSP - 3P -2'                              then    0
                    when    pl_group = 'TOWER HEALTH PHYS - 3P -2'                              then    0
                    when    pl_group = 'TPC - SHANNON - HOSP - 3P-2'                            then    600
                    when    pl_group = 'TPC - SHANNON - PHY - 3P-2'                             then    650
                    when    pl_group = 'TPC - UNITED REGIONAL - 3P'                             then    150
                    when    pl_group = 'U OF CHICAGO MEDICAL - 3P'                              then    330
                    when    pl_group = 'U OF CINCINNATI HEALTH SYSTEM - 3P'                     then    200
                    when    pl_group = 'U OF IL AT CHICAGO - 3P'                                then    110
                    when    pl_group = 'UNITED REGIONAL - 3P-2'                                 then    150
                    when    pl_group = 'UNIVERSAL HEALTH SERVICES - 3P'                         then    770
                    when    pl_group = 'WEILL CORNELL PHY - 3P'                                 then    0
                    else    0
                    end     as  max_cost_running_voapps,


            0   as  max_cost_running_emails,


            0   as  min_activity_running_client,
            0   as  min_activity_running_letters,
            case    when    pl_group = 'ELIZABETH RIVER CROSSINGS - 3P'                         then    35000
                    else    0
                    end     as  min_activity_running_texts,
            0   as  min_activity_running_voapps,
            0   as  min_activity_running_emails,


            -1  as  min_margin_running_client,
            -1  as  min_margin_running_letters,
            -1  as  min_margin_running_texts,
            -1  as  min_margin_running_voapps,
            -1  as  min_margin_running_emails

from        edwprodhh.hermes.master_config_clients_active
order by    1
;