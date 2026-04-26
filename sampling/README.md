# Sampling Folder

## Files

| File | Description |
|---|---|
| `sampling.R` | Main R script — Census + Random + Stratified sampling |

## How to run

```r
# 1. Install packages (first time only)
install.packages(c("dplyr", "sf", "ggplot2"))

# 2. Set working directory to DaNang_Solar/
setwd("path/to/DaNang_Solar")

# 3. Make sure data/danang_solar.shp exists
# (Download danang_solar.shp from Google Drive)

# 4. Run analysis
source("sampling/sampling.R")

# 5. Results saved to:
#    sampling/results_sampling.csv
#    sampling/Fig_sampling_comparison.png
```

## Methods (Thompson, 2012)

| Method | Sample size | Description |
|---|---|---|
| Census | N = 47,472 | All buildings — ground truth |
| Random sampling | n = 384 | Cochran formula (Z=1.96, p=0.5, e=0.05) |
| Stratified equal | n = 120 | 60 built-up + 60 non built-up |
| Stratified optimal | n = 100 | 95 built-up + 5 non built-up |

## Strata definition

Based on Copernicus LULC 2015:
- **Built-up**: pixel values 50–60 → urban areas
- **Non built-up**: all other pixel values → peri-urban, rural areas

## Key equations

```
t̂ = N × ȳ                          (estimated total)
var_hat(ȳ) = ((N-n)/N) × (s²/n)    (variance of sample mean)
SET = N × √(var_hat(ȳ))            (standard error of total)
CI  = t̂ ± t(0.05, df) × SET        (90% confidence interval)
```
