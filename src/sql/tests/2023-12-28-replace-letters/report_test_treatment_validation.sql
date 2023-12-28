create or replace table
    edwprodhh.hermes.report_test_replace_letters_20231211_execution
as
with temp_master_prediction_pool_log as
(
    select      debtor_idx,
                treatment_group,
                pass_debtor_active
    from        edwprodhh.hermes.master_prediction_pool_log
    where       execute_time = (select max(execute_time) from edwprodhh.hermes.master_prediction_pool_log)
)
, contacts as
(
    select      debtor.debtor_idx,
                pool.treatment_group,
                debtor.batch_date,
                contacts.contact_type,

                case    when    contacts.contact_type = 'Letter'
                        then    case    when    letters.collection_type = 'Validation'
                                        then    'Validation'
                                        else    'Dunning'
                                        end
                        else    ''
                        end     as contact_detail,
                
                contacts.contact_time::date as contact_date,
                floor(datediff(day, debtor.batch_date, contact_date) / 3) * 3 as day_index
    from        temp_master_prediction_pool_log as pool
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on pool.debtor_idx = debtor.debtor_idx
                    and debtor.batch_date >= '2000-01-01'
                    and debtor.pl_group not in (
                        'LURIE CHILDRENS - 1P',
                        'CARLE HEALTHCARE - PHY - 1P',
                        'PROVIDENCE ST JOSEPH HEALTH - 3P-2'
                    )
                inner join
                    edwprodhh.pub_jchang.master_contacts as contacts
                    on pool.debtor_idx = contacts.debtor_idx
                    and contacts.contact_type in ('Letter', 'Text Message')
                    and contacts.contact_time >= debtor.batch_date
                left join
                    edwprodhh.pub_jchang.master_letters as letters
                    on contacts.contact_id = letters.letter_id

    where       pool.treatment_group != 'NOT IN EXP'
                and case    when    letters.letter_id is not null
                            then    letters.letter_code not in ('NV60')
                            else    TRUE
                            end
)
, summary as
(
    select      treatment_group,
                contact_type,
                contact_detail,
                day_index,
                count(*) as n
    from        contacts
    group by    1,2,3,4
)
, template as
(
    with channels as
    (
        select 'Letter'         as channel, 'Validation'    as contact_detail union all
        select 'Letter'         as channel, 'Dunning'       as contact_detail union all
        select 'Text Message'   as channel, ''              as contact_detail
    )
    , day_index as
    (
        with vector as
        (
            select      row_number() over (order by 1) - 1 as rn
            from        table(generator(rowcount => 91))
            order by    1
        )
        select      *
        from        vector
        where       mod(rn, 3) = 0
    )
    , treatments as
    (
        select      'TEST'      as treatment_group union all
        select      'CONTROL'   as treatment_group
    )
    select      treatments.treatment_group,
                channels.channel,
                channels.contact_detail,
                day_index.rn as day_index
    from        treatments
                cross join
                    channels
                cross join
                    day_index
)
select      template.treatment_group,
            template.channel,
            template.contact_detail,
            template.day_index,
            coalesce(summary.n, 0) as n_contacts,
            'ccccc' as tableau_relation

from        template
            left join
                summary
                on  template.treatment_group    = summary.treatment_group
                and template.channel            = summary.contact_type
                and template.contact_detail     = summary.contact_detail
                and template.day_index          = summary.day_index
order by    1,2,3,4
;



create or replace task
    edwprodhh.pub_jchang.replace_report_test_replace_letters_20231211_execution
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.merge_master_debtor
as
create or replace table
    edwprodhh.hermes.report_test_replace_letters_20231211_execution
as
with temp_master_prediction_pool_log as
(
    select      debtor_idx,
                treatment_group,
                pass_debtor_active
    from        edwprodhh.hermes.master_prediction_pool_log
    where       execute_time = (select max(execute_time) from edwprodhh.hermes.master_prediction_pool_log)
)
, contacts as
(
    select      debtor.debtor_idx,
                pool.treatment_group,
                debtor.batch_date,
                contacts.contact_type,

                case    when    contacts.contact_type = 'Letter'
                        then    case    when    letters.collection_type = 'Validation'
                                        then    'Validation'
                                        else    'Dunning'
                                        end
                        else    ''
                        end     as contact_detail,
                
                contacts.contact_time::date as contact_date,
                floor(datediff(day, debtor.batch_date, contact_date) / 3) * 3 as day_index
    from        temp_master_prediction_pool_log as pool
                inner join
                    edwprodhh.pub_jchang.master_debtor as debtor
                    on pool.debtor_idx = debtor.debtor_idx
                    and debtor.batch_date >= '2000-01-01'
                    and debtor.pl_group not in (
                        'LURIE CHILDRENS - 1P',
                        'CARLE HEALTHCARE - PHY - 1P',
                        'PROVIDENCE ST JOSEPH HEALTH - 3P-2'
                    )
                inner join
                    edwprodhh.pub_jchang.master_contacts as contacts
                    on pool.debtor_idx = contacts.debtor_idx
                    and contacts.contact_type in ('Letter', 'Text Message')
                    and contacts.contact_time >= debtor.batch_date
                left join
                    edwprodhh.pub_jchang.master_letters as letters
                    on contacts.contact_id = letters.letter_id

    where       pool.treatment_group != 'NOT IN EXP'
                and case    when    letters.letter_id is not null
                            then    letters.letter_code not in ('NV60')
                            else    TRUE
                            end
)
, summary as
(
    select      treatment_group,
                contact_type,
                contact_detail,
                day_index,
                count(*) as n
    from        contacts
    group by    1,2,3,4
)
, template as
(
    with channels as
    (
        select 'Letter'         as channel, 'Validation'    as contact_detail union all
        select 'Letter'         as channel, 'Dunning'       as contact_detail union all
        select 'Text Message'   as channel, ''              as contact_detail
    )
    , day_index as
    (
        with vector as
        (
            select      row_number() over (order by 1) - 1 as rn
            from        table(generator(rowcount => 91))
            order by    1
        )
        select      *
        from        vector
        where       mod(rn, 3) = 0
    )
    , treatments as
    (
        select      'TEST'      as treatment_group union all
        select      'CONTROL'   as treatment_group
    )
    select      treatments.treatment_group,
                channels.channel,
                channels.contact_detail,
                day_index.rn as day_index
    from        treatments
                cross join
                    channels
                cross join
                    day_index
)
select      template.treatment_group,
            template.channel,
            template.contact_detail,
            template.day_index,
            coalesce(summary.n, 0) as n_contacts,
            'ccccc' as tableau_relation

from        template
            left join
                summary
                on  template.treatment_group    = summary.treatment_group
                and template.channel            = summary.contact_type
                and template.contact_detail     = summary.contact_detail
                and template.day_index          = summary.day_index
order by    1,2,3,4
;