#' @export
getAtEventDistribution <- function(connection, cohortDatabaseSchema, cdmDatabaseSchema, cohortTable,
                                          targetIds, databaseId, packageName, sqlFileName){
  targetIds <- paste(targetIds, collapse = ', ')
  pathToSql <- system.file("sql", "sql_server", sqlFileName, package = packageName)
  sql <- readChar(pathToSql, file.info(pathToSql)$size)
  sql <- SqlRender::render(sql, cohort_database_schema = cohortDatabaseSchema, cdm_database_schema = cdmDatabaseSchema,
                               cohort_table = cohortTable, target_ids = targetIds)
  sql <- SqlRender::translate(sql, targetDialect = connection@dbms)
  
  data <- DatabaseConnector::querySql(connection, sql, snakeCaseToCamelCase = T)
  
  data.frame(cohortDefinitionId = data$cohortDefinitionId, iqr = data$iqr, minimum = data$minimum, q1 = data$q1, 
             median = data$median, q3 = data$q3, maximum = data$maximum, analysisName = data$analysisName, database_id = databaseId)

}