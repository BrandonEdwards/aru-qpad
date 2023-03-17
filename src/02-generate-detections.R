####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# 02-generate-detections.R
# Created March 2023
# Last Updated March 2023

####### Import Libraries and External Files #######

library(locaR)

####### Read Data #################################

filenames <- as.vector(read.csv("data/generated/filenames_wav.csv", header = FALSE)[,1])
tags <- read.csv("data/raw/wildtrax_tags.csv"); names(tags)[1] <- "location"
stations <- read.csv("data/raw/station_locs.csv")

####### Main Code #################################


####### Output ####################################
