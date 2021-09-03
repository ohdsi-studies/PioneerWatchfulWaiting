-- create subject age table
IF OBJECT_ID('@cohort_database_schema.subject_age', 'U') IS NOT NULL
   DROP TABLE @cohort_database_schema.subject_age;
SELECT tab.cohort_definition_id,
       tab.person_id,
       tab.cohort_start_date,
       DATEDIFF(year, DATEFROMPARTS(tab.year_of_birth, tab.month_of_birth, tab.day_of_birth),
                tab.cohort_start_date) AS age
INTO @cohort_database_schema.subject_age
FROM (
     SELECT c.cohort_definition_id, p.person_id, c.cohort_start_date, p.year_of_birth,
               CASE WHEN ISNUMERIC(p.month_of_birth) = 1 THEN p.month_of_birth ELSE 1 END AS month_of_birth,
               CASE WHEN ISNUMERIC(p.day_of_birth) = 1 THEN p.day_of_birth ELSE 1 END AS day_of_birth
     FROM @cohort_database_schema.@cohort_table c
     JOIN @cdm_database_schema.person p
         ON p.person_id = c.subject_id
     WHERE c.cohort_definition_id IN (@target_ids)
     ) tab
;

-- Charlson analysis
IF OBJECT_ID('@cohort_database_schema.charlson_concepts', 'U') IS NOT NULL
   DROP TABLE @cohort_database_schema.charlson_concepts;
CREATE TABLE @cohort_database_schema.charlson_concepts
(
    diag_category_id INT,
    concept_id       INT
);

IF OBJECT_ID('@cohort_database_schema.charlson_scoring', 'U') IS NOT NULL
   DROP TABLE @cohort_database_schema.charlson_scoring;
CREATE TABLE @cohort_database_schema.charlson_scoring
(
    diag_category_id   INT,
    diag_category_name VARCHAR(255),
    weight             INT
);


--acute myocardial infarction
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (1, 'Myocardial infarction', 1);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 1, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (4329847);


--Congestive heart failure
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (2, 'Congestive heart failure', 1);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 2, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (316139);


--Peripheral vascular disease
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (3, 'Peripheral vascular disease', 1);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 3, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (321052);


--Cerebrovascular disease
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (4, 'Cerebrovascular disease', 1);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 4, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (381591, 434056);


--Dementia
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (5, 'Dementia', 1);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 5, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (4182210);


--Chronic pulmonary disease
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (6, 'Chronic pulmonary disease', 1);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 6, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (4063381);


--Rheumatologic disease
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (7, 'Rheumatologic disease', 1);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 7, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (257628, 134442, 80800, 80809, 256197, 255348);


--Peptic ulcer disease
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (8, 'Peptic ulcer disease', 1);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 8, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (4247120);


--Mild liver disease
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (9, 'Mild liver disease', 1);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 9, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (4064161, 4212540);


--Diabetes (mild to moderate)
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (10, 'Diabetes (mild to moderate)', 1);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 10, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (201820);


--Diabetes with chronic complications
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (11, 'Diabetes with chronic complications', 2);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 11, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (443767, 442793);


--Hemoplegia or paralegia
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (12, 'Hemoplegia or paralegia', 2);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 12, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (192606, 374022);


--Renal disease
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (13, 'Renal disease', 2);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 13, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (4030518);

--Any malignancy
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (14, 'Any malignancy', 2);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 14, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (443392);


--Leukemia
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (15, 'Leukemia', 2);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 15, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (317510);


--Lymphoma
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (16, 'Lymphoma', 2);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 16, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (432571);


--Moderate to severe liver disease
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (17, 'Moderate to severe liver disease', 3);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 17, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (4245975, 4029488, 192680, 24966);


--Metastatic solid tumor
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (18, 'Metastatic solid tumor', 6);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 18, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (432851);


--AIDS
INSERT INTO @cohort_database_schema.charlson_scoring (diag_category_id, diag_category_name, weight)
VALUES (19, 'AIDS', 6);

INSERT INTO @cohort_database_schema.charlson_concepts (diag_category_id, concept_id)
SELECT 19, descendant_concept_id
FROM @cdm_database_schema.concept_ancestor
WHERE ancestor_concept_id IN (439727);



