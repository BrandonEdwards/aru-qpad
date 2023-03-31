####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# 03-generate-detections.R
# Created March 2023
# Last Updated March 2023

####### Import Libraries and External Files #######

library(locaR)
library(tuneR)
library(seewave)

####### Read Data #################################

filenames <- as.vector(read.csv("data/generated/filenames_wav.csv", header = FALSE)[,1])
tags <- read.csv("data/raw/wildtrax_tags.csv"); names(tags)[1] <- "location"

####### Main Code #################################

# Add array name column to tags
tags$array_name <- NULL
for (i in 1:nrow(tags))
{
  loc <- tags$location[i]
  tokens <- unlist(strsplit(loc, "-"))
  proj <- tokens[1]
  
  if (proj == "SBL")
  {
    tags$array_name[i] <- paste0(tokens[1], "-", tokens[2], "-", tokens[3])
  }
}

# Get list of mic locations for each project
mic_locations <- vector(mode = "list", length = length(unique(tags$array_name)))
names(mic_locations) <- unique(tags$array_name)
mic_matrix <- vector(mode = "list", length = length(unique(tags$array_name)))
names(mic_matrix) <- unique(tags$array_name)
for (m in names(mic_locations))
{
  temp <- read.csv(paste0("data/generated/mic_locations/completed/",
                          m,
                          ".csv"))
  mic_locations[[m]] <- temp
  
  temp_matrix <- matrix(nrow = max(temp$Y), ncol = max(temp$X))
  for (x in 1:max(temp$X))
  {
    for (y in 1:max(temp$Y))
    {
      temp_matrix[y,x] <- temp[which(temp$Y == y &
                                       temp$X == x),
                               "Station"]
    }
  }
  mic_matrix[[m]] <- temp_matrix
}

for (i in 1:nrow(tags))
{
  files <- filenames[which(grepl(tags$array[i], filenames, fixed = TRUE))]

  sounds <- vector(mode = "list", length = nrow(mic_locations[[tags$array_name[i]]]))
  names(sounds) <- paste0(substr(mic_locations[[tags$array_name[i]]]$Station, 1, 4),
                          substr(mic_locations[[tags$array_name[i]]]$Station, 6, 
                                 nchar(mic_locations[[tags$array_name[i]]]$Station)))
  
  for (s in names(sounds))
  {
    # This doesn't work, I need a way to just cross-reference tags to the appropriate file names
    sounds[[s]] <- tuneR::readWave(filename = files[which(grepl(s, files, fixed = TRUE))])
  }
  
}
















survey_list <- vector(mode = "list", length = nrow(coords_filenames))
names(survey_list) <- coords_filenames$project


for (i in 1:nrow(coords_filenames))
{
  dir.create(paste0("data/generated/surveys/",
                    coords_filenames$project[i]))
  survey <- setupSurvey(folder = paste0("data/generated/surveys/",
                                        coords_filenames$project[i]),
                        projectName = coords_filenames$project[i],
                        run = 1,
                        coordinatesFile = coords_filenames$filename[i],
                        siteWavsFolder = tempdir(),
                        date = '20200617', time = '091000', surveyLength = 7)  
}



st <- processSettings(settings = survey, getFilepaths = TRUE, types = 'wav')

####### Output ####################################
