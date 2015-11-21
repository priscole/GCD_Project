#Getting and Cleaning Data - Course Project
#Authored by Priscole, 11/20/15

#Instructions
#============
#You should create one R script called run_analysis.R that does the following: 
        # 1. Merges the training and the test sets to create one data set.
        # 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
        # 3. Uses descriptive activity names to name the activities in the data set
        # 4. Appropriately labels the data set with descriptive variable names. 
        # 5. From the data set in step 4, creates a second, independent tidy data 
                #set with the average of each variable for each activity and each subject.
#============

library(dplyr)
 
#set working directory
setwd("C:\\Users\\Priscole\\Documents\\R\\GettingAndCleaningData\\UCI HAR Dataset")

#Data Paths
colNamesPath <- "features.txt"
activityLPath <- "activity_labels.txt"

subjectsTsPath <- "test\\subject_test.txt"
activitiesTsPath <- "test\\y_test.txt"
X_TsPath <- "test\\X_test.txt"

subjectsTrPath <- "train\\subject_train.txt"
activitiesTrPath <- "train\\y_train.txt"
X_TrPath <- "train\\X_train.txt"

#function to read in files as dataframes
readFiles <- function(path, sep="", stringsAsFactors=FALSE){
        read.table(path)        
}
activityLabels <- readFiles(activityLPath)
colNames <- readFiles(colNamesPath)
x_test <- readFiles(X_TsPath)
subjectsTs <- readFiles(subjectsTsPath)
activitiesTs <- readFiles(activitiesTsPath)
x_train <- readFiles(X_TrPath)
subjectsTr <- readFiles(subjectsTrPath)
activitiesTr <- readFiles(activitiesTrPath)

#De-Dup
dup <- duplicated(colNames$V2)
colNamesDups <- mutate(colNames, dups=dup)
Table <- colNamesDups %>% select(V1, V2, dups) %>% filter(dups==FALSE)
deDupIdx <- Table$V1

deDupColNames <- colNames[deDupIdx, V2]
deDupTs <- x_test[, deDupIdx] 
deDupTr <- x_train[, deDupIdx]


#adds column names to data
addColNames <- function(df, colDf){
        headers <- colDf$V2
        names(df) <- headers
        df
}
namedDataTs <- addColNames(deDupTs, deDupColNames)
namedDataTr <- addColNames(deDupTr, deDupColNames)

#select columns contatin "mean" or "std"
selectTs <- select(namedDataTs, contains("mean()"), contains("std()"))
selectTr <- select(namedDataTr, contains("mean()"), contains("std()"))

#names columns for activity and subject dataframes
names(activityLabels) <- c("actCode", "activity")
names(activitiesTs) <- c("actCode")
names(subjectsTs) <- c("subject")
names(activitiesTr) <- c("actCode")
names(subjectsTr) <- c("subject")

#add columns activities and subjects to data
xTest <- cbind(activitiesTs, selectTs)
yTest <- cbind(subjectsTs, xTest)
xTrain <- cbind(activitiesTr, selectTr)
yTrain <- cbind(subjectsTr, xTrain)

#merge activity labels
mergeTsData <- merge(yTest, activityLabels, by.x="actCode", by.y="actCode", all=TRUE)
mergeTrData <- merge(yTrain, activityLabels, by.x="actCode", by.y="actCode", all=TRUE)

#select out columns containing "mean" or "std"
testData <- select(mergeTsData, subject, activity, contains("mean()"), contains("std()"))
trainData <- select(mergeTrData, subject, activity, contains("mean"), contains("std"))

#Tidy dataset #1
DATA <- rbind(testData, trainData)

#sumarize by subject, the mean for each variable
DATA2 <- DATA %>% group_by(subject, activity) %>% summarise_each(funs(mean), -subject, -activity)

write.table(DATA2, file="tidyData2.txt" row.name=FALSE)