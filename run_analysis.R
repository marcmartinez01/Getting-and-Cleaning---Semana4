
# installing packages and loading libraries
install.packages("dplyr")
install.packages("data.table")

library(data.table)
library(dplyr)

#Set your working directory
setwd("C:/Users/MarcosD/OneDrive/03- Cursos/Practicas en R/04- Coursera/03- Getting and Cleaning Data/Semana 4/Proyecto") #Setting my working directory

#Download UCI data files from the web, unzip them, and specify time/date settings
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

destFile <- "CourseDSsem4.zip"
if (!file.exists(destFile)){
  download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("./Semana4_Protecto")){
  unzip(destFile)
}
dateDownloaded <- date()

############################
setwd("./UCI_HAR_Dataset") #Start reading files
##########################

ActivityTest <- read.table("./test/y_test.txt", header = F)###Reading Activity files
ActivityTrain <- read.table("./train/y_train.txt", header = F) ###Reading Activity files

FeaturesTest <- read.table("./test/X_test.txt", header = F)###Read features files
FeaturesTrain <- read.table("./train/X_train.txt", header = F)###Read features files
##############################

SubjectTest <- read.table("./test/subject_test.txt", header = F)#Read subject files
SubjectTrain <- read.table("./train/subject_train.txt", header = F)#Read subject files

ActivityLabels <- read.table("./activity_labels.txt", header = F)####Read Activity Labels


FeaturesNames <- read.table("./features.txt", header = F) #####Read Feature Names

FeaturesData <- rbind(FeaturesTest, FeaturesTrain)#####Merg dataframes: Features Test&Train,Activity Test&Train, Subject Test&Train
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)


names(ActivityData) <- "ActivityN"####Renaming colums in ActivityData & ActivityLabels dataframes
names(ActivityLabels) <- c("ActivityN", "Activity")


Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2] ####Get factor of Activity names


names(SubjectData) <- "Subject"####Rename SubjectData columns

names(FeaturesData) <- FeaturesNames$V2#Rename FeaturesData columns using columns from FeaturesNames


DataSet <- cbind(SubjectData, Activity)###Create one large Dataset with only these variables: SubjectData,  Activity,  FeaturesData
DataSet <- cbind(DataSet, FeaturesData)




###Create New datasets by extracting only the measurements on the mean and standard deviation for each measurement
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet, select=DataNames)

#####Rename the columns of the large dataset using more descriptive activity names
names(DataSet)<-gsub("^t", "time", names(DataSet))
names(DataSet)<-gsub("^f", "frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))

####Create a second, independent tidy data set with the average of each variable for each activity and each subject
OtroDataSet<-aggregate(. ~Subject + Activity, DataSet, mean)
OtroDataSet<-OtroDataSet[order(OtroDataSet$Subject,OtroDataSet$Activity),]

#Save this tidy dataset to local file
write.table(SecondDataSet, file = "finaldata2.txt",row.name=FALSE)

