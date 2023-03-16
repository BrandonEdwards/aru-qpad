####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# 01-convert-files.R
# Created March 2023
# Last Updated March 2023

####### Import Libraries and External Files #######

####### Set Constants #############################

####### Read Data #################################

wac_files <- as.vector(read.csv(file = "data/generated/filenames_wac.csv", header = FALSE)[,1])
if (file.exists("data/generated/filenames_wav.csv"))
{
  wav_files <- as.vector(read.csv(file = "data/generated/filenames_wav.csv", header = FALSE)[,1])
}else{
  wav_files <- vector(mode = "character", length = 0)
}

####### Main Code #################################

i <- 1
for (f in wac_files)
{
  print(paste0(i, "/", length(wac_files)))
  output_file <- gsub('.{1}$', 'v', f)
  output_file_sanitized <- gsub("\\$", "\\\\$", output_file)
  f_sanitized <- gsub("\\$", "\\\\$", f)
  if (output_file %in% wav_files)
  {
    i <- i + 1
    next
  }

  system(paste0("src/functions/wac2wav.exe ", f_sanitized,
                " ",
                output_file_sanitized))
  wav_files <- c(wav_files, output_file)

  write.table(data.frame(f = wav_files),
            file = "data/generated/filenames_wav.csv",
            col.names = FALSE, row.names = FALSE, sep = ",")

  i <- i + 1
}
