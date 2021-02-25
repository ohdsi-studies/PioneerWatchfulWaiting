# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

execute <- function(connection,
                    cdmDatabaseSchema,
                    targetDatabaseSchema,
                    cohortTable,
                    oracleTempSchema,
                    outputFolder,
                    createCohorts,
                    days_offset){


  ### Create output directory
  folder <- "output"
  dir.create(folder, showWarnings = FALSE)
  output_folder <- paste0(folder,"/",outputFolder)
  dir.create(output_folder, showWarnings = FALSE)


  ### createCohorts
  if(createCohorts){

    .createCohorts(connection,
                   cdmDatabaseSchema,
                   vocabularyDatabaseSchema = cdmDatabaseSchema,
                   cohortDatabaseSchema = targetDatabaseSchema,
                   cohortTable = cohortTable,
                   oracleTempSchema = oracleTempSchema,
                   output_folder,
                   days_offset)
  }


  # ### Read pathway JSON
  # pathwayDef <- jsonlite::read_json(system.file("settings", "pathwaySpecification.json", package = "OT2DSI"))
  #
  # ### Read names of cohort to create
  # pathwaysCohorts <- read.csv(system.file("settings", "CohortsToCreate.csv", package = "OT2DSI"))
  #
  # event_cohort_id_index_map <- pathwaysCohorts %>%
  #   filter(cohortType == 1) %>%
  #   rename(cohort_definition_id = cohortId) %>%
  #   mutate(cohort_index = row_number() - 1) %>%
  #   mutate(atlasName = stringr::str_replace(atlasName,'OT2DSI_','')) %>%
  #   select(cohort_definition_id, cohort_index, atlasName) %>%
  #   as.data.frame()
  #
  # event_cohort_id_index_map <- event_cohort_id_index_map %>% mutate(powered_index = 2^cohort_index)
  #
  # write.csv(event_cohort_id_index_map, file.path("inst/settings", "cohort_id_index_map.csv"), row.names = F)
  #
  # ### Create target cohort data frame
  # target_cohorts <- pathwaysCohorts %>%
  #   filter(cohortType == 0) %>%
  #   select(cohortId, atlasName) %>%
  #   rename(cohort_definition_id = cohortId, name = atlasName)


  # ### generatePathways
  # if(generatePathways){
  #
  #         .generatePathways(connection,
  #                           cdmDatabaseSchema = cdmDatabaseSchema,
  #                           targetDatabaseSchema = targetDatabaseSchema,
  #                           cohortTable = cohortTable,
  #                           event_cohort_id_index_map,
  #                           target_cohorts,
  #                           pathwayDef,
  #                           oracleTempSchema,
  #                           output_folder = output_folder)
  # }
  #
  #
  # ### plotResults
  # if(plotResults){
  #
  #             .plotResults(connection,
  #                           cdmDatabaseSchema,
  #                           vocabularyDatabaseSchema = cdmDatabaseSchema,
  #                           cohortDatabaseSchema = targetDatabaseSchema,
  #                           cohortTable = cohortTable,
  #                           oracleTempSchema,
  #                           output_folder = output_folder)
  # }
  #
  #
  # ### getCharacterization
  # if (getCharacterization) {
  #
  #     .getCohortCharacteristics (connectionDetails = connectionDetails,
  #                                connection = connection,
  #                                cdmDatabaseSchema,
  #                                oracleTempSchema ,
  #                                cohortDatabaseSchema = cdmDatabaseSchema,
  #                                cohortTable = cohortTable,
  #                                cohortId = 1,
  #                                minCellCount = pathwayDef$minCellCount,
  #                                output_folder = output_folder)
  # }
  #
  #
  # ### getIncidenceRates
  # if (getIncidenceRates) {
  #
  #     .getIncidenceRates (connectionDetails = connectionDetails,
  #                         connection = connection,
  #                         targetDatabaseSchema,
  #                         cdmDatabaseSchema,
  #                         oracleTempSchema,
  #                         cohortTable = cohortTable,
  #                         output_folder = output_folder)
  # }

  ### Zip output folder
#   .zip_folder(output_folder ,paste0("output_",outputFolder,".zip"))

   DatabaseConnector::disconnect(connection)
 }

#
#
#

.extract_bitSum <- function(x) {

  series <- c(2^(0:20))

  remainder = x
  combination = c()

  while(remainder != 0){

    component = match(TRUE, series > remainder) - 1

    remainder = remainder - series[component]

    combination[length(combination)+1] <- component - 1

  }

  return(combination)

}
