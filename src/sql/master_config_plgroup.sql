create or replace table
    edwprodhh.hermes.transform_config_plgroup
(
    PL_GROUP	                        VARCHAR(16777216),          --1
    IS_CLIENT_ACTIVE_HERMES_CONTACTS	NUMBER(1,0),                --2
    IS_CLIENT_ALLOWED_LETTERS	        NUMBER(1,0),                --3
    IS_CLIENT_ALLOWED_TEXTS	            NUMBER(1,0),                --4
    IS_CLIENT_ALLOWED_VOAPPS	        NUMBER(1,0),                --5
    IS_CLIENT_ALLOWED_CALLS	            NUMBER(1,0),                --6

    MAX_COST_RUNNING_CLIENT	            NUMBER(18,2),               --7
    MAX_COST_RUNNING_LETTERS	        NUMBER(18,2),               --8
    MAX_COST_RUNNING_TEXTS	            NUMBER(18,2),               --9
    MAX_COST_RUNNING_VOAPPS	            NUMBER(18,2),               --10
    MAX_COST_RUNNING_EMAILS	            NUMBER(18,2),               --11

    MIN_ACTIVITY_RUNNING_CLIENT	        NUMBER(18,2),               --12
    MIN_ACTIVITY_RUNNING_LETTERS	    NUMBER(18,2),               --13
    MIN_ACTIVITY_RUNNING_TEXTS	        NUMBER(18,2),               --14
    MIN_ACTIVITY_RUNNING_VOAPPS	        NUMBER(18,2),               --15
    MIN_ACTIVITY_RUNNING_EMAILS	        NUMBER(18,2),               --16

    MIN_MARGIN_RUNNING_CLIENT	        NUMBER(18,2),               --17
    MIN_MARGIN_RUNNING_LETTERS	        NUMBER(18,2),               --18
    MIN_MARGIN_RUNNING_TEXTS	        NUMBER(18,2),               --19
    MIN_MARGIN_RUNNING_VOAPPS	        NUMBER(18,2),               --20
    MIN_MARGIN_RUNNING_EMAILS	        NUMBER(18,2),               --21

    LETTER_CODE	                        VARCHAR(8),                 --22
    TEXT_CODE	                        VARCHAR(8),                 --23
    VOAPP_CODE	                        VARCHAR(5),                 --24

    LETTER_CODE_CLIENT	                VARCHAR(16777216),          --25
    TEXT_CODE_CLIENT	                VARCHAR(16777216),          --26
    VOAPP_CODE_CLIENT	                VARCHAR(16777216),          --27
    MIN_ACTIVITY_JSON	                OBJECT                      --28
)
;



insert into
    edwprodhh.hermes.transform_config_plgroup
