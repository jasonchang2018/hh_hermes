create or replace table
    edwprodhh.hermes.report_test_replace_letters_20231211_results
as
with debtor as
(
    with pool_log as
    (
        select      debtor_idx,
                    treatment_group
        from        edwprodhh.hermes.master_prediction_pool_log
        where       execute_time = (select max(execute_time) from edwprodhh.hermes.master_prediction_pool_log)
    )
    select      debtor.debtor_idx,
                debtor.packet_idx,
                pool_log.treatment_group,
                debtor.batch_date,
                debtor.pl_group,
                debtor.commission
    from        pool_log
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on pool_log.debtor_idx = debtor.debtor_idx
                    and debtor.batch_date >= '2023-12-11'
                    and debtor.pl_group not in (
                        'LURIE CHILDRENS - 1P',
                        'CARLE HEALTHCARE - PHY - 1P',
                        'PROVIDENCE ST JOSEPH HEALTH - 3P-2'
                    )
)
, contacts as
(
    select      contacts.debtor_idx,

                count(case when contacts.contact_type = 'Letter'                                                                                        then 1 end) as n_letters_,
                count(case when contacts.contact_type = 'Letter'        and letters.collection_type != 'Validation'                                     then 1 end) as n_letters_dunning_,
                count(case when contacts.contact_type = 'Letter'        and letters.collection_type =  'Validation'                                     then 1 end) as n_letters_validation_,
                count(case when contacts.contact_type = 'Text Message'                                                                                  then 1 end) as n_texts_,
                count(case when contacts.contact_type = 'VoApp'                                                                                         then 1 end) as n_voapps_,
                count(case when contacts.contact_type = 'Email'                                                                                         then 1 end) as n_emails_,
                count(case when contacts.contact_type in ('Dialer-Agent Call', 'Dialer-Agentless Call', 'Dialer-IMC Call', 'Outbound-Manual Call')      then 1 end) as n_dialer_

    from        edwprodhh.pub_jchang.transform_contacts as contacts
                left join
                    edwprodhh.pub_jchang.master_letters as letters
                    on contacts.contact_id = letters.letter_id
                    and letters.letter_code not in ('NV60')
    where       contacts.debtor_idx in (select debtor_idx from debtor)
    group by    1
)
, attr as
(
    select      attr.debtor_idx,

                sum(case when attr.contact_type = 'Letter'                                                                                              then attr.sig_comm_amt end) as dol_attr_letters_,
                sum(case when attr.contact_type = 'Letter'                   and letters.collection_type != 'Validation'                                then attr.sig_comm_amt end) as dol_attr_letters_dunning_,
                sum(case when attr.contact_type = 'Letter'                   and letters.collection_type =  'Validation'                                then attr.sig_comm_amt end) as dol_attr_letters_validation_,
                sum(case when attr.contact_type = 'Text Message'                                                                                        then attr.sig_comm_amt end) as dol_attr_texts_,
                sum(case when attr.contact_type = 'VoApp'                                                                                               then attr.sig_comm_amt end) as dol_attr_voapps_,
                sum(case when attr.contact_type = 'Email'                                                                                               then attr.sig_comm_amt end) as dol_attr_emails_,
                sum(case when attr.contact_type in ('Dialer-Agent Call', 'Dialer-Agentless Call', 'Dialer-IMC Call', 'Outbound-Manual Call')            then attr.sig_comm_amt end) as dol_attr_dialer_,
                sum(case when attr.contact_type = 'Inbound-Agent Call'                                                                                  then attr.sig_comm_amt end) as dol_attr_ibcall_,
                sum(case when attr.contact_type = 'No Contact'                                                                                          then attr.sig_comm_amt end) as dol_attr_nocontact_

    from        (
                    select      debtor_idx,
                                contact_id,
                                contact_type,
                                sum(sig_comm_amt * attribution_weight) as sig_comm_amt
                    -- from        edwprodhh.pub_jchang.transform_payment_attribution_contact_weights
                    from        edwprodhh.pub_jchang.transform_payment_attribution_ibcall_distributed_contact_weights
                    where       debtor_idx in (select debtor_idx from debtor)
                    group by    1,2,3
                )   as attr
                left join
                    edwprodhh.pub_jchang.master_letters as letters
                    on attr.contact_id = letters.letter_id
                    and letters.letter_code not in ('NV60')
    group by    1
)
select      debtor.pl_group,
            debtor.treatment_group,
            'ddddd'                                                             as tableau_relation,
            

            count(*)                                                            as n_debtors,
            count(distinct debtor.packet_idx)                                   as n_packets,
            sum(debtor.commission)                                              as fee,

            sum(coalesce(contacts.n_letters_,               0))                 as n_letters,
            sum(coalesce(contacts.n_letters_dunning_,       0))                 as n_letters_dunning,
            sum(coalesce(contacts.n_letters_validation_,    0))                 as n_letters_validation,
            sum(coalesce(contacts.n_texts_,                 0))                 as n_texts,
            sum(coalesce(contacts.n_voapps_,                0))                 as n_voapps,
            sum(coalesce(contacts.n_emails_,                0))                 as n_emails,
            sum(coalesce(contacts.n_dialer_,                0))                 as n_dialer,

            sum(coalesce(attr.dol_attr_letters_,            0))                 as dol_attr_letters,
            sum(coalesce(attr.dol_attr_letters_dunning_,    0))                 as dol_attr_letters_dunning,
            sum(coalesce(attr.dol_attr_letters_validation_, 0))                 as dol_attr_letters_validation,
            sum(coalesce(attr.dol_attr_texts_,              0))                 as dol_attr_texts,
            sum(coalesce(attr.dol_attr_voapps_,             0))                 as dol_attr_voapps,
            sum(coalesce(attr.dol_attr_emails_,             0))                 as dol_attr_emails,
            sum(coalesce(attr.dol_attr_dialer_,             0))                 as dol_attr_dialer,
            sum(coalesce(attr.dol_attr_ibcall_,             0))                 as dol_attr_ibcall,
            sum(coalesce(attr.dol_attr_nocontact_,          0))                 as dol_attr_nocontact,

            n_letters               * 0.78                                      as cost_letters,
            n_letters_dunning       * 0.78                                      as cost_letters_dunning,
            n_letters_validation    * 0.78                                      as cost_letters_validation,
            n_texts                 * 0.03                                      as cost_texts,
            n_voapps                * 0.06                                      as cost_voapps

            -- edwprodhh.pub_jchang.divide(fee,                n_debtors)          as rev_per_debtor,
            -- edwprodhh.pub_jchang.divide(dol_attr_letters,   n_letters)          as yield_letters,
            -- edwprodhh.pub_jchang.divide(dol_attr_texts,     n_texts)            as yield_texts,
            -- edwprodhh.pub_jchang.divide(dol_attr_voapps,    n_voapps)           as yield_voapps,
            -- edwprodhh.pub_jchang.divide(dol_attr_letters,   cost_letters)   - 1 as roi_letters,
            -- edwprodhh.pub_jchang.divide(dol_attr_texts,     cost_texts)     - 1 as roi_texts,
            -- edwprodhh.pub_jchang.divide(dol_attr_voapps,    cost_voapps)    - 1 as roi_voapps
            
