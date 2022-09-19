library(PIONEER_clinician_driven_model)
#=======================
# USER INPUTS
#=======================
# The folder where the study intermediate and result files will be written:
outputFolder <- "C:/PIONEER_clinician_driven_modelResults"

# Details for connecting to the server:
dbms <- "you dbms"
user <- 'your username'
pw <- 'your password'
server <- 'your server'
port <- 'your port'

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# Add the database containing the OMOP CDM data
cdmDatabaseSchema <- 'cdm database schema'
# Add a sharebale name for the database containing the OMOP CDM data
cdmDatabaseName <- 'a friendly shareable  name for your database'
# Add a database with read/write access as this is where the cohorts will be generated
cohortDatabaseSchema <- 'work database schema'

tempEmulationSchema <- NULL

# table name where the cohorts will be generated
cohortTable <- 'PIONEER_clinician_driven_modelCohort'

# here we specify the databaseDetails using the 
# variables specified above
databaseDetails <- PatientLevelPrediction::createDatabaseDetails(
        connectionDetails = connectionDetails, 
        cdmDatabaseSchema = cdmDatabaseSchema, 
        cdmDatabaseName = cdmDatabaseName, 
        tempEmulationSchema = tempEmulationSchema, 
        cohortDatabaseSchema = cohortDatabaseSchema, 
        cohortTable = cohortTable, 
        outcomeDatabaseSchema = cohortDatabaseSchema,  
        outcomeTable = cohortTable, 
        cdmVersion = 5
)

# specify the level of logging 
logSettings <- PatientLevelPrediction::createLogSettings(
        verbosity = 'INFO', 
        logName = 'PIONEER_clinician_driven_model'
)


#======================
# PICK THINGS TO EXECUTE
#=======================
# want to generate a study protocol? Set below to TRUE
createProtocol <- FALSE
# want to generate the cohorts for the study? Set below to TRUE
createCohorts <- TRUE
# want to run a diagnoston on the prediction and explore results? Set below to TRUE
runDiagnostic <- FALSE
viewDiagnostic <- FALSE
# want to run the prediction study? Set below to TRUE
runAnalyses <- TRUE
sampleSize <- NULL # edit this to the number to sample if needed
# want to create a validation package with the developed models? Set below to TRUE
createValidationPackage <- FALSE
analysesToValidate = NULL
# want to package the results ready to share? Set below to TRUE
packageResults <- FALSE
# pick the minimum count that will be displayed if creating the shiny app, the validation package, the 
# diagnosis or packaging the results to share 
minCellCount= 5
# want to create a shiny app with the results to share online? Set below to TRUE
createShiny <- FALSE


#=======================

PIONEER_clinician_driven_model::execute(
        databaseDetails = databaseDetails,
        outputFolder = outputFolder,
        createProtocol = createProtocol,
        createCohorts = createCohorts,
        runDiagnostic = runDiagnostic,
        viewDiagnostic = viewDiagnostic,
        runAnalyses = runAnalyses,
        createValidationPackage = createValidationPackage,
        analysesToValidate = analysesToValidate,
        packageResults = packageResults,
        minCellCount= minCellCount,
        logSettings = logSettings,
        sampleSize = sampleSize
)

# Uncomment and run the next line to see the shiny results:
# PatientLevelPrediction::viewMultiplePlp(outputFolder)
