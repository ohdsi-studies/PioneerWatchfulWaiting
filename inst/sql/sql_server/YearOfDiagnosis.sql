WITH year_of_diagnosis AS (
                          SELECT cohort_definition_id, subject_id,
                                 cohort_start_date, YEAR(cohort_start_date) AS year
                          FROM @cohort_database_schema.@cohort_table
                          WHERE cohort_definition_id IN (@target_ids)
                          ),
     details           AS (
                          SELECT cohort_definition_id,
                                 YEAR,
                                 ROW_NUMBER() OVER (PARTITION BY cohort_definition_id ORDER BY YEAR) AS row_number,
                                 SUM(1) OVER (PARTITION BY cohort_definition_id) AS total
                          FROM year_of_diagnosis
                          ),
     quartiles         AS (
                          SELECT cohort_definition_id,
                                 YEAR,
                                 AVG(CASE
                                         WHEN row_number >= (FLOOR(total / 2.0) / 2.0)
                                             AND row_number <= (FLOOR(total / 2.0) / 2.0) + 1
                                             THEN YEAR / 1.0
                                     END
                                     ) OVER (PARTITION BY cohort_definition_id) AS q1,
                                 AVG(CASE
                                         WHEN row_number >= (total / 2.0)
                                             AND row_number <= (total / 2.0) + 1
                                             THEN YEAR / 1.0
                                     END
                                     ) OVER (PARTITION BY cohort_definition_id) AS median,
                                 AVG(CASE
                                         WHEN row_number >= (CEIL(total / 2.0) + (FLOOR(total / 2.0) / 2.0))
                                             AND row_number <= (CEIL(total / 2.0) + (FLOOR(total / 2.0) / 2.0) + 1)
                                             THEN YEAR / 1.0
                                     END
                                     ) OVER (PARTITION BY cohort_definition_id) AS q3
                          FROM details
                          )
SELECT cohort_definition_id,
       AVG(q3) - AVG(q1) as iqr,
       MIN(YEAR) AS minimum,
       AVG(q1) AS q1,
       AVG(median) AS median,
       AVG(q3) AS q3,
       MAX(YEAR) AS maximum,
       'Year of diagnosis' AS analysis_name
FROM quartiles
GROUP BY 1;
