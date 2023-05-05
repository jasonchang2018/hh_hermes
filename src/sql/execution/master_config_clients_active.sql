create or replace view
    edwprodhh.hermes.master_config_clients_active
as
select      client_idx,
            logon,
            pl_group
from        edwprodhh.pub_jchang.master_client
where       pl_group in (
                'UNIVERSAL HEALTH SERVICES - 3P',
                'FRANCISCAN HEALTH - 3P'
                -- 'STATE OF OK - TAX COMMISSION - 3P',
                -- 'STATE OF VA - DOT - 3P-2'
            )
order by    2,3,1
;