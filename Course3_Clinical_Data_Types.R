library(tidyverse)
library(magrittr)
library(bigrquery)
library(caret)

con <- DBI::dbConnect(drv = bigquery(),
                      project = "learnclinicaldatascience")


### ICD Codes
diabetes <- tbl(con, "course3_data.diabetes_goldstandard")
diabetes

training <- diabetes %>% 
  collect() %>% 
  sample_n(80)

testing <- diabetes %>% 
  filter(!SUBJECT_ID %in% training_population$SUBJECT_ID)

training <- tbl(con, "course3_data.diabetes_training")

## getStats(df, predicted, reference)
getStats <- function(df, ...){
  df %>%
    select_(.dots = lazyeval::lazy_dots(...)) %>%
    mutate_all(funs(factor(., levels = c(1,0)))) %>% 
    table() %>% 
    confusionMatrix()
}

diagnoses_icd <- tbl(con, "mimic3_demo.DIAGNOSES_ICD")

icd_25060 <- diagnoses_icd %>% 
  filter(ICD9_CODE == "25060") %>% 
  distinct(SUBJECT_ID) %>% 
  mutate(icd_25060 = 1)

training %>% 
  left_join(icd_25060)

training %>% 
  left_join(icd_25060) %>% 
  mutate(icd_25060 = coalesce(icd_25060, 0))

training %<>% 
  left_join(icd_25060) %>% 
  mutate(icd_25060 = coalesce(icd_25060, 0))

training %>% 
  collect() %>% 
  getStats(icd_25060, DIABETES)

### Laboratory Data
labevents <- tbl(con, "mimic3_demo.LABEVENTS")

glucose <- labevents %>% 
  filter(ITEMID %in% c(50931)) %>% 
  distinct(SUBJECT_ID) %>% 
  mutate(glucose = 1)

training %<>% 
  left_join(glucose) %>% 
  mutate(glucose = coalesce(glucose, 0))

training %>% 
  collect() %>% 
  getStats(glucose, DIABETES)

### Medication Data
prescriptions <- tbl(con, "mimic3_demo.PRESCRIPTIONS")

insulin <- prescriptions %>% 
  filter(tolower(DRUG) %like% "%insulin%") %>% 
  distinct(SUBJECT_ID) %>% 
  mutate(insulin = 1)

training %<>% 
  left_join(insulin) %>% 
  mutate(insulin = coalesce(insulin, 0))

training %>% 
  collect() %>% 
  getStats(insulin, DIABETES)
