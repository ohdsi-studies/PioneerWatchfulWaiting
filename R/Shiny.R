# Copyright 2021 Observational Health Data Sciences and Informatics
#
# This file is part of PioneerWatchfulWaiting
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

#' @export
launchShinyApp <- function(outputFolder, 
                           shinySettings = list(storage = "filesystem", 
                                                dataFolder = outputFolder, 
                                                dataFile = "PreMerged.RData")) 
{
  ensure_installed("shiny")
  ensure_installed("shinydashboard")
  ensure_installed("shinyWidgets")
  ensure_installed("DT")
  ensure_installed("data.table")
  ensure_installed("VennDiagram")
  ensure_installed("htmltools")
  ensure_installed("pool")
  appDir <- system.file("shiny/PioneerWatchfulWaitingExplorer", package = getThisPackageName(), mustWork = TRUE)
  .GlobalEnv$shinySettings <- shinySettings
  on.exit(rm(shinySettings, envir = .GlobalEnv))
  shiny::runApp(appDir)
}

#' Premerge Shiny results files
#' 
#' @description 
#' If there are many results files, starting the Shiny app may take a very long time. This function 
#' already does most of the preprocessing, increasing loading speed.
#' 
#' The merged data will be stored in the same folder, and will automatically be recognized by the Shiny app.
#'
#' @param dataFolder  folder where the exported zip files for the diagnostics are stored. Use
#'                         the runStudy function to generate these zip files. 
#'                         Zip files containing results from multiple databases can be placed in the same
#'                         folder.
#'                         
#' @export
preMergeResultsFiles <- function(dataFolder) {
  zipFiles <- list.files(dataFolder, pattern = ".zip", full.names = TRUE)
  
  loadFile <- function(file, folder, overwrite) {
    # print(file)
    tableName <- gsub(".csv$", "", file)
    camelCaseName <- SqlRender::snakeCaseToCamelCase(tableName)
    data <- data.table::fread(file.path(folder, file))
    colnames(data) <- SqlRender::snakeCaseToCamelCase(colnames(data))
    
    if (!overwrite && exists(camelCaseName, envir = .GlobalEnv)) {
      existingData <- get(camelCaseName, envir = .GlobalEnv)
      if (nrow(existingData) > 0) {
        if (nrow(data) > 0) {
          if (all(colnames(existingData) %in% colnames(data)) &&
              all(colnames(data) %in% colnames(existingData))) {
            existingCols <- colnames(existingData)
            data <- data[, ..existingCols]
          } else {
            stop("Table columns do no match previously seen columns. Columns in ", 
                 file, 
                 ":\n", 
                 paste(colnames(data), collapse = ", "), 
                 "\nPrevious columns:\n",
                 paste(colnames(existingData), collapse = ", "))
            
          }
        }
      }
      data <- rbind(existingData, data)
    }
    assign(camelCaseName, data, envir = .GlobalEnv)
    
    invisible(NULL)
  }
  tableNames <- c()
  for (i in 1:length(zipFiles)) {
    writeLines(paste("Processing", zipFiles[i]))
    tempFolder <- tempfile()
    dir.create(tempFolder)
    unzip(zipFiles[i], exdir = tempFolder)
    
    csvFiles <- list.files(tempFolder, pattern = ".csv")
    tableNames <- c(tableNames, csvFiles)
    lapply(csvFiles, loadFile, folder = tempFolder, overwrite = (i == 1))
    
    unlink(tempFolder, recursive = TRUE)
  }
  
  # Update the covariate names for the age groups 
  # that are > 100 years since they are truncated to 2
  # digits
  ageCovariateIdsToReformat <- seq(200031,380031, by=10000) # This represents the covariate IDs that are used to represent age groups from 100-200
  if (exists("covariate", envir = .GlobalEnv)) {
    covars <- get("covariate", envir = .GlobalEnv)
    
    #Ensure all covariates are unique by making all covarateName fields lower case
    covars$covariateName <- tolower(covars$covariateName)
    covars <- unique(covars)
    
    # Reformat age covariates
    ageCovars <- covars[covars$covariateId %in% ageCovariateIdsToReformat, ]
    if (nrow(ageCovars) > 0) {
      for (i in 1:nrow(ageCovars)) {
        covars[covars$covariateId == ageCovars$covariateId[i], ]$covariateName <- reformatAgeCovariateDescription(ageCovars$covariateName[i])
      }
    }
    
    # Re-assign to the global environment
    assign("covariate", covars, envir = .GlobalEnv)
  }

  tableNames <- unique(tableNames)
  tableNames <- gsub(".csv$", "", tableNames)
  tableNames <- SqlRender::snakeCaseToCamelCase(tableNames)
  save(list = tableNames, file = file.path(dataFolder, "PreMerged.RData"), compress = TRUE)
  ParallelLogger::logInfo("Merged data saved in ", file.path(dataFolder, "PreMerged.RData"))
}

reformatAgeCovariateDescription <- function(description) {
  splitDesc <- strsplit(description, " ") # Split to get the age range
  ageRange <- strsplit(splitDesc[[1]][3], "-")
  lowerBound <- as.integer(ageRange[[1]][1]) + 100
  upperBound <- as.integer(ageRange[[1]][2]) + 100
  return(paste0("age group: ", lowerBound, "-", upperBound))
}


# Borrowed from devtools:
# https://github.com/hadley/devtools/blob/ba7a5a4abd8258c52cb156e7b26bb4bf47a79f0b/R/utils.r#L44
is_installed <- function(pkg, version = 0) {
  installed_version <- tryCatch(utils::packageVersion(pkg), error = function(e) NA)
  !is.na(installed_version) && installed_version >= version
}

# Borrowed and adapted from devtools:
# https://github.com/hadley/devtools/blob/ba7a5a4abd8258c52cb156e7b26bb4bf47a79f0b/R/utils.r#L74
ensure_installed <- function(pkg) {
  if (!is_installed(pkg)) {
    msg <- paste0(sQuote(pkg), " must be installed for this functionality.")
    if (interactive()) {
      message(msg, "\nWould you like to install it?")
      if (menu(c("Yes", "No")) == 1) {
        install.packages(pkg)
      } else {
        stop(msg, call. = FALSE)
      }
    } else {
      stop(msg, call. = FALSE)
    }
  }
}
