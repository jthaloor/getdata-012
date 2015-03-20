README.md
The included program run_analysis.R is used to create a tody data set that 
shows the means of underlying metrics as described in the file codebook.txt.

run_analysis.R is well documented but here is a brief description of the overall
code.

run_analysis uses some functions within the script. These are described below
setup() is a function that make sure we have the data and if not downloads the file for analysis.
readInputFilesByType(name) is function that takes "test" or "train" as input and combines all the underlying data into a single table.
getFeatures() - Returns a table with the features (variables) in each table that is needed for this assignment. It filters the column names by "std" or "mean".
getActivities() - returns the table of activities. 

The main portion of the script does the following;
1) calls setup() to make sure all input data exists
2) calls readInputFilesByType twice each with a "train" or "test" and combines the data into a single "tinyData" table
3) Next tinyData is reduced by removing all unneccary columns by using the getFeatures() function
4) Then the column names are updated in tinyData
5) The activity column in tinyData is remapped to actual activity name using the mapvalues function.
6) A new table tidyData2 is created with the means of the columns grouped by subeject and activity.
7) tinyData2 is written to disk file "project_final.txt".


