create or replace temporary table
    edwprodhh.hermes.temp_master_client_config
as
with unioned as
(
    select      distinct
                pl_group
    from        (
                    select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_letters union all
                    select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_texts   union all
                    select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_voapps  union all
                    select pl_group from edwprodhh.hermes.transform_criteria_client_allowed_calls   union all
                    select pl_group from edwprodhh.hermes.master_config_clients_active              union all
                    select pl_group from edwprodhh.hermes.master_config_constraints_plgroup         union all
                    select pl_group from edwprodhh.hermes.master_config_contact_codes_plgroup       union all
                    select pl_group from edwprodhh.hermes.master_config_contact_codes_client
                    -- select pl_group from edwprodhh.hermes.master_config_contact_minimums
                )   as unioned
)
, agg_codes_client as
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
select      pl_groups.pl_group,


            --  PRODUCTION CONFIGS
            case when active.pl_group   is not null then 1 else 0 end       as is_client_active_hermes_contacts,
            case when letters.pl_group  is not null then 1 else 0 end       as is_client_allowed_letters,
            case when texts.pl_group    is not null then 1 else 0 end       as is_client_allowed_texts,
            case when voapps.pl_group   is not null then 1 else 0 end       as is_client_allowed_voapps,
            case when calls.pl_group    is not null then 1 else 0 end       as is_client_allowed_calls,

            coalesce(constraints.max_cost_running_client,       0)          as max_cost_running_client,
            coalesce(constraints.max_cost_running_letters,      0)          as max_cost_running_letters,
            coalesce(constraints.max_cost_running_texts,        0)          as max_cost_running_texts,
            coalesce(constraints.max_cost_running_voapps,       0)          as max_cost_running_voapps,
            coalesce(constraints.max_cost_running_emails,       0)          as max_cost_running_emails,
            coalesce(constraints.min_activity_running_client,   0)          as min_activity_running_client,
            coalesce(constraints.min_activity_running_letters,  0)          as min_activity_running_letters,
            coalesce(constraints.min_activity_running_texts,    0)          as min_activity_running_texts,
            coalesce(constraints.min_activity_running_voapps,   0)          as min_activity_running_voapps,
            coalesce(constraints.min_activity_running_emails,   0)          as min_activity_running_emails,
            coalesce(constraints.min_margin_running_client,     0)          as min_margin_running_client,
            coalesce(constraints.min_margin_running_letters,    0)          as min_margin_running_letters,
            coalesce(constraints.min_margin_running_texts,      0)          as min_margin_running_texts,
            coalesce(constraints.min_margin_running_voapps,     0)          as min_margin_running_voapps,
            coalesce(constraints.min_margin_running_emails,     0)          as min_margin_running_emails,


            --  SUMMARY
            codes_plgroup.letter_code,
            codes_plgroup.text_code,
            codes_plgroup.voapp_code,
            codes_client.letter_code                                        as letter_code_client,
            codes_client.text_code                                          as text_code_client,
            codes_client.voapp_code                                         as voapp_code_client,

            act_mins.json_minimums                                          as min_activity_json




from        unioned as pl_groups

            left join edwprodhh.hermes.transform_criteria_client_allowed_letters                        as letters          on pl_groups.pl_group = letters.pl_group
            left join edwprodhh.hermes.transform_criteria_client_allowed_texts                          as texts            on pl_groups.pl_group = texts.pl_group
            left join edwprodhh.hermes.transform_criteria_client_allowed_voapps                         as voapps           on pl_groups.pl_group = voapps.pl_group
            left join edwprodhh.hermes.transform_criteria_client_allowed_calls                          as calls            on pl_groups.pl_group = calls.pl_group

            left join edwprodhh.hermes.master_config_constraints_plgroup                                as constraints      on pl_groups.pl_group = constraints.pl_group
            left join edwprodhh.hermes.master_config_contact_codes_plgroup                              as codes_plgroup    on pl_groups.pl_group = codes_plgroup.pl_group

            left join agg_codes_client                                                                  as codes_client     on pl_groups.pl_group = codes_client.pl_group
            left join agg_activity_minimums                                                             as act_mins         on pl_groups.pl_group = act_mins.pl_group

            left join (select distinct pl_group from edwprodhh.hermes.master_config_clients_active)     as active           on pl_groups.pl_group = active.pl_group

order by    1
;   


/*
1. The above is what I want the final file to look like.
2. PRODUCTION_CONFIGS: All will be set, probably as a view.
3. SUMMARY:
    A. PL_GROUP CODES: All will be set, probably as a view.
    B. CLIENT CODES: All will be set, probably in a CTE prior to the aforementioned view.
        - Will maintain the same CTE currently written to aggregate into PL GROUP level.
    C. JSON MINIMUMS: All will be set, in the separate table/file that exists.
        - - Will maintain the same CTE currently written to aggregate into PL GROUP level.
*/
