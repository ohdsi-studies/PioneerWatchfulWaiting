createValidationPackage <- function(
  devPackageName = 'PIONEER_clinician_driven_model',
  devDatabaseName,
  analysisLocation,
  analysisIds = NULL,
  outputFolder,
  validationPackageName,
  description = 'missing',
  createdBy = 'anonymous',
  organizationName = 'none',
  useHydra = F,
  skeletonVersion = 'v1.0.0'
){
  
  if(missing(analysisLocation)){
    stop('Must Enter analysisLocation')
  }
  if(missing(outputFolder)){
    stop('Must Enter outputFolder')
  }
  if(missing(validationPackageName)){
    stop('Must Enter validationPackageName')
  }
  
  
  packageLoc <- file.path(outputFolder, validationPackageName)
  
  # get settings
  plpSettingsLocation <- system.file(
    "settings",
    "predictionAnalysisList.json",
    package = devPackageName
    )
  plpSettings <- PatientLevelPrediction::loadPlpAnalysesJson(plpSettingsLocation)
  ParallelLogger::logInfo('Loaded development json')
  
  # get models specified by user
  #======
  results <- dir(file.path(analysisLocation), pattern = 'Analysis_')
  if(!is.null(analysisIds)){
    results <- results[gsub('Analysis_','',results) %in% analysisIds]
  }
  
  if(length(results) == 0 ){
    ParallelLogger::logInfo('No valid analyses selected')
    return(NULL)
  }
  
  ParallelLogger::logInfo(paste0('Loading models: ', paste0(results, collapse = ',')))
  
  modelJson <- list()
  length(modelJson) <- length(results)
  
  for(i in 1:length(results)){
    
    modelJson[[i]] <- PatientLevelPrediction::loadPlpModel(
      file.path(
        analysisLocation,
        results[i],
        'plpResult',
        'model'
      )
    )
    
  }
  #======
  
  # get the cohorts of interest from the models
  #======
  cohortDefinitions <- extractCohorts(modelJson, plpSettings$cohortDefinitions)
  ParallelLogger::logInfo('Restricted CohortDefinitions')
  #======
  
  # create the validation json settings 
  #======
  
  jsonList <- createValidationJson(
    packageName = validationPackageName,
    description = description,
    createdBy = createdBy,
    organizationName = organizationName,
    modelsJson = modelJson,
    cohortDefinitions = cohortDefinitions
  )
  ParallelLogger::logInfo('created jsonList')
  
  #======
  
  #======
  # create the skeleton package
  #======
  if(useHydra){
    ensure_installed("Hydra")
    if(!is_installed("Hydra", version = '0.0.8')){
      warning('Hydra need to be updated to use custom cohort covariates')
    }
    
    jsonList$skeletonVersion <- skeletonVersion
    jsonSet <- jsonlite::serializeJSON(jsonList, digits = 23)
    
    Hydra::hydrate(
      jsonSet,
      outputFolder = packageLoc
    )
    
    ParallelLogger::logInfo('Skeleton package created using Hydra')
    
  } else{
    
    nonHydraSkeleton(
      outputFolder = outputFolder,
      developmentPackageName = devPackageName,
      validationPackageName = validationPackageName,
      packageLocation =  packageLoc,
      jsonList = jsonList,
      cohortDefinitions = cohortDefinitions
    )
    
    ParallelLogger::logInfo('Skeleton package created using R functions')
    
  }
  
  #======
  # insert the models into the package
  #======
  transportModelsToJson(
    modelJson, 
    packageLoc
  )
  ParallelLogger::logInfo('Prediction models inserted into package')
  
  return(packageLoc)
}



nonHydraSkeleton <- function(
  outputFolder,
  developmentPackageName,
  validationPackageName,
  packageLocation,
  jsonList,
  cohortDefinitions
){
  
  packageLocation <- downLoadSkeleton(
    outputFolder = outputFolder,
    packageName = validationPackageName,
    skeletonType = 'SkeletonPredictionValidationStudy'
  )
  
  # replace 'SkeletonPredictionValidationStudy' with packageName 
  replaceName(
    packageLocation = packageLocation,
    packageName = validationPackageName,
    skeletonType = 'SkeletonPredictionValidationStudy'
  )
  
  # save json file into package
  saveAnalysisJson(
    packageLocation = packageLocation,
    jsonList = jsonList
  )
  
  # copy cohorts and Cohorts.csv from development package
  saveCohorts(
    developmentPackage = developmentPackageName,
    packageLocation = packageLocation,
    cohortDefinitions = cohortDefinitions
  )
}



# code to use skeleton master from github rather than hydra
# download a .zip file of the repository
# from the "Clone or download - Download ZIP" button
# on the GitHub repository of interest
downLoadSkeleton <- function(
  outputFolder,
  packageName,
  skeletonType = 'SkeletonPredictionValidationStudy'
){
  # check outputFolder exists
  
  # check file.path(outputFolder,  packageName) does not exist
  
  # download, unzip and rename:
  
  utils::download.file(url = paste0("https://github.com/ohdsi/",skeletonType,"/archive/main.zip")
    , destfile = file.path(outputFolder, "package.zip"))
  # unzip the .zip file
  utils::unzip(zipfile = file.path(outputFolder, "package.zip"), exdir = outputFolder)
  file.rename( from = file.path(outputFolder, paste0(skeletonType, '-main')),
    to = file.path(outputFolder,  packageName))
  unlink(file.path(outputFolder, "package.zip"))
  return(file.path(outputFolder, packageName))
}


