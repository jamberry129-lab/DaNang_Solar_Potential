# ============================================================
# Da Nang, Vietnam — Rooftop Solar PV Potential
# Sampling Analysis — R Script
#
# Methodology based on:
# Thompson, S. K. (2012). Sampling (3rd ed.). Wiley.
#
# Adapted from Grinberg (2022):
# "Estimating building rooftop solar potential in a city
#  from a developing country" — Rosario/La Plata, Argentina
# Technical guide: https://bookdown.org/einavg7/sp_technical_guide/
# ============================================================

# ── Install packages (chạy 1 lần) ───────────────────────────
# install.packages("dplyr")
# install.packages("sf")
# install.packages("ggplot2")

# ── Load packages ────────────────────────────────────────────
library(dplyr)
library(sf)
library(ggplot2)

# ── Set working directory ────────────────────────────────────
# setwd("path/to/DaNang_Solar")

# ── Load data ────────────────────────────────────────────────
# Load shapefile exported từ Colab pipeline
# (tương đương sample100.shp của Rosario nhưng dùng toàn bộ dataset)
buildings <- read_sf("data/danang_solar.shp")
buildings <- st_transform(buildings,
  "+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
)

# Apply density factor — giống hệt Rosario
# "change to 0 above and equal 30 sqm"
buildings$elec_prod[buildings$area_m2 <= 30] <- 0

# Create MWh column — giống hệt Rosario
# "create mega watt per hour (mWh) column"
buildings$elec_prod_mwh <- buildings$elec_prod / 1000

head(buildings)
summary(buildings)

# ── Total population size ─────────────────────────────────────
N_all <- nrow(buildings)
paste("Total buildings in Da Nang (N):", N_all)

# ============================================================
# 4.4.1 RANDOM SAMPLING
# Giống hệt Section 4.4.1 của Rosario technical guide
# ============================================================

# Sample size: n = 384 (Cochran formula)
# n0 = Z² × p(1-p) / e² = 1.96² × 0.5 × 0.5 / 0.05² = 384
n_sample <- 384

set.seed(42) # reproducibility
sample1 <- buildings %>% sample_n(n_sample)

# ── Primary parameters — giống Rosario ──
n1 <- as.numeric(nrow(sample1))
y1 <- mean(sample1$elec_prod_mwh)
paste("The mean of sample 1:", round(y1, 2), "(mWh)")

s1 <- var(sample1$elec_prod_mwh)
paste("The variance of sample 1:", round(s1, 2), "(mWh)")

# Unbiased variance of estimator ȳ
# var_hat(ȳ) = ((N-n)/N) × (s²/n)   [Eq. 4.3]
var_un1 <- ((N_all - n1) / N_all) * (s1 / n1)
paste("The variance of the sample mean:", round(var_un1, 2), "(mWh)")

# Estimated standard error of ȳ (SEM)
# SEM = sqrt(var_hat(ȳ))   [Eq. 4.4]
ese1 <- sqrt(var_un1)
paste("The estimated standard error of the sample mean:", round(ese1, 2), "(mWh)")

# Estimated population total
# t_hat = N × ȳ   [Eq. 4.5]
t_un1 <- N_all * y1
paste("The estimation of the renewable electricity production potential",
      "by all the buildings in the city:", round(t_un1, 2), "(mWh)")

# Unbiased variance of t_hat
# var_hat(t_hat) = N² × var_hat(ȳ)   [Eq. 4.6]
t_var_un1 <- (N_all ^ 2) * var_un1
paste("The variance of the estimated total:", round(t_var_un1, 2), "(mWh)")

# Estimated standard error of t_hat (SET)
# SET = sqrt(var_hat(t_hat))   [Eq. 4.7]
ese_t1 <- sqrt(t_var_un1)
paste("The estimated standard error of the total:", round(ese_t1, 2), "(mWh)")

# 95% Confidence Interval — giống Rosario
CI1 <- t_un1 + qt(c(0.05, 0.95), df = n1 - 1) * ese_t1
paste("The 95% confidence interval estimation for sample 1 is: (",
      round(CI1[1], 2), "(mWh),", round(CI1[2], 2), "(mWh))")

# ============================================================
# 4.4.2 EQUAL SIZE STRATIFICATION
# Giống Section 4.4.2 Rosario
# Strata: Built-up vs Non built-up (từ Copernicus LULC 2015)
# ============================================================

