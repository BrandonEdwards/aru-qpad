####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# 03-generate-spectograms.R
# Created March 2023
# Last Updated April 2023

####### Import Libraries and External Files #######

library(locaR)
library(tuneR)
library(seewave)
library(ggplot2)
library(ggpubr)
library(foreach)
library(doParallel)

####### Read Data #################################

args <- commandArgs(trailingOnly=TRUE)
filenames <- read.csv("data/generated/filenames_wav.csv")
tags <- read.csv("data/generated/tags.csv")

####### Main Code #################################

n_cores <- as.numeric(args[1])
cluster <- makeCluster(n_cores)
registerDoParallel(cluster)

foreach (i = 1:nrow(tags), .packages = c('tuneR', 'seewave', "ggplot2", "ggpubr")) %dopar%
{
  loc <- tags$location[i]
  tokens <- unlist(strsplit(loc, "-"))
  
  # First step is to build the file path to where this particular recording lives
  proj <- tokens[1]
  if (proj == "SBL")
  {
    mic_locations <- read.csv(paste0("data/generated/mic_locations/completed/",
                                     tags$array_name[i],
                                     ".csv"))
    files <- filenames[which(filenames$Key == tags$dir_key[i]),]
    
    sounds <- vector(mode = "list", length = nrow(files))
    names(sounds) <- files$File
    
    spec_plots <- vector(mode = "list", length = nrow(files))
    names(spec_plots) <- mic_locations$Station_Nonpadded#files$File
    
    j <- 1
    for (s in names(spec_plots))
    {
      file <- files[which(files$Station == s), "File"]
      sound <- tryCatch(
        {
          tuneR::readWave(filename = file,
                          from = tags$startTime[i],
                          to = tags$startTime[i] + tags$tagLength[i],
                          units = "seconds")@left
        },
        error = function (e) {
          #message(e)
          return(NULL)
        }
      )
      
      if (is.null(sound))
      {
        spec_plots[[s]] <- ggplot() + theme_void()
        next
      }else
      {
        Fs <- tuneR::readWave(filename = file, header = TRUE)$sample.rate
        spec_plots[[s]] <- ggspectro(sound, ovlp = 50, f = Fs) +
          stat_contour(geom="polygon", aes(fill=..level..), bins=30) +
          scale_fill_continuous(name="Amplitude\n(dB)\n", limits=c(-30,0), na.value="transparent") +#, low="white", high="black") +
          #theme_bw() +
          theme(legend.position = "none") +
          ggtitle(s) +
          NULL
      }
      
      j <- j + 1
    }
    
    mic_locations$order <- mic_locations$X + (mic_locations$Y - 1)*max(mic_locations$X)
    mic_locs_sorted <- mic_locations[order(mic_locations$order), ]
    spec_plots_sorted <- spec_plots[mic_locs_sorted$Station_Nonpadded]
    
    png(filename = paste0("data/generated/spectrograms/", i, ".png"),
        width = 10, height = 7, units = "in", res = 300)
    spectro_matrix <- ggarrange(plotlist = spec_plots_sorted,
                                ncol = max(mic_locations$X),
                                nrow = max(mic_locations$Y), 
                                common.legend = TRUE)
    print(annotate_figure(spectro_matrix, top = text_grob(tags$species[i])))
    
    dev.off()
  }
}

stopCluster(cluster)
