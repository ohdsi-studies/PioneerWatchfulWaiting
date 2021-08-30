IF OBJECT_ID('@cohort_database_schema.subject_age', 'U') IS NOT NULL
   DROP TABLE @cohort_database_schema.subject_age;

IF OBJECT_ID('@cohort_database_schema.charlson_concepts', 'U') IS NOT NULL
   DROP TABLE @cohort_database_schema.charlson_concepts;

IF OBJECT_ID('@cohort_database_schema.charlson_scoring', 'U') IS NOT NULL
   DROP TABLE @cohort_database_schema.charlson_scoring;

IF OBJECT_ID('@cohort_database_schema.charlson_map', 'U') IS NOT NULL
   DROP TABLE @cohort_database_schema.charlson_map;
