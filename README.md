Long term outcomes of prostate cancer patients undergoing non-interventional management
=============

<img src="https://img.shields.io/badge/Study%20Status-Repo%20Created-lightgray.svg" alt="Study Status: Repo Created">

- Analytics use case(s): **Characterization**
- Study type: **Clinical Application**
- Tags: **cancer**
- Study lead: **Giorgio Gandaglia**
- Study lead forums tag: please refer to **[keesvanbochove](https://forums.ohdsi.org/u/keesvanbochove)**
- Study start date: **09-Mar-2021**
- Study end date: **-**
- Protocol: **-**
- Publications: **-**
- Results explorer: **-**

The aim of this study is to assess the long-term outcomes of prostate cancer patients managed with non-curative intent therapies in different disease risk profiles. The impact of life expectancy and comorbidities on the risk of recurrence and disease-free and overall survival will be assessed. 

This study is undertaken by the joint prostate cancer studyathon of the [IMI PIONEER](https://prostate-pioneer.eu) project, the [IMI EHDEN](https://www.ehden.eu) project and the [OHDSI](https://www.ohdsi.org/) community (see [announcement](https://prostate-pioneer.eu/uncovering-the-natural-history-of-prostate-cancer-in-data-from-millions-of-patient-across-the-globe)).


How to run
===========

1. Requirements for executing this package:
   - DatabaseConnector ( >= 3.0.0 )
   - SqlRender ( >= 1.6.8 )
 

2. The package needs to be installed into the R environment.

   - with the devtools package inside a R session it could be done with
      ```r
         devtools::install_github("ohdsi-studies/PioneerWatchfulWaiting")
      ```
   - from the command line on linux machines it could be done with
      ```bash
          R CMD build PioneerWatchfulWaiting
          R CMD INSTALL PioneerWatchfulWaiting_0.0.1.tar.gz
      ```

3. Then, within an interactive R session, execute the adapted commands below. The commands below can also be found in extras/codeToRun.R

   ```r
library(PIONEER)

### Connection details for the SQL server
connectionDetails <-  DatabaseConnector::createConnectionDetails(
  dbms = "",														### Name of dialect (Type ?DatabaseConnector::createConnectionDetails to see how your dialect should be written)
  server = "",													### Server URL or IP
  user = "",														### Username
  password = "",												### Password
  port = 5439)

### Declare variables
cdmDatabaseSchema <- ""          ### Name of the schema where the CDM data are located
targetDatabaseSchema <- ""       ### Name of the schema where the results of the package will be saved
cohortTable <- "pioneer"         ### Name of the table where the cohort data will be saved
oracleTempSchema <- NULL         ### (Only for Oracle users)Name of temp schema
outputFolder <- ""               ### Name of the folder the output will be saved (it should named after the database)
days_offset <- 180				       ### Days added to the index event start date

### Connect to the server
con <- DatabaseConnector::connect(connectionDetails)


### Execute analysis
PIONEER::execute(connection = con,
                cdmDatabaseSchema = cdmDatabaseSchema,
                targetDatabaseSchema = targetDatabaseSchema,
                oracleTempSchema = oracleTempSchema,
                cohortTable = cohortTable,
                outputFolder = outputFolder,
                createCohorts = T,
                days_offset
)
   ```
