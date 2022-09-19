Installing the study package using devtools
===========================================================================================

It is recommended that study organisers add an renv lockfile into the study to ensure the study can be run in the future. If the lockfile is in the study, it is recommended to install the package using renv (see [study install using renv guide](STUDY-PACKAGE-SETUP.md)). If the renv lockfile is not available, to install the package with devtools (without using renv) run:

```r
  # get the latest PatientLevelPrediction
  install.packages("devtools")
  devtools::install_github("OHDSI/FeatureExtraction")
  devtools::install_github("OHDSI/PatientLevelPrediction")
  
  # install the network package
  devtools::install_github("ohdsi-studies/SkeletonPredictionStudy")
```  

If the above runs sucessfully, you can now proceed to execute the study.