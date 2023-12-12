####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# src/01-build-recordings-table.R
# Created December 2023
# Last Updated December 2023

####### Import Libraries and External Files #######

library(DBI)
library(RSQLite)

####### Read Data #################################

if (!file.exists("data/raw/KIRBfilelist.csv"))
{
  kirb_files <- read.csv("data/raw/aru/BU_Public/BU/ARU/KIRB/KIRBfilelist.csv", header = FALSE)
  write.table(kirb_files, file = "data/raw/KIRBfilelist.csv", col.names = FALSE, row.names = FALSE,
              sep = ",")
}else
{
  kirb_files <- read.csv("data/raw/KIRBfilelist.csv", header = FALSE)
}

if (!file.exists("data/raw/SBTfilelist.csv"))
{
  sbt_files <- read.csv("data/raw/aru/BU_Public/BU/ARU/SBT/SBTfilelist.csv", header = FALSE)
  write.table(sbt_files, file = "data/raw/SBTfilelist.csv", col.names = FALSE, row.names = FALSE,
              sep = ",")
}else
{
  sbt_files <- read.csv("data/raw/SBTfilelist.csv", header = FALSE)
}

if (!file.exists("data/raw/SBLfilelist.csv"))
{
  sbl_files <- read.csv("data/raw/aru/BU_Public/BU/ARU/SBL/SBLfilelist.csv", header = FALSE)
  write.table(sbl_files, file = "data/raw/SBLfilelist.csv", col.names = FALSE, row.names = FALSE,
              sep = ",")
}else
{
  sbl_files <- read.csv("data/raw/SBLfilelist.csv", header = FALSE)
}

####### SBL Files #################################

# Create empty data frame
sbl_out <- data.frame(Station = NA, 
                      File = NA, 
                      Date = NA,
                      isWAC = NA,
                      isDownloaded = rep(FALSE, nrow(sbl_files)),
                      isConverted = rep(FALSE, nrow(sbl_files)),
                      isDetected = rep(FALSE, nrow(sbl_files)),
                      isLocalized = rep(FALSE, nrow(sbl_files)))

# Change backslash to forward slash and get rid of Z:/
sbl_files[,1] <- gsub("\\\\", "/", sbl_files[,1])
sbl_out$File <- substr(sbl_files[,1], start = 4, stop = nchar(sbl_files[,1]))

# Reformat station names to match station locations table/file
station <- sapply(strsplit(sbl_out$File, split = "/"),
                  `[`, 
                  7)
station_toks <- strsplit(station, split = "-")
sbl_out$Station <- paste0(sapply(station_toks, `[`, 1), "-",
                            formatC(as.integer(sapply(station_toks, `[`, 2)),
                                    width = 4, 
                                    format = "d", 
                                    flag = "0"), "-",
                            sapply(station_toks, `[`, 3), "-",
                            formatC(as.integer(sapply(station_toks, `[`, 4)),
                                    width = 2, 
                                    format = "d", 
                                    flag = "0"))

# Extract the time and the date out of each recording
time_date <- sapply(strsplit(sbl_out$File, split = "\\+"),
                    `[`,
                    2)
# Figure out whether it's a wac file while we're at it
sbl_out$isWAC <- grepl(".wac", time_date, fixed = TRUE)
sbl_out$isConverted <- !sbl_out$isWAC

# Dealing with annoying inconsistencies in naming

time_date <- strsplit(time_date, split = c("_", "\\_ |\\$"))
