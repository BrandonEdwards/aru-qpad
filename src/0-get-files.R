####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# 00-get-files.R
# Created February 2023
# Last Updated February 2023

####### Import Libraries and External Files #######

library(magrittr)

####### Set Constants #############################

#' Definitely not my preferred way of doing things, but
#' because the data are huge, and more or less need to live
#' on a hard drive, I have to hard code some data paths
aru_path <- "E:/aru-data/"

####### Read Data #################################

tags <- read.csv("data/raw/wildtrax_tags.csv"); names(tags)[1] <- "location"

####### Main Code #################################

filenames <- vector(mode = "character", length = 0)

for (i in 1:nrow(tags))
{
  loc <- tags$location[i]
  tokens <- unlist(strsplit(loc, "-"))
  
  # First step is to build the file path to where this particular recording lives
  proj <- tokens[1]
  if (proj == "SBL")
  {
    proj_path <- paste0(aru_path, proj, "/2017/V1/",
                        proj, "-", tokens[2], "-", tokens[3])
  }
  array_dirs <- list.files(proj_path)
  if (!any(array_dirs == loc))
  {
    message(paste0("Could not find ", loc, " in ", proj_path, ".\n"))
    next
  }
  date_string <- gsub(" ", "$", tags$recordingDate[i])
  date_string <- gsub("-", "", date_string)
  date_string <- gsub(":", "", date_string)
  date_string <- sub('.', '', date_string)
  
  recording_file <- paste0(proj_path, "-", tokens[4], "/",
                           loc, "_0+1_", date_string, ".wac")
  
  system(paste0("src/wac2wav/wac2wav.exe ", recording_file,
                " data/generated/test.wav"))
}

####### Output ####################################
