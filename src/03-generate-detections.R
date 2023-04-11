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
library(ggplot2)

####### Read Data #################################

filenames <- read.csv("data/generated/filenames_wav.csv")
tags <- read.csv("data/generated/tags.csv")

####### Main Code #################################

for (i in 1:nrow(tags))
{
  mic_locations <- read.csv(paste0("data/generated/mic_locations/completed/",
                                   tags$array_name[i],
                                   ".csv"))
  files <- filenames[which(filenames$Key == tags$dir_key[i]),]
  
  sounds <- vector(mode = "list", length = nrow(files))
  names(sounds) <- files$File
  
  spec_plots <- vector(mode = "list", length = nrow(files))
  names(spec_plots) <- files$File
  
  j <- 1
  for (s in names(sounds))
  {
    sounds[[s]] <- tryCatch(
      {
        tuneR::readWave(filename = s,
                        from = tags$startTime[i],
                        to = tags$startTime[i] + tags$tagLength[i],
                        units = "seconds")@left
      },
      error = function(e) {
        message(e)
        return(list(NULL))
      }
    )
    # sounds[[s]] <- tuneR::readWave(filename = s,
    #                                from = tags$startTime[i],
    #                                to = tags$startTime[i] + tags$tagLength[i],
    #                                units = "seconds")@left
    if (length(sounds[[s]]) == 1)
      next
    
    Fs <- tuneR::readWave(filename = s, header = TRUE)$sample.rate
    png(paste0("data/generated/spectrograms/", j, ".png"))
    
    spec_plot <- ggspectro(sounds[[s]], ovlp = 50, f = Fs) +
      stat_contour(geom="polygon", aes(fill=..level..), bins=30) +
      scale_fill_continuous(name="Amplitude\n(dB)\n", limits=c(-30,0), na.value="transparent") +#, low="white", high="black") +
      #theme_bw() +
      NULL
    
    #spectro(wave = sounds[[s]], f = Fs)
    print(spec_plot)
    dev.off()
    j <- j + 1
  }
  
}


# need to test for lengths=0 to account for null list entries!!




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
