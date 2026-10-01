# Selected results from the original analysis

These values were transcribed from the saved NHANES Code and Output Walkthrough and Diabetes IPTW Reference documents prepared in September 2026. They are a record of the original project; they are not presented as outputs from rerunning the curated scripts.

## Prediction assessment on 2017-2018

The saved R history trains a logistic model on 2015-2016 and applies it to 2017-2018. The walkthrough records the following test-cycle estimates:

| Predicted risk band | Observed undiagnosed rate | Average predicted rate |
|---|---:|---:|
| Under 1% | 0.263% | 0.549% |
| 1% to under 3% | 1.994% | 1.953% |
| 3% or higher | 6.639% | 5.200% |
| Overall | 2.667% | 2.364% |

The at-least-3% band contained 25.86% of the eligible test population and 64.37% of observed undiagnosed cases, using survey weights. The latter is case capture within the band, not the chance that a person in the band has diabetes. Predictions underestimated the observed rate in the highest band.

## IPTW diagnosis comparison

| Measure | Recorded result |
|---|---:|
| Participants with classified diabetes and BMI | 1,939 |
| Complete-covariate IPTW sample | 1,934 |
| Diagnosis proportion after IPTW, BMI <30 | 87.71% |
| Diagnosis proportion after IPTW, BMI >=30 | 81.27% |
| Adjusted difference, BMI >=30 minus BMI <30 | -6.44 percentage points |
| 95% confidence interval for the difference | -11.86 to -1.02 percentage points |
| Largest absolute standardized difference before IPTW | 0.44 |
| Largest absolute standardized difference after IPTW | Approximately 0.02 |
| Fitted propensity-score range | 0.1057 to 0.8779 |
| Maximum stabilized IPTW multiplier | 6.0156 |

The difference is an exploratory adjusted association, not a demonstrated causal effect. The interval treats the fitted propensity scores as fixed. Original values are rounded; before/after sample definitions should be checked when comparing these numbers with a new run.
