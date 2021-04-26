settingsPath <- "inst/settings"
cohortGroups <- readr::read_csv("inst/settings/CohortGroups.csv", col_types=readr::cols())

# Create the corresponding diagnostic file 
for (i in 1:nrow(cohortGroups)) {
  ParallelLogger::logInfo("* Creating diagnostics settings file for: ", cohortGroups$cohortGroup[i], " *")
  cohortsToCreate <- readr::read_csv(file.path("inst/", cohortGroups$fileName[i]), col_types = readr::cols())
  cohortsToCreate$name <- cohortsToCreate$cohortId
  readr::write_csv(cohortsToCreate, file.path("inst/settings/diagnostics/", basename(cohortGroups$fileName[i])))
}


# Create the list of combinations of T, TwS, TwoS for the combinations of strata ----------------------------
useSubset <- as.logical(Sys.getenv("USE_SUBSET"))
if (useSubset) {
  settingsPath <- file.path(settingsPath, "subset/")
}
targetCohorts <- read.csv(file.path(settingsPath, "CohortsToCreateTarget.csv"))
bulkStrata <- read.csv(file.path(settingsPath, "BulkStrata.csv"))
atlasCohortStrata <- read.csv(file.path(settingsPath, "CohortsToCreateStrata.csv"))
outcomeCohorts <- read.csv(file.path(settingsPath, "CohortsToCreateOutcome.csv"))

# Get a list of strata IDs for which there's no need to create "without" strata
exclusion <- atlasCohortStrata$cohortId[atlasCohortStrata$createInverse == FALSE]


# Ensure all of the IDs are unique
allCohortIds <- c(targetCohorts[,match("cohortId", names(targetCohorts))],
                  bulkStrata[,match("cohortId", names(bulkStrata))],
                  atlasCohortStrata[,match("cohortId", names(atlasCohortStrata))],
                  outcomeCohorts[,match("cohortId", names(outcomeCohorts))])
allCohortIds <- sort(allCohortIds)

totalRows <- nrow(targetCohorts) + nrow(bulkStrata) + nrow(atlasCohortStrata) + nrow(outcomeCohorts)
if (length(unique(allCohortIds)) != totalRows) {
  warning("There are duplicate cohort IDs in the settings files!")
}

# When necessary, use this to view the full list of cohorts in the study
fullCohortList <- rbind(targetCohorts[,c("cohortId", "atlasId", "name")],
                        atlasCohortStrata[,c("cohortId", "atlasId", "name")],
                        outcomeCohorts[,c("cohortId", "atlasId", "name")])

fullCohortList <- fullCohortList[order(fullCohortList$cohortId),]

# Target cohorts
colNames <- c("name", "cohortId") # Use this to subset to the columns of interest
# targetCohorts <- rbind(covidCohorts, influenzaCohorts)
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
tWithoutS <- tWithoutS[!(tWithoutS$strataId) %in% exclusion, ]
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

shinyCohortXref <- rbind(targetCohortsForShiny[,xrefColumnNames], 
                         inverseStrata[,xrefColumnNames],
                         targetStrataXRef[targetStrataXRef$cohortType == "TwS",xrefColumnNames])
if (!useSubset) {
  readr::write_csv(shinyCohortXref, file.path("inst/shiny/PIONEERWatchfulWaitingExplorer", "cohortXref.csv"))
}

targetStrataXRef <- targetStrataXRef[,c("targetId","strataId","cohortId","cohortType","name")]

# Write out the final targetStrataXRef
readr::write_csv(targetStrataXRef, file.path(settingsPath, "targetStrataXref.csv"))


# Store environment in which the study was executed -----------------------
# OhdsiRTools::insertEnvironmentSnapshotInPackage("PioneerWatchfulWaiting")

