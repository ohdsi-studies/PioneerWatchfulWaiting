#' Updates the package with the latest skeleton features
#'
#' @details
#' Fetches the latest feature and changes to the skeleton to update the existing
#' package.
#'
updatePackageVersion <- function(force = FALSE) {
  source("./extras/updateSkeletonHelper.R")
  
  # Get the skeleton version of the current package. The skeleton version is
  # stored in the SkeletonNote field in the DESCRIPTION file.
  skeletonVersion <- packageDescription(
    pkg = "SkeletonPredictionStudy",
    lib.loc = NULL,
    fields = "SkeletonNote")
  
  # Get the name of the package that is to be updated to rename the new skeleton
  # files accordingly.
  packageName <- packageDescription(
    pkg = "SkeletonPredictionStudy",
    lib.loc = NULL,
    fields = "Package"
  )
  
  # Download the latest skeleton to a temporary location
  packageLocation <- downLoadSkeleton(outputFolder = tempdir(),
                                      packageName = packageName)
  
  # Get the version number of the downloaded/latest skeleton
  latestSkeletonVersion <- getLatestSkeletonVersion(dir = tempdir(),
                                                    packageName = packageName)
  
  # If a new version is available?
  if (compareVersion(skeletonVersion, latestSkeletonVersion) == 0 && !force) {
    print("Package skeleton is up-to-date.")
  } else if (compareVersion(skeletonVersion, latestSkeletonVersion) == -1 || force) {
    print(paste0("Your current version is ", skeletonVersion, " and version ",
                 latestSkeletonVersion, " is available. Updating.."))
    
    # replace name of downloaded skeleton
    replaceName(packageLocation = packageLocation,
                packageName = packageName)
    
    # Copy latest files from R folder to project
    file.copy(file.path(file.path(packageLocation, "R"),dir(file.path(packageLocation, "R"))),
              file.path(getwd(), "R"),
              recursive = TRUE, overwrite = TRUE)
    
    # Update skeleton version number in DESCRIPTION file
    desc::desc_set(SkeletonNote = latestSkeletonVersion)
    print("Update successful")
  } else {
    # do nothing
    print("Your skeleton version is ahead, this must be a mistake...")
  }
}
