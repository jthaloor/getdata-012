# run_analysis.R
# Mar 19 2015
# Jesse Thaloor
# Version 1.0

#Needed libraries
library(dplyr)
library(plyr)

#Constants
DATADIR <- "UCI HAR Dataset"
LOCALDATAFILE <- "getdata_prog.zip"
REMOTEDATAFILE <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"


# This function sets up the data we need to work on by downloading the file and unzipping it.
setup <- function() {

    # First start with a clean data directory
    if(file.exists(DATADIR)) {
        # remove the old data
        print("Cleaning up old data directories.")
        unlink(DATADIR,recursive = TRUE)
    }

    # Check if we have already downloaded the file (since this is a big file, we do not want to waste time if it exists)
    if( !  file.exists(LOCALDATAFILE)) {
        # file does not exist so download the file
        # Download ZIP file
        print("Downloading data file..")
        download.file(REMOTEDATAFILE,destfile=LOCALDATAFILE,method="curl")
    } else {
        print("Data file exists and will not be downloaded.")
    }
    # Unzip file
    print("Unzipping data file...")
    unzip(LOCALDATAFILE)
}

# Read the files necessary for each class and clean them-up dropping all columns that are not needed
# name = c(test,train)

readInputFilesByType <- function(name) {
    print(sprintf("Reading-in %s data..",name))
    # The three files we have to read. The X_<name>.txt, y_<name>.txt and subject_<name>.txt
    xdata <- sprintf("%s/%s/X_%s.txt",DATADIR,name,name)
    ydata <- sprintf("%s/%s/y_%s.txt",DATADIR,name,name)
    subjects <- sprintf("%s/%s/subject_%s.txt",DATADIR,name,name)
    # Read in first datafile
    data1 <- read.table(xdata,header=FALSE)
    # read in labels
    data2 <- read.table(ydata,header=FALSE)
    # read in subjects
    data3 <- read.table(subjects,header=FALSE)
    # Add a class column to show if the data is test or train.
    # add the subject and activity to the end becuase we need to separate out the std,mean later
    # return a data_table object
    return(tbl_df(cbind(data1,group=rep(name,nrow(data2)),activity=as.factor(data2$V1),subject=as.factor(data3$V1))))
}

#get data from the features.txt file.
getFeatures <- function() {
    # extract columns you need. You get this from the features.txt file
    features <- tbl_df(read.table(sprintf("%s/%s",DATADIR,"features.txt"),header=F,stringsAsFactors=F))
    # Just get the mean and std rows
    features <- features[grep("-(std|mean)\\(",features$V2),]
    # remove the unneccesary parathesis in the col name
    features$V2 <- gsub("[()]","",features$V2)
    return(features)
}

# Read the activities.txt file and return all the activities
getActivities <- function() {
    # Read-in activity table
    activities  <- tbl_df(read.table(sprintf("%s/%s",DATADIR,"activity_labels.txt"),header=F,stringsAsFactors=F))
    names(activities) <- c("label","activity")
    return(activities)
}


# first get the data and unzip if required
setup()

# merge the test and train data together into a new table tidyData
tidyData<-rbind(readInputFilesByType("test"),readInputFilesByType("train"))

# filtered only the columns required and rename all column headers with proper names
neededColsTable <- getFeatures()
numColsInData <- ncol(tidyData)
tidyData<- tidyData[,c(neededColsTable$V1,((numColsInData-2):numColsInData))]
numCols <- nrow(neededColsTable)
names(tidyData)[1:numCols] <- c(neededColsTable$V2)

# change activity to descriptive name
activities <- getActivities()
# use mapvalues from ddply to swap factors with actual names
tidyData$activity <- mapvalues(tidyData$activity,levels(tidyData$activity),activities$activity)

# Create a new table of means of means and stds
tidyData2 <- ddply(tidyData, .(subject, activity), function(x) colMeans(x[,1:66]))
#rename all headers to mean(<old_header>)
names(tidyData2)[3:ncol(tidyData2)] <- sapply(names(tidyData2)[3:ncol(tidyData2)],function(x) sprintf("mean(%s)",x))
# write outout to a file called project_final.txt
write.table(tidyData2,file="project_final.txt",row.names=FALSE)

