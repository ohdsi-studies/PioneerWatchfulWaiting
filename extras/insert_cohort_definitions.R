#remotes::install_github("ohdsi/ROhdsiWebApi")
library(ROhdsiWebApi)

baseUrl="https://pioneer-atlas.thehyve.net/WebAPI"
ROhdsiWebApi::setAuthHeader(baseUrl,"Bearer ey...") # get this token from an active ATLAS web session

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
#Post-processing to match json style:
#cd inst/cohorts
#find . -iname '*.json' -type f -exec sed -i.orig 's/\t/  /g' {} +
#find . -iname '*.json' -type f -exec sed -i.orig 's/" : /": /g' {} +
#rm -r *.orig