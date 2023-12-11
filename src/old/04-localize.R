####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# 04-localize.R
# Created April 2023
# Last Updated April 2023

####### Import Libraries and External Files #######

library(locaR)

####### Read Data #################################

filenames <- read.csv("data/generated/filenames_wav.csv")
tags <- read.csv("data/generated/tags.csv")[77,] #eventually will be entire dataset
detections <- read.csv("data/generated/detections.csv")

####### Main Code #################################

#' For now, just going to try for one (for conference purposes), 
#' and then will generalize

for (i in 1:1)#1:nrow(detections))
{
  detection <- detections[i,]
  stations <- unlist(as.vector(detection[,1:6]))
  files <- filenames[which(filenames$Station %in% stations),]
  files <- files[which(files$Key == tags[i, "dir_key"]), ]
  
  wl <- createWavList(paths = files$File,
                      names = stations,
                      from = detection$From,
                      to = detection$To,
                      buffer = 0.2)
  
  mic_locations <- read.csv(paste0("data/generated/mic_locations/completed/",
                                   tags$array_name[i],
                                   ".csv"))
  coordinates <- mic_locations[,c(ncol(mic_locations), 2,3,4,5)]
  names(coordinates)[1] <- "Station"
  row.names(coordinates) <- coordinates$Station
  crd <- coordinates[stations, ]
  
  output_folder <- "data/generated/localizations/"
  jpeg_name <- paste0(i, ".jpeg")
  
  loc <- localize(wavList = wl, coordinates = crd, locFolder = output_folder,
                  F_Low = detection$F_Low, F_High = detection$F_High, jpegName = jpeg_name, keep.SearchMap = T)
}

