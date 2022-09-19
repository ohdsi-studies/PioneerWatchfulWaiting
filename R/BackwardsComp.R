backwards <- function(predictionAnalysisListFile){
  
  json <- tryCatch({ParallelLogger::loadSettingsFromJson(file=predictionAnalysisListFile)},
                   error=function(cond) {
                     stop('Issue with json file...')
                   })
  
  modelList <- list()
  length(modelList) <-  length(json$modelSettings)
  for(i in 1:length(json$modelSettings)){
    ParallelLogger::logWarn('Using backwards compatible json - only default hyper-parameters can be used')
    name <- names(json$modelSettings[[i]])
    modelList[[i]] <- do.call(get(paste0('set',gsub('Settings','',name)), envir = environment(PatientLevelPrediction::getPlpData)), 
                              list()
    )
  }
  
  # this can be multiple?
  ##covariateSettingList <- lapply(json$covariateSettings, function(x) do.call(FeatureExtraction::createCovariateSettings, x))
  covariateSettingList <- json$covariateSettings
  
  # extract the population settings:
  for(i in 1:length(json$populationSettings)){
    json$populationSettings[[i]]$startAnchor <- ifelse(json$populationSettings[[i]]$addExposureDaysToStart, 'cohort end', 'cohort start')
    json$populationSettings[[i]]$addExposureDaysToStart <- NULL
    json$populationSettings[[i]]$endAnchor <- ifelse(json$populationSettings[[i]]$addExposureDaysToEnd, 'cohort end', 'cohort start')
    json$populationSettings[[i]]$addExposureDaysToEnd <- NULL
  }
  
  populationSettingList <- lapply(json$populationSettings, function(x) do.call(PatientLevelPrediction::createStudyPopulationSettings, x))
  
  preprocessSettings <- PatientLevelPrediction::createPreprocessSettings(
    minFraction = json$runPlpArgs$minCovariateFraction, 
    normalize = json$runPlpArgs$normalizeData
    )
  
  restrictPlpDataSettings <- PatientLevelPrediction::createRestrictPlpDataSettings(
    washoutPeriod = json$getPlpDataArgs$washoutPeriod, 
    sampleSize = json$getPlpDataArgs$maxSampleSize
      )
  
  modelDesign <- list()
  length(modelDesign) <- length(json$targetIds)*length(json$outcomeIds)*length(modelList)*length(covariateSettingList)*length(populationSettingList)
  mdind <- 1
  for(i in 1:length(json$targetIds)){
    tid <- json$targetIds[i]
    
    for(j in 1:length(json$outcomeIds)){
      oid <- json$outcomeIds[j]
      
      for(k in 1:length(modelList)){
        mod <- modelList[[k]]
        
        for(l in 1:length(covariateSettingList)){
          covs <- covariateSettingList[[l]]
          
          for(m in 1:length(populationSettingList)){
            pop <- populationSettingList[[m]]
            
            modelDesign[[mdind]] <- PatientLevelPrediction::createModelDesign(
              targetId = tid, 
              outcomeId = oid,
              restrictPlpDataSettings = restrictPlpDataSettings, 
              populationSettings = pop, 
              covariateSettings = covs, 
              featureEngineeringSettings = PatientLevelPrediction::createFeatureEngineeringSettings(),
              sampleSettings = PatientLevelPrediction::createSampleSettings(), 
              preprocessSettings = preprocessSettings, 
              modelSettings = mod, 
              runCovariateSummary = T
              )
            
            mdind <- mdind + 1
            
          } # end pop
        } # end cov
      } # end model
    } # end out
  } # end tar
  
  # create modelDesigns:
  json$analyses <- modelDesign
  
  #create split setting
  if(json$runPlpArgs$testSplit %in% c('subject', 'time', 'stratified')){
    splitType <- json$runPlpArgs$testSplit
  }else{
    splitType <- 'subject'
  }
  
  # If splitSeed is NULL then give a default SplitSeed
  if(is.null(json$runPlpArgs$splitSeed)){
    splitSeed <- sample(1e+05, 1)
  } else {
    splitSeed <- json$runPlpArgs$splitSeed
  }
  
  json$splitSettings <- PatientLevelPrediction::createDefaultSplitSetting(
    testFraction = json$runPlpArgs$testFraction, 
    splitSeed = splitSeed, 
    nfold = json$runPlpArgs$nfold, 
    type = splitType
    )
  
  return(json)
}

#backwards("/Users/jreps/Documents/github/PIONEER_clinician_driven_model/inst/settings/predictionAnalysisList_old.json")


