     details   AS (
                  SELECT cohort_definition_id,
                         value,
                         ROW_NUMBER() OVER (PARTITION BY cohort_definition_id ORDER BY value) AS row_number,
                         SUM(1) OVER (PARTITION BY cohort_definition_id) AS total
                  FROM init_data
                  ),
     quartiles AS (
                  SELECT cohort_definition_id,
                         value,
                         AVG(CASE
                                 WHEN row_number >= (FLOOR(total / 2.0) / 2.0)
                                     AND row_number <= (FLOOR(total / 2.0) / 2.0) + 1
                                     THEN value / 1.0
                             END
                             ) OVER (PARTITION BY cohort_definition_id) AS q1,
                         AVG(CASE
                                 WHEN row_number >= (total / 2.0)
                                     AND row_number <= (total / 2.0) + 1
                                     THEN value / 1.0
                             END
                             ) OVER (PARTITION BY cohort_definition_id) AS median,
                         AVG(CASE
                                 WHEN row_number >= (CEILING(total / 2.0) + (FLOOR(total / 2.0) / 2.0))
                                     AND row_number <= (CEILING(total / 2.0) + (FLOOR(total / 2.0) / 2.0) + 1)
                                     THEN value / 1.0
                             END
                             ) OVER (PARTITION BY cohort_definition_id) AS q3
                  FROM details
                  )
SELECT cohort_definition_id,
       AVG(q3) - AVG(q1) AS IQR,
       MIN(value) AS minimum,
       AVG(q1) AS q1,
       AVG(median) AS median,
       AVG(q3) AS q3,
       MAX(value) AS maximum,
       '@analysis_name' AS analysis_name
FROM quartiles
GROUP BY cohort_definition_id;
