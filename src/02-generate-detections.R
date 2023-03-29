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

# Create file list for each project's coordinates
coords_filenames <- data.frame(project = unique(tags$array_name),
                               filename = NA)
i <- 1
for (p in coords_filenames$project)
{
  if (grepl("SBL", p, fixed = TRUE))
  {
    p_mod <- p
    stringi::stri_sub(p_mod, 5, 4) <- "0"
    coords <- stations[which(grepl(p_mod, stations$Station, fixed = TRUE)), ]
    f <- tempfile()
    coords_filenames$filename[i] <- f
    coords <- coords[, 1:5]
    write.table(coords, file = f,
                row.names = FALSE, sep = ",")
  }
  i <- i + 1
}

#' * for each project:
#'   * create a new survey

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
