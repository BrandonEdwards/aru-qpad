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

####### Output ####################################