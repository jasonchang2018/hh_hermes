create or replace table
    edwprodhh.hermes.transform_criteria_debtor_status
as
select      debtor_idx,
            status,


            case    when    logon = 'HH'
                    then    case    when    status in  ('ACT', 'PPD')
                                    -- when    status in  ('ACT', 'PPD', 'SKP', 'LNA')
                                    then    1
                                    else    0
                                    end

                    when    logon = 'CO'
                    then    case    when    status in  ('ACT', 'PPD')
                                    -- when    status in  ('ACT', 'PPD', 'LNA', 'LAE')
                                    then    1
                                    else    0
                                    end

                    else    case    when    status in  ('ACT', 'PPD')
                                    then    1
                                    else    0
                                    end

                    end     as pass_debtor_status

from        edwprodhh.pub_jchang.master_debtor
;



create task
    edwprodhh.pub_jchang.replace_transform_criteria_debtor_status
    warehouse = analysis_wh
    after edwprodhh.pub_jchang.hermes_root
as
create or replace table
    edwprodhh.hermes.transform_criteria_debtor_status
as
select      debtor_idx,
            status,


            case    when    logon = 'HH'
                    then    case    when    status in  ('ACT', 'PPD')
                                    -- when    status in  ('ACT', 'PPD', 'SKP', 'LNA')
                                    then    1
                                    else    0
                                    end

                    when    logon = 'CO'
                    then    case    when    status in  ('ACT', 'PPD')
                                    -- when    status in  ('ACT', 'PPD', 'LNA', 'LAE')
                                    then    1
                                    else    0
                                    end

                    else    case    when    status in  ('ACT', 'PPD')
                                    then    1
                                    else    0
                                    end

                    end     as pass_debtor_status

from        edwprodhh.pub_jchang.master_debtor
;