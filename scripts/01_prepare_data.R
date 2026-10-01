# Retain the full examined frame before selecting adult analysis domains.
source("scripts/_common.R")
demo_columns <- c("SEQN", "SDDSRVYR", "RIDAGEYR", "RIAGENDR", "RIDRETH3",
                  "DMDEDUC2", "WTMEC2YR", "SDMVSTRA", "SDMVPSU")
frames <- lapply(c("I", "J"), function(cycle) {
  demo <- read_source(paste0("DEMO_", cycle), demo_columns)
  diq <- read_source(paste0("DIQ_", cycle), c("SEQN", "DIQ010"))
  bmx <- read_source(paste0("BMX_", cycle), c("SEQN", "BMXBMI"))
  ghb <- read_source(paste0("GHB_", cycle), c("SEQN", "LBXGH"))
  demo %>% left_join(diq, by = "SEQN") %>%
    left_join(bmx, by = "SEQN") %>% left_join(ghb, by = "SEQN")
})
frame <- bind_rows(frames) %>% mutate(
  survey_cycle = case_when(SDDSRVYR == 9 ~ "2015-2016",
                           SDDSRVYR == 10 ~ "2017-2018"),
  WTMEC4YR = WTMEC2YR / 2,
  # Preserve the original study classification, including borderline responses.
  diabetes_group = case_when(
    DIQ010 == 1 ~ "Diagnosed",
    DIQ010 %in% c(2, 3) & !is.na(LBXGH) & LBXGH >= 6.5 ~ "Undiagnosed",
    DIQ010 %in% c(2, 3) & !is.na(LBXGH) & LBXGH < 6.5 ~ "No diabetes",
    TRUE ~ NA_character_
  ),
  undiagnosed = case_when(diabetes_group == "Undiagnosed" ~ 1,
                          diabetes_group == "No diabetes" ~ 0,
                          TRUE ~ NA_real_),
  age_group = cut(RIDAGEYR, c(20, 40, 60, Inf), right = FALSE,
                  labels = c("20-39", "40-59", "60+"))
)
assert_unique_ids(frame, "Combined NHANES frame")
stopifnot(all(frame$SDDSRVYR %in% c(9, 10)))
saveRDS(frame, file.path(processed_dir, "nhanes_full_frame.rds"))
adults <- frame %>% filter(RIDAGEYR >= 20)
saveRDS(adults, file.path(processed_dir, "nhanes_2015_2018.rds"))
# A convenience dataset with laboratory labels retained but HbA1c removed.
# Prediction scripts select age, sex, and BMI explicitly; they never use DIQ010
# or diabetes_group as predictors, since those variables define the outcome.
prediction <- adults %>% filter(!is.na(undiagnosed)) %>% select(-LBXGH)
saveRDS(prediction, file.path(processed_dir, "nhanes_prediction.rds"))
save_table(as.data.frame(table(adults$survey_cycle, adults$diabetes_group,
                              useNA = "ifany")), "adult_classification_counts.csv")
message("Prepared ", nrow(frame), " participants and ", nrow(adults), " adults.")
