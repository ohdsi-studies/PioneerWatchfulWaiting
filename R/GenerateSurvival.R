#' @export
generateSurvival <- function(connection, cohortDatabaseSchema, cohortTable, targetIds, outcomeIds){
  sql <- "
  select
    t.subject_id,
    t.cohort_start_date,
    coalesce(min(o.cohort_start_date), max(t.cohort_end_date)) as event_date,
    case when min(o.cohort_start_date) is null then 0 else 1 end as event
  from @cohort_database_schema.@cohort_table t
  left join @cohort_database_schema.@cohort_table o
    on t.subject_id = o.subject_id
    and o.cohort_start_date >= t.cohort_start_date
    and o.cohort_start_date <= t.cohort_end_date
    and o.cohort_definition_id = @outcome_id
  where t.cohort_definition_id = @target_id
  group by t.subject_id, t.cohort_start_date
  "
  surv_outputs <- purrr::map_df(targetIds, function(targetId){
    
    purrr::map_df(outcomeIds, function(outcomeId){
      
      sql_tmp <- SqlRender::render(sql, cohort_database_schema = cohortDatabaseSchema,
                                   cohort_table = cohortTable, outcome_id = outcomeId, target_id = targetId)
      sql_tmp <- SqlRender::translate(sql_tmp, targetDialect = connection@dbms)
      
      km_raw <- DatabaseConnector::querySql(connection, sql_tmp, snakeCaseToCamelCase = T)
      
      ## edit
      if(nrow(km_raw) < 100 | length(km_raw$event[km_raw$event == 1]) < 1){return(NULL)}
      
      km_proc <- km_raw %>%
        dplyr::mutate(timeToEvent = as.integer(as.Date(eventDate) - as.Date(cohortStartDate)),
               id = dplyr::row_number()) %>%
        dplyr::select(id, timeToEvent, event)
      
      surv_obj <- survival::survfit(survival::Surv(timeToEvent, event) ~ 1, data = km_proc)
      
      data.frame(targetId = targetId, outcomeId = outcomeId, time = surv_obj$time,
                 survival = surv_obj$surv, lower = surv_obj$lower, upper = surv_obj$upper)
    })
  })
}

#' @export
generateCombinedSurvival <- function(connection, cohortDatabaseSchema, cohortTable, targetIds, outcomeIds, combinedIdNum){
  outcomeIds <- paste(outcomeIds, collapse = ', ')
  sql <- "
  SELECT subject_id, cohort_start_date, min(event_date) as event_date,
         CASE WHEN min(outcome) IS NULL THEN 0 ELSE 1 END AS event
  FROM (
    SELECT t.subject_id, t.cohort_start_date, o.cohort_definition_id outcome,
           coalesce(min(o.cohort_start_date), max(t.cohort_end_date)) AS event_date
    FROM @cohort_database_schema.@cohort_table t
    LEFT JOIN @cohort_database_schema.@cohort_table o
        ON t.subject_id = o.subject_id
        AND o.cohort_start_date >= t.cohort_start_date
        AND o.cohort_start_date <= t.cohort_end_date
        AND o.cohort_definition_id IN (@outcome_ids)
    WHERE t.cohort_definition_id IN (@target_id)
    GROUP BY t.subject_id, t.cohort_start_date, o.cohort_definition_id
  ) t
  GROUP BY subject_id, cohort_start_date
  "
  
  surv_outputs <- purrr::map_df(targetIds, function(targetId){
    
      sql_tmp <- SqlRender::render(sql, cohort_database_schema = cohortDatabaseSchema,
                                   cohort_table = cohortTable, outcome_ids = outcomeIds, target_id = targetId)
      sql_tmp <- SqlRender::translate(sql_tmp, targetDialect = connection@dbms)
      
      km_raw <- DatabaseConnector::querySql(connection, sql_tmp, snakeCaseToCamelCase = T)
      
      ## edit
      if(nrow(km_raw) < 100 | length(km_raw$event[km_raw$event == 1]) < 1){return(NULL)}
      
      km_proc <- km_raw %>%
        dplyr::mutate(timeToEvent = as.integer(as.Date(eventDate) - as.Date(cohortStartDate)),
               id = dplyr::row_number()) %>%
        dplyr::select(id, timeToEvent, event)
      
      surv_obj <- survival::survfit(survival::Surv(timeToEvent, event) ~ 1, data = km_proc)
      
      data.frame(targetId = targetId, outcomeId = combinedIdNum, time = surv_obj$time,
                 survival = surv_obj$surv, lower = surv_obj$lower, upper = surv_obj$upper)
  })
}


