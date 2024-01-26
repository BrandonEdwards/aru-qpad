####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# src/02-build-events-table.R
# Created December 2023
# Last Updated January 2024

####### Import Libraries and External Files #######

library(DBI)
library(RSQLite)

####### Read Data #################################
db <- DBI::dbConnect(RSQLite::SQLite(),
                     "data/generated/recordings.db")
stations <- dbGetQuery(conn = db,
                       statement = "SELECT * FROM stations")
recordings <- dbGetQuery(conn = db,
                         statement = "SELECT * FROM recordings")

####### Main Code #################################

# Link up each recording with their respective project information
stations_recordings <- merge(stations, recordings, by = "Station")

# Create a unique key for each localization "event"
stations_recordings$Event <- paste0(stations_recordings$Site, "-",
                                    as.POSIXct(stations_recordings$Date, origin = "1970-01-01"))

# Filter out events that only have fewer than 4 receivers being used
num_events <- as.data.frame(table(stations_recordings$Event))
names(num_events) <- c("Event", "Freq")
num_events <- num_events[-which(num_events$Freq < 4), ]
stations_recordings_red <- stations_recordings[which(stations_recordings$Event %in%
                                                       num_events$Event), ]
stations_recordings_red$Local_File <- NA

####### Output ####################################

db <- DBI::dbConnect(RSQLite::SQLite(),
                     "data/generated/recordings.db")

DBI::dbWriteTable(conn = db,
                  name = "events",
                  value = stations_recordings_red,
                  overwrite = TRUE)
dbDisconnect(conn = db)
