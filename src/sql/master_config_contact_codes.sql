create or replace view
    edwprodhh.hermes.master_config_contact_codes
as
select  'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P'       as pl_group,    'Dun'           as collection_type,     'AVC2PB'    as letter_code,      NULL           as text_code,   'USUAL'     as voapp_code union all
select  'BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P-2'     as pl_group,    'Dun'           as collection_type,     'AVC2PB'    as letter_code,      NULL           as text_code,   'USUAL'     as voapp_code union all
select  'CARLE HEALTHCARE - 3P'                         as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,     'TXTSMSH1'      as text_code,   'USUAL'     as voapp_code union all
select  'CARLE HEALTHCARE - 3P-2'                       as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,     'TXTSMSH1'      as text_code,   'USUAL'     as voapp_code union all
select  'CHILDRENS HOSP OF ATLANTA - 3P'                as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,      NULL           as text_code,   'USUAL'     as voapp_code union all
select  'CHOP - 3P'                                     as pl_group,    'Dun'           as collection_type,     'HMHHC'     as letter_code,      NULL           as text_code,   'USUAL'     as voapp_code union all
select  'CITY OF CLEVELAND OH - CONDUENT - 3P'          as pl_group,    'Dun'           as collection_type,     'EDN1-CLE'  as letter_code,     NULL            as text_code,   NULL        as voapp_code union all
select  'CITY OF LA CA - PARKING CONDUENT - 3P'         as pl_group,    'Dun'           as collection_type,     'EDN1_LA'   as letter_code,     'TXT1'          as text_code,   NULL        as voapp_code union all
select  'CITY OF PHILADELPHIA PA - PARKING - 3P'        as pl_group,    'Dun'           as collection_type,     'EDN1-PP'   as letter_code,     'TXT-SMS1'      as text_code,   NULL        as voapp_code union all
select  'CITY OF SEATTLE WA - MUNI COURT - 3P'          as pl_group,    'Dun'           as collection_type,     'EDN1-SMC'  as letter_code,     'TXT-SMS1'      as text_code,   NULL        as voapp_code union all
select  'COUNTY OF LOS ANGELES CA - 3P'                 as pl_group,    'Dun'           as collection_type,     'ECCFTAP1'  as letter_code,     NULL            as text_code,   NULL        as voapp_code union all
select  'ELIZABETH RIVER CROSSINGS - 3P'                as pl_group,    'Dun'           as collection_type,     'ERC1'      as letter_code,     'TXT-ERC'       as text_code,   NULL        as voapp_code union all
select  'FRANCISCAN HEALTH - 3P'                        as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,     'TXTSMSH1'      as text_code,   'USUAL'     as voapp_code union all
select  'IU HEALTH - 3P'                                as pl_group,    'Dun'           as collection_type,     'AVC2P'     as letter_code,      NULL           as text_code,   'USUAL'     as voapp_code union all
select  'LOYOLA UNIV HEALTH SYSTEM - 3P'                as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,      NULL           as text_code,   'USUAL'     as voapp_code union all
select  'MCLEOD HEALTH - 3P'                            as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,      NULL           as text_code,   'USUAL'     as voapp_code union all
select  'MOUNT SINAI - 3P'                              as pl_group,    'Dun'           as collection_type,     'HMHHN'     as letter_code,     'TXTNY01'       as text_code,   NULL        as voapp_code union all
select  'NORTHSHORE UNIV HEALTH - 3P'                   as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,     'TXTSMSH1'      as text_code,   'USUAL'     as voapp_code union all
select  'NORTHWESTERN MEDICINE - 3P'                    as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,     'TXTSMSH1'      as text_code,   'USUAL'     as voapp_code union all
select  'NW COMM HOSP - 3P'                             as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,     'TXTSMSH1'      as text_code,   'USUAL'     as voapp_code union all
select  'PRISMA HEALTH - 3P'                            as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,     'TXTSMSH1'      as text_code,   'USUAL'     as voapp_code union all
select  'PRISMA HEALTH - 3P-2'                          as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,     'TXT1-IC'       as text_code,   'USUAL'     as voapp_code union all
select  'PROVIDENCE ST JOSEPH HEALTH - 3P'              as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,     'TXTSMSH1'      as text_code,   'USUAL'     as voapp_code union all
select  'STATE OF IL - DOR - 3P'                        as pl_group,    'Dun'           as collection_type,     'ESOI3'     as letter_code,     'TXT1IC'        as text_code,   'USUAL'     as voapp_code union all
select  'STATE OF KS - DOR - 3P'                        as pl_group,    'Dun'           as collection_type,     'E-KSS3'    as letter_code,     'TXT1IC'        as text_code,   'USUAL'     as voapp_code union all
select  'STATE OF OK - TAX COMMISSION - 3P'             as pl_group,    'Dun'           as collection_type,     'OTC3'      as letter_code,     'TXT1IC'        as text_code,   'USUAL'     as voapp_code union all
select  'STATE OF PA - TURNPIKE COMMISSION - 3P'        as pl_group,    'Dun'           as collection_type,     'PATC1'     as letter_code,     'TXT-SMS1'      as text_code,   NULL        as voapp_code union all
select  'STATE OF VA - DOT - 3P'                        as pl_group,    'Dun'           as collection_type,     'VATAX4'    as letter_code,      NULL           as text_code,   'USUAL'     as voapp_code union all
select  'STATE OF VA - DOT - 3P-2'                      as pl_group,    'Dun'           as collection_type,     'VATAX4'    as letter_code,      NULL           as text_code,   'USUAL'     as voapp_code union all
select  'U OF CHICAGO MEDICAL - 3P'                     as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,      NULL           as text_code,   'USUAL'     as voapp_code union all
select  'U OF IL AT CHICAGO - 3P'                       as pl_group,    'PP Offer'      as collection_type,     'HMHHP'     as letter_code,      NULL           as text_code,   'USUAL'     as voapp_code union all
select  'UNIVERSAL HEALTH SERVICES - 3P'                as pl_group,    'Dun'           as collection_type,     'HMHHU'     as letter_code,     'TXTUHS01'      as text_code,   'USUAL'     as voapp_code




