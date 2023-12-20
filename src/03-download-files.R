####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# src/03-download-files.R
# Created December 2023
# Last Updated December 2023

####### Import Libraries and External Files #######

library(DBI)
library(RSQLite)

####### Set Constants #############################

aru_dir <- "data/raw/aru/BU_Public/"
db <- DBI::dbConnect(RSQLite::SQLite(),
                     "data/generated/recordings.db")

####### Read Data #################################

events <- dbGetQuery(conn = db,
                     statement = "SELECT DISTINCT Event FROM events")[,1]

####### Main Code #################################

for (e in events[1:10])
{
  sr_temp <- dbGetQuery(db,
                        paste0("SELECT * FROM events WHERE Event = \"", e, "\""))
  
  site <- unique(sr_temp$Site)

  event_dir_name <- paste0("data/temp_files/",
                           gsub(pattern = " ", replacement = "_", x = e), 
                           "/")
  
  dir.create(path = event_dir_name)
  
  for (i in 1:nrow(sr_temp))
  {
    if (as.logical(sr_temp$isDownloaded[i]))
    {
      next
    }else
    {
      new_filename <- paste0(event_dir_name, sr_temp$Station[i],
                             ifelse(sr_temp$isWAC[i],
                                    ".wac",
                                    ".wav"))
      
      # copy file from Nextcloud server to local
      system(paste0("cp ",
                    aru_dir, ifelse(grepl("\\$", sr_temp$File[i]),
                                    gsub("\\$", "\\\\$", sr_temp$File[i]),
                                    sr_temp$File[i]),
                    " ",
                    new_filename))
      
      q <- dbExecute(conn = db,
                  statement = paste0("UPDATE events SET isDownloaded = 1 WHERE Event = \"", e, 
                                     "\" AND Station = \"", sr_temp$Station[i], "\""))
      q <- dbExecute(conn = db,
                     statement = paste0("UPDATE events SET Local_File = \"", new_filename,
                                        "\" WHERE Event = \"", e, 
                                        "\" AND Station = \"", sr_temp$Station[i], "\""))
    }
    
  }
}

dbDisconnect(db)
