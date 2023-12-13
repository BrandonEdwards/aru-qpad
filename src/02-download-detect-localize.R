####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# src/02-download-detect-localize.R
# Created December 2023
# Last Updated December 2023

####### Import Libraries and External Files #######

####### Read Data #################################

stations <- read.csv("data/generated/stations.csv")
recordings <- read.csv("data/generated/recordings.csv")

####### Main Code #################################

# Link up each recording with their respective project information
stations_recordings <- merge(stations, recordings, by = "Station")

# Create a unique key for each localization "event"
stations_recordings$Event <- paste0(stations_recordings$Site, "-",
                                  stations_recordings$Date)

# Filter out events that only have fewer than 4 receivers being used
num_events <- as.data.frame(table(stations_recordings$Event))
num_events <- num_events[-which(num_events$Freq < 4), ]
stations_recordings_red <- stations_recordings[which(stations_recordings$Event %in%
                                                       num_events$Var1), ]
