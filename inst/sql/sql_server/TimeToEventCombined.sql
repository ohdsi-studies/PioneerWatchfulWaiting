SELECT t.subject_id,
	 t.cohort_start_date,
	 coalesce(min(o.cohort_start_date), max(t.cohort_end_date)) AS event_date,
	 CASE WHEN min(o.cohort_start_date) IS NULL THEN 0 ELSE 1 END AS event
FROM @cohort_database_schema.@cohort_table t
LEFT JOIN (
		SELECT subject_id, min(cohort_start_date) AS cohort_start_date
		FROM @cohort_database_schema.@cohort_table
		WHERE cohort_definition_id IN (@outcome_ids)
		GROUP BY subject_id
		) o
  ON t.subject_id = o.subject_id
	  AND o.cohort_start_date >= t.cohort_start_date
	  AND o.cohort_start_date <= t.cohort_end_date
WHERE t.cohort_definition_id = @target_id
GROUP BY t.subject_id, t.cohort_start_date;