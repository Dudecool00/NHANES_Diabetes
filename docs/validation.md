# Reproduction check

The complete pipeline was run against the eight public CDC source files on October 1, 2026, with R 4.3.3, haven 2.5.4, dplyr 1.1.4, and survey 4.2-1.

The run completed data downloading, preparation, prediction, IPTW, figure generation, and session-info export. A subsequent run also verified reuse of the cached XPT files. The README figures were inspected for readable labels and layout.

| Check | Result |
|---|---:|
| Combined demographic frame | 19,225 participants |
| Adult dataset | 11,288 participants |
| BMI-complete diabetes domain | 1,939 participants |
| Complete-covariate IPTW sample | 1,934 participants |
| Adjusted diagnosis difference | -6.44236 percentage points |
| 95% confidence interval | -11.86380 to -1.02093 percentage points |
| Maximum absolute post-IPTW standardized difference | 0.01769 |
| Test population in the at-least-3% risk band | 25.8587% |
| Test cases in the at-least-3% risk band | 64.3723% |

These results agree with the recorded original findings to their reported precision. Reproduction verifies the implementation against this analysis record; it does not establish clinical validity or causality. The limitations in `methods.md` still apply.

All R scripts parsed successfully. Relative documentation links and SVG markup were checked. Participant datasets and numeric generated outputs are excluded from the repository; aggregate overview figures are included.
