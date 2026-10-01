# Download eight public CDC files; existing readable files are reused.
source("scripts/_common.R")
options(timeout = max(300, getOption("timeout")))
for (cycle in c("I", "J")) {
  year <- if (cycle == "I") "2015" else "2017"
  for (component in c("DEMO", "DIQ", "BMX", "GHB")) {
    filename <- paste0(component, "_", cycle, ".xpt")
    destination <- file.path(raw_dir, filename)
    if (file.exists(destination)) {
      cached <- tryCatch(haven::read_xpt(destination), error = function(e) NULL)
      if (!is.null(cached)) {
        assert_unique_ids(cached, filename)
        message("Using existing ", filename)
        next
      }
      stop("Existing file is not readable XPT: ", destination,
           ". Remove that file and retry.")
    }
    url <- paste0("https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/", year,
                  "/DataFiles/", filename)
    temporary <- tempfile(fileext = ".xpt")
    message("Downloading ", filename)
    tryCatch({
      status <- download.file(url, temporary, mode = "wb", method = "libcurl")
      if (status != 0) stop("Download failed.")
      downloaded <- haven::read_xpt(temporary)
      assert_unique_ids(downloaded, filename)
      if (!file.copy(temporary, destination)) stop("Could not save ", destination)
    }, error = function(e) {
      stop("Could not download ", filename, ": ", conditionMessage(e),
           " See data/raw/README.md for manual download links.")
    }, finally = unlink(temporary))
  }
}
