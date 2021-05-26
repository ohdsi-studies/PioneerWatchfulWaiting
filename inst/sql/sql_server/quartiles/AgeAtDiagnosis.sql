WITH init_data AS (
                  SELECT cohort_definition_id, age AS value
                  FROM @cohort_database_schema.subject_age
                  ),