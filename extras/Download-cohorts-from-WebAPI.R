# This file just contains some example maintenance code and shouldn't be run as is

# ROhdsiWebApi version to install:
# remotes::install_github("ohdsi/ROhdsiWebApi",ref="develop")

baseUrl <- "https://pioneer-atlas.thehyve.net/WebAPI"
ROhdsiWebApi::setAuthHeader(baseUrl,
                            "Bearer ey...")  # get this token from an active ATLAS web session
ROhdsiWebApi::insertCohortDefinitionInPackage(cohortId = 142, baseUrl = baseUrl)


# Alternatively, once you have obtained a token (see Authenticate.R), you can use a global config:
# set_config(token = token) and then retrieve the cohort definition JSONs directly from WebAPI

getCohortDefinitionExpression <- function(definitionId, baseUrl) {
  url <- paste(baseUrl, "cohortdefinition", definitionId, sep = "/")
  json <- httr::GET(url)
  httr::content(json)
}

cohortPath <- "./inst/cohorts"

cohort <- getCohortDefinitionExpression(definitionId = 141, baseUrl = Sys.getenv("baseUrl"))
write(cohort$expression, file = file.path(cohortPath, "cohortname.json"))
