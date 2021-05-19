WITH tab       AS (
                  SELECT cohort.cohort_definition_id, cohort.subject_id, m.measurement_id, value_as_number,
                         cohort_start_date, m.measurement_date
                  FROM @cohort_database_schema.@cohort_table cohort
                  JOIN @cdm_database_schema.measurement m
                      ON cohort.subject_id = m.person_id
                          AND m.measurement_concept_id IN (44793131, 37392634, 3039443, 3013603, 3005013,
                                                           3002131, 3001784, 2617206, 2212543, 2212542, 2212541)
                  WHERE cohort_definition_id IN (@target_ids)
                    AND abs(datediff(day, cohort.cohort_start_date, m.measurement_date)) <= 30
                  ),
     init_data AS (
                  SELECT t1.cohort_definition_id,
                         value_as_number AS value
                  FROM tab t1
                  JOIN (
                       SELECT cohort_definition_id, subject_id, min(measurement_date) AS min_date
                       FROM tab
                       GROUP BY cohort_definition_id, subject_id
                       ) t2
                      ON t1.cohort_definition_id = t2.cohort_definition_id
                          AND t1.subject_id = t2.subject_id
                          AND t1.measurement_date = t2.min_date
                  ),