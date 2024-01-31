select      execute_time,
            count(*) as n,
            sum(pass_client_active_hermes_contacts) as pass_client_active_hermes_contacts_,
            sum(pass_client_active_hermes_contacts * pass_client_allowed_texts) as pass_client_allowed_texts_,
            sum(pass_client_active_hermes_contacts * pass_client_allowed_texts * pass_validation_requirement_nonoffer) as pass_validation_requirement_nonoffer_,
            sum(pass_client_active_hermes_contacts * pass_client_allowed_texts * pass_validation_requirement_nonoffer * pass_debtor_status) as pass_debtor_status_,
            sum(pass_client_active_hermes_contacts * pass_client_allowed_texts * pass_validation_requirement_nonoffer * pass_debtor_status * pass_debtor_active) as pass_debtor_active_,
            sum(pass_client_active_hermes_contacts * pass_client_allowed_texts * pass_validation_requirement_nonoffer * pass_debtor_status * pass_debtor_active * pass_phone_texts) as pass_phone_texts_,
            sum(pass_client_active_hermes_contacts * pass_client_allowed_texts * pass_validation_requirement_nonoffer * pass_debtor_status * pass_debtor_active * pass_phone_texts * pass_debtor_balance) as pass_debtor_balance_,
            sum(pass_client_active_hermes_contacts * pass_client_allowed_texts * pass_validation_requirement_nonoffer * pass_debtor_status * pass_debtor_active * pass_phone_texts * pass_debtor_balance * pass_packet_balance) as pass_packet_balance_,
            sum(pass_client_active_hermes_contacts * pass_client_allowed_texts * pass_validation_requirement_nonoffer * pass_debtor_status * pass_debtor_active * pass_phone_texts * pass_debtor_balance * pass_packet_balance * pass_debtor_age_packet) as pass_debtor_age_packet_,
            sum(pass_client_active_hermes_contacts * pass_client_allowed_texts * pass_validation_requirement_nonoffer * pass_debtor_status * pass_debtor_active * pass_phone_texts * pass_debtor_balance * pass_packet_balance * pass_debtor_age_packet * pass_texts_cooldown) as pass_texts_cooldown_,
            sum(pass_client_active_hermes_contacts * pass_client_allowed_texts * pass_validation_requirement_nonoffer * pass_debtor_status * pass_debtor_active * pass_phone_texts * pass_debtor_balance * pass_packet_balance * pass_debtor_age_packet * pass_texts_cooldown * pass_delay_texts) as pass_delay_texts_,
            sum(is_eligible_texts)
from        edwprodhh.hermes.master_prediction_pool_log as pool
where       pl_group in (select distinct pl_group from edwprodhh.pub_jchang.master_debtor where industry = 'HC' and batch_date >= '2023-01-01')
group by    1
order by    1 desc
;