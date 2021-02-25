# Copyright 2021 Observational Health Data Sciences and Informatics
#
# This file is part of PIONEER
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.createCohorts <- function(connection,
                           cdmDatabaseSchema,
                           vocabularyDatabaseSchema = cdmDatabaseSchema,
                           cohortDatabaseSchema,
                           cohortTable,
                           oracleTempSchema,
                           outputFolder,
                           days_offset) {

  # Create study cohort table
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "CreateCohortTable.sql",
                                           packageName = "PIONEER",
                                           dbms = attr(connection, "dbms"),
                                           oracleTempSchema = oracleTempSchema,
                                           cohort_database_schema = cohortDatabaseSchema,
                                           cohort_table = cohortTable)

  DatabaseConnector::executeSql(connection, sql, progressBar = FALSE, reportOverallTime = FALSE)


  # Insert CohortsToCreate.csv file
  pathToCsv <- system.file("settings", "CohortsToCreate.csv", package = "PIONEER")
  cohortsToCreate <- readr::read_csv(pathToCsv, col_types = readr::cols())

  # Instantiate cohorts with offset
  cohortsToCreate1 <- cohortsToCreate %>% dplyr::filter(cohortsToCreate$cohortId %in% c(2,3,4,5,6))

  for (i in 1:nrow(cohortsToCreate1)) {

    writeLines(paste("Creating cohort:", cohortsToCreate1$name[i]))

    sql <- SqlRender::loadRenderTranslateSql(sqlFilename = paste0(cohortsToCreate1$name[i], ".sql"),
                                             packageName = "PIONEER",
                                             dbms = attr(connection, "dbms"),
                                             oracleTempSchema = oracleTempSchema,
                                             cdm_database_schema = cdmDatabaseSchema,
                                             vocabulary_database_schema = vocabularyDatabaseSchema,
                                             results_database_schema.cohort_inclusion = "#cohort_inclusion",
                                             results_database_schema.cohort_inclusion_result = "#cohort_inc_result",
                                             results_database_schema.cohort_inclusion_stats = "#cohort_inc_stats",
                                             results_database_schema.cohort_summary_stats = "#cohort_summary_stats",
                                             days_offset = days_offset,
                                             target_database_schema = cohortDatabaseSchema,
                                             target_cohort_table = cohortTable,
                                             target_cohort_id = cohortsToCreate1$cohortId[i])

    DatabaseConnector::executeSql(connection, sql)
  }


  # Instantiate cohorts without offset
  cohortsToCreate2 <- cohortsToCreate %>% dplyr::filter(cohortsToCreate$cohortId %in% c(1,7,8,9,10,11,12))

  for (i in 1:nrow(cohortsToCreate2)) {

    writeLines(paste("Creating cohort:", cohortsToCreate2$name[i]))

    sql <- SqlRender::loadRenderTranslateSql(sqlFilename = paste0(cohortsToCreate2$name[i], ".sql"),
                                             packageName = "PIONEER",
                                             dbms = attr(connection, "dbms"),
                                             oracleTempSchema = oracleTempSchema,
                                             cdm_database_schema = cdmDatabaseSchema,
                                             vocabulary_database_schema = vocabularyDatabaseSchema,
                                             results_database_schema.cohort_inclusion = "#cohort_inclusion",
                                             results_database_schema.cohort_inclusion_result = "#cohort_inc_result",
                                             results_database_schema.cohort_inclusion_stats = "#cohort_inc_stats",
                                             results_database_schema.cohort_summary_stats = "#cohort_summary_stats",
                                             target_database_schema = cohortDatabaseSchema,
                                             target_cohort_table = cohortTable,
                                             target_cohort_id = cohortsToCreate2$cohortId[i])

    DatabaseConnector::executeSql(connection, sql)
  }

  # Fetch cohort counts and export CohortCounts.csv file
  sql <- "SELECT cohort_definition_id, COUNT(*) AS count FROM @cohort_database_schema.@cohort_table GROUP BY cohort_definition_id"

  sql <- SqlRender::render(sql,
                           cohort_database_schema = cohortDatabaseSchema,
                           cohort_table = cohortTable)

  sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))

  counts <- DatabaseConnector::querySql(connection, sql)

  names(counts) <- SqlRender::snakeCaseToCamelCase(names(counts))

  counts <- merge(counts, data.frame(cohortDefinitionId = cohortsToCreate$cohortId, cohortName  = cohortsToCreate$name))

  write.csv(counts, file.path(outputFolder, "CohortCounts.csv"), row.names = FALSE)



}