#
# sql_tmp <- SqlRender::render(sql, cohort_database_schema = cohortDatabaseSchema,
#                              cohort_table = cohortStagingTable, outcome_id = c(201, 202, 203), target_id = c(101, 102))
# sql_tmp <- SqlRender::translate(sql_tmp, targetDialect = connection@dbms)
# km_raw <- DatabaseConnector::querySql(connection, sql_tmp, snakeCaseToCamelCase = T)
# nrow(km_raw) < 100 | length(km_raw$event[km_raw$event == 1]) < 1


# 
# library(survival)
# library(dplyr)
# library(ggplot2)
#
# connectionDetails <- DatabaseConnector::createConnectionDetails(
#   dbms = "redshift",
#   server = Sys.getenv("GERMANY_SERVERDB"),
#   user = Sys.getenv("REDSHIFT_USER"),
#   password =  Sys.getenv("REDSHIFT_PASSWORD"),
#   port = 5439
# )


# targetIds <- allStudyCohorts[ ! allStudyCohorts$cohortId %in% featureCohortIds, "cohortId"]
# targetIds <- allStudyCohorts[[2]]
# targetIds <- setdiff(targetIds, featureCohortIds)
# targetIds <- setdiff(targetIds, strataCohortIds)



# survival_outputs <- generateSurvival(connection, cohortDatabaseSchema, cohortTable = cohortStagingTable,
#                                      outcomeIds = featureCohortIds, targetIds = targetIds)

# survival_outputs %>% as_tibble
# 
# survival_outputs %>%
#   bind_rows({.}) %>%
#   arrange(targetId, outcomeId, time) %>%
#   group_by(targetId, outcomeId) %>%
#   mutate(survival = coalesce(lag(survival, 1),1)) %>%
#   ggplot() +
#   geom_line(aes(x = time, y = survival)) +
#   # geom_errorbar() +
#   facet_wrap(vars(targetId, outcomeId))





# 
# plot <- ggplot()
# data <- survival_outputs %>% filter(targetId == 101) %>% filter(outcomeId == 201)
# plot <- plot + geom_line(data = data, aes(x = time, y = survival, color = as.factor(outcomeId)), size = 2)
# data <- survival_outputs %>% filter(targetId == 101) %>% filter(outcomeId == 202)
# plot <- plot + geom_line(data = data, aes(x = time, y = survival, color = as.factor(outcomeId)), size = 2)
# data <- survival_outputs %>% filter(targetId == 102) %>% filter(outcomeId == 201)
# plot <- plot + geom_line(data = data, aes(x = time, y = survival, color = as.factor(outcomeId)), size = 2)
# data <- survival_outputs %>% filter(targetId == 102) %>% filter(outcomeId == 202)
# plot <- plot + geom_line(data = data, aes(x = time, y = survival, color = as.factor(outcomeId)), size = 2)
# plot <- plot + labs(color = "Cohort")
# plot <- plot + theme(legend.position = "bottom")
# plot



# ggplot(mtcars, aes(x=wt, y=mpg, color=as.factor(cyl), shape=as.factor(cyl))) +
#   geom_point() +
#   geom_smooth(method=lm, se=FALSE, fullrange=TRUE)+
#   scale_shape_manual(values=c(3, 16, 17))+
#   scale_color_manual(values=c('#999999','#E69F00', '#56B4E9'))+
#   theme(legend.position="top")
# 
# 
# 
# plot <- ggplot2::ggplot(data, ggplot2::aes(x = .data$time,
#                                            y = .data$s, color = .data$strata, fill = .data$strata,
#                                            ymin = .data$lower, ymax = .data$upper))
# 
# 
# 
# 
# plot <-
#   survival_outputs %>%
#   filter(targetId == 101) %>%
#   filter(outcomeId == 201) %>%
#   ggplot(aes(x = time, y = survival)) +
#   geom_line(size=2, color='red')
# 
# plot