# Tách 2 strata — giống Rosario dùng strata_bu.shp + strata_nonbu.shp
bu    <- buildings %>% filter(landuse == "built_up")
nonbu <- buildings %>% filter(landuse == "non_built_up")

paste("Built-up buildings (N1):", nrow(bu))
paste("Non built-up buildings (N2):", nrow(nonbu))

# Sample 60 per stratum — giống Rosario
set.seed(42)
sample_bu    <- bu    %>% sample_n(min(60, nrow(bu)))
sample_nonbu <- nonbu %>% sample_n(min(60, nrow(nonbu)))

# Add landuse column — giống Rosario
sample_bu$landuse    <- "Built up"
sample_nonbu$landuse <- "Non built up"

# Combine — giống Rosario dùng rbind
strat_equal <- rbind(sample_bu, sample_nonbu)
strat_equal$elec_prod[strat_equal$area_m2 <= 30] <- 0
strat_equal$elec_prod_mwh <- strat_equal$elec_prod / 1000

# ── Calculations per stratum ──
calc_stratum <- function(samp, N_s, label) {
  n_s     <- as.numeric(nrow(samp))
  y_s     <- mean(samp$elec_prod_mwh)
  s2_s    <- var(samp$elec_prod_mwh)
  var_s   <- ((N_s - n_s) / N_s) * (s2_s / n_s)
  ese_s   <- sqrt(var_s)
  t_s     <- N_s * y_s
  tvar_s  <- (N_s ^ 2) * var_s
  tese_s  <- sqrt(tvar_s)

  cat("\n--- Stratum:", label, "---\n")
  cat("n =", n_s, "| N =", N_s, "\n")
  cat("Mean (ȳ):", round(y_s, 2), "mWh\n")
  cat("Variance (s²):", round(s2_s, 2), "mWh\n")
  cat("var_hat(ȳ):", round(var_s, 2), "mWh\n")
  cat("SEM:", round(ese_s, 2), "mWh\n")
  cat("t_hat:", round(t_s, 2), "mWh\n")
  cat("SET:", round(tese_s, 2), "mWh\n")

  list(n=n_s, N=N_s, mean=y_s, var=s2_s,
       total=t_s, var_total=tvar_s, set=tese_s)
}

N1 <- nrow(bu)
N2 <- nrow(nonbu)

res_bu_eq    <- calc_stratum(sample_bu,    N1, "Built-up (n=60)")
res_nonbu_eq <- calc_stratum(sample_nonbu, N2, "Non built-up (n=60)")

# Combined estimate
t_eq   <- res_bu_eq$total + res_nonbu_eq$total
var_eq <- res_bu_eq$var_total + res_nonbu_eq$var_total
set_eq <- sqrt(var_eq)
df_eq  <- nrow(strat_equal) - 2

CI_eq  <- t_eq + qt(c(0.05, 0.95), df = df_eq) * set_eq

cat("\n=== EQUAL STRATIFICATION (60+60) ===\n")
cat("Estimated total:", round(t_eq, 2), "mWh\n")
paste("The 95% CI for equal stratification is: (",
      round(CI_eq[1], 2), "(mWh),", round(CI_eq[2], 2), "(mWh))")

# ============================================================
# 4.4.3 OPTIMAL ALLOCATION STRATIFICATION
# Giống Section 4.4.3 Rosario
# Built-up: 95 buildings, Non built-up: 5 buildings
# ============================================================

set.seed(42)
sample_bu_op    <- bu    %>% sample_n(min(95, nrow(bu)))
sample_nonbu_op <- nonbu %>% sample_n(min(5,  nrow(nonbu)))

sample_bu_op$landuse    <- "Built up"
sample_nonbu_op$landuse <- "Non built up"

strat_opt <- rbind(sample_bu_op, sample_nonbu_op)
strat_opt$elec_prod[strat_opt$area_m2 <= 30] <- 0
strat_opt$elec_prod_mwh <- strat_opt$elec_prod / 1000

res_bu_op    <- calc_stratum(sample_bu_op,    N1, "Built-up (n=95)")
res_nonbu_op <- calc_stratum(sample_nonbu_op, N2, "Non built-up (n=5)")

t_op   <- res_bu_op$total + res_nonbu_op$total
var_op <- res_bu_op$var_total + res_nonbu_op$var_total
set_op <- sqrt(var_op)
df_op  <- nrow(strat_opt) - 2

