if (!requireNamespace("reshape2", quietly = TRUE)) {
  install.packages("reshape2", repos = "https://cloud.r-project.org")
}
library(reshape2)

sensor_data <- read.csv("data/farm_sensor_data_wide.csv", stringsAsFactors = FALSE)

plot_ids <- sensor_data$Plot_ID
sensor_values <- as.numeric(sensor_data$Soil_Moisture_W1)
sensor_list <- list(soil_moisture = sensor_values, plot_id = plot_ids)
sensor_matrix <- as.matrix(sensor_data[, c("Soil_Moisture_W1", "Soil_Moisture_W2", "Soil_Moisture_W3", "Soil_Moisture_W4")])

soil_long <- melt(sensor_data, id.vars = "Plot_ID", measure.vars = c("Soil_Moisture_W1", "Soil_Moisture_W2", "Soil_Moisture_W3", "Soil_Moisture_W4"), variable.name = "Week", value.name = "Soil_Moisture")
soil_long$Week <- sub("Soil_Moisture_", "", soil_long$Week)
soil_wide_mean <- dcast(soil_long, Plot_ID ~ Week, value.var = "Soil_Moisture", fun.aggregate = mean, na.rm = TRUE)

clean_sensor <- function(x, lower, upper) {
  result <- x
  for (i in seq_along(result)) {
    if (is.na(result[i])) {
      result[i] <- NA
    } else if (result[i] < lower || result[i] > upper) {
      result[i] <- NA
    }
  }
  result
}

clean_soil <- function(x) clean_sensor(x, 0, 100)
clean_rain <- function(x) clean_sensor(x, 0, 100)
clean_temp <- function(x) clean_sensor(x, -10, 60)

soil_cols <- grep("^Soil_Moisture_W", names(sensor_data), value = TRUE)
rain_cols <- grep("^Rainfall_W", names(sensor_data), value = TRUE)
temp_cols <- grep("^Temperature_W", names(sensor_data), value = TRUE)

for (col in soil_cols) sensor_data[[col]] <- clean_soil(sensor_data[[col]])
for (col in rain_cols) sensor_data[[col]] <- clean_rain(sensor_data[[col]])
for (col in temp_cols) sensor_data[[col]] <- clean_temp(sensor_data[[col]])

median_impute <- function(x) {
  replacement <- median(x, na.rm = TRUE)
  for (i in seq_along(x)) {
    if (is.na(x[i])) x[i] <- replacement
  }
  x
}

for (col in c(soil_cols, rain_cols, temp_cols)) sensor_data[[col]] <- median_impute(sensor_data[[col]])

sensor_data$Average_Weekly_Soil_Moisture <- rowMeans(sensor_data[, soil_cols])
sensor_data$Average_Weekly_Temperature <- rowMeans(sensor_data[, temp_cols])
sensor_data$Total_Weekly_Rainfall <- rowSums(sensor_data[, rain_cols])

normalized_data <- sensor_data[, c("Plot_ID", "Average_Weekly_Soil_Moisture", "Average_Weekly_Temperature", "Total_Weekly_Rainfall", "Yield_Tons_per_Hectare")]

mode_value <- function(x) {
  values <- unique(x)
  values[which.max(tabulate(match(x, values)))]
}

skewness <- function(x) {
  n <- length(x); m <- mean(x); s <- sd(x)
  n / ((n - 1) * (n - 2)) * sum(((x - m) / s)^3)
}

kurtosis <- function(x) {
  n <- length(x); m <- mean(x); s <- sd(x)
  term1 <- n * (n + 1) / ((n - 1) * (n - 2) * (n - 3))
  term2 <- 3 * (n - 1)^2 / ((n - 2) * (n - 3))
  term1 * sum(((x - m) / s)^4) - term2
}

moisture <- normalized_data$Average_Weekly_Soil_Moisture
yield <- normalized_data$Yield_Tons_per_Hectare

cat("DATA STRUCTURES\n")
print(head(sensor_values))
print(sensor_list)
print(dim(sensor_matrix))

cat("\nMELTED SENSOR DATA\n")
print(head(soil_long))

cat("\nCAST DATA\n")
print(head(soil_wide_mean))

cat("\nMISSING/INVALID VALUES AFTER CLEANING\n")
print(colSums(is.na(sensor_data[, c(soil_cols, rain_cols, temp_cols)])))

cat("\nUNIVARIATE EDA: AVERAGE SOIL MOISTURE\n")
cat("Mean:", mean(moisture), "\n")
cat("Median:", median(moisture), "\n")
cat("Mode:", mode_value(round(moisture, 1)), "\n")
cat("Range:", diff(range(moisture)), "\n")
cat("Variance:", var(moisture), "\n")
cat("Standard Deviation:", sd(moisture), "\n")
cat("Skewness:", skewness(moisture), "\n")
cat("Kurtosis:", kurtosis(moisture), "\n")

cat("\nUNIVARIATE EDA: YIELD\n")
cat("Mean:", mean(yield), "\n")
cat("Median:", median(yield), "\n")
cat("Mode:", mode_value(round(yield, 1)), "\n")
cat("Range:", diff(range(yield)), "\n")
cat("Variance:", var(yield), "\n")
cat("Standard Deviation:", sd(yield), "\n")
cat("Skewness:", skewness(yield), "\n")
cat("Kurtosis:", kurtosis(yield), "\n")

cat("\nBIVARIATE EDA\n")
cat("Covariance:", cov(moisture, yield), "\n")
cat("Correlation:", cor(moisture, yield), "\n")

png("output/01_soil_moisture_histogram.png", 900, 600)
hist(moisture, main = "Distribution of Average Weekly Soil Moisture", xlab = "Average Soil Moisture (%)", ylab = "Number of Plots")
dev.off()

moisture_group <- cut(moisture, breaks = c(-Inf, 45, 60, Inf), labels = c("Low", "Moderate", "High"))
png("output/02_yield_boxplot.png", 900, 600)
boxplot(yield ~ moisture_group, main = "Yield by Soil Moisture Category", xlab = "Soil Moisture Category", ylab = "Yield (tons/hectare)")
dev.off()

png("output/03_moisture_yield_scatter.png", 900, 600)
plot(moisture, yield, main = "Average Soil Moisture vs Crop Yield", xlab = "Average Weekly Soil Moisture (%)", ylab = "Yield (tons/hectare)", pch = 19)
abline(lm(yield ~ moisture), lwd = 2)
dev.off()

model <- lm(Yield_Tons_per_Hectare ~ Average_Weekly_Soil_Moisture + Average_Weekly_Temperature + Total_Weekly_Rainfall, data = normalized_data)
cat("\nMULTIPLE LINEAR REGRESSION\n")
print(summary(model))

new_plot <- data.frame(Average_Weekly_Soil_Moisture = 58, Average_Weekly_Temperature = 27, Total_Weekly_Rainfall = 160)
predicted_yield <- predict(model, newdata = new_plot)
cat("\nPredicted Yield for Example Plot:", round(predicted_yield, 2), "tons/hectare\n")

write.csv(normalized_data, "output/normalized_farm_sensor_data.csv", row.names = FALSE)
write.csv(soil_long, "output/soil_moisture_long_format.csv", row.names = FALSE)
