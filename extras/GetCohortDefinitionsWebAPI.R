library(dplyr)
library(ROhdsiWebApi)
library(RJSONIO)

# Error when reading fields containing '#'
# copy required info into clipboard prior to next instruction execution 
# allCohorts <- read.table(file = "clipboard",
#                       sep = "\t", header=TRUE)


# Cohort definitions (sql json) files and "toCreate" csv list are placed here
outputFolderPath <- "C:/Users/Artem/PIONEERcohorts"

# cohorts description source file
cohortListPath <- 'C:\\Users\\Artem\\work\\PIONEER studyathon\\cohorts.csv'

# set up correct names for essential columns
cohortIdField <- "ï..PhenoID"
cohortNameField <- "Phenotype.name"
atlasLinkField <- "Where..link.to.PIONEER.CENTRAL.ATLAS."
cohortTypeField <- "Intended.use"

# WebAPI connection info
token <- 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhcnRlbS5nb3JiYWNoZXZAb2R5c3NldXNpbmMuY29tIiwiZXhwIjoxNjE4MDA5NjM0fQ.ijPIQRWZSheSXRNXeO8EOQ5ZrkEB6DiCIM09zqnaVEXSk-cZ_lz_6Mw9h-T-UBtPHyqk1bRUW3yKoah27H4fsA'
baseUrl <- 'https://pioneer-atlas.thehyve.net/WebAPI'
setAuthHeader(baseUrl = baseUrl, token)
# to be sure that connection is established
getCdmSources(baseUrl)

allCohorts <- read.csv(cohortListPath)
print(names(allCohorts))

allCohorts <- allCohorts[, c(cohortIdField, cohortNameField, atlasLinkField, cohortTypeField)]
colnames(allCohorts) <- c("cohortId", "name", "atlasLink", "type")



getCohortInfo <- function(allCohorts, type, baseUrl){
  cohortsToCreate <- data.frame(name = character(), 
                                atlasName = character(),
                                atlasId = character(),
                                cohortId = character()
  )
  cohorts <- allCohorts[allCohorts$type == type, ]
  cohorts <- cohorts[order(cohorts$cohortId), ]
  
  if(type =='Stratum'){
    type = 'Strata'
  }
  
  outputFolder <- file.path(outputFolderPath, type)
  
  if (!file.exists(outputFolder)) {
    dir.create(outputFolder, recursive = TRUE)
  }
  
  if(!file.exists(file.path(outputFolder, paste0("CohortsToCreate", type, ".csv")))){
    write.csv(cohortsToCreate, file=file.path(outputFolder, paste0("CohortsToCreate", type, ".csv")), row.names = FALSE)
  }
  
  for(rowNum in 1 : nrow(cohorts)){
    createdCohorts <- read.csv(file.path(outputFolder, paste0("CohortsToCreate", type, ".csv")))
    createdCohorts <- createdCohorts$atlasId
    
    atlasId <- cohorts[rowNum, "atlasLink"]
    atlasId <- as.integer(tail(strsplit(atlasId, '/')[[1]], n=1))
    if(!(atlasId %in% createdCohorts)){
      name <- cohorts[rowNum, "name"]
      name <- trimws(name)
      print(name)
      cohortInfo <- getCohortDefinition(atlasId, baseUrl)
      atlasName <- cohortInfo$name
      sql <- getCohortSql(cohortInfo, baseUrl, generateStats = FALSE)
      json <- toJSON(cohortInfo$expression)
      row <- c(name, atlasName, atlasId, atlasId)
      
      write(json, file.path(outputFolder, paste(atlasId, "json", sep = '.')))
      write(sql, file.path(outputFolder, paste(atlasId, "sql", sep = '.')))
      
      write.table(t(row), 
                  file=file.path(outputFolder, paste0("CohortsToCreate", type, ".csv")),
                  sep = ',',
                  row.names = FALSE,
                  col.names = FALSE,
                  append = TRUE)
    }
  }
}



getCohortInfo(allCohorts, 'Target', baseUrl)
getCohortInfo(allCohorts, 'Outcome', baseUrl)
getCohortInfo(allCohorts, 'Stratum', baseUrl)

