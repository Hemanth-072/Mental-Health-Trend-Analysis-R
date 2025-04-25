# Mental-Health-Trend-Analysis-R

This project examines global trends in mental health disorder prevalence (schizophrenia, bipolar disorder, anxiety, depression, etc.) across 20+ countries from 1990–2017. We perform exploratory analysis, hypothesis testing, and per-country trend modeling using R.

## Table of Contents

1. [Overview](#overview)  
2. [Data](#data)  
3. [Installation](#installation)  
4. [Usage](#usage)  
5. [Analysis Steps](#analysis-steps)  
6. [Results Summary](#results-summary)  
7. [Future Directions](#future-directions)  
8. [License](#license)  

---

## Overview

We test two main hypotheses:

1. **Trend in Depression Over Time**  
   - H₀₍trend₎: The slope of “Depression (%) vs. Year” is zero (no trend).  
   - H₁₍trend₎: The slope is non-zero (significant increasing or decreasing trend).  

2. **Correlation Between Disorders**  
   - H₀₍corr₎: No correlation between Depression (%) & Anxiety (%) and between Depression (%) & Bipolar (%).  
   - H₁₍corr₎: A correlation exists for one or both pairs.

Using `ggplot2`, `dplyr`, and base R, we:

- Clean and trim the dataset  
- Visualize global and per-country trends  
- Conduct Shapiro–Wilk normality tests  
- Compute Spearman’s ρ and Kendall’s τ correlations  
- Fit linear models for global and country-level trends  

---

## Data

- **Source: "https://www.kaggle.com/datasets/thedevastator/uncover-global-trends-in-mental-health-disorder"
- Data trimming -  “Mental health Depression disorder Data” (trimmed to first 6,470 records)
- **Format:** CSV at `data/mental_health_trimmed.csv`  
- **Key columns:**  
  - `Entity` (Country)  
  - `Year`  
  - `Depression (%)`, `Anxiety disorders (%)`, `Bipolar disorder (%)`, `Schizophrenia (%)`, etc.

---

## Installation

```bash
# Clone the repo
git clone https://github.com/Hemanth-072/Mental-Health-Trend-Analysis-R.git
cd Mental-Health-Trend-Analysis-R

# Install required R packages (run in R/RStudio)
install.packages(c(
  "readr", "dplyr", "ggplot2", "broom",
  "tidyr", "ggfortify", "cluster"
))

Usage

Open and run the RMarkdown file report/analysis.Rmd or individually execute the scripts under src/:

    src/load_and_inspect.R

    src/eda_plots.R

    src/statistical_tests.R

    src/country_trends.R

Analysis Steps

    Load & Trim Data (src/load_and_inspect.R)

    Exploratory Data Analysis (src/eda_plots.R)

    Statistical Testing (src/statistical_tests.R)

    Country-level Trend Analysis (src/country_trends.R)

Results Summary

    Global Trend: Significant upward trend in Depression (%) over 1990–2017 (p < 0.001).

    Correlations:

        Depression vs Anxiety: Spearman’s ρ ≈ 0.345, p < 2.2e-16 → reject H₀₍corr₎.

        Depression vs Bipolar: Spearman’s ρ ≈ 0.149, p < 2.2e-16 → reject H₀₍corr₎.

Country-level linear models reveal which nations have significantly increasing or decreasing depression rates over time.
Future Directions

    Clustering of Countries
    Group nations by both their average depression level and yearly trend slopes (e.g., k-means clustering of slope vs mean).

    Principal Component Analysis
    Reduce dimensionality across multiple disorders to identify shared patterns and latent factors.

    Predictive Modeling
    Build regression or classification models to predict depression prevalence from other disorder rates.

    Interactive Dashboard
    Develop a Shiny app for dynamic exploration of country trends and correlations.
