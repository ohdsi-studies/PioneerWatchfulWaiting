#' Repack diagnostics files
#' 
#' @description 
#' The preMergeDiagnostics files creates one zip file per database with diagnostics for all cohort groups
#' (target, outcome,strata). However, in order to show diagnostics results from multiple databases, these
#' have to be re-combined per cohort group.
#' This function will unpack all 
#'
#' @param dataFolder  folder where the exported zip files for the diagnostics are stored. Use
#'                         the runStudy function to generate these zip files. 
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
      dbname <- stringr::str_match(zipFiles[i],"diagnostics_(\\w++).zip$")[,2] # extract database name
      writeLines(paste("naam",dbname))
      
      # Unpack zip file
      tempFolder <- tempfile()
      dir.create(tempFolder)
      unzip(zipFiles[i], exdir = tempFolder)
      
      # Iterate over folders from zip file
      writeLines(list.files(tempFolder))
      dirs <- list.dirs(path = tempFolder)
      writeLines("th")
      writeLines(dirs)
      writeLines("df")
      for (j in 2:length(dirs)) {
        #writeLines(dirs[j])
        #writeLines("Processing",dirs[j])
        dirname <- stringr::str_match(dirs[j],"(\\w*)$")[,1]
        # Iterate over zip files in folder
        writeLines(dirname)
        zips <- list.files(path = dirs[j], full.names = TRUE)
        for (k in 1:length(zips)) {
          writeLines(zips[k])
          newname <- paste0(stringr::str_match(zips[k],"(\\w*).zip$")[,2],"_",dirname,".zip")
          writeLines(file.path(dataFolder,"repacked",newname))
          writeLines("now2")
          file.copy(zips[k],file.path(dataFolder,"repacked",newname))
        }
      }
      
      writeLines("unlink")
      unlink(tempFolder, recursive = TRUE)
      
    }
  }
}