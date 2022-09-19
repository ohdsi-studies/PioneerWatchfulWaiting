# code to create lockfiles

devtools::install_github('ohdsi/OhdsiRTools')

OhdsiRTools::createRenvLockFile(rootPackage = "SkeletonPredictionStudy",
                                includeRootPackage = FALSE,
                                additionalRequiredPackages = c(
                                  "CirceR",
                                  "CohortGenerator", # can't get this?
                                  "survAUC",
                                  "xgboost", 
                                  "DBI", 
                                  "DT", 
                                  "htmltools", 
                                  "Hydra",
                                  "plotly", 
                                  "pool", 
                                  "shiny", 
                                  "shinycssloaders", 
                                  "shinydashboard", 
                                  "shinyWidgets"
                                )
                                )


args <- c('env', 'export','-n','r-reticulate', '--no-builds',
          '|', 'findstr', '-v', '"prefix"' ,'> pyEnvironment.yml')
system2(reticulate::conda_binary(), args, stdout = TRUE)


