WITH charlson_data AS (
                      SELECT cohort_definition_id,
                             subject_id AS person_id,
                             cohort_start_date,
                             SUM(weight) AS score
                      FROM @cohort_database_schema.charlson_map
                      GROUP BY cohort_definition_id,
                               subject_id,
                               cohort_start_date
                      ),
     details       AS (
                      SELECT cohort_definition_id,
                             score,
                             ROW_NUMBER() OVER (PARTITION BY cohort_definition_id ORDER BY score) AS row_number,
                             SUM(1) OVER (PARTITION BY cohort_definition_id) AS total
                      FROM charlson_data
                      ),
     quartiles     AS (
                      SELECT cohort_definition_id,
                             score,
                             AVG(CASE
                                     WHEN row_number >= (FLOOR(total / 2.0) / 2.0)
                                         AND row_number <= (FLOOR(total / 2.0) / 2.0) + 1
                                         THEN score / 1.0
                                 END
                                 ) OVER (PARTITION BY cohort_definition_id) AS q1,
                             AVG(CASE
                                     WHEN row_number >= (total / 2.0)
                                         AND row_number <= (total / 2.0) + 1
                                         THEN score / 1.0
                                 END
                                 ) OVER (PARTITION BY cohort_definition_id) AS median,
                             AVG(CASE
                                     WHEN row_number >= (CEIL(total / 2.0) + (FLOOR(total / 2.0) / 2.0))
                                         AND row_number <= (CEIL(total / 2.0) + (FLOOR(total / 2.0) / 2.0) + 1)
                                         THEN score / 1.0
                                 END
                                 ) OVER (PARTITION BY cohort_definition_id) AS q3
                      FROM details
                      )
SELECT cohort_definition_id,
	   AVG(q3) - AVG(q1) as iqr,
       MIN(score) AS minimum,
       AVG(q1) AS q1,
       AVG(median) AS median,
       AVG(q3) AS q3,
       MAX(score) AS maximum,
       'Charlson Comorbidity Index' AS analysis_name
FROM quartiles
GROUP BY 1;
