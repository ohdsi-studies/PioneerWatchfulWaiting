# code to use skeleton master from github rather than hydra
# download a .zip file of the repository
# from the "Clone or download - Download ZIP" button
# on the GitHub repository of interest
downLoadSkeleton <- function(outputFolder,
                             packageName,
                             skeletonType = 'SkeletonPredictionStudy'){
  # check outputFolder exists
  
  # check file.path(outputFolder,  packageName) does not exist
  
  # download, unzip and rename:
  
  download.file(url = paste0("https://github.com/ohdsi/",skeletonType,"/archive/master.zip")
                , destfile = file.path(outputFolder, "package.zip"))
  # unzip the .zip file
  unzip(zipfile = file.path(outputFolder, "package.zip"), exdir = outputFolder)
  file.rename( from = file.path(outputFolder, paste0(skeletonType, '-master')),
               to = file.path(outputFolder,  packageName))
  unlink(file.path(outputFolder, "package.zip"))
  return(file.path(outputFolder, packageName))
}

# change name
replaceName <- function(packageLocation = getwd(),
                        packageName = 'ValidateRCRI',
                        skeletonType = 'SkeletonPredictionStudy'){
  
  filesToRename <- c(paste0(skeletonType,".Rproj"),paste0("R/",skeletonType,".R"))
  for(f in filesToRename){
    ParallelLogger::logInfo(paste0('Renaming ', f))
    fnew <- gsub(skeletonType, packageName, f)
    file.rename(from = file.path(packageLocation,f), to = file.path(packageLocation,fnew))
  }
  
  filesToEdit <- c(file.path(packageLocation,"DESCRIPTION"),
                   file.path(packageLocation,"README.md"),
                   file.path(packageLocation,"extras/CodeToRun.R"),
                   file.path(packageLocation, "extras/updateSkeleton.R"),
                   dir(file.path(packageLocation,"R"), full.names = T))
  for( f in filesToEdit ){
    ParallelLogger::logInfo(paste0('Editing ', f))
    x <- readLines(f)
    y <- gsub( skeletonType, packageName, x )
    cat(y, file=f, sep="\n")
    
  }
  
  return(packageName)
}

getLatestSkeletonVersion <- function(dir, packageName) {
  packageDescription(packageName,
                     lib.loc = dir,
                     fields = "Version")
}
