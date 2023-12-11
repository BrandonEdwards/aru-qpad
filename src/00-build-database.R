####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# src/00-build-database.R
# Created December 2023
# Last Updated December 2023

####### Import Libraries and External Files #######

library(DBI)
library(RSQLite)

####### Read Data #################################

station_locs <- read.csv(file = "data/raw/station_locs.csv")
kirb_files <- read.csv("data/raw/aru/BU_Public/BU/ARU/KIRB/KIRBfilelist.csv", header = FALSE)
sbt_files <- read.csv("data/raw/aru/BU_Public/BU/ARU/SBT/SBTfilelist.csv", header = FALSE)
sbl_files <- read.csv("data/raw/aru/BU_Public/BU/ARU/SBL/SBLfilelist.csv", header = FALSE)

####### Main Code #################################

# Create a connection to a database
db <- DBI::dbConnect(RSQLite::SQLite(),
                     "data/generated/localization.db")

station_locs$Project <- sub("-.*", "", station_locs$Station)
sl_red <- station_locs[which(station_locs$Project %in% c("SBL", "SBT", "KIRB")), ]
sl_red$Site <- substr(sl_red$Station, 1, nchar(sl_red$Station) - 3)

sl_red_reordered <- sl_red[, c("Project", "Site", "Station", "Zone", "Easting", "Northing", "Elevation",
                               "Paired", "Type", "Channel")]

DBI::dbWriteTable(conn = db,
                  name = "stations",
                  value = sl_red_reordered,
                  overwrite = TRUE)

####### Output ####################################