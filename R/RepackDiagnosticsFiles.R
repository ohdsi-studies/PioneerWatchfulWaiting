# @file RepackDiagnosticsFiles.R
#
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

#' Repack diagnostics files
#' 
#' @description 
#' The preMergeDiagnostics files creates one zip file per database with diagnostics for all cohort groups
#' (target, outcome,strata). However, in order to show diagnostics results from multiple databases, these
#' have to be re-combined per cohort group.
#' This function will unpack all zip files found in `dataFolder`, 
#' and copy any zip files found in subfolders of these zip files into a new folder 'repacked'.
#'
#' @param dataFolder  folder where the exported zip files for the diagnostics are stored. 
#'                         Zip files containing results from multiple databases can be placed in the same
#'                         folder.
#'                         
#' @export
repackDiagnosticsFiles <- function(dataFolder) {
  # Iterate over zip files in data folder
  zipFiles <- list.files(dataFolder, pattern = ".zip", full.names = TRUE)
  if (length(zipFiles) == 0) {
    writeLines("No zip files found in folder.")
  }
  else {
    dir.create(file.path(dataFolder,"repacked"))
    for (i in 1:length(zipFiles)) {
      writeLines(paste("Processing", zipFiles[i]))
      # Extract database name, if the name of the zip file doesn't match then it will be NA
      dbname <- stringr::str_match(zipFiles[i],"diagnostics_(\\w++).zip$")[,2] # extract database name
      
      # Unpack zip file
      tempFolder <- tempfile()
      dir.create(tempFolder)
      unzip(zipFiles[i], exdir = tempFolder)
      
      # Iterate over folders from zip file
      dirs <- list.dirs(path = tempFolder)
      # Start from 2 because first entry is the folder itself
      for (j in 2:length(dirs)) {
        dirname <- stringr::str_match(dirs[j],"(\\w*)$")[,1]

        # Iterate over zip files in folder
        zips <- list.files(path = dirs[j], full.names = TRUE)
        for (k in 1:length(zips)) {
          newname <- paste0(stringr::str_match(zips[k],"(\\w*).zip$")[,2],"_",dirname,".zip")
          newfile <- file.path(dataFolder,"repacked",newname)
          file.copy(zips[k],newfile)
          writeLines(paste("Writing",newfile))
        }
      }
      
      # Remove temporary folder
      unlink(tempFolder, recursive = TRUE)
      
    }
  }
}