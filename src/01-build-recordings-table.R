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
# First change all underscores in the date-time section into a dollar sign
sbl_files_mod <- sbl_out$File
substring(sbl_files_mod, nchar(sbl_files_mod) - 10, nchar(sbl_files_mod) - 10) <- "$"
time_date <- strsplit(sbl_files_mod, split = "\\$")
time <- sapply(time_date, `[`, 2)
date <- sapply(time_date, `[`, 1)
date <- sapply(strsplit(date, split = "_"), `[`, 3)

# Figure out whether it's a wac file while we're at it
sbl_out$isWAC <- grepl(".wac", time, fixed = TRUE)
sbl_out$isConverted <- !sbl_out$isWAC

# Now properly format
time <- sapply(strsplit(time, split = "\\."), `[`, 1)
sbl_out$Date <- as.POSIXct(paste0(date, time), 
                        format = "%Y%m%d%H%M%S")

####### SBT Files #################################

# Create empty data frame
sbt_out <- data.frame(Station = NA, 
                      File = NA, 
                      Date = NA,
                      isWAC = NA,
                      isDownloaded = rep(FALSE, nrow(sbt_files)),
                      isConverted = rep(FALSE, nrow(sbt_files)),
                      isDetected = rep(FALSE, nrow(sbt_files)),
                      isLocalized = rep(FALSE, nrow(sbt_files)))

# Change backslash to forward slash and get rid of Z:/
sbt_files[,1] <- gsub("\\\\", "/", sbt_files[,1])
sbt_out$File <- substr(sbt_files[,1], start = 4, stop = nchar(sbt_files[,1]))

# We only want 2016 data from SBT so filter out non 2016
year <- sapply(strsplit(sbt_out$File, split = "/"),
               `[`,
               4)
indices_to_keep <- which(year == "2016")
sbt_out <- sbt_out[indices_to_keep,]

# Reformat station names to match station locations table/file
station <- sapply(strsplit(sbt_out$File, split = "/"),
                  `[`, 
                  7)
station_toks <- strsplit(station, split = "-")
sbt_out$Station <- paste0(sapply(station_toks, `[`, 1), "-",
                          formatC(as.integer(sapply(station_toks, `[`, 2)),
                                  width = 2, 
                                  format = "d", 
                                  flag = "0"), "-",
                          formatC(as.integer(sapply(station_toks, `[`, 3)),
                                  width = 2, 
                                  format = "d", 
                                  flag = "0"), "-",
                          formatC(as.integer(sapply(station_toks, `[`, 4)),
                                  width = 2, 
                                  format = "d", 
                                  flag = "0"))

# Extract the time and the date out of each recording
# First change all underscores in the date-time section into a dollar sign
sbt_files_mod <- sbt_out$File
substring(sbt_files_mod, nchar(sbt_files_mod) - 10, nchar(sbt_files_mod) - 10) <- "$"
time_date <- strsplit(sbt_files_mod, split = "\\$")
time <- sapply(time_date, `[`, 2)
date <- sapply(time_date, `[`, 1)
date <- strsplit(date, split = "_")
date <- sapply(date, tail, 1)

# Figure out whether it's a wac file while we're at it
sbt_out$isWAC <- grepl(".wac", time, fixed = TRUE)
sbt_out$isConverted <- !sbt_out$isWAC

# Now properly format
time <- sapply(strsplit(time, split = "\\."), `[`, 1)
sbt_out$Date <- as.POSIXct(paste0(date, time), 
                           format = "%Y%m%d%H%M%S")

####### KIRB Files ################################

# Create empty data frame
kirb_out <- data.frame(Station = NA, 
                      File = NA, 
                      Date = NA,
                      isWAC = NA,
                      isDownloaded = rep(FALSE, nrow(kirb_files)),
                      isConverted = rep(FALSE, nrow(kirb_files)),
                      isDetected = rep(FALSE, nrow(kirb_files)),
                      isLocalized = rep(FALSE, nrow(kirb_files)))

# Change backslash to forward slash and get rid of Z:/
kirb_files[,1] <- gsub("\\\\", "/", kirb_files[,1])
kirb_out$File <- substr(kirb_files[,1], start = 4, stop = nchar(kirb_files[,1]))

# Reformat station names to match station locations table/file
station <- sapply(strsplit(kirb_out$File, split = "/"),
                  `[`, 
                  6)
station_toks <- strsplit(station, split = "-")
kirb_out$Station <- paste0(sapply(station_toks, `[`, 1), "-",
                          formatC(as.integer(sapply(station_toks, `[`, 2)),
                                  width = 3, 
                                  format = "d", 
                                  flag = "0"))

# Extract the time and the date out of each recording
# First change all underscores in the date-time section into a dollar sign
kirb_files_mod <- kirb_out$File
substring(kirb_files_mod, nchar(kirb_files_mod) - 10, nchar(kirb_files_mod) - 10) <- "$"
time_date <- strsplit(kirb_files_mod, split = "\\$")
time <- sapply(time_date, `[`, 2)
date <- sapply(time_date, `[`, 1)
date <- strsplit(date, split = "_")
date <- sapply(date, tail, 1)

# Figure out whether it's a wac file while we're at it
kirb_out$isWAC <- grepl(".wac", time, fixed = TRUE)
kirb_out$isConverted <- !kirb_out$isWAC

# Now properly format
time <- sapply(strsplit(time, split = "\\."), `[`, 1)
kirb_out$Date <- as.POSIXct(paste0(date, time), 
                           format = "%Y%m%d%H%M%S")

####### Output ####################################

# Create a connection to a database
db <- DBI::dbConnect(RSQLite::SQLite(),
                     "data/generated/localization.db")
DBI::dbWriteTable(conn = db,
                  name = "recordings",
                  value = rbind(sbt_out, sbl_out, kirb_out),
                  overwrite = TRUE)
dbDisconnect(conn = db)
