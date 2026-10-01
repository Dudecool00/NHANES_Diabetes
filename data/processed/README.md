# Generated participant datasets

Run `scripts/01_prepare_data.R` after downloading the raw components.

| Generated file | Contents |
|---|---|
| `nhanes_full_frame.rds` | Combined demographic frame with joined measures and labels; retains all ages and survey information |
| `nhanes_2015_2018.rds` | Adult subset aged 20 or older |
| `nhanes_prediction.rds` | Adults classified as undiagnosed or no diabetes, with HbA1c removed |

Analysis scripts construct survey designs from the full frame, then select adult domains. Derived datasets are excluded from Git. Do not replace the full frame with an adult-only or prediction-only file when defining the survey design.
