create or replace view
    edwprodhh.hermes.master_config_contact_codes_client
as
select  'DC-DCRA'   as client_idx,  'CITY OF WASHINGTON DC - CCU - 3P'  as pl_group,    NULL    as collection_type,     NULL    as letter_code,     'TXT-SMS'   as text_code,   NULL    as voapp_code union all
select  'DC-DCRA1'  as client_idx,  'CITY OF WASHINGTON DC - CCU - 3P'  as pl_group,    NULL    as collection_type,     NULL    as letter_code,     'TXT-SMS'   as text_code,   NULL    as voapp_code union all
select  'DC-OFT'    as client_idx,  'CITY OF WASHINGTON DC - CCU - 3P'  as pl_group,    NULL    as collection_type,     NULL    as letter_code,     'TXT-SMS'   as text_code,   NULL    as voapp_code union all
select  'DC-OFTC'   as client_idx,  'CITY OF WASHINGTON DC - CCU - 3P'  as pl_group,    NULL    as collection_type,     NULL    as letter_code,     'TXT-SMS'   as text_code,   NULL    as voapp_code union all
select  'DC-UDCT'   as client_idx,  'CITY OF WASHINGTON DC - CCU - 3P'  as pl_group,    NULL    as collection_type,     NULL    as letter_code,     'TXT-SMS'   as text_code,   NULL    as voapp_code union all
select  'DC-UDCTB'  as client_idx,  'CITY OF WASHINGTON DC - CCU - 3P'  as pl_group,    NULL    as collection_type,     NULL    as letter_code,     'TXT-SMS'   as text_code,   NULL    as voapp_code union all
select  'DC-UMC'    as client_idx,  'CITY OF WASHINGTON DC - CCU - 3P'  as pl_group,    NULL    as collection_type,     NULL    as letter_code,     'TXT1-SMS'  as text_code,   NULL    as voapp_code union all
select  'DC-UMCAI'  as client_idx,  'CITY OF WASHINGTON DC - CCU - 3P'  as pl_group,    NULL    as collection_type,     NULL    as letter_code,     'TXT1-SMS'  as text_code,   NULL    as voapp_code union all
select  'DC-UMCM'   as client_idx,  'CITY OF WASHINGTON DC - CCU - 3P'  as pl_group,    NULL    as collection_type,     NULL    as letter_code,     'TXT1-SMS'  as text_code,   NULL    as voapp_code union all
select  'DC-UMCSP'  as client_idx,  'CITY OF WASHINGTON DC - CCU - 3P'  as pl_group,    NULL    as collection_type,     NULL    as letter_code,     'TXT1-SMS'  as text_code,   NULL    as voapp_code
;