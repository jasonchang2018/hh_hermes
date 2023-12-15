create or replace table
    edwprodhh.hermes.master_config_contact_minimums
(
    PL_GROUP                    VARCHAR(16777216),
    PROPOSED_CHANNEL            VARCHAR(16777216),
    NUMBER_CONTACTS             NUMBER(18,0),
    WITHIN_DAYS_PLACEMENT       NUMBER(18,0),
    DELAY_DAYS_PLACEMENT        NUMBER(18,0),
    TREATMENT_GROUP             VARCHAR(16777216)
)
;

truncate table edwprodhh.hermes.master_config_contact_minimums;


insert into
    edwprodhh.hermes.master_config_contact_minimums
values
    --PL_GROUP                                      --PROPOSED_CHANNEL      --NUMBER_CONTACTS       --WITHIN_DAYS_PLACEMENT     --DELAY_DAYS_PLACEMENT      --TREATMENT_GROUP
    ('CITY OF WASHINGTON DC - ABRA - 3P',           'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - BEGA - 3P',           'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - CCU - 3P',            'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - DHCD - 3P',           'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - DLCP - 3P',           'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - DMV - 3P',            'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - DOB - 3P',            'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - DOC - 3P',            'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - DOEE - 3P',           'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - FEMS - 3P',           'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - MPD - 3P',            'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - OAG - 3P',            'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - OLG - 3P',            'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - OP - 3P',             'Text Message',         2,                      10,                         0,                          'ALL'),
    ('CITY OF WASHINGTON DC - OSSE - 3P',           'Text Message',         2,                      10,                         0,                          'ALL'),
    ('ALL',                                         'Dialer-Agent Call',    1,                      10,                         0,                          'ALL'),
    ('ALL',                                         'Dialer-Agent Call',    2,                      30,                         0,                          'ALL'),
    ('ALL',                                         'Dialer-Agent Call',    3,                      45,                         0,                          'ALL'),

    ----  INTERFERING TREATMENTS  ----

    -- ('ALL',                                         'Letter',               1,                      90,                         0,                          'ALL'),
    -- ('ALL',                                         'Text Message',         1,                      90,                         0,                          'ALL'),



    ----  RESOLUTION TREATMENTS  ----

    --    NOT IN EXP
    ('ALL',                                         'Letter',               1,                      90,                         0,                          'NOT IN EXP'),
    ('ALL',                                         'Text Message',         2,                      90,                         0,                          'NOT IN EXP'),



    ----  EXPERIMENT TREATMENTS  ----

    --    TEST
    ('CARLE HEALTHCARE - 3P',                       'Text Message',         3,                      45,                         0,                          'TEST'),
    ('CARLE HEALTHCARE - 3P-2',                     'Text Message',         3,                      45,                         0,                          'TEST'),
    ('COLUMBIA DENTAL - 3P',                        'Text Message',         3,                      45,                         0,                          'TEST'),
    ('COLUMBIA DOCTORS - 3P',                       'Text Message',         3,                      45,                         0,                          'TEST'),
    ('IU HEALTH - 3P',                              'Text Message',         3,                      45,                         0,                          'TEST'),
    ('MCLEOD HEALTH - 3P',                          'Text Message',         3,                      45,                         0,                          'TEST'),
    ('MOUNT SINAI - 3P',                            'Text Message',         3,                      45,                         0,                          'TEST'),
    ('NORTHSHORE UNIV HEALTH - 3P',                 'Text Message',         3,                      45,                         0,                          'TEST'),
    ('NORTHWESTERN MEDICINE - 3P',                  'Text Message',         3,                      45,                         0,                          'TEST'),
    ('NW COMM HOSP - 3P',                           'Text Message',         3,                      45,                         0,                          'TEST'),
    ('NW COMM HOSP - 3P-2',                         'Text Message',         3,                      45,                         0,                          'TEST'),
    ('PALOS HEALTH - 3P',                           'Text Message',         3,                      45,                         0,                          'TEST'),
    ('PRISMA HEALTH - 3P',                          'Text Message',         3,                      45,                         0,                          'TEST'),
    ('PRISMA HEALTH - 3P-2',                        'Text Message',         3,                      45,                         0,                          'TEST'),
    ('PRISMA HEALTH UNIVERSITY - 3P',               'Text Message',         3,                      45,                         0,                          'TEST'),
    ('PROVIDENCE ST JOSEPH HEALTH - 3P',            'Text Message',         3,                      45,                         0,                          'TEST'),
    ('SWEDISH HOSPITAL - 3P',                       'Text Message',         3,                      45,                         0,                          'TEST'),
    ('U OF CHICAGO MEDICAL - 3P',                   'Text Message',         3,                      45,                         0,                          'TEST'),
    ('U OF CINCINNATI HEALTH SYSTEM - 3P',          'Text Message',         3,                      45,                         0,                          'TEST'),
    ('UNIVERSAL HEALTH SERVICES - 3P',              'Text Message',         3,                      45,                         0,                          'TEST'),
    ('WEILL CORNELL PHY - 3P',                      'Text Message',         3,                      45,                         0,                          'TEST'),
    
    ('CARLE HEALTHCARE - 3P',                       'Letter',               1,                      90,                         45,                         'TEST'),
    ('CARLE HEALTHCARE - 3P-2',                     'Letter',               1,                      90,                         45,                         'TEST'),
    ('COLUMBIA DENTAL - 3P',                        'Letter',               1,                      90,                         45,                         'TEST'),
    ('COLUMBIA DOCTORS - 3P',                       'Letter',               1,                      90,                         45,                         'TEST'),
    ('IU HEALTH - 3P',                              'Letter',               1,                      90,                         45,                         'TEST'),
    ('MCLEOD HEALTH - 3P',                          'Letter',               1,                      90,                         45,                         'TEST'),
    ('MOUNT SINAI - 3P',                            'Letter',               1,                      90,                         45,                         'TEST'),
    ('NORTHSHORE UNIV HEALTH - 3P',                 'Letter',               1,                      90,                         45,                         'TEST'),
    ('NORTHWESTERN MEDICINE - 3P',                  'Letter',               1,                      90,                         45,                         'TEST'),
    ('NW COMM HOSP - 3P',                           'Letter',               1,                      90,                         45,                         'TEST'),
    ('NW COMM HOSP - 3P-2',                         'Letter',               1,                      90,                         45,                         'TEST'),
    ('PALOS HEALTH - 3P',                           'Letter',               1,                      90,                         45,                         'TEST'),
    ('PRISMA HEALTH - 3P',                          'Letter',               1,                      90,                         45,                         'TEST'),
    ('PRISMA HEALTH - 3P-2',                        'Letter',               1,                      90,                         45,                         'TEST'),
    ('PRISMA HEALTH UNIVERSITY - 3P',               'Letter',               1,                      90,                         45,                         'TEST'),
    ('PROVIDENCE ST JOSEPH HEALTH - 3P',            'Letter',               1,                      90,                         45,                         'TEST'),
    ('SWEDISH HOSPITAL - 3P',                       'Letter',               1,                      90,                         45,                         'TEST'),
    ('U OF CHICAGO MEDICAL - 3P',                   'Letter',               1,                      90,                         45,                         'TEST'),
    ('U OF CINCINNATI HEALTH SYSTEM - 3P',          'Letter',               1,                      90,                         45,                         'TEST'),
    ('UNIVERSAL HEALTH SERVICES - 3P',              'Letter',               1,                      90,                         45,                         'TEST'),
    ('WEILL CORNELL PHY - 3P',                      'Letter',               1,                      90,                         45,                         'TEST'),
    


    --    CONTROL
    ('CARLE HEALTHCARE - 3P',                       'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('CARLE HEALTHCARE - 3P-2',                     'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('COLUMBIA DENTAL - 3P',                        'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('COLUMBIA DOCTORS - 3P',                       'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('IU HEALTH - 3P',                              'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('MCLEOD HEALTH - 3P',                          'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('MOUNT SINAI - 3P',                            'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('NORTHSHORE UNIV HEALTH - 3P',                 'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('NORTHWESTERN MEDICINE - 3P',                  'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('NW COMM HOSP - 3P',                           'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('NW COMM HOSP - 3P-2',                         'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('PALOS HEALTH - 3P',                           'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('PRISMA HEALTH - 3P',                          'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('PRISMA HEALTH - 3P-2',                        'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('PRISMA HEALTH UNIVERSITY - 3P',               'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('PROVIDENCE ST JOSEPH HEALTH - 3P',            'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('SWEDISH HOSPITAL - 3P',                       'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('U OF CHICAGO MEDICAL - 3P',                   'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('U OF CINCINNATI HEALTH SYSTEM - 3P',          'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('UNIVERSAL HEALTH SERVICES - 3P',              'Letter',               1,                      60,                         0,                          'CONTROL'),
    ('WEILL CORNELL PHY - 3P',                      'Letter',               1,                      60,                         0,                          'CONTROL'),
    
    ('CARLE HEALTHCARE - 3P',                       'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('CARLE HEALTHCARE - 3P-2',                     'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('COLUMBIA DENTAL - 3P',                        'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('COLUMBIA DOCTORS - 3P',                       'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('IU HEALTH - 3P',                              'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('MCLEOD HEALTH - 3P',                          'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('MOUNT SINAI - 3P',                            'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('NORTHSHORE UNIV HEALTH - 3P',                 'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('NORTHWESTERN MEDICINE - 3P',                  'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('NW COMM HOSP - 3P',                           'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('NW COMM HOSP - 3P-2',                         'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('PALOS HEALTH - 3P',                           'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('PRISMA HEALTH - 3P',                          'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('PRISMA HEALTH - 3P-2',                        'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('PRISMA HEALTH UNIVERSITY - 3P',               'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('PROVIDENCE ST JOSEPH HEALTH - 3P',            'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('SWEDISH HOSPITAL - 3P',                       'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('U OF CHICAGO MEDICAL - 3P',                   'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('U OF CINCINNATI HEALTH SYSTEM - 3P',          'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('UNIVERSAL HEALTH SERVICES - 3P',              'Text Message',         3,                      90,                         60,                         'CONTROL'),
    ('WEILL CORNELL PHY - 3P',                      'Text Message',         3,                      90,                         60,                         'CONTROL')


;