from        debtor
            left join
                contacts
                on debtor.debtor_idx = contacts.debtor_idx
            left join
                attr
                on debtor.debtor_idx = attr.debtor_idx
group by    1,2,3
order by    case when debtor.treatment_group = 'NOT IN EXP' then 2 else 1 end asc, 1, 2
;



create or replace task
    edwprodhh.pub_jchang.replace_report_test_replace_letters_20231211_results
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.merge_master_debtor
as
create or replace table
    edwprodhh.hermes.report_test_replace_letters_20231211_results
as
with debtor as
(
    with pool_log as
    (
        select      debtor_idx,
                    treatment_group
        from        edwprodhh.hermes.master_prediction_pool_log
        where       execute_time = (select max(execute_time) from edwprodhh.hermes.master_prediction_pool_log)
    )
    select      debtor.debtor_idx,
                debtor.packet_idx,
                pool_log.treatment_group,
                debtor.batch_date,
                debtor.pl_group,
                debtor.commission
    from        pool_log
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on pool_log.debtor_idx = debtor.debtor_idx
                    and debtor.batch_date >= '2023-12-11'
                    and debtor.pl_group not in (
                        'LURIE CHILDRENS - 1P',
                        'CARLE HEALTHCARE - PHY - 1P',
                        'PROVIDENCE ST JOSEPH HEALTH - 3P-2'
                    )
)
, contacts as
(
    select      contacts.debtor_idx,

                count(case when contacts.contact_type = 'Letter'                                                                                        then 1 end) as n_letters_,
                count(case when contacts.contact_type = 'Letter'        and letters.collection_type != 'Validation'                                     then 1 end) as n_letters_dunning_,
                count(case when contacts.contact_type = 'Letter'        and letters.collection_type =  'Validation'                                     then 1 end) as n_letters_validation_,
                count(case when contacts.contact_type = 'Text Message'                                                                                  then 1 end) as n_texts_,
                count(case when contacts.contact_type = 'VoApp'                                                                                         then 1 end) as n_voapps_,
                count(case when contacts.contact_type = 'Email'                                                                                         then 1 end) as n_emails_,
                count(case when contacts.contact_type in ('Dialer-Agent Call', 'Dialer-Agentless Call', 'Dialer-IMC Call', 'Outbound-Manual Call')      then 1 end) as n_dialer_

    from        edwprodhh.pub_jchang.transform_contacts as contacts
                left join
                    edwprodhh.pub_jchang.master_letters as letters
                    on contacts.contact_id = letters.letter_id
                    and letters.letter_code not in ('NV60')
    where       contacts.debtor_idx in (select debtor_idx from debtor)
    group by    1
)
, attr as
(
    select      attr.debtor_idx,

                sum(case when attr.contact_type = 'Letter'                                                                                              then attr.sig_comm_amt end) as dol_attr_letters_,
                sum(case when attr.contact_type = 'Letter'                   and letters.collection_type != 'Validation'                                then attr.sig_comm_amt end) as dol_attr_letters_dunning_,
                sum(case when attr.contact_type = 'Letter'                   and letters.collection_type =  'Validation'                                then attr.sig_comm_amt end) as dol_attr_letters_validation_,
                sum(case when attr.contact_type = 'Text Message'                                                                                        then attr.sig_comm_amt end) as dol_attr_texts_,
                sum(case when attr.contact_type = 'VoApp'                                                                                               then attr.sig_comm_amt end) as dol_attr_voapps_,
                sum(case when attr.contact_type = 'Email'                                                                                               then attr.sig_comm_amt end) as dol_attr_emails_,
                sum(case when attr.contact_type in ('Dialer-Agent Call', 'Dialer-Agentless Call', 'Dialer-IMC Call', 'Outbound-Manual Call')            then attr.sig_comm_amt end) as dol_attr_dialer_,
                sum(case when attr.contact_type = 'Inbound-Agent Call'                                                                                  then attr.sig_comm_amt end) as dol_attr_ibcall_,
                sum(case when attr.contact_type = 'No Contact'                                                                                          then attr.sig_comm_amt end) as dol_attr_nocontact_

    from        (
                    select      debtor_idx,
                                contact_id,
                                contact_type,
                                sum(sig_comm_amt * attribution_weight) as sig_comm_amt
                    -- from        edwprodhh.pub_jchang.transform_payment_attribution_contact_weights
                    from        edwprodhh.pub_jchang.transform_payment_attribution_ibcall_distributed_contact_weights
                    where       debtor_idx in (select debtor_idx from debtor)
                    group by    1,2,3
                )   as attr
                left join
                    edwprodhh.pub_jchang.master_letters as letters
                    on attr.contact_id = letters.letter_id
                    and letters.letter_code not in ('NV60')
    group by    1
)
select      debtor.pl_group,
            debtor.treatment_group,
            'ddddd'                                                             as tableau_relation,
            

            count(*)                                                            as n_debtors,
            count(distinct debtor.packet_idx)                                   as n_packets,
            sum(debtor.commission)                                              as fee,

            sum(coalesce(contacts.n_letters_,               0))                 as n_letters,
            sum(coalesce(contacts.n_letters_dunning_,       0))                 as n_letters_dunning,
            sum(coalesce(contacts.n_letters_validation_,    0))                 as n_letters_validation,
            sum(coalesce(contacts.n_texts_,                 0))                 as n_texts,
            sum(coalesce(contacts.n_voapps_,                0))                 as n_voapps,
            sum(coalesce(contacts.n_emails_,                0))                 as n_emails,
            sum(coalesce(contacts.n_dialer_,                0))                 as n_dialer,

            sum(coalesce(attr.dol_attr_letters_,            0))                 as dol_attr_letters,
            sum(coalesce(attr.dol_attr_letters_dunning_,    0))                 as dol_attr_letters_dunning,
            sum(coalesce(attr.dol_attr_letters_validation_, 0))                 as dol_attr_letters_validation,
            sum(coalesce(attr.dol_attr_texts_,              0))                 as dol_attr_texts,
            sum(coalesce(attr.dol_attr_voapps_,             0))                 as dol_attr_voapps,
            sum(coalesce(attr.dol_attr_emails_,             0))                 as dol_attr_emails,
            sum(coalesce(attr.dol_attr_dialer_,             0))                 as dol_attr_dialer,
            sum(coalesce(attr.dol_attr_ibcall_,             0))                 as dol_attr_ibcall,
            sum(coalesce(attr.dol_attr_nocontact_,          0))                 as dol_attr_nocontact,

            n_letters               * 0.78                                      as cost_letters,
            n_letters_dunning       * 0.78                                      as cost_letters_dunning,
            n_letters_validation    * 0.78                                      as cost_letters_validation,
            n_texts                 * 0.03                                      as cost_texts,
            n_voapps                * 0.06                                      as cost_voapps

            -- edwprodhh.pub_jchang.divide(fee,                n_debtors)          as rev_per_debtor,
            -- edwprodhh.pub_jchang.divide(dol_attr_letters,   n_letters)          as yield_letters,
            -- edwprodhh.pub_jchang.divide(dol_attr_texts,     n_texts)            as yield_texts,
            -- edwprodhh.pub_jchang.divide(dol_attr_voapps,    n_voapps)           as yield_voapps,
            -- edwprodhh.pub_jchang.divide(dol_attr_letters,   cost_letters)   - 1 as roi_letters,
            -- edwprodhh.pub_jchang.divide(dol_attr_texts,     cost_texts)     - 1 as roi_texts,
            -- edwprodhh.pub_jchang.divide(dol_attr_voapps,    cost_voapps)    - 1 as roi_voapps
            
from        debtor
            left join
                contacts
                on debtor.debtor_idx = contacts.debtor_idx
            left join
                attr
                on debtor.debtor_idx = attr.debtor_idx
group by    1,2,3
order by    case when debtor.treatment_group = 'NOT IN EXP' then 2 else 1 end asc, 1, 2
;