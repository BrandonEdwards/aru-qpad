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
for (f in wac_files[1:5])
{
  print(paste0(i, "/", length(wac_files)))
  output_file <- gsub('.{1}$', 'v', f)
  if (file.exists(output_file))
  {
    next
  }
  system(paste0("src/functions/wac2wav.exe ", f,
                " ",
                output_file))
  wav_files <- c(wav_files, output_file)
  i <- i + 1
}

####### Output ####################################

write.table(data.frame(f = filenames),
            file = "data/generated/filenames_wav.csv",
            col.names = FALSE, row.names = FALSE, sep = ",")
