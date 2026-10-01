# Analysis notes

## Data and analysis populations

The public 2015-2016 and 2017-2018 releases are combined by appending cycles after joining component files within each cycle on `SEQN`.

The portfolio scripts use four components per cycle: DEMO, DIQ, BMX, and GHB. The original exploratory work also joined insurance and employment components. Those variables were not predictors or adjustment covariates in the final analyses, so the runnable project does not require those extra files.

The full demographics frame is retained. A survey design is built on participants with positive examination weights, then adult analysis domains are selected with `subset()` on the design object. Two-year MEC weights are divided by two for the combined four-year analysis. Strata (`SDMVSTRA`), PSUs (`SDMVPSU`), and cycle (`SDDSRVYR`) are preserved.

### Study labels

| Label | Rule |
|---|---|
| Diagnosed | `DIQ010 == 1`, irrespective of the current HbA1c measurement |
| Undiagnosed | `DIQ010` is 2 or 3, HbA1c is observed, and `LBXGH >= 6.5` |
| No diabetes | `DIQ010` is 2 or 3, HbA1c is observed, and `LBXGH < 6.5` |
| Unclassified | All remaining combinations |

"No diabetes" is shorthand for this study's classification; it does not rule out diabetes by other tests or clinical criteria. Borderline diagnosis responses are included under the original rule and excluded in a sensitivity model. A single examination HbA1c is an operational research definition.

## Prediction

The prediction domain includes adults aged 20 or older classified as undiagnosed or no diabetes. Reported diagnosed participants are excluded. Missing BMI is excluded at model fitting; missing diagnosis responses or missing HbA1c cannot be assigned to the prediction outcome under this rule.

The logistic model is:

```r
undiagnosed ~ age_group + factor(RIAGENDR) + BMXBMI
```

`svyglm(..., family = quasibinomial())` fits the model with the NHANES survey design. Age groups are 20-39, 40-59, and 60+. The prediction script fits a combined-cycle descriptive model, then a separate model trained on 2015-2016 and assessed on 2017-2018.

Predictions are probabilities of the study's current undiagnosed status, not future diabetes onset. Test-cycle risk bands are below 1%, 1% to below 3%, and at least 3%. Observed and average predicted rates assess calibration; risk-band case concentration assesses a possible targeting rule. The project does not report a generic "accuracy" score.

**Denominator note:** the original walkthrough reports a 2.48% overall estimate as an adult-domain result. The saved history sets diagnosed participants' prediction outcome to missing and excludes them from that domain. It must therefore not be described as prevalence among all adults. The curated script writes an explicitly labeled eligible-domain estimate on each run; the headline README omits this ambiguous original figure.

Confidence intervals for observed rates use the survey design. Standard errors for averages of fitted predictions treat those predictions as fixed; they do not include uncertainty from fitting the training model.

## IPTW diagnosis comparison

This domain includes adults classified as diagnosed or undiagnosed diabetes with observed BMI and complete propensity-model covariates. The original complete-covariate analysis had 1,934 participants. The code reports the sample size it actually obtains rather than forcing that historical count.

- Outcome `Y`: reported diagnosis (1) versus undiagnosed classification (0).
- Exposure `A`: examination BMI at least 30 (1) versus BMI below 30 (0).
- Adjustment variables: age group, recorded sex, race/ethnicity, adult education, and survey cycle.

Survey-weighted logistic regression estimates the probability of the observed BMI category. Stabilized weights are `p / e(X)` in the BMI >=30 group and `(1 - p) / (1 - e(X))` in the BMI <30 group, where `p` is the survey-weighted BMI >=30 proportion. These factors multiply the examination weights.

Diagnostics inspect propensity-score ranges, weight tails, and standardized differences in model-matrix indicators before and after weighting. Diagnosis proportions and an identity-link survey regression give the adjusted difference in percentage points, BMI >=30 minus BMI <30. Before/after diagnosis tables in the curated script use the same complete-covariate sample.

### Limits of interpretation

The result is an adjusted association. Examination BMI can follow diagnosis, healthcare access and other historical factors are incompletely measured, and restricting to diabetes cases can create selection bias. A BMI category at one examination does not define a single assigned intervention. Balance of measured covariates does not address these issues.

The reported interval treats estimated propensity scores as fixed. It does not include additional uncertainty from refitting the propensity model. Sparse outcome cells and NHANES design degrees of freedom also matter for subgroup reliability.

## Provenance and reproducibility

The scripts were curated from `NHANES_diabetes_analysis_history.R` and `NHANES_IPTW_analysis(1).R`. The history is a console record with repeated commands and failed attempts, not a standalone program. The original Word walkthrough and IPTW reference document supplied explanations and recorded output.

The curated project removes personal paths, reconstructs required inputs from public files, retains the full survey frame, restores the survey-cycle covariate omitted from the standalone IPTW script, and exports results. Historical values in `results/original_results.md` are explicitly separated from regenerated outputs. Input files and outputs can change; rerun and inspect them before making new claims.
