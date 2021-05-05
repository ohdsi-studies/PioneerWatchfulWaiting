WITH tab       AS (
                  SELECT t.cohort_definition_id,
                         t.subject_id,
                         t.cohort_start_date,
                         coalesce(min(o.cohort_start_date), max(t.cohort_end_date)) AS event_date,
                         CASE WHEN min(o.cohort_start_date) IS NULL THEN 0 ELSE 1 END AS event
                  FROM @cohort_database_schema.@cohort_table t
                  LEFT JOIN @cohort_database_schema.@cohort_table o
                      ON t.subject_id = o.subject_id
                          AND o.cohort_start_date >= t.cohort_start_date
                          AND o.cohort_start_date <= t.cohort_end_date
                          AND o.cohort_definition_id = @outcome_id
                  WHERE t.cohort_definition_id IN (@target_ids)
                  GROUP BY t.cohort_definition_id, t.subject_id, t.cohort_start_date
                  ),
     init_data AS (
                  SELECT cohort_definition_id, datediff(day, tab.cohort_start_date, tab.event_date) AS value
                  FROM tab
                  ),