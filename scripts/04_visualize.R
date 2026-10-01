# Rebuild the two aggregate figures displayed in the README.
source("scripts/_common.R")
figure_dir <- file.path("results", "figures")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
navy <- "#173D52"
teal <- "#139E88"
ink <- "#233746"
read_output <- function(filename) {
  path <- file.path(output_dir, filename)
  if (!file.exists(path)) stop("Missing ", path, ". Run analysis stages 02 and 03 first.")
  read.csv(path, check.names = FALSE)
}
risk <- read_output("test_risk_band_rates.csv")
png(file.path(figure_dir, "prediction_risk_bands.png"),
    width = 1600, height = 950, res = 170, type = "cairo")
par(mar = c(5, 5, 5, 2), family = "sans", col.axis = ink,
    col.lab = ink, fg = ink, las = 1)
rates <- 100 * rbind(risk$undiagnosed, risk$predicted)
tops <- barplot(rates, beside = TRUE, col = c(navy, teal), border = NA,
                ylim = c(0, max(rates) * 1.35),
                names.arg = c("Under 1%", "1% to under 3%", "3% or higher"),
                ylab = "Undiagnosed diabetes (%)", xlab = "Predicted risk band")
text(tops, rates + 0.18, labels = sprintf("%.2f%%", rates), cex = 0.9, col = ink)
title(main = "Observed and predicted rates across risk bands", col.main = ink,
       cex.main = 1.1, line = 2.5)
mtext("2017-2018 test cycle | model trained on 2015-2016 | survey-weighted means",
       side = 3, line = 1, cex = 0.78, col = "#586E7C")
legend("topleft", c("Observed", "Average prediction"),
        fill = c(navy, teal), border = NA, bty = "n", cex = 0.9)
dev.off()

balance <- read_output("iptw_covariate_balance.csv")
label_map <- c("age_group40-59" = "Age: 40-59",
  "age_group60+" = "Age: 60+", "factor(RIAGENDR)2" = "Sex: female",
  "factor(RIDRETH3)2" = "Race/ethnicity: other Hispanic",
  "factor(RIDRETH3)3" = "Race/ethnicity: White",
  "factor(RIDRETH3)4" = "Race/ethnicity: Black",
  "factor(RIDRETH3)6" = "Race/ethnicity: Asian",
  "factor(RIDRETH3)7" = "Race/ethnicity: other / multiracial",
  "factor(education_clean)2" = "Education: grades 9-11",
  "factor(education_clean)3" = "Education: high school / GED",
  "factor(education_clean)4" = "Education: some college / AA",
  "factor(education_clean)5" = "Education: college graduate+",
  "factor(SDDSRVYR)10" = "Survey cycle: 2017-2018")
labels <- unname(label_map[balance$variable])
labels[is.na(labels)] <- balance$variable[is.na(labels)]
positions <- rev(seq_len(nrow(balance)))
png(file.path(figure_dir, "iptw_covariate_balance.png"),
    width = 1750, height = 1100, res = 170, type = "cairo")
par(mar = c(5, 15, 5, 2), family = "sans", col.axis = ink,
    col.lab = ink, fg = ink, las = 1)
limit <- max(0.5, max(abs(balance$before), abs(balance$after)) * 1.1)
plot(NA, xlim = c(0, limit), ylim = c(0, nrow(balance) + 1),
      yaxt = "n", xlab = "Absolute standardized difference", ylab = "", bty = "n")
abline(h = positions, col = "#EDF1F4")
abline(v = 0.10, lty = 2, col = "#9CAAB4")
segments(abs(balance$before), positions, abs(balance$after), positions,
          col = "#CED9E0", lwd = 2)
points(abs(balance$before), positions, pch = 16, col = navy, cex = 1.1)
points(abs(balance$after), positions, pch = 16, col = teal, cex = 1.1)
axis(2, at = positions, labels = labels, tick = FALSE, cex.axis = 0.8)
title(main = "Measured covariate balance improved after weighting",
       col.main = ink, cex.main = 1.05, line = 2.5)
mtext("Absolute differences in covariate indicators | complete-covariate diabetes domain",
       side = 3, line = 1, cex = 0.75, col = "#586E7C")
legend("topright", c("Before IPTW", "After IPTW"),
        col = c(navy, teal), pch = 16, bty = "n", cex = 0.9)
dev.off()
message("README figures saved in ", figure_dir)
