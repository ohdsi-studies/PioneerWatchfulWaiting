source(file.path(getwd(),'extras/createDevelopmentPackageFunctions.R'))
#devtools::source_url("https://raw.github.com/ohdsi/SkeletonPredictionStudy/issue242/extras/createDevelopmentPackageFunctions.R")

packageName <- 'ExamplePrediction'
baseUrl <- 'https://api.ohdsi.org/WebAPI/'

# create a model to predict cohortId 2 in patients in cohortId 1
modelDesign1 <- PatientLevelPrediction::createModelDesign(
  targetId = 3644, 
  outcomeId = 3992, 
  restrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings(sampleSize = 1000000), 
  populationSettings = PatientLevelPrediction::createStudyPopulationSettings(
    washoutPeriod = 365, 
    requireTimeAtRisk = F, 
    riskWindowStart = 1, 
    riskWindowEnd = 365
    ), 
  covariateSettings = FeatureExtraction::createCovariateSettings(
    useDemographicsGender = T, 
    useDemographicsAgeGroup = T, 
    useConditionGroupEraLongTerm = T
    ), 
  featureEngineeringSettings = NULL, 
  sampleSettings = NULL, 
  preprocessSettings = PatientLevelPrediction::createPreprocessSettings(
    minFraction = 1/10000, 
    normalize = T
    ), 
  modelSettings = PatientLevelPrediction::setLassoLogisticRegression(), 
  runCovariateSummary = T
  )

# this model will include 2 cohort variables
modelDesign2 <- PatientLevelPrediction::createModelDesign(
  targetId = 3644, 
  outcomeId = 3992, 
  restrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings(sampleSize = 1000000), 
  populationSettings = PatientLevelPrediction::createStudyPopulationSettings(
    washoutPeriod = 365, 
    requireTimeAtRisk = F, 
    riskWindowStart = 1, 
    riskWindowEnd = 365
  ), 
  covariateSettings = list(
    FeatureExtraction::createCovariateSettings(
      useDemographicsGender = T, 
      useDemographicsAgeGroup = T, 
      useConditionGroupEraLongTerm = T
    ), 
    PatientLevelPrediction::createCohortCovariateSettings(
      cohortName = 'diabetes', 
      settingId = 1, 
      cohortDatabaseSchema = NULL, 
      cohortTable = NULL, 
      cohortId = 1182, 
      startDay = -365, 
      endDay = 0, 
      analysisId = 456
    ),
    PatientLevelPrediction::createCohortCovariateSettings(
      cohortName = 'liver conditions', 
      settingId = 1, 
      cohortDatabaseSchema = NULL, 
      cohortTable = NULL, 
      cohortId = 4016, 
      startDay = -365, 
      endDay = 0, 
      analysisId = 456
    )
  ),
  featureEngineeringSettings = NULL, 
  sampleSettings = NULL, 
  preprocessSettings = PatientLevelPrediction::createPreprocessSettings(
    minFraction = 1/10000, 
    normalize = T
  ), 
  modelSettings = PatientLevelPrediction::setLassoLogisticRegression(), 
  runCovariateSummary = T
)

modelDesignList <- list(
  modelDesign1,
  modelDesign2 
)

jsonList <- createDevelopmentSkeletonSettings(
  packageName = packageName,
  organizationName = "OHDSI",
  modelDesignList = modelDesignList,
  splitSettings = PatientLevelPrediction::createDefaultSplitSetting(),
  baseUrl = baseUrl,
  saveDirectory = NULL
  )


createDevelopmentPackage(
  jsonList = jsonList, 
  baseUrl = baseUrl,
  #skeletonLocation = 'D:/GitHub/SkeletonPredictionStudy', 
  skeletonUrl = "https://github.com/ohdsi/SkeletonPredictionStudy/archive/master.zip",
  outputLocation = '/Users/jreps/Documents/testing2',
  packageName = packageName
  )