CI_op  <- t_op + qt(c(0.05, 0.95), df = df_op) * set_op

cat("\n=== OPTIMAL STRATIFICATION (95+5) ===\n")
cat("Estimated total:", round(t_op, 2), "mWh\n")
paste("The 95% CI for optimal stratification is: (",
      round(CI_op[1], 2), "(mWh),", round(CI_op[2], 2), "(mWh))")

# ============================================================
# 4.5 CENSUS — Total từ toàn bộ dataset
# (Bonus: có thể làm vì có đủ data — khác với Rosario)
# ============================================================

total_census <- sum(buildings$elec_prod_mwh, na.rm = TRUE)
cat("\n=== CENSUS (all", N_all, "buildings) ===\n")
cat("Total electricity potential:", round(total_census, 2), "mWh/yr\n")
cat("                         =", round(total_census / 1000, 2), "GWh/yr\n")

# ============================================================
# COMPARISON TABLE — giống Section 4.5 Rosario
# ============================================================

results <- data.frame(
  Method = c(
    "Census (N=47,472)",
    paste0("Random sampling (n=", n_sample, ")"),
    "Stratified Equal (n=120)",
    "Stratified Optimal (n=100)"
  ),
  Estimated_mWh = c(
    round(total_census, 0),
    round(t_un1, 0),
    round(t_eq, 0),
    round(t_op, 0)
  ),
  Estimated_GWh = c(
    round(total_census / 1000, 2),
    round(t_un1 / 1000, 2),
    round(t_eq / 1000, 2),
    round(t_op / 1000, 2)
  ),
  CI_lower_mWh = c(
    NA,
    round(CI1[1], 0),
    round(CI_eq[1], 0),
    round(CI_op[1], 0)
  ),
  CI_upper_mWh = c(
    NA,
    round(CI1[2], 0),
    round(CI_eq[2], 0),
    round(CI_op[2], 0)
  )
)

cat("\n=== COMPARISON: ALL METHODS ===\n")
print(results)

# Save results
write.csv(results, "sampling/results_sampling.csv",
          row.names = FALSE)
cat("\n✓ Saved: sampling/results_sampling.csv\n")

# ============================================================
# VISUALIZATION — Comparison plot
# ============================================================

# Filter sampling methods (not census)
res_plot <- results[-1, ] %>%
  mutate(Method = factor(Method, levels = Method))

p <- ggplot(res_plot, aes(x = Method, y = Estimated_GWh)) +
  geom_col(fill = c("#FFAA00","#E8593C","#1B3A6B"),
           width = 0.55, color = "#333", linewidth = 0.4) +
  geom_errorbar(
    aes(ymin = CI_lower_mWh / 1000,
        ymax = CI_upper_mWh / 1000),
    width = 0.2, color = "#333", linewidth = 0.8
  ) +
  geom_hline(
    yintercept = total_census / 1000,
    color = "black", linewidth = 1, linetype = "dashed"
  ) +
  annotate("text",
    x = 0.6, y = total_census / 1000 + 20,
    label = paste0("Census: ", round(total_census/1000, 1), " GWh/yr"),
    hjust = 0, size = 3.5, color = "black"
  ) +
  geom_text(
    aes(label = paste0(Estimated_GWh, " GWh")),
    vjust = -0.5, size = 3.5, fontface = "bold"
  ) +
  scale_x_discrete(labels = function(x) gsub(" \\(", "\n(", x)) +
  labs(
    title    = "Rooftop Solar PV Potential — Da Nang, Vietnam",
    subtitle = "Comparison of estimation methods (90% CI shown)",
    x        = NULL,
    y        = "Estimated Electricity Potential (GWh/yr)",
    caption  = paste0(
      "η = 18%  ·  PR = 0.75  ·  GHI = 1,684 kWh/m²/yr\n",
      "Strata: Copernicus LULC 2015 (built-up: pixels 50–60)\n",
      "Methodology: Thompson (2012), Grinberg (2022)"
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title    = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(color = "#555"),
    plot.caption  = element_text(color = "#888", size = 9),
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    axis.text.x        = element_text(size = 9)
  )

print(p)
ggsave("sampling/Fig_sampling_comparison.png",
       p, width = 9, height = 6, dpi = 300)
cat("✓ Saved: sampling/Fig_sampling_comparison.png\n")
