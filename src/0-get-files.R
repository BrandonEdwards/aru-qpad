####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# 00-get-files.R
# Created February 2023
# Last Updated March 2023

####### Import Libraries and External Files #######

# Get command line arguments
#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)

####### Set Constants #############################

#' Definitely not my preferred way of doing things, but
#' because the data are huge, and more or less need to live
#' on a hard drive, I have to hard code some data paths

if (length(args) == 0)
{
  aru_path <- "E:/aru-data/"
}else
{
  aru_path <- args[1]
}
print(aru_path)
####### Read Data #################################

tags <- read.csv("data/raw/wildtrax_tags.csv"); names(tags)[1] <- "location"

# Undecided if I want to keep this so just commenting out for now
# if (file.exists("data/generated/filenames_wac.csv"))
# {
#   filenames <- as.vector(read.csv(file = "data/generated/filenames_wac.csv", header = FALSE)[,1])
# }else{
#   filenames <- vector(mode = "character", length = 0)
# }

filenames <- vector(mode = "character", length = 0)
dir_keys <- vector(mode = "character", length = 0)

####### Main Code #################################

# Add a column to the tags list to match tags with filenames
tags$dir_key <- paste0(tags$location, "-", tags$recordingDate)

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
    
    for (d in array_dirs)
    {
      recording_file <- paste0(proj_path, "/", d, "/", d, "_0+1_", date_string, ".wac")
      if (isFALSE(file.exists(recording_file)))
      {
        message(paste0("Could not find file ", recording_file))
      }
      if (isFALSE(recording_file %in% filenames))
      {
        filenames <- c(filenames, recording_file)
        dir_keys <- c(dir_keys, tags$dir_key[i])
      }
    }
    
  }
  
  #Commenting this line of code out to save for later
  # system(paste0("src/wac2wav/wac2wav.exe ", recording_file,
  #               " data/generated/test.wav"))
}

####### Output ####################################

write.table(data.frame(File = filenames, Key = dir_keys),
            file = "data/generated/filenames_wac.csv",
            row.names = FALSE, sep = ",")