values
    --1                                                         2,      3,      4,      5,      6,                  7,      8,      9,      10,     11,                 12,     13,     14,     15,     16,                 17,     18,     19,     20,     21,                 22,             23,             24,                         25,     26,     27,     28 ,
    ('ADVOCATE HC - 3P',                                        1,      1,      0,      1,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('ASPEN DENTAL - 3P',                                       1,      1,      0,      1,      1,                  260,    0,      0,      260,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P',                 1,      1,      0,      1,      1,                  1100,   0,      0,      1100,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'AVC2PB',       NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('BAYLOR SCOTT WHITE HEALTHCARE EPIC - 3P-2',               1,      1,      0,      1,      1,                  770,    0,      0,      770,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'AVC2PB',       NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('BROWARD HEALTH - 3P',                                     1,      1,      1,      1,      1,                  585,    0,      0,      585,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('CARLE HEALTHCARE - 3P',                                   1,      1,      1,      1,      1,                  462,    0,      462,    429,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('CARLE HEALTHCARE - 3P-2',                                 1,      1,      1,      1,      1,                  143,    0,      110,    143,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('CARLE HEALTHCARE - PHY - 1P',                             0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CHILDRENS HOSP OF ATLANTA - 3P',                          1,      1,      0,      1,      1,                  286,    0,      0,      286,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('CHOP - 3P',                                               1,      1,      0,      1,      1,                  286,    0,      0,      286,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHC',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('CITY OF CHICAGO IL - EMS - 3P',                           0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF CLEVELAND OH - CONDUENT - 3P',                    1,      1,      1,      0,      1,                  420,    0,      420,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'EDN1-CLE',     NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF DALLAS TX - CONDUENT - 3P',                       0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF DENVER CO - CONDUENT - 3P',                       0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF DETROIT MI - EMS - 3P',                           0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF DETROIT MI - PARKING CONDUENT - 3P',              1,      1,      1,      0,      1,                  420,    0,      420,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF EAST LANSING MI - 54-B DISTRICT COURT - 3P',      0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF INDIANAPOLIS IN - CONDUENT - 3P',                 0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF LA CA - CUPA - 3P',                               0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF LA CA - EMS - 3P',                                0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF LA CA - FINANCE - 3P',                            1,      1,      1,      0,      1,                  150,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF LA CA - PARKING CONDUENT - 3P',                   1,      1,      1,      0,      1,                  420,    0,      420,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'EDN1_LA',      'TXT1',         NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF LV NV - MUNI COURT - 1P',                         0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF LV NV - MUNI COURT - 3P',                         0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF MILWAUKEE WI - 3P',                               0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF N LV NV - 3P',                                    0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF OKLAHOMA CITY OK - 3P',                           0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF OKLAHOMA CITY OK - PARKING - 3P',                 0,      1,      1,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF PHILADELPHIA PA - MISC - 3P',                     0,      1,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF PHILADELPHIA PA - PARKING - 3P',                  1,      1,      1,      0,      1,                  700,    0,      700,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'EDN1-PP',      'TXT-SMS1',     NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF PHILADELPHIA PA - WATER - 3P',                    0,      1,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF SAN DIEGO CA - TOLLWAY - 3P',                     0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF SAN FRANCISCO CA - EMS - 3P',                     0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF SAN FRANCISCO CA - HOSPITALS - 3P',               0,      1,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF SAN FRANCISCO CA - MTA - 3P',                     0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF SANTA FE NM - CONDUENT - 3P',                     0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF SEATTLE WA - MUNI COURT - 3P',                    1,      1,      1,      0,      1,                  560,    0,      560,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'EDN1-SMC',     'TXT-SMS2',     NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF SEATTLE WA - MUNI COURT - 3P-2',                  0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - ABRA - 3P',                       1,      0,      1,      0,      0,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - BEGA - 3P',                       1,      0,      1,      0,      0,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - CCU - 3P',                        1,      1,      1,      0,      1,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - DHCD - 3P',                       1,      0,      1,      0,      0,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - DLCP - 3P',                       1,      1,      1,      0,      0,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - DMV - 3P',                        1,      1,      1,      0,      1,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - DMV AMNESTY - 3P',                0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - DOB - 3P',                        1,      1,      1,      0,      0,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - DOC - 3P',                        1,      0,      1,      0,      0,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - DOEE - 3P',                       1,      1,      1,      0,      0,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - FEMS - 3P',                       1,      1,      1,      0,      1,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT1-SMS',     NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - MPD - 3P',                        1,      1,      1,      0,      0,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - OAG - 3P',                        1,      0,      1,      0,      0,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - OLG - 3P',                        1,      0,      1,      0,      0,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - OP - 3P',                         1,      0,      1,      0,      0,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CITY OF WASHINGTON DC - OSSE - 3P',                       1,      0,      1,      0,      0,                  1500,   0,      1500,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COC - BUILDINGS',                                         0,      1,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COC - PARKING',                                           0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COC - WATER',                                             0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COLUMBIA DENTAL - 3P',                                    1,      1,      1,      0,      1,                  150,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           'TXTNY01',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COLUMBIA DOCTORS - 3P',                                   1,      1,      1,      0,      1,                  1120,   0,      1120,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHCD',       'TXTNY01',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('CONSUMERS ENERGY - 3P',                                   0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF CHAMPAIGN IL - 3P',                             1,      1,      1,      0,      1,                  206,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF DEKALB IL - 3P',                                1,      1,      1,      0,      1,                  230,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF DUPAGE IL - 3P',                                1,      1,      1,      0,      1,                  186,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF DUVAL FL - 3P',                                 1,      1,      1,      0,      1,                  150,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF KANE IL - 3P',                                  1,      1,      1,      0,      1,                  169,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF KANKAKEE IL - 3P',                              1,      1,      1,      0,      1,                  150,    0,      164,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF KENDALL IL - 3P',                               1,      0,      1,      0,      1,                  150,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF LAKE IL - 3P',                                  1,      1,      1,      0,      1,                  150,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF LASALLE IL - 3P',                               1,      1,      1,      0,      1,                  198,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF LEE IL - 3P',                                   1,      1,      1,      0,      1,                  251,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF LOS ANGELES CA - 3P',                           0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  'ECCFTAP1',     NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF LV NV - JUSTICE COURT - 1P',                    0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF LV NV - JUSTICE COURT - 3P',                    0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF MADISON IL - 3P',                               1,      1,      1,      0,      1,                  150,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF MCHENRY IL - 3P',                               1,      1,      1,      0,      1,                  180,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF POLK FL - 3P',                                  1,      0,      1,      0,      1,                  150,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT1',         NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF SANGAMON IL - 3P',                              1,      1,      1,      0,      1,                  150,    0,      163,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF SARASOTA FL - 3P',                              1,      1,      1,      0,      1,                  150,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-CNTY',     NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF SHELBY TN - GENERAL SESSIONS - 3P',             0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF TIPPECANOE IN - 3P',                            0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF VENTURA CA - 3P',                               1,      1,      1,      0,      1,                  150,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF WILL IL - 3P',                                  1,      1,      1,      0,      1,                  178,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-CNTY',     NULL,                       NULL,   NULL,   NULL,   NULL),
    ('COUNTY OF WINNEBAGO IL - 3P',                             1,      1,      1,      0,      1,                  206,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           'TXT-SMS',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('DTE - 3P',                                                0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('DTE - EOP - 1P',                                          0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('ELIZABETH RIVER CROSSINGS - 3P',                          1,      0,      1,      0,      1,                  1000,   0,      1000,   0,      0,                  0,      0,      30000,  0,      0,                  -1,     -1,     -1,     -1,     -1,                 'ERC1',         'TXT-ERC',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('EVERGY - 3P',                                             1,      1,      1,      1,      1,                  195,    0,      150,    195,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHUP',       NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('EVERGY - 3P-2',                                           1,      1,      1,      1,      1,                  100,    0,      100,    100,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHUP',       NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('EVERSOURCE ENERGY - 3P',                                  0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('EVERSOURCE ENERGY - 3P-2',                                0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('EXELON - 3P',                                             0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('FRANCISCAN HEALTH - 3P',                                  1,      1,      1,      1,      1,                  5733,   0,      3000,   5733,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('FRANCISCAN HEALTH PPLAN - 3P',                            0,      1,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('HUDSON UTILITY - 3P',                                     0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('HUDSON UTILITY - 3P-2',                                   0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('INGALLS MEMORIAL HOSPITAL - 3P',                          1,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('INTEGRIS HEALTH - 3P',                                    0,      0,      0,      1,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('INTEGRIS HEALTH - 3P-2',                                  0,      0,      0,      1,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('IU HEALTH - 3P',                                          1,      1,      0,      1,      1,                  1980,   0,      0,      1980,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'AVC2P',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('IU SURGICAL CARE AFF - 3P',                               1,      1,      0,      1,      1,                  130,    0,      0,      130,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHSP',       NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('JUST ENERGY - 3P',                                        0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('LOYOLA UNIV HEALTH SYSTEM - 3P',                          1,      1,      0,      1,      1,                  286,    0,      0,      286,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('LURIE CHILDRENS - 1P',                                    0,      1,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('MCLEOD HEALTH - 3P',                                      1,      1,      1,      1,      1,                  700,    0,      700,    572,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('MD ANDERSON - 3P',                                        0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('MD ANDERSON - 3P-2',                                      0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('MOUNT SINAI - 3P',                                        1,      1,      1,      0,      1,                  110,    0,      110,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHN',        'TXTNY01',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('NICOR - 3P',                                              0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('NORTHSHORE UNIV HEALTH - 3P',                             1,      1,      1,      1,      1,                  1092,   0,      840,    1092,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('NORTHWESTERN MEDICINE - 3P',                              1,      1,      1,      1,      1,                  1100,   0,      280,    1100,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('NW COMM HOSP - 3P',                                       1,      1,      1,      1,      1,                  143,    0,      110,    143,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('NW COMM HOSP - 3P-2',                                     1,      1,      1,      1,      1,                  130,    0,      100,    130,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('ONE GAS - 3P',                                            0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('PALOS HEALTH - 3P',                                       1,      1,      1,      1,      1,                  65,     0,      50,     65,     0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('PRISMA HEALTH - 3P',                                      1,      1,      1,      1,      1,                  1144,   0,      840,    1144,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('PRISMA HEALTH - 3P-2',                                    1,      1,      1,      1,      1,                  1144,   0,      840,    1144,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('PRISMA HEALTH UNIVERSITY - 3P',                           1,      1,      1,      1,      1,                  585,    0,      490,    585,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'AVC2P',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('PROMEDICA HS - 3P',                                       0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('PROMEDICA HS - 3P-2',                                     1,      1,      0,      1,      1,                  1235,   0,      0,      1235,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('PROVIDENCE ST JOSEPH HEALTH - 3P',                        1,      1,      1,      1,      1,                  2200,   0,      420,    2200,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('SHIRLEY RYAN ABILITY LABS - 3P',                          1,      1,      0,      1,      1,                  65,     0,      0,      65,     0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('SILVER CROSS - 3P',                                       1,      1,      0,      1,      1,                  195,    0,      0,      195,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('SILVER CROSS - HEALTH SYSTEM SERVICES INC - 3P',          1,      1,      0,      1,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('SILVER CROSS - PSMG - 3P',                                0,      1,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('ST ELIZABETH HEALTHCARE - 3P',                            1,      1,      0,      1,      1,                  390,    0,      0,      390,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('STATE OF AZ - FARE - CONDUENT - 3P',                      1,      0,      1,      0,      1,                  150,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           'TXT-AZF',      NULL,                       NULL,   NULL,   NULL,   NULL),
    ('STATE OF CO - JUDICIAL DEPT - 3P',                        0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('STATE OF IL - DOR - 3P',                                  1,      1,      1,      1,      1,                  464,    0,      1054,   286,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'ESOI3',        'TXT1IC',       'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('STATE OF IL - DOR - 3P-2',                                1,      1,      1,      1,      1,                  557,    0,      1114,   260,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'ESOI3',        'TXT1IC',       'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('STATE OF KS - DOR - 3P',                                  1,      1,      1,      1,      1,                  1760,   0,      1968,   1760,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'E-KSS3',       'TXT3IC',       'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('STATE OF LA - DOR - 3P',                                  0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('STATE OF MD - DBM CCU - 3P',                              0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('STATE OF NY - DOT - 3P',                                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('STATE OF OK - TAX COMMISSION - 3P',                       1,      1,      1,      1,      1,                  2042,   0,      1393,   1430,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'OTC3',         'TXT1IC',       'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('STATE OF PA - TURNPIKE COMMISSION - 3P',                  1,      1,      1,      0,      1,                  970,    0,      1200,   0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'PATC1',        'TXT-SMS1',     NULL,                       NULL,   NULL,   NULL,   NULL),
    ('STATE OF UT - OSDC - 3P',                                 0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('STATE OF UT - OSDC - 3P-2',                               0,      1,      1,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('STATE OF VA - DOT - 3P',                                  1,      1,      0,      1,      1,                  330,    0,      0,      330,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'VATAX4',       NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('STATE OF VA - DOT - 3P-2',                                1,      1,      0,      1,      1,                  2288,   0,      0,      2288,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'VATAX4',       NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('STATE OF VA - DOT - ACCESS - 3P',                         0,      0,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('SWEDISH HOSPITAL - 3P',                                   1,      1,      1,      1,      1,                  100,    0,      100,    0,      0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHSP',       'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('TOWER HEALTH HOSP - 3P -2',                               0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('TOWER HEALTH PHYS - 3P -2',                               0,      1,      0,      0,      1,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           NULL,           NULL,                       NULL,   NULL,   NULL,   NULL),
    ('TPC - SHANNON - HOSP - 3P-2',                             1,      1,      0,      1,      1,                  780,    0,      0,      780,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHSP',       NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('TPC - SHANNON - PHY - 3P-2',                              1,      1,      0,      1,      1,                  845,    0,      0,      845,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHSP',       NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('TPC - UNITED REGIONAL - 3P',                              1,      1,      0,      1,      1,                  195,    0,      0,      195,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHH',         NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('U OF CHICAGO MEDICAL - 3P',                               1,      1,      1,      1,      1,                  429,    0,      420,    429,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        'TXTSMSH1',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('U OF CINCINNATI HEALTH SYSTEM - 3P',                      1,      1,      1,      1,      1,                  420,    0,      420,    260,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHPUC',      'TXT1',         'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('U OF IL AT CHICAGO - 3P',                                 1,      1,      0,      1,      1,                  143,    0,      0,      143,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHP',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('UNITED REGIONAL - 3P-2',                                  1,      1,      0,      1,      1,                  195,    0,      0,      195,    0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'AVC2P',        NULL,           'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('UNIVERSAL HEALTH SERVICES - 3P',                          1,      1,      1,      1,      1,                  1320,   0,      1078,   1001,   0,                  0,      0,      0,      0,      0,                  -1,     -1,     -1,     -1,     -1,                 'HMHHU',        'TXTSIF01',     'USUAL',                    NULL,   NULL,   NULL,   NULL),
    ('WEILL CORNELL PHY - 3P',                                  1,      1,      1,      0,      1,                  500,    0,      150,    0,      0,                  0,      0,      0,      0,      0,                  0,      0,      0,      0,      0,                  NULL,           'TXTNY01',      NULL,                       NULL,   NULL,   NULL,   NULL)
;



create or replace table
    edwprodhh.hermes.master_config_plgroup
as
with agg_codes_client as
(
    with df as
    (
        select      client_idx,
                    pl_group,
                    letter_code::varchar    as letter_code,
                    text_code::varchar      as text_code,
                    voapp_code::varchar     as voapp_code
        from        edwprodhh.hermes.master_config_contact_codes_client
    )
    , unpvt as
    (
        select      pl_group,
                    channel,
                    object_agg(client_idx, code::variant)::varchar as obj
        from        df
                    unpivot(
                        code for channel in (
                            letter_code,
                            text_code,
                            voapp_code
                        )
                    )
        group by    1,2
        order by    1,2
    )
    , pvt as
    (
        select      *
        from        unpvt
                    pivot(
                        max(obj) for channel in (
                            'LETTER_CODE',
                            'TEXT_CODE',
                            'VOAPP_CODE'
                        )
                    )   as pvt (
                        pl_group,
                        letter_code,
                        text_code,
                        voapp_code
                    )
    )
    select      *
    from        pvt
)
, agg_activity_minimums as
(
    with df as
    (
        select      *,
                    proposed_channel || '-' || lpad(number_contacts, 3, '0') || '-' || lpad(within_days_placement, 3, '0') as rule_key
        from        edwprodhh.hermes.master_config_contact_minimums
    )
    , unpvt as
    (
        select      *
        from        df
                    unpivot (
                        metric_value for metric_name in (
                            number_contacts,
                            within_days_placement
                        )
                    )
    )
    , by_rulekey as
    (
        select      pl_group,
                    proposed_channel,
                    rule_key,
                    object_agg(metric_name, metric_value) as rule_params
        from        unpvt
        group by    1,2,3
        order by    1,2,3
    )
    , by_channel as
    (
        select      pl_group,
                    proposed_channel,
                    array_agg(rule_params) as rule_params_array
        from        by_rulekey
        group by    1,2
        order by    1,2
    )
    , by_client as
    (
        select      pl_group,
                    object_agg(proposed_channel, rule_params_array::variant) as json_minimums
        from        by_channel
        group by    1
        order by    1
    )
    select      *
    from        by_client
    order by    1
)
select      
            config_main.pl_group,

            --  PRODUCTION CONFIGS
            config_main.is_client_active_hermes_contacts,
            config_main.is_client_allowed_letters,
            config_main.is_client_allowed_texts,
            config_main.is_client_allowed_voapps,
            config_main.is_client_allowed_calls,
            config_main.max_cost_running_client,
            config_main.max_cost_running_letters,
            config_main.max_cost_running_texts,
            config_main.max_cost_running_voapps,
            config_main.max_cost_running_emails,
            config_main.min_activity_running_client,
            config_main.min_activity_running_letters,
            config_main.min_activity_running_texts,
            config_main.min_activity_running_voapps,
            config_main.min_activity_running_emails,
            config_main.min_margin_running_client,
            config_main.min_margin_running_letters,
            config_main.min_margin_running_texts,
            config_main.min_margin_running_voapps,
            config_main.min_margin_running_emails,


            --  SUMMARY
            config_main.letter_code,
            config_main.text_code,
            config_main.voapp_code,

            codes_client.letter_code                                        as letter_code_client,
            codes_client.text_code                                          as text_code_client,
            codes_client.voapp_code                                         as voapp_code_client,

            act_mins.json_minimums                                          as min_activity_json

from        edwprodhh.hermes.transform_config_plgroup as config_main

            left join
                agg_codes_client as codes_client
                on config_main.pl_group = codes_client.pl_group
            left join
                agg_activity_minimums as act_mins
                on config_main.pl_group = act_mins.pl_group

            -- left join (select distinct pl_group from edwprodhh.hermes.master_config_clients_active)     as active           on pl_groups.pl_group = active.pl_group         --this was client ID level, probably still need something for that. include PL Groups + exclude Client IDs?

order by    1
;   