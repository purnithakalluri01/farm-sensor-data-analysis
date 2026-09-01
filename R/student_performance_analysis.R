# ============================================================
# Student Performance Analysis and Prediction Using R
# ============================================================

# 1. Import dataset
data <- read.csv("data/student_performance.csv")

# 2. Inspect the dataset
cat("First six records:\n")
print(head(data))
cat("\nDataset structure:\n")
str(data)

cat("\nSummary statistics:\n")
print(summary(data))

cat("\nMissing values by column:\n")
print(colSums(is.na(data)))

# 3. Descriptive statistics
cat("\nAverage Study Hours:",
    round(mean(data$Study_Hours), 2), "\n")
cat("Average Attendance:",
    round(mean(data$Attendance_Percent), 2), "%\n")
cat("Average Assignment Score:",
    round(mean(data$Assignment_Average), 2), "\n")
cat("Average Final Score:",
    round(mean(data$Final_Score), 2), "\n")

# 4. Visualizations
png("output/01_marks_distribution.png", width=900, height=600)
hist(data$Final_Score,
     main="Distribution of Final Scores",
     xlab="Final Score",
     ylab="Number of Students",
     col="lightgray",
     border="black")
dev.off()

png("output/02_attendance_vs_marks.png", width=900, height=600)
plot(data$Attendance_Percent, data$Final_Score,
     main="Attendance vs Final Score",
     xlab="Attendance (%)",
     ylab="Final Score",
     pch=19)
abline(lm(Final_Score ~ Attendance_Percent, data=data), lwd=2)
dev.off()

png("output/03_study_hours_vs_marks.png", width=900, height=600)
plot(data$Study_Hours, data$Final_Score,
     main="Study Hours vs Final Score",
     xlab="Study Hours per Day",
     ylab="Final Score",
     pch=19)
abline(lm(Final_Score ~ Study_Hours, data=data), lwd=2)
dev.off()

# 5. Correlation analysis
study_cor <- cor(data$Study_Hours, data$Final_Score)
attendance_cor <- cor(data$Attendance_Percent, data$Final_Score)

cat("\nCorrelation: Study Hours vs Final Score:",
    round(study_cor, 3), "\n")
cat("Correlation: Attendance vs Final Score:",
    round(attendance_cor, 3), "\n")

# 6. Multiple linear regression
model <- lm(
  Final_Score ~ Study_Hours + Attendance_Percent +
    Assignment_Average + Previous_Score,
  data=data
)

cat("\nRegression Model Summary:\n")
print(summary(model))

# 7. Prediction
new_student <- data.frame(
  Study_Hours = 5,
  Attendance_Percent = 90,
  Assignment_Average = 85,
  Previous_Score = 80
)

prediction <- predict(model, newdata=new_student)
prediction <- max(0, min(100, prediction))

cat("\nPredicted Final Score:",
    round(prediction, 2), "\n")
