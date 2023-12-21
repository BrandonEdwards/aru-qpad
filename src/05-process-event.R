####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# src/05-process-event.R
# Created December 2023
# Last Updated December 2023

####### Import Libraries and External Files #######

library(DBI)
library(RSQLite)

####### Read Data #################################

args <- commandArgs(trailingOnly=TRUE)

####### Main Code #################################

event <- gsub(pattern = "_", replacement = " ", x = args[1])
message(paste0("Now processing event ", event))

db <- DBI::dbConnect(RSQLite::SQLite(),
                     "data/generated/recordings.db")


isWAC <- dbGetQuery(conn = db,
                    paste0("SELECT isWAC FROM events WHERE Event = \"", event, "\""))[,1]
if (any(as.logical(isWAC)))
{
  # convert()
}

isDetected <- dbGetQuery(db,
                         paste0("SELECT isDetected FROM events WHERE Event = \"", 
                                event,
                                "\""))[,1]
if (any(isDetected == 0))
{
  dir_out <- paste0("data/temp_files/", args[1], "/")
  dir_string <- paste0(dir_out, "\\*.wav")
  files <- dbGetQuery(db,
                      paste0("SELECT Local_File FROM events WHERE Event = \"", 
                             event,
                             "\""))[,1]
  for (f in files)
  {
    system(paste("python3 src/detect.py", dir_string, dir_out))
  }
}

isLocalized <- dbGetQuery(db,
                          paste0("SELECT isLocalized FROM events WHERE Event = \"", 
                                 event,
                                 "\""))[,1]
if (any(isLocalized == 0))
{
  # Localize detected birds and output
}

# Change directory to DONE, or add a DONE file to it

dbDisconnect(db)

####### Output ####################################