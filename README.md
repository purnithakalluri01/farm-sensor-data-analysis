# Data Cleaning, Exploratory Analysis and Predictive Modelling of Farm Sensor Data using R

## Project Overview
This project demonstrates an end-to-end R workflow for cleaning farm sensor data, performing exploratory data analysis, visualizing relationships, and predicting crop yield.

The dataset is synthetic and was created for academic demonstration because no class dataset was supplied. It contains 36 farm plots with four weekly readings for soil moisture, temperature and rainfall, together with crop yield.

## Main Focus
The analysis focuses on average weekly soil moisture and its relationship with crop yield.

## Requirements
- R 4.x
- RStudio
- reshape2

## Methods
1. Vectors, lists, matrices and a normalized data frame
2. Wide-to-long reshaping using melt() and dcast()
3. Custom data-cleaning functions using loops and if-else conditions
4. Missing and invalid-value handling
5. Derived weekly sensor features
6. Univariate and bivariate EDA
7. Histogram, box plot and scatter plot
8. Multiple linear regression for continuous crop yield
9. Example crop-yield prediction

## Regression Choice
Crop yield is measured as a continuous quantity in tons per hectare, so multiple linear regression is appropriate for estimating the relationship between yield and the sensor variables.

## Limitation
The dataset is synthetic and relatively small. Real farms may contain seasonal effects, soil type, crop variety, irrigation schedules and sensor calibration issues that are not represented here.

## SDG Relevance
The project supports SDG 2 (Zero Hunger), SDG 9 (Industry, Innovation and Infrastructure), and SDG 13 (Climate Action).

## How to Run
From the repository root in RStudio, run:

```r
source("R/farm_sensor_analysis.R")
```

The script reads the raw CSV, cleans and reshapes the data, creates analytical outputs, fits the regression model, and saves result files under `output/`.

## Project Structure
```text
student-performance-analysis-r/
├── data/
│   └── farm_sensor_data_wide.csv
├── R/
│   └── farm_sensor_analysis.R
├── output/
│   ├── 01_soil_moisture_histogram.png
│   ├── 02_yield_boxplot.png
│   ├── 03_moisture_yield_scatter.png
│   ├── normalized_farm_sensor_data.csv
│   └── soil_moisture_long_format.csv
├── pseudocode.txt
├── test_cases.txt
└── README.md
```
