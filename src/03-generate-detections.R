####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# 03-generate-detections.R
# Created March 2023
# Last Updated April 2023

####### Import Libraries and External Files #######

library(locaR)
library(tuneR)
library(seewave)

####### Read Data #################################

filenames <- read.csv("data/generated/filenames_wav.csv")
tags <- read.csv("data/generated/tags.csv")

####### Main Code #################################
# Add array name column to tags (may not need this)
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

for (i in 1:nrow(tags))
{
  files <- filenames[which(filenames$Key == tags$dir_key[i]),]
  
  sounds <- vector(mode = "list", length = nrow(files))
  names(sounds) <- files$File
  j <- 1
  for (s in names(sounds))
  {
    Fs <- tuneR::readWave(filename = s, header = TRUE)$sample.rate
    sounds[[s]] <- tuneR::readWave(filename = s,
                                   from = tags$startTime[i],
                                   to = tags$startTime[i] + tags$tagLength[i],
                                   units = "seconds")@left
    png(paste0("data/generated/spectrograms/", j, ".png"))
    spectro(wave = sounds[[s]], f = Fs)
    dev.off()
    j <- j + 1
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
