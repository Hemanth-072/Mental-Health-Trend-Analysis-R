---
title: "Mental Health data Analysis"
author: "Hemanth"
date: "`r Sys.Date()`"
output: pdf_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## R Markdown

This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:

```{r cars}
summary(cars)
```

## Including Plots

You can also embed plots, for example:

```{r pressure, echo=FALSE}
plot(pressure)
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.

```{r}
# Step 1: Load trimmed data and confirm structure

# 1.1 Install & load required packages
# install.packages(c("readr", "dplyr"))
library(readr)
library(dplyr)

# 1.2 Read in the trimmed CSV
mh <- read_csv("mental_health_trimmed.csv")

# 1.3 Quick checks
cat("Dimensions:", dim(mh), "\n\n")
cat("Column names:\n"); print(colnames(mh)); cat("\n")
cat("First 6 rows:\n"); print(head(mh)); cat("\n")
cat("Data types:\n"); str(mh); cat("\n")
cat("Summary of key variables:\n"); print(summary(select(mh, Year, 
    `Schizophrenia (%)`, `Bipolar disorder (%)`, `Depression (%)`, `Anxiety disorders (%)`))); 

# Step 2: hypotheses 
# Trend in Depression Over Time:
#   H0_trend: The slope of Depression (%) vs. Year is zero (no trend).
#   H1_trend: The slope is non-zero (there is an increasing or decreasing trend).
#
# Correlation Between Disorders:
#   H0_corr: No correlation exists between Depression (%) & Anxiety (%) 
#            and between Depression (%) & Bipolar (%).
#   H1_corr: A correlation exists between Depression & Anxiety and/or Depression & Bipolar.

# Next: we can proceed to EDA (plots of Depression over time) or run statistical tests.

```
```{r}
# Step 3: Exploratory Data Analysis (EDA)

# 3.1 Load plotting libraries
library(ggplot2)
library(dplyr)
```
```{r}
# 3.2 Global average depression trend over time
global_trend <- mh %>%
  group_by(Year) %>%
  summarise(mean_depr = mean(`Depression (%)`, na.rm = TRUE))

ggplot(global_trend, aes(x = Year, y = mean_depr)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    title = "Global Mean Depression Prevalence Over Time",
    x     = "Year",
    y     = "Mean Depression (%)"
  ) +
  theme_minimal()
```
```{r}
# 3.3 Depression trends for selected countries
selected_countries <- c("United States", "India", "China", "Brazil", "Nigeria")

mh_sel <- mh %>%
  filter(Entity %in% selected_countries)

ggplot(mh_sel, aes(x = Year, y = `Depression (%)`, color = Entity)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    title = "Depression Prevalence Over Time by Country",
    x     = "Year",
    y     = "Depression (%)"
  ) +
  theme_minimal() +
  scale_color_brewer(palette = "Set1")
```
```{r}
# 3.4 Distribution of Depression (%) across all countries
ggplot(mh, aes(x = `Depression (%)`)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  labs(
    title = "Distribution of Depression Prevalence Across All Countries",
    x     = "Depression (%)",
    y     = "Count"
  ) +
  theme_minimal()
```

```{r}
# Step 4: Statistical Testing (fixed Shapiro-Wilk sample-size issue)

# 4.1 Shapiro–Wilk normality test for Depression (%)
#    Shapiro-Wilk in R only accepts up to 5000 observations,
#    so we’ll take a random subsample if needed.

depr <- mh$`Depression (%)`
if (length(depr) > 5000) {
  set.seed(42)
  depr_sample <- sample(depr, 5000)
} else {
  depr_sample <- depr
}
shapiro.test(depr_sample)
```
```{r}
# 4.2 Spearman’s ρ: Depression vs. Anxiety Disorders
cor.test(
  mh$`Depression (%)`,
  mh$`Anxiety disorders (%)`,
  method = "spearman",
  exact = FALSE
)

```
```{r}
# 4.3 Spearman’s ρ: Depression vs. Bipolar Disorder
cor.test(
  mh$`Depression (%)`,
  mh$`Bipolar disorder (%)`,
  method = "spearman",
  exact = FALSE
)


```
```{r}
# 4.4 Kendall’s τ: Depression vs. Anxiety Disorders
cor.test(
  mh$`Depression (%)`,
  mh$`Anxiety disorders (%)`,
  method = "kendall"
)

```
```{r}
# 4.5 Kendall’s τ: Depression vs. Bipolar Disorder
cor.test(
  mh$`Depression (%)`,
  mh$`Bipolar disorder (%)`,
  method = "kendall"
)

```
```{r}
# 4.6 Global Linear Trend: Depression (%) ~ Year
lm_global <- lm(`Depression (%)` ~ Year, data = mh)
summary(lm_global)

```
```{r}
# 7. United States Trend: Depression (%) ~ Year
lm_us <- lm(`Depression (%)` ~ Year, data = subset(mh, Entity == "United States"))
summary(lm_us)

```
### Correlation Results

#- Spearman’s ρ (Depression vs Anxiety): ρ = 0.345, p < 2.2e-16 → reject H₀₍corr₎.  
#- Spearman’s ρ (Depression vs Bipolar): ρ = 0.149, p = 2.8e-16 → reject H₀₍corr₎.  
#- Kendall’s τ gives the same conclusion.


```{r}
# 5.1 Load needed packages
library(dplyr)
library(broom)

# 5.2 Fit a separate lm for each country
country_trends <- mh %>%
  group_by(Entity) %>%
  do(tidy(lm(`Depression (%)` ~ Year, data = .))) %>%
  filter(term == "Year") %>%       # keep only the Year coefficient
  select(Entity, estimate, std.error, p.value) %>%
  rename(
    slope    = estimate,
    se_slope = std.error,
    p_slope  = p.value
  )

# 5.3 View the first few countries
head(country_trends, 10)

```

```{r}
library(ggplot2)

ggplot(country_trends, aes(x = reorder(Entity, slope), y = slope, fill = p_slope < 0.05)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("FALSE" = "grey70", "TRUE" = "steelblue"),
                    labels = c("ns", "p < .05")) +
  labs(
    title = "Per-Country Trend in Depression Prevalence",
    x     = "Country",
    y     = "Annual Change in Depression (%)",
    fill  = "Significant\nTrend?"
  ) +
  theme_minimal()

```

### Trend Results

#- Global linear model: slope = …, p < 0.05 → reject H₀₍trend₎, there is a significant global trend.  
#- Per-country slopes are summarized above

…
```{r}
# 2. PCA on Multi-Disorder Prevalences
install (ggfortify)
library(dplyr)
library(ggfortify)

# Average each country over time
pca_df <- mh %>%
  group_by(Entity) %>%
  summarise(across(
    c(`Schizophrenia (%)`, `Bipolar disorder (%)`,
      `Anxiety disorders (%)`, `Depression (%)`),
    mean, na.rm = TRUE
  )) %>%
  column_to_rownames("Entity")

# Run PCA
pca_res <- prcomp(pca_df, scale. = TRUE)

# Scree plot
autoplot(pca_res, data = pca_df, loadings = FALSE) +
  labs(title = "PCA: Disorder Prevalence Across Countries")

# Biplot of first two PCs
autoplot(pca_res, data = pca_df, loadings = TRUE, loadings.label = TRUE) +
  labs(title = "PCA Biplot: Disorder Prevalence Across Countries")

```


