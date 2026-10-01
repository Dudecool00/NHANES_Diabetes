# Run from the repository root: Rscript scripts/run_all.R
source("scripts/_common.R")
for (script in c("00_download_data.R", "01_prepare_data.R",
                 "02_prediction.R", "03_iptw.R", "04_visualize.R")) {
  message("Running ", script)
  source(file.path("scripts", script))
}
capture.output(sessionInfo(), file = file.path(output_dir, "session_info.txt"))
message("Finished. See results/generated for tables and summaries.")
