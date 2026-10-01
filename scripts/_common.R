# Run scripts from the repository root. No machine-specific paths are needed.
if (!file.exists("scripts/_common.R")) {
  stop("Open the NHANES_Diabetes folder and run this script from that folder.")
}
required_packages <- c("haven", "dplyr", "survey")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages)) {
  stop("Install required packages first: install.packages(c(",
       paste(sprintf('"%s"', missing_packages), collapse = ", "), "))")
}
suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
  library(survey)
})
raw_dir <- file.path("data", "raw")
processed_dir <- file.path("data", "processed")
output_dir <- file.path("results", "generated")
for (directory in c(raw_dir, processed_dir, output_dir)) {
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
}
assert_columns <- function(data, required, label) {
  missing <- setdiff(required, names(data))
  if (length(missing)) stop(label, " is missing: ", paste(missing, collapse = ", "))
}
assert_unique_ids <- function(data, label) {
  if (anyNA(data$SEQN) || anyDuplicated(data$SEQN)) {
    stop(label, " must have nonmissing, unique SEQN values.")
  }
}
read_source <- function(stem, columns) {
  path <- file.path(raw_dir, paste0(stem, ".xpt"))
  if (!file.exists(path)) stop("Missing ", path, ". Run scripts/00_download_data.R first.")
  data <- haven::read_xpt(path)
  assert_columns(data, columns, stem)
  assert_unique_ids(data, stem)
  dplyr::select(data, dplyr::all_of(columns))
}
read_frame <- function() {
  path <- file.path(processed_dir, "nhanes_full_frame.rds")
  if (!file.exists(path)) stop("Run scripts/01_prepare_data.R first.")
  frame <- readRDS(path)
  assert_unique_ids(frame, "Combined NHANES frame")
  frame
}
make_design <- function(frame) {
  survey::svydesign(ids = ~SDMVPSU, strata = ~SDMVSTRA,
                    weights = ~WTMEC4YR, nest = TRUE,
                    data = subset(frame, !is.na(WTMEC4YR) & WTMEC4YR > 0))
}
save_table <- function(data, filename) {
  write.csv(data, file.path(output_dir, filename), row.names = FALSE)
}
