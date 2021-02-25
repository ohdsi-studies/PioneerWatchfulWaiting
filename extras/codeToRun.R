### Load libraries
library(PIONEER)


### Connection details for the SQL server
connectionDetails <-  DatabaseConnector::createConnectionDetails(
  dbms = "",														### Name of dialect (Type ?DatabaseConnector::createConnectionDetails to see how your dialect should be written)
  server = "",														### Server URL or IP
  user = "",														### Username
  password = "",													### Password
  port = 5439)

### Declare variables
cdmDatabaseSchema <- ""          ### Name of the schema where the CDM data are located
targetDatabaseSchema <- ""       ### Name of the schema where the results of the package will be saved
cohortTable <- "pioneer"         ### Name of the table where the cohort data will be saved
oracleTempSchema <- NULL         ### (Only for Oracle users)Name of temp schema
outputFolder <- ""               ### Name of the folder the output will be saved (it should named after the database)
days_offset <- 180				 ### Days added to the index event start date

### Connect to the server
con <- DatabaseConnector::connect(connectionDetails)


### Execute analysis
PIONEER::execute(connection = con,
                cdmDatabaseSchema = cdmDatabaseSchema,
                targetDatabaseSchema = targetDatabaseSchema,
                oracleTempSchema = oracleTempSchema,
                cohortTable = cohortTable,
                outputFolder = outputFolder,
                createCohorts = T,
                days_offset
)