# change name
replaceName <- function(
  packageLocation = getwd(),
  packageName = 'ValidateRCRI',
  skeletonType = 'SkeletonPredictionValidationStudy'
){
  
  filesToRename <- c(paste0(skeletonType,".Rproj"),paste0("R/",skeletonType,".R"))
  for(f in filesToRename){
    ParallelLogger::logInfo(paste0('Renaming ', f))
    fnew <- gsub(skeletonType, packageName, f)
    file.rename(from = file.path(packageLocation,f), to = file.path(packageLocation,fnew))
  }
  
  filesToEdit <- c(
    file.path(packageLocation,"DESCRIPTION"),
    file.path(packageLocation,"README.md"),
    file.path(packageLocation,"extras/CodeToRun.R"
    ),
    dir(file.path(packageLocation,"R"), full.names = T)
  )
  for( f in filesToEdit ){
    ParallelLogger::logInfo(paste0('Editing ', f))
    x <- readLines(f)
    y <- gsub( skeletonType, packageName, x )
    cat(y, file=f, sep="\n")
    
  }
  
  return(packageName)
}

saveAnalysisJson <- function(
  packageLocation,
  jsonList
){
  
  
  jsonList <- jsonlite::serializeJSON(jsonList, digits = 23)
  write(jsonList, file.path(packageLocation, 'inst', 'settings', 'predictionAnalysisList.json'))
  
  return(invisible(packageLocation))
}

saveCohorts <- function(
  developmentPackage,
  packageLocation,
  cohortDefinitions
){
  
  if(!dir.exists(file.path(packageLocation, 'inst', 'cohorts'))){
    dir.create(file.path(packageLocation, 'inst', 'cohorts'), recursive = T)
  }
  if(!dir.exists(file.path(packageLocation, 'inst', 'sql', 'sql_server'))){
    dir.create(file.path(packageLocation, 'inst',  'sql', 'sql_server'), recursive = T)
  }
  
  # get the csv of cohorts from the development
  cohortDf <- utils::read.csv(
    system.file(
      "Cohorts.csv",
      package = developmentPackage
    )
  )
  
  inds <- cohortDf$cohortId %in% unlist(lapply(cohortDefinitions, function(x) x$id))
  
  cohortDf <- cohortDf[inds,]
  ParallelLogger::logInfo('Saving CohortsToCreate.csv')
  utils::write.csv(x = cohortDf, file = file.path(packageLocation, 'inst', 'Cohorts.csv'))
  
  for( fileName in cohortDf$cohortId ){
    cohortLoc <- system.file(
      "cohorts",
      paste0(fileName, '.json'),
      package = developmentPackage
    )
    
    ParallelLogger::logInfo(paste0('Saving json for ', fileName))
    file.copy(
      from = cohortLoc, 
      to = file.path(packageLocation, 'inst', 'cohorts')
    )
    
    sqlLoc <- system.file(
      "sql", 
      "sql_server",
      paste0(fileName, '.sql'),
      package = developmentPackage
    )
    
    ParallelLogger::logInfo(paste0('Saving sql for ', fileName))
    file.copy(
      from = sqlLoc, 
      to = file.path(packageLocation, 'inst', 'sql', 'sql_server')
    )
    
    
  }
  
  return(invisible(T))
}


getCovariateCohorts <- function(covariateSettings){
  
  if(class(covariateSettings) == 'covariateSettings'){
    covariateSettings <- list(covariateSettings)
  }
  
  return(unlist(lapply(covariateSettings, function(x) x$cohortId)))
}

extractCohorts <- function(modelsJson, cohortDefinitions){
  
  targetIds <- unlist(lapply(modelsJson, function(x) x$trainDetails$cohortId))
  outcomeIds <- unlist(lapply(modelsJson, function(x) x$trainDetails$outcomeId))
  covariateIds <- unlist(lapply(modelsJson, function(x) getCovariateCohorts(x$settings$covariateSettings)))
  
  cohortIds <- unique(c(targetIds, outcomeIds, covariateIds))
  
  ind <- unlist(lapply(cohortDefinitions, function(x) x$id))
  cohortDefinitions <- cohortDefinitions[ind%in%cohortIds]
  
  return(cohortDefinitions)
}


# code to create validation json
createValidationJson <- function(
  packageName,
  description = "an example of the skeleton",
  skeletonVersion = 'v1.0.0',
  createdBy = 'name',
  organizationName = "add organization",
  modelsJson,
  cohortDefinitions
){
  
  # study details
  settings <- list(skeletonType = "PatientLevelPredictionValidationStudy")
  
  settings$packageName <- packageName
  settings$organizationName <- organizationName
  settings$description <- description
  settings$createdDate <- as.character(Sys.Date())
  settings$createdBy <-  createdBy
  
  # extract the settings and remove the rest
  settings$analyses <- lapply(modelsJson, function(x){
    list(
      trainDetails = x$trainDetails,
      settings = x$settings
    )
  }
  )
  
  settings$cohortDefinitions <- cohortDefinitions
  
  return(settings)
}


transportModelsToJson <- function(modelJson, packageLoc){
  
  lapply(
    1:length(modelJson), 
    function(i){
      PatientLevelPrediction::savePlpModel(
        plpModel = modelJson[[i]], 
        dirPath = file.path(packageLoc, 'inst', 'models', modelJson[[i]]$trainDetails$analysisId)
      )
    }
  )
  
  return(invisible(NULL))
}



