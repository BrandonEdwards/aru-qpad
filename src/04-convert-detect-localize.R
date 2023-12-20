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
  
  for (e in events)
  {
    if (e %in% events_being_processed)
    {
      next
    }else
    {
      indices_available <- which(events_being_processed == "")
      i <- min(indices_available)
      events_being_processed[i] <- e
    }
  }
  
  
}

####### Output ####################################