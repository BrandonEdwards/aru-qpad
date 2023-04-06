####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# 01-convert-files.R
# Created March 2023
# Last Updated March 2023

####### Import Libraries and External Files #######

####### Set Constants #############################

####### Read Data #################################

wac_df <- read.csv(file = "data/generated/filenames_wac.csv")
# Commenting for same reason as in 0-get-files.R
# if (file.exists("data/generated/filenames_wav.csv"))
# {
#   wav_files <- as.vector(read.csv(file = "data/generated/filenames_wav.csv", header = FALSE)[,1])
# }else{
#   wav_files <- vector(mode = "character", length = 0)
# }
wav_files <- vector(mode = "character", length = 0)
dir_keys <- vector(mode = "character", length = 0)
####### Main Code #################################

i <- 1
wac_files <- wac_df$File
for (f in wac_files)
{
  print(paste0(i, "/", length(wac_files)))
  output_file <- gsub('.{1}$', 'v', f)
  output_file_sanitized <- gsub("\\$", "\\\\$", output_file)
  f_sanitized <- gsub("\\$", "\\\\$", f)
  if (file.exists(output_file))
  {
    i <- i + 1
    next
  }

  system(paste0("src/functions/wac2wav.exe ", f_sanitized,
                " ",
                output_file_sanitized))
  wav_files <- c(wav_files, output_file)
  dir_keys <- c(dir_keys, wac_df$Key[i])
  

  write.table(data.frame(File = wav_files, Key = dir_keys),
            file = "data/generated/filenames_wav.csv",
            row.names = FALSE, sep = ",")

  i <- i + 1
}
