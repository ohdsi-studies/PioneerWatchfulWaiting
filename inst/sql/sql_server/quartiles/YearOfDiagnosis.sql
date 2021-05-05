WITH init_data AS (
                  SELECT cohort_definition_id, subject_id,
                         cohort_start_date, YEAR(cohort_start_date) AS value
                  FROM @cohort_database_schema.@cohort_table
                  WHERE cohort_definition_id IN (@target_ids)
                  ),