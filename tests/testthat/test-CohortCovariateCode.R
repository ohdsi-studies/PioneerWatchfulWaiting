# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of SkeletonPredictionStudy
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

library("testthat")

context("CohortCovariateCode")

test_that("applyModel inputs", {
  
  covariateName <- paste(c('A','B','C','D','E','F','G','H','J')[sample(9, 5)], collapse = '')
  covariateId <- sample(100000,1)
  result <- createCohortCovariateSettings(covariateName = covariateName, 
                                covariateId = covariateId,
                                cohortDatabaseSchema = 'madeup', 
                                cohortTable = 'cohort', 
                                cohortId = covariateId,
                                startDay=-30, endDay=0)
  # correct class
  testthat::expect_equal(class(result) == "covariateSettings", TRUE)
  
  # correct attribute 
  testthat::expect_equal(attr(result, "fun") == "getCohortCovariateData", TRUE)
  
  # correct list
  testthat::expect_equal(result$covariateName, covariateName)
  testthat::expect_equal(result$covariateId, covariateId)
  testthat::expect_equal(result$cohortDatabaseSchema, 'madeup')
  testthat::expect_equal(result$cohortId, covariateId)
  testthat::expect_equal(result$startDay, -30)
  testthat::expect_equal(result$endDay, 0)
  
})