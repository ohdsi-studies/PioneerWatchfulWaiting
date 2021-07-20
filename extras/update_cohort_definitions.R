#remotes::install_github("ohdsi/ROhdsiWebApi")
library(ROhdsiWebApi)

# First, update the cohort tables under inst/settings/cohortsToCreate.csv (for Target, Outcome and Strata)
# name = cohortId, the internal id (1xx for Target, 2xx for Outcome and 3xx for Strata cohorts), used for cohort file names
# atlasName = human readable name of the cohort
# atlasId = id of cohort definition on PIONEER Atlas

# Pull in Cohort Definitions from Atlas -----------------------------------
baseUrl="https://pioneer-atlas.thehyve.net/WebAPI"
# get this token from an active ATLAS web session
ROhdsiWebApi::setAuthHeader(baseUrl,"Bearer ey...")


for (cohortType in c("Target", "Outcome", "Strata")) {
  ROhdsiWebApi::insertCohortDefinitionSetInPackage(
    fileName = paste0("inst/settings/CohortsToCreate", cohortType, ".csv"),
    baseUrl = baseUrl,
    jsonFolder = "inst/cohorts",
    sqlFolder = "inst/sql/sql_server",
    rFileName = "R/CreateCohorts.R",
    insertTableSql = TRUE,
    insertCohortCreationR = FALSE,
    generateStats = FALSE,
    packageName = "PioneerWatchfulWaiting"
  )
}
# Optional post-processing to match old json style:
#cd inst/cohorts
#find . -iname '*.json' -type f -exec sed -i.orig 's/\t/  /g' {} +
#find . -iname '*.json' -type f -exec sed -i.orig 's/" : /": /g' {} +
#rm -r *.orig

json_cohorts_path <- "inst/cohorts"
settingsPath <- "inst/settings"
shinyPath <- "inst/shiny/PioneerWatchfulWaitingExplorer"
# Create the list of combinations of T, TwS, TwoS for the combinations of strata ----------------------------

# The Atlas Name is used as the name. The 'name' column (containing same id as cohortId) is ignored.
targetCohorts <- read.csv(file.path(settingsPath, "CohortsToCreateTarget.csv"), col.names = c('unused','name','atlasId','cohortId'))
bulkStrata <- read.csv(file.path(settingsPath, "BulkStrata.csv"))
atlasCohortStrata <- read.csv(file.path(settingsPath, "CohortsToCreateStrata.csv"), col.names = c('unused','name','atlasId','cohortId'))
outcomeCohorts <- read.csv(file.path(settingsPath, "CohortsToCreateOutcome.csv"), col.names = c('unused','name','atlasId','cohortId'))

# Target cohorts
colNames <- c("name", "cohortId") # Use this to subset to the columns of interest
targetCohorts <- targetCohorts[, match(colNames, names(targetCohorts))]
names(targetCohorts) <- c("targetName", "targetId")
# Strata cohorts
bulkStrata <- bulkStrata[, match(colNames, names(bulkStrata))]
bulkStrata$withStrataName <- paste("with", trimws(bulkStrata$name))
bulkStrata$inverseName <- paste("without", trimws(bulkStrata$name))
atlasCohortStrata <- atlasCohortStrata[, match(colNames, names(atlasCohortStrata))]
atlasCohortStrata$withStrataName <- paste("with", trimws(atlasCohortStrata$name))
atlasCohortStrata$inverseName <- paste("without", trimws(atlasCohortStrata$name))
strata <- rbind(bulkStrata, atlasCohortStrata)
names(strata) <- c("name", "strataId", "strataName", "strataInverseName")
# Get all of the unique combinations of target + strata
targetStrataCP <- do.call(expand.grid, lapply(list(targetCohorts$targetId, strata$strataId), unique))
names(targetStrataCP) <- c("targetId", "strataId")
targetStrataCP <- merge(targetStrataCP, targetCohorts)
targetStrataCP <- merge(targetStrataCP, strata)
targetStrataCP <- targetStrataCP[order(targetStrataCP$strataId, targetStrataCP$targetId),]
targetStrataCP$cohortId <- (targetStrataCP$targetId * 1000000) + (targetStrataCP$strataId*10)
tWithS <- targetStrataCP
tWithoutS <- targetStrataCP[targetStrataCP$strataId %in% atlasCohortStrata$cohortId, ]
tWithS$cohortId <- tWithS$cohortId + 1
tWithS$cohortType <- "TwS"
tWithS$name <- paste(tWithS$targetName, tWithS$strataName)
tWithoutS$cohortId <- tWithoutS$cohortId + 2
tWithoutS$cohortType <- "TwoS"
tWithoutS$name <- paste(tWithoutS$targetName, tWithoutS$strataInverseName)
targetStrataXRef <- rbind(tWithS, tWithoutS)

# For shiny, construct a data frame to provide details on the original cohort names
xrefColumnNames <- c("cohortId", "targetId", "targetName", "strataId", "strataName", "cohortType")
targetCohortsForShiny <- targetCohorts
targetCohortsForShiny$cohortId <- targetCohortsForShiny$targetId
targetCohortsForShiny$strataId <- 0
targetCohortsForShiny$strataName <- "All"
targetCohortsForShiny$cohortType <- "Target"
inverseStrata <- targetStrataXRef[targetStrataXRef$cohortType == "TwoS",]
inverseStrata$strataName <- inverseStrata$strataInverseName

# Write out Shiny cohortXref.csv
shinyCohortXref <- rbind(targetCohortsForShiny[,xrefColumnNames], 
                         inverseStrata[,xrefColumnNames],
                         targetStrataXRef[targetStrataXRef$cohortType == "TwS",xrefColumnNames])
readr::write_csv(shinyCohortXref, file.path(shinyPath, "cohortXref.csv"))

# Write out the final targetStrataXRef
targetStrataXRef <- targetStrataXRef[,c("targetId","strataId","cohortId","cohortType","name")]
readr::write_csv(targetStrataXRef, file.path(settingsPath, "targetStrataXref.csv"))

#Write out Shiny cohorts.csv
cohorts <- rbind(targetCohorts,outcomeCohorts,atlasCohortStrata)
cohorts <- cohorts[,c("cohortId","atlasName","atlasId")]
cohorts <- cbind(cohorts,TRUE)
names(cohorts) <- c("cohortId","name","atlasId","circeDef")
readr::write_csv(cohorts, file.path(shinyPath, "cohorts.csv"))
