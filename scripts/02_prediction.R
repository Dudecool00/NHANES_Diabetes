# Model current undiagnosed status; this is not future disease forecasting.
source("scripts/_common.R")
frame <- read_frame()
full_design <- make_design(frame)
eligible <- subset(full_design, RIDAGEYR >= 20 & !is.na(undiagnosed))
model_design <- subset(eligible, !is.na(BMXBMI))
model_1 <- svyglm(undiagnosed ~ age_group + factor(RIAGENDR) + BMXBMI,
                  design = model_design, family = quasibinomial())
saveRDS(model_1, file.path(output_dir, "prediction_model.rds"))
odds_ratios <- exp(cbind(odds_ratio = coef(model_1), confint(model_1)))
save_table(data.frame(term = rownames(odds_ratios), odds_ratios,
                      row.names = NULL), "prediction_odds_ratios.csv")
save_table(as.data.frame(svyby(~undiagnosed, ~age_group, eligible,
                               svymean, vartype = "ci")), "age_group_rates.csv")
profiles <- expand.grid(
  age_group = factor(c("20-39", "40-59", "60+"),
                     levels = levels(model_design$variables$age_group)),
  RIAGENDR = 1, BMXBMI = c(25, 30, 35)
)
profiles$predicted_probability <- as.numeric(
  predict(model_1, newdata = profiles, type = "response")
)
save_table(profiles, "example_predictions.csv")

# Train on one cycle and check predictions on the later cycle.
train_design <- subset(model_design, SDDSRVYR == 9)
test_design <- subset(model_design, SDDSRVYR == 10)
train_model <- svyglm(undiagnosed ~ age_group + factor(RIAGENDR) + BMXBMI,
                      design = train_design, family = quasibinomial())
pred_test <- as.numeric(predict(train_model, newdata = test_design$variables,
                                type = "response"))
stopifnot(length(pred_test) == nrow(test_design$variables),
          all(is.finite(pred_test)), all(pred_test >= 0 & pred_test <= 1))
test_design <- update(test_design, predicted = pred_test)
test_design <- update(test_design, risk_group = cut(
  predicted, c(-Inf, 0.01, 0.03, Inf), right = FALSE,
  labels = c("Under 1%", "1% to under 3%", "3% or higher")
))
risk_rates <- svyby(~undiagnosed + predicted, ~risk_group, test_design,
                   svymean, vartype = "ci")
save_table(as.data.frame(risk_rates), "test_risk_band_rates.csv")
save_table(as.data.frame(table(test_design$variables$risk_group,
                               test_design$variables$undiagnosed)),
           "test_risk_band_counts.csv")
overall <- svymean(~undiagnosed + predicted, test_design)
save_table(data.frame(measure = names(coef(overall)),
                      estimate = as.numeric(coef(overall)),
                      standard_error = as.numeric(SE(overall))),
           "test_overall_rates.csv")
test_design <- update(test_design, high_risk = as.integer(predicted >= 0.03))
targeting <- c(
  population_share = as.numeric(coef(svymean(~high_risk, test_design))),
  case_share = as.numeric(coef(svymean(~high_risk,
                                     subset(test_design, undiagnosed == 1))))
)
save_table(data.frame(measure = names(targeting), proportion = unname(targeting)),
           "test_targeting.csv")

# Sensitivity analysis: exclude borderline reported diagnosis (DIQ010 = 3).
strict_model <- svyglm(undiagnosed ~ age_group + factor(RIAGENDR) + BMXBMI,
                       design = subset(model_design, DIQ010 == 2),
                       family = quasibinomial())
save_table(data.frame(term = names(coef(strict_model)),
                      odds_ratio = exp(coef(strict_model))),
           "strict_outcome_odds_ratios.csv")
capture.output({
  cat("Eligible adult domain excludes reported diagnosed diabetes.\n")
  print(svymean(~undiagnosed, eligible))
  print(confint(svymean(~undiagnosed, eligible)))
  print(summary(model_1)); print(odds_ratios)
  cat("Train: 2015-2016. Test: 2017-2018.\n")
  print(overall); print(risk_rates); print(targeting)
}, file = file.path(output_dir, "prediction_summary.txt"))
message("Prediction outputs saved in ", output_dir)
