# code to set up package dependancies
packages <- c('DatabaseConnector',
              'jsonlite',
              'magrittr',
              'PatientLevelPrediction',
              'ParallelLogger',
              'reshape2',
              'SqlRender',
              'utils',
              'Andromeda',
              'DT',
              'devtools',
              'FeatureExtraction',
              'ggplot2',
              'grDevices',
              'gridExtra',
              'htmltools',
              'Hydra',
              'knitr',
              'officer',
              'OhdsiSharing',
              'plotly',
              'rmarkdown',
              'R.utils',
              'shiny',
              'shinycssloaders',
              'shinydashboard',
              'shinyWidgets',
              'VennDiagram')


# Borrowed from devtools: https://github.com/hadley/devtools/blob/ba7a5a4abd8258c52cb156e7b26bb4bf47a79f0b/R/utils.r#L44
is_installed <- function (pkg, version = 0) {
  installed_version <- tryCatch(utils::packageVersion(pkg), 
                                error = function(e) NA)
  !is.na(installed_version) && installed_version >= version
}

# Borrowed and adapted from devtools: https://github.com/hadley/devtools/blob/ba7a5a4abd8258c52cb156e7b26bb4bf47a79f0b/R/utils.r#L74
ensure_installed <- function(pkg) {
  if (!is_installed(pkg)) {
    msg <- paste0(sQuote(pkg), " must be installed for this functionality.")
    if (interactive()) {
      message(msg, "\nWould you like to install it?")
      if (utils::menu(c("Yes", "No")) == 1) {
        if(pkg%in%c('BigKnn','Andromeda','DatabaseConnector', 'SqlRender', 'Cyclops', 'FeatureExtraction', 'PatientLevelPrediction','OhdsiSharing', 'ParallelLogger')){
          devtools::install_github(paste0('OHDSI/',pkg))
        }else{
          utils::install.packages(pkg)
        }
      } else {
        stop(msg, call. = FALSE)
      }
    } else {
      stop(msg, call. = FALSE)
    }
  }
}


sapply(packages, ensure_installed)