IF OBJECT_ID('@cohort_database_schema.charlson_map', 'U') IS NOT NULL
   DROP TABLE @cohort_database_schema.charlson_map;
SELECT DISTINCT @cohort_database_schema.charlson_scoring.diag_category_id,
                @cohort_database_schema.charlson_scoring.weight,
                cohort_definition_id,
                cohort.subject_id,
                cohort.cohort_start_date
INTO @cohort_database_schema.charlson_map
FROM @cohort_database_schema.@cohort_table cohort
INNER JOIN @cdm_database_schema.condition_era condition_era
    ON cohort.subject_id = condition_era.person_id
INNER JOIN @cohort_database_schema.charlson_concepts
    ON condition_era.condition_concept_id = charlson_concepts.concept_id
INNER JOIN @cohort_database_schema.charlson_scoring
    ON @cohort_database_schema.charlson_concepts.diag_category_id = @cohort_database_schema.charlson_scoring.diag_category_id
WHERE condition_era_start_date <= cohort.cohort_start_date;


-- Update weights to avoid double counts of mild/severe course of the disease
-- Diabetes
UPDATE @cohort_database_schema.charlson_map
SET weight = 0
FROM (
  SELECT
    t1.subject_id AS sub_id
  , t1.cohort_definition_id AS coh_id
  , t1.diag_category_id AS d1
  , t2.diag_category_id AS d2
  FROM @cohort_database_schema.charlson_map t1
  INNER JOIN @cohort_database_schema.charlson_map t2 ON
    t1.subject_id = t2.subject_id
    AND t1.cohort_definition_id = t2.cohort_definition_id
) x
WHERE
  subject_id = x.sub_id
  AND cohort_definition_id = x.coh_id
  AND charlson_map.diag_category_id = 10
  AND x.d1 = 10
  AND x.d2 = 11;

-- Liver disease
UPDATE @cohort_database_schema.charlson_map
SET weight = 0
FROM (
  SELECT
    t1.subject_id AS sub_id
  , t1.cohort_definition_id AS coh_id
  , t1.diag_category_id AS d1
  , t2.diag_category_id AS d2
  FROM @cohort_database_schema.charlson_map t1
  INNER JOIN @cohort_database_schema.charlson_map t2 ON
    t1.subject_id = t2.subject_id
    AND t1.cohort_definition_id = t2.cohort_definition_id
) x
WHERE
  subject_id = x.sub_id
  AND cohort_definition_id = x.coh_id
  AND charlson_map.diag_category_id = 9
  AND x.d1 = 9
  AND x.d2 = 17;

-- Malignancy
UPDATE @cohort_database_schema.charlson_map
SET weight = 0
FROM (
  SELECT
    t1.subject_id AS sub_id
  , t1.cohort_definition_id AS coh_id
  , t1.diag_category_id AS d1
  , t2.diag_category_id AS d2
  FROM @cohort_database_schema.charlson_map t1
  INNER JOIN @cohort_database_schema.charlson_map t2 ON
    t1.subject_id = t2.subject_id
    AND t1.cohort_definition_id = t2.cohort_definition_id
) x
WHERE
  subject_id = x.sub_id
  AND cohort_definition_id = x.coh_id
  AND charlson_map.diag_category_id = 14
  AND x.d1 = 14
  AND x.d2 = 18;

-- Add age criteria
INSERT INTO @cohort_database_schema.charlson_map
SELECT 0 AS diag_category_id,
       CASE
           WHEN age < 50
               THEN 0
           WHEN age >= 50 AND age < 60
               THEN 1
           WHEN age >= 60 AND age < 70
               THEN 2
           WHEN age >= 70 AND age < 80
               THEN 3
           WHEN age >= 80
               THEN 4
       END AS weight,
       cohort_definition_id, person_id AS subject_id, cohort_start_date
FROM @cohort_database_schema.subject_age
WHERE cohort_definition_id IN (
                              SELECT DISTINCT cohort_definition_id
                              FROM @cohort_database_schema.charlson_map
                              );

