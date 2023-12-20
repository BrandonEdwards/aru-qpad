####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# src/04-event-handler.R
# Created December 2023
# Last Updated December 2023

####### Import Libraries and External Files #######

library(DBI)
library(RSQLite)

####### Set Constants #############################

db <- DBI::dbConnect(RSQLite::SQLite(),
                     "data/generated/recordings.db")
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
    }else{
      # Check if all files in event are downloaded
      isDownloaded <- dbGetQuery(db,
                                 paste0("SELECT isDownloaded FROM events WHERE Event = \"",
                                 e,
                                 "\""))[,1]
      
      if (all(as.logical(isDownloaded)))
      {
        indices_available <- which(events_being_processed == "")
        
        if (length(indices_available) != 0)
        {
          i <- min(indices_available)
          events_being_processed[i] <- e   
          
          system(paste0("Rscript src/05-process-event.R ",
                        gsub(pattern = " ", replacement = "_", x = e), 
                        " &"))
          
        }
      }
    }
  }
}
