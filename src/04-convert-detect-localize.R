####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# src/04-convert-detect-localize.R
# Created December 2023
# Last Updated December 2023

####### Import Libraries and External Files #######

library(DBI)
library(RSQLite)

####### Set Constants #############################

# db <- DBI::dbConnect(RSQLite::SQLite(),
#                      "data/generated/recordings.db")
n_cores <- 5

####### Main Code #################################

events_being_processed <- vector(mode = "character", length = n_cores)

run <- TRUE
while(run)
{
  dirs <- list.dirs(path = "data/temp_files/", recursive = FALSE,
                    full.names = FALSE)
  events <- gsub(pattern = "_", replacement = " ", x = dirs)
  
  #' Check for "DONE" events. I.e., once localization is finished, the directories
  #' should be renamed DONE_event. If DONE events are in the directory, this event
  #' should be removed from the events_being_processed list, thereby freeing up a space
  #' for another event to be processed.
  
  
  for (e in events)
  {
    if (grepl(pattern = "DONE", x = e))
    {
      actual_event <- substr(e, start = 6, stop = nchar(e))
      events_being_processed[which(events_being_processed == actual_event)] <- ""
      # move this directory to a "DONE" subdir?
      next
    }
    if (e %in% events_being_processed)
    {
      next
    }else
    {
      indices_available <- which(events_being_processed == "")
      i <- min(indices_available)
      events_being_processed[i] <- e
      
      # Spawn new process that does the conversions and whatnot
    }
  }
  
  
}

####### Output ####################################