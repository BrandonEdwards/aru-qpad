####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# 999-sandbox.R
# Created October 2022
# Last Updated January 2023

####### Import Libraries and External Files #######

library(locaR) # currently not on CRAN
library(sf)
library(proj4)
library(ggplot2)

####### Read Data #################################

locs <- read.csv("data/raw/station_locs.csv")
tags <- read.csv("data/raw/wildtrax_tags.csv")

####### Testing Plotting ##########################

# Testing out plotting the locations of the stations
# Take just the first 50 locations, I'm pretty sure they are part of the same grid?

locs_red <- locs[810:824,]
# Convert UTM to Lat Lon 
zone <- locs_red$Zone[1]

proj4string <- paste0("+proj=utm +zone=",
                      zone,
                      " +north +ellps=WGS84 +datum=WGS84 +units=m +no_defs ")
  
projected <- proj4::project(locs_red[, c("Easting", "Northing")], 
                            proj4string,
                            inverse = TRUE)
lat_lon <- data.frame(lat = projected$y, lon = projected$x)

locs_red <- cbind(locs_red, lat_lon)
plot(locs_red$lon, locs_red$lat)
text(locs_red$lon, locs_red$lat,labels = locs_red$Station)

####### Output ####################################
