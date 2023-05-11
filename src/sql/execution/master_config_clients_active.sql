create or replace view
    edwprodhh.hermes.master_config_clients_active
as
select      client_idx,
            logon,
            pl_group
from        edwprodhh.pub_jchang.master_client
where       pl_group in (
                'FRANCISCAN HEALTH - 3P',
                'PRISMA HEALTH - 3P',
                'PRISMA HEALTH - 3P-2',
                'STATE OF KS - DOR - 3P',
                'STATE OF OK - TAX COMMISSION - 3P',
                'UNIVERSAL HEALTH SERVICES - 3P'
            )
            or client_idx in (
                'CO-ERCTB',         --'ELIZABETH RIVER CROSSINGS - 3P'
                'CO-VATBL',         --'STATE OF VA - DOT - 3P-2'
                'CO-VATCBL'         --'STATE OF VA - DOT - 3P-2'
            )
order by    2,3,1
;