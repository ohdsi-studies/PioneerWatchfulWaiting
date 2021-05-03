WITH details   AS (
                  SELECT cohort_definition_id,
                         age,
                         ROW_NUMBER() OVER (PARTITION BY cohort_definition_id ORDER BY age) AS row_number,
                         SUM(1) OVER (PARTITION BY cohort_definition_id) AS total
                  FROM @cohort_database_schema.subject_age
                  ),
     quartiles AS (
                  SELECT cohort_definition_id,
                         age,
                         AVG(CASE
                                 WHEN row_number >= (FLOOR(total / 2.0) / 2.0)
                                     AND row_number <= (FLOOR(total / 2.0) / 2.0) + 1
                                     THEN age / 1.0
                             END
                             ) OVER (PARTITION BY cohort_definition_id) AS q1,
                         AVG(CASE
                                 WHEN row_number >= (total / 2.0)
                                     AND row_number <= (total / 2.0) + 1
                                     THEN age / 1.0
                             END
                             ) OVER (PARTITION BY cohort_definition_id) AS median,
                         AVG(CASE
                                 WHEN row_number >= (CEIL(total / 2.0) + (FLOOR(total / 2.0) / 2.0))
                                     AND row_number <= (CEIL(total / 2.0) + (FLOOR(total / 2.0) / 2.0) + 1)
                                     THEN age / 1.0
                             END
                             ) OVER (PARTITION BY cohort_definition_id) AS q3
                  FROM details
                  )
SELECT cohort_definition_id,
       AVG(q3) - AVG(q1) AS iqr,
       MIN(age) AS minimum,
       AVG(q1) AS q1,
       AVG(median) AS median,
       AVG(q3) AS q3,
       MAX(age) AS maximum,
	   'Age at Diagnosis' as analysis_name
FROM quartiles
GROUP BY 1;