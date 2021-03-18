Long term outcomes of prostate cancer patients undergoing non-interventional management
=============

<img src="https://img.shields.io/badge/Study%20Status-Started-blue.svg" alt="Study Status: Started">

- Analytics use case(s): **Characterization**
- Study type: **Clinical Application**
- Tags: **cancer**
- Study lead: **Giorgio Gandaglia**
- Study lead forums tag: please refer to **[keesvanbochove](https://forums.ohdsi.org/u/keesvanbochove)**
- Study start date: **09-Mar-2021**
- Study end date: **-**
- Protocol: please look in Teams
- Publications: **-**
- Diagnositcs explorer: **[Shiny App: Cohort diagnostics](https://data.ohdsi.org/PioneerWatchfulWaitingDiag/)**
- Results explorer: **[Shiny App: Characterization Study](https://data.ohdsi.org/PioneerWatchfulWaiting/)**

The aim of this study is to assess the long-term outcomes of prostate cancer patients managed with non-curative intent therapies in different disease risk profiles. The impact of life expectancy and comorbidities on the risk of recurrence and disease-free and overall survival will be assessed. 

This study is undertaken by the joint prostate cancer studyathon of the [IMI PIONEER](https://prostate-pioneer.eu) project, the [IMI EHDEN](https://www.ehden.eu) project and the [OHDSI](https://www.ohdsi.org/) community (see [announcement](https://prostate-pioneer.eu/uncovering-the-natural-history-of-prostate-cancer-in-data-from-millions-of-patient-across-the-globe)).

### FAQ
#### *What do I need to do to run the package?*
OHDSI study repos are designed to have information in the README.md (where you are now) to provide you with instructions on how to navigate the repo. This package has two major components:
1. [CohortDiagnostics](http://www.github.com/ohdsi/cohortDiagnostics) - an OHDSI R package used to perform diagnostics around the fitness of use of the study phenotypes on your CDM. By running this package you will allow study leads to understand: cohort inclusion rule attrition, inspect source code lists for a phenotype, find orphan codes that should be in a particular concept set but are not, compute incidnece across calendar years, age and gender, break down index events into specific concepts that triggered then, compute overlap of two cohorts and compute basic characteristics of selected cohorts. This package will be requested of all sites. It is run on all available data not just your prostate cancer populations. This allows us to understand how the study phenotypes perform in your database and identify any potential gaps in the phenotype definitions.
2. RunStudy - the characterization package to evaluate Target-Stratum-Feature pairings computing cohort characteristics and creating tables/visualizations to summarize differences between groups.

#### *I don't understand the organization of this Github Repo.*
The study repo has the following major pieces:
- `R` folder = the folder which will provide the R library the scripts it needs to execute this study
- `documents` folder = the folder where you will find study documents (protocols, 1-sliders to explain the study, etc)
- `extras` folder = the folder where we store a copy of the instructions (called `CodeToRun.R`) below and other files that the study needs to do things like package maintenance or talk with the Shiny app. Aside from `CodeToRun.R`, you can largely ignore the rest of these files.
- `inst` folder = This is the "install" folder. It contains the most important parts of the study: the study cohort JSONs (analogous to what ATLAS shows you in the Export tab), the study settings, a sub-folder that contains information to the Shiny app, and the study cohort SQL scripts that [SqlRender](https://cran.r-project.org/web/packages/SqlRender/index.html) will use to translate these into your RDBMS.

Below you will find instructions for how to bring this package into your `R`/ `RStudio` environment. Note that if you are not able to connect to the internet in `R`/ `RStudio` to download pacakges, you will have to pull the [TAR file](https://github.com/ohdsi-studies/PioneerWatchfulWaiting/archive/master.zip). 

#### *I see you've got a reference `Renviron` but I've never used that? What do I do?*
You can install a package like `usethis` to quickly access your Renviron file.  `usethis` :package: has a useful helper function to modify `.Renviron`:

`usethis::edit_r_environ()` will open your user .Renviron which is in your home

`usethis::edit_r_environ("project")` will open the one in your project

Your Renviron file will pop-up through these commands. It will give you the opportunity to edit it as the directions instruct. If you need more help, consider reviewing this [R Community Resource](https://rviews.rstudio.com/2017/04/19/r-for-enterprise-understanding-r-s-startup/).

#### *What should I do if I get an error when I run the package?*
If you have any issues running the package, please report bugs / roadblocks via [GitHub Issues](https://github.com/ohdsi-studies/PioneerWatchfulWaiting/issues) on this repo. Where possible, we ask you share error logs and snippets of warning messages that come up in your `R` console. You may also attach screenshots. Please include the RDMBS (aka your SQL dialect) you work on. If possible, run `traceback()` in your `R` and paste this into your error as well. The study leads will triage these errors with you.

#### *What should I do when I finish?*
If you finish running a study package and upload results to the SFTP, please post a message in the *Data sources and study execution* channel in Teams to notify you have dropped results in the folder. If your upload is unsucessful, please add the results to Teams directly.

## Package Requirements
- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, or Microsoft APS.
- R version 3.5.0 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/)
- [Java](http://java.com)
- Suggested: 25 GB of free disk space

See [this video](https://youtu.be/DjVgbBGK4jM) for instructions on how to set up the R environment on Windows.

## How to Run the Study
1. In `R`, you will build an `.Renviron` file. An `.Renviron` is an R environment file that sets variables you will be using in your code. It is encouraged to store these inside your environment so that you can protect sensitive information. Below are brief instructions on how to do this:

````
# The code below makes use of R environment variables (denoted by "Sys.getenv(<setting>)") to 
# allow for protection of sensitive information. If you'd like to use R environment variables stored
# in an external file, this can be done by creating an .Renviron file in the root of the folder
# where you have cloned this code. For more information on setting environment variables please refer to: 
# https://stat.ethz.ch/R-manual/R-devel/library/base/html/readRenviron.html
#
# Below is an example .Renviron file's contents: (please remove)
# the "#" below as these too are interprted as comments in the .Renviron file:
#
#    DBMS = "postgresql"
#    DB_SERVER = "database.server.com"
#    DB_PORT = 5432
#    DB_USER = "database_user_name_goes_here"
#    DB_PASSWORD = "your_secret_password"
#    FFTEMP_DIR = "E:/fftemp"
#    USE_SUBSET = FALSE
#
# The following describes the settings
#    DBMS, DB_SERVER, DB_PORT, DB_USER, DB_PASSWORD := These are the details used to connect
#    to your database server. For more information on how these are set, please refer to:
#    http://ohdsi.github.io/DatabaseConnector/
#
#    FFTEMP_DIR = A directory where temporary files used by the FF package are stored while running.
#
#    USE_SUBSET = TRUE/FALSE. When set to TRUE, this will allow for runnning this package with a 
#    subset of the cohorts/features. This is used for testing. PLEASE NOTE: This is only enabled
#    by setting this environment variable.
#
# Once you have established an .Renviron file, you must restart your R session for R to pick up these new
# variables. 
````

2. To install the study package (which will build a new R library for you that is specifically for `PioneerWatchfulWaiting`), type the following into a new `R` script and run. You can also retrieve this code from `extras/CodeToRun.R`.

````
# Prevents errors due to packages being built for other R versions: 
Sys.setenv("R_REMOTES_NO_ERRORS_FROM_WARNINGS" = TRUE)
# 
# First, it probably is best to make sure you are up-to-date on all existing packages.
# Important: This code is best run in R, not RStudio, as RStudio may have some libraries
# (like 'rlang') in use.
#update.packages(ask = "graphics")

# When asked to update packages, select '1' ('update all') (could be multiple times)
# When asked whether to install from source, select 'No' (could be multiple times)
#install.packages("devtools")
#devtools::install_github("ohdsi-studies/PioneerWatchfulWaiting")
````
In [`CodeToRun.R`](extras/CodeToRun.R) you will find a function `verifyDependencies()` which you can use to verify that all dependencies installed correctly.

*Note: When using this installation method it can be difficult to 'retrace' because you will not see the same folders that you see in the GitHub Repo. If you would prefer to have more visibility into the study contents, you may alternatively download the [TAR file](https://github.com/ohdsi-studies/PioneerWatchfulWaiting/archive/master.zip) for this repo and bring this into your `R`/`RStudio` environment. An example of how to call ZIP files into your `R` environment can be found in the [The Book of OHDSI](https://ohdsi.github.io/TheBookOfOhdsi/PopulationLevelEstimation.html#running-the-study-package).*

*Note: if you run into the error `LoadLibrary failure: %1 is not a valid Win32 application` when compiling rJava dependencies, try this instead: *devtools::install_github("ohdsi-studies/PioneerWatchfulWaiting",INSTALL_opts = "--no-multiarch").*

*Note: If you are using the `DatabaseConnector` package for the first time, then you may also need to download the JDBC drivers to your database. See the [package documentation](https://ohdsi.github.io/DatabaseConnector/reference/jdbcDrivers.html), you can do this with a command like `DatabaseConnector::downloadJdbcDrivers(dbms="redshift", pathToDriver="/my-home-folder/jdbcdrivers")`.*


3. Great work! Now you have set-up your environment and installed the library that will run the package. You can use the following `R` script to load in your library and configure your environment connection details:

```
library(PioneerWatchfulWaiting)

# Optional: specify where the temporary files (used by the ff package) will be created:
fftempdir <- if (Sys.getenv("FFTEMP_DIR") == "") "~/fftemp" else Sys.getenv("FFTEMP_DIR")
options(fftempdir = fftempdir)

# Details for connecting to the server:
dbms = Sys.getenv("DBMS")
user <- if (Sys.getenv("DB_USER") == "") NULL else Sys.getenv("DB_USER")
password <- if (Sys.getenv("DB_PASSWORD") == "") NULL else Sys.getenv("DB_PASSWORD")
server = Sys.getenv("DB_SERVER")
port = Sys.getenv("DB_PORT")
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = password,
                                                                port = port)
````
4. You will first need to run the `CohortDiagnostics` package on your entire database. This package is used as a diagnostic to provide transparency into the concept prevalence in your database as it relates to the concept sets and phenotypes we've prepared for the Target, Stratum and Features included in this analysis. We encourage sites to share this information so that we can help design better studies that capture the nuance of your local care delivery and coding practices.

````
# Run cohort diagnostics -----------------------------------
runCohortDiagnostics(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     cohortDatabaseSchema = cohortDatabaseSchema,
                     cohortStagingTable = cohortStagingTable,
                     oracleTempSchema = oracleTempSchema,
                     cohortIdsToExcludeFromExecution = cohortIdsToExcludeFromExecution,
                     exportFolder = outputFolder,
                     #cohortGroupNames = c("target", "outcome", "strata"), # Optional - will use all groups by default
                     databaseId = databaseId,
                     databaseName = databaseName,
                     databaseDescription = databaseDescription,
                     minCellCount = minCellCount)
````

this package may take some time to run. This is normal. Allow at least 3 hours for this step. Package runtime will vary based on your infrastructure. We appreciate your patience!

When the package is completed, you can view the `CohortDiagnostics` output in a local Shiny viewer:
````
# Use the next command to review cohort diagnostics and replace "target" with
# one of these options: "target", "outcome", "strata"
# CohortDiagnostics::launchDiagnosticsExplorer(file.path(outputFolder, "diagnostics", "target"))
````

5. Once you have run `CohortDiagnostics` you are encouraged to reach out to the study leads to review your outputs. 

6. You can now run the characterization package. This step is designed to take advantage of incremental building. This means if the job fails, the R package will start back up where it left off. This package has been designed to be computationally efficient. Package runtime will vary based on your infrastructure but it should be significantly faster than your prior CohortDiagnostic run.

In your `R` script, you will use the following code:
````
# Use this to run the study. The results will be stored in a zip file called 
# 'Results_<databaseId>.zip in the outputFolder. 
runStudy(connectionDetails = connectionDetails,
         cdmDatabaseSchema = cdmDatabaseSchema,
         cohortDatabaseSchema = cohortDatabaseSchema,
         cohortStagingTable = cohortStagingTable,
         cohortTable = cohortTable,
         featureSummaryTable = featureSummaryTable,
         oracleTempSchema = cohortDatabaseSchema,
         exportFolder = outputFolder,
         databaseId = databaseId,
         databaseName = databaseName,
         databaseDescription = databaseDescription,
         #cohortGroups = c("target", "outcome", "strata"), # Optional - will use all groups by default
         cohortIdsToExcludeFromExecution = cohortIdsToExcludeFromExecution,
         cohortIdsToExcludeFromResultsExport = cohortIdsToExcludeFromResultsExport,
         incremental = TRUE,
         useBulkCharacterization = useBulkCharacterization,
         minCellCount = minCellCount) 
  ````

7. You can now look at the characterization output in a local Shiny application:
````
preMergeResultsFiles(outputFolder)
launchShinyApp(outputFolder)
````

8. If the study code runs to completion, your outputFolder will have the following contents:
- RecordKeeping = a folder designed to store incremental information such that if the study code dies, it will restart where it left off
- cohort.csv: An export of the cohort definitions used in the study. This is simply a cross reference for the other files and does not contain sensitive information.
- _**cohort_count.csv**_: Contains the list of target and strata cohorts in the study with their counts. The fields `cohort_entries` and cohort_subjects` contain the number of people in the cohort. 
- _**cohort_staging_count.csv**_: Contains a full list of all cohorts produced by the code in the study inclusive of features. The fields `cohort_entries` and cohort_subjects` contain the number of people in the cohort. 
- covariate.csv: A list of features that were identified in the analyzed cohorts. This is a cross reference file with names and does not contain sensitive information.
- _**covariate_value.csv**_: Contains the statistics produced by the study. The field `mean` will contain the proportion computed. When censored, you will see negative values in this field. 
- database.csv: Contains metadata information that you supplied as part of running the package to identify the database across the OHDSI network. Additionally, the vocabulary version used in your CDM is included.
- **_feature_proportion.csv_**: This file contains the list of feature proportions calculated through the combination of target/stratified and features. The fields `total_count`,`feature_count`, contain the subject counts for the cohort and feature respectively. The field `mean` contains the proportion of `feature_count/total_count`. 

Those files noted in **_bold italics_** above should be reviewed for sensitive information for your site. The package will censor values based on the `minCellCount` parameter specified when calling the `runStudy` function. Censored values will be represented with a negative to show it has been censored. In the case of the fields `cohort_entries` and cohort_subjects`, this will be -5 (where 5=your min cell count specified). In the case of the `mean` field, this will be a negative representation of that proportion that was censored.

As a data owner, you will want to inspect these files for adherence to the minCellCount you input. You may find that only some files are generated. If this happens, please reach out to the study leads to debug. 

9. To utilize the `OhdsiSharing` library to connect and upload results to the OHDSI STFP server, you will need a site key. You may reach out to the study leads to get a key file. You will store this key file in a place that is retrievable by your `R`/`RStudio` environment (e.g. on your desktop if local `R` or uploaded to a folder in the cloud for `RServer`)

Once you have checked results, you can use the following code to send:
````
# For uploading the results. You should have received the key file from the study coordinator:
#keyFileName <- "[location where you are storing: e.g. ~/keys/study-data-site-pioneer]"
userName <- "study-data-site-pioneer" # do not change this, it is linked to the key you have

# Upload results to OHDSI SFTP server:
OhdsiSharing::sftpUploadFile(privateKeyFileName = keyFileName,
                             userName = userName,
                             remoteFolder = "[your db name]",
                             fileName = "[location where you stored your export: e.g. home/studyresults/MyResults.zip])
````

Please notify Susan Evans Axelsson via Teams when you have dropped results in the folder.
