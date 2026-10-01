# Public NHANES source data

Run `Rscript scripts/00_download_data.R` from the repository root to obtain the eight files below. Alternatively, download each file manually and save it in this folder with the exact filename shown.

| Component | 2015-2016 data | 2017-2018 data |
|---|---|---|
| Demographics | [DEMO_I.xpt](https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/DEMO_I.xpt) | [DEMO_J.xpt](https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/DEMO_J.xpt) |
| Diabetes questionnaire | [DIQ_I.xpt](https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/DIQ_I.xpt) | [DIQ_J.xpt](https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/DIQ_J.xpt) |
| Body measurements | [BMX_I.xpt](https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/BMX_I.xpt) | [BMX_J.xpt](https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/BMX_J.xpt) |
| Glycohemoglobin | [GHB_I.xpt](https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/GHB_I.xpt) | [GHB_J.xpt](https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/GHB_J.xpt) |

Codebooks are available at the same URLs with `.htm` instead of `.xpt`. If a download link changes, locate the same component and cycle on the [NHANES data page](https://wwwn.cdc.gov/nchs/nhanes/continuousnhanes/).

Raw files are public-use CDC data. They are excluded from Git because the source is available from CDC and the preparation code documents every transformation. Do not use the separate 2017-March 2020 pre-pandemic `P_` files for this two-cycle analysis.
