create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_lastpayment
as
with last_payment as
(
    select      packet_idx,
                max(trans_date) as last_payment_date
    from        edwprodhh.pub_jchang.master_transactions
    where       is_payment = 1
                and trans_date < current_date()
    group by    1
)
select      debtor.debtor_idx,
            last_payment.last_payment_date,

            case    when    last_payment.packet_idx is not null
                    then    1
                    else    0
                    end     as packet_has_previous_payment,
            case    when    count(*) over (partition by debtor.packet_idx order by debtor.batch_date asc) = 1
                    then    1
                    else    0
                    end     as debtor_is_first_in_packet,


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
                            then    case    when    coalesce(last_payment.last_payment_date, '2000-01-01') <= current_date() - 14
                                            then    1
                                            else    0
                                            end
                            else    case    when    coalesce(last_payment.last_payment_date, '2000-01-01') <= current_date() - 14
                                            then    1
                                            else    0
                                            end
                            end     as pass_contraints_packet_last_payment

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                last_payment
                on debtor.packet_idx = last_payment.packet_idx
;



create task
    edwprodhh.pub_jchang.replace_transform_businessrules_debtor_lastpayment
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_businessrules_debtor_lastpayment
as
with last_payment as
(
    select      packet_idx,
                max(trans_date) as last_payment_date
    from        edwprodhh.pub_jchang.master_transactions
    where       is_payment = 1
                and trans_date < current_date()
    group by    1
)
select      debtor.debtor_idx,
            last_payment.last_payment_date,

            case    when    last_payment.packet_idx is not null
                    then    1
                    else    0
                    end     as packet_has_previous_payment,
            case    when    count(*) over (partition by debtor.packet_idx order by debtor.batch_date asc) = 1
                    then    1
                    else    0
                    end     as debtor_is_first_in_packet,


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
                            then    case    when    coalesce(last_payment.last_payment_date, '2000-01-01') <= current_date() - 14
                                            then    1
                                            else    0
                                            end
                            else    case    when    coalesce(last_payment.last_payment_date, '2000-01-01') <= current_date() - 14
                                            then    1
                                            else    0
                                            end
                            end     as pass_contraints_packet_last_payment

from        edwprodhh.pub_jchang.master_debtor as debtor
            left join
                last_payment
                on debtor.packet_idx = last_payment.packet_idx
;