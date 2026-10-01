# Exploratory diagnosis comparison among adults classified as having diabetes.
source("scripts/_common.R")
frame <- read_frame()
full_design <- make_design(frame)
diabetes_design <- subset(full_design, RIDAGEYR >= 20 &
  diabetes_group %in% c("Diagnosed", "Undiagnosed") & !is.na(BMXBMI))
diabetes_design <- update(diabetes_design,
  Y = as.integer(diabetes_group == "Diagnosed"),
  A = as.integer(BMXBMI >= 30),
  education_clean = ifelse(DMDEDUC2 %in% 1:5, DMDEDUC2, NA_real_))
iptw_design <- subset(diabetes_design, !is.na(education_clean) &
  !is.na(age_group) & !is.na(RIAGENDR) & !is.na(RIDRETH3) & !is.na(SDDSRVYR))
if (!all(c(0L, 1L) %in% iptw_design$variables$A)) stop("Both BMI groups are required.")
# SDDSRVYR is preserved in preparation and used explicitly here.
ps_model <- svyglm(A ~ age_group + factor(RIAGENDR) + factor(RIDRETH3) +
                    factor(education_clean) + factor(SDDSRVYR),
                  design = iptw_design, family = quasibinomial())
ps <- as.numeric(fitted(ps_model))
stopifnot(length(ps) == nrow(iptw_design$variables),
          all(is.finite(ps)), all(ps > 0 & ps < 1))
p_a1 <- as.numeric(coef(svymean(~A, iptw_design)))
iptw_factor <- ifelse(iptw_design$variables$A == 1,
                      p_a1 / ps, (1 - p_a1) / (1 - ps))
stopifnot(all(is.finite(iptw_factor)), all(iptw_factor > 0))
iptw_design <- update(iptw_design, propensity = ps, iptw = iptw_factor)
design_data <- full_design$variables
position <- match(design_data$SEQN, iptw_design$variables$SEQN)
included <- !is.na(position)
design_data$in_analysis <- included
design_data$A <- NA_integer_
design_data$Y <- NA_integer_
design_data$A[included] <- iptw_design$variables$A[position[included]]
design_data$Y[included] <- iptw_design$variables$Y[position[included]]
design_data$combined_weight <- design_data$WTMEC4YR
design_data$combined_weight[included] <- design_data$WTMEC4YR[included] *
  iptw_design$variables$iptw[position[included]]
weighted_full <- svydesign(ids = ~SDMVPSU, strata = ~SDMVSTRA,
                           weights = ~combined_weight, nest = TRUE,
                           data = design_data)
weighted_diabetes <- subset(weighted_full, in_analysis)

balance_check <- function(design) {
  d <- design$variables
  w <- as.numeric(weights(design))
  x <- model.matrix(~ age_group + factor(RIAGENDR) + factor(RIDRETH3) +
                      factor(education_clean) + factor(SDDSRVYR), data = d)
  x <- x[, colnames(x) != "(Intercept)", drop = FALSE]
  g0 <- d$A == 0
  g1 <- d$A == 1
  p0 <- colSums(x[g0, , drop = FALSE] * w[g0]) / sum(w[g0])
  p1 <- colSums(x[g1, , drop = FALSE] * w[g1]) / sum(w[g1])
  denominator <- sqrt((p1 * (1 - p1) + p0 * (1 - p0)) / 2)
  smd <- ifelse(denominator == 0, 0, (p1 - p0) / denominator)
  data.frame(variable = colnames(x), smd = smd)
}
# Retain the cleaned education coding in the adjusted design for diagnostics.
weighted_diabetes <- update(weighted_diabetes,
  education_clean = ifelse(DMDEDUC2 %in% 1:5, DMDEDUC2, NA_real_))
before <- balance_check(iptw_design)
after <- balance_check(weighted_diabetes)
stopifnot(identical(before$variable, after$variable))
balance_results <- data.frame(variable = before$variable,
                               before = before$smd, after = after$smd)
before_rates <- svyby(~Y, ~A, iptw_design, svymean, vartype = "ci")
after_rates <- svyby(~Y, ~A, weighted_diabetes, svymean, vartype = "ci")
# Identity-link model: A coefficient is a difference in proportions.
risk_difference <- svyglm(Y ~ A, design = weighted_diabetes)
interval <- confint(risk_difference, "A")
difference <- data.frame(contrast = "BMI >=30 minus BMI <30",
  difference_pp = 100 * unname(coef(risk_difference)["A"]),
  lower_pp = 100 * interval[1], upper_pp = 100 * interval[2])
save_table(balance_results, "iptw_covariate_balance.csv")
save_table(as.data.frame(before_rates), "iptw_before_rates.csv")
save_table(as.data.frame(after_rates), "iptw_after_rates.csv")
save_table(difference, "iptw_diagnosis_difference.csv")
save_table(data.frame(stage = c("BMI complete diabetes domain", "Complete covariates"),
  participants = c(nrow(diabetes_design$variables), nrow(iptw_design$variables))),
  "iptw_sample_counts.csv")
capture.output({
  print(table(diabetes_design$variables$A, diabetes_design$variables$Y))
  print(summary(ps)); print(summary(iptw_factor))
  print(quantile(iptw_factor, c(.01, .50, .99)))
  print(balance_results)
  cat("Maximum absolute post-weighting SMD:", max(abs(after$smd)), "\n")
  print(before_rates); print(after_rates); print(difference)
  cat("Exploratory association; confidence interval treats propensity scores as fixed.\n")
}, file = file.path(output_dir, "iptw_summary.txt"))
message("IPTW outputs saved in ", output_dir)
