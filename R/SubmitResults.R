# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of PIONEER_clinician_driven_model
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

#' Submit the study results to the study coordinating center
#'
#' @details
#' This will upload the file \code{StudyResults.zip} to the OHDSI SFTP server
#' This requires an active internet connection.
#'
#' @param outputFolder   Name of local folder where the results were generated; make sure to use forward slashes
#'                       (/). Do not use a folder on a network drive since this greatly impacts
#'                       performance.
#' @param privateKeyFileName   A character string denoting the path to an RSA private key.
#' @param userName             A character string containing the user name.
#' @param remoteFolder         The remote folder to upload the file to (default is 'patientLevelPrediction').
#'
#' @return
#' TRUE if the upload was successful.
#'
#' @export
submitResults <- function(outputFolder, privateKeyFileName, userName, remoteFolder = NULL) {
  zipName <- file.path(outputFolder, "resultsToShare.zip")
  if (!file.exists(zipName)) {
    stop(paste("Cannot find file", zipName))
  }
  ParallelLogger::logInfo(paste0("Uploading file '", zipName, "' to study coordinating center"))
  tryCatch({OhdsiSharing::sftpUploadFile(fileName = zipName, 
    remoteFolder = ifelse(is.null(remoteFolder), "patientLevelPrediction", remoteFolder),
    privateKeyFileName  = privateKeyFileName,
    userName = userName)},
    error = function(e){ParallelLogger::logInfo("Upload failed. Please contact the study coordinator"); ParallelLogger::logInfo(paste0('Error: ', e))}
  )
  ParallelLogger::logInfo("Finished uploading")
}
