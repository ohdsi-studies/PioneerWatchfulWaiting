#' Create a protocol template for the study 
#'
#' @details
#' This function will create a template protocol 
#'
#' @param predictionAnalysisListFile       the location of the json analysis settings
#' @param outputLocation    Directory location where you want the protocol written to
#' @export
createPlpProtocol <- function(
  predictionAnalysisListFile = NULL, 
  outputLocation = getwd()
  ){
  
  ensure_installed('CirceR')
  
  if(is.null(predictionAnalysisListFile)){
    predictionAnalysisListFile <- system.file(
      "settings",
      "predictionAnalysisList.json",
      package = "PIONEER_clinician_driven_model"
    )
  }
  
  protocolLoc <- system.file(
    "protocol",
    "main.Rmd",
    package = "PIONEER_clinician_driven_model"
  )
  
  rmarkdown::render(
    input = protocolLoc, 
    output_dir = outputLocation, 
    params = list(
      jsonSettingLocation = predictionAnalysisListFile
    )
  )
  
}
