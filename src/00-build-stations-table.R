####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# src/00-build-stations-table.R
# Created December 2023
# Last Updated December 2023

####### Import Libraries and External Files #######

library(DBI)
library(RSQLite)

####### Read Data #################################

station_locs <- read.csv(file = "data/raw/station_locs.csv")

####### Main Code #################################

station_locs$Project <- sub("-.*", "", station_locs$Station)
sl_red <- station_locs[which(station_locs$Project %in% c("SBL", "SBT", "KIRB")), ]
sl_red$Site <- substr(sl_red$Station, 1, nchar(sl_red$Station) - 3)

sl_red_reordered <- sl_red[, c("Project", "Site", "Station", "Zone", "Easting", "Northing", "Elevation",
                               "Paired", "Type", "Channel")]

####### Output ####################################

db <- DBI::dbConnect(RSQLite::SQLite(),
                     "data/generated/recordings.db")

DBI::dbWriteTable(conn = db,
                 name = "stations",
                 value = sl_red_reordered,
                 overwrite = TRUE)
dbDisconnect(conn = db)
