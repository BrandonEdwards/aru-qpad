####### Script Information ########################
# Brandon P.M. Edwards
# aru-qpad
# 02-generate-mic-array_files.R
# Created March 2023
# Last Updated April 2023

####### Import Libraries and External Files #######

#library(sf)
library(proj4)
library(ggplot2)
library(stringi)

####### Read Data #################################

tags <- read.csv("data/generated/tags.csv")
stations <- read.csv("data/raw/station_locs.csv")

####### Main Code #################################

i <- 1
for (p in unique(tags$array_name))
{
  if (grepl("SBL", p, fixed = TRUE))
  {
    p_mod <- p
    stringi::stri_sub(p_mod, 5, 4) <- "0"
    coords <- stations[which(grepl(p_mod, stations$Station, fixed = TRUE)), ]

    # Convert UTM to Lat Lon 
    zone <- coords$Zone[1]
    
    proj4string <- paste0("+proj=utm +zone=",
                          zone,
                          " +north +ellps=WGS84 +datum=WGS84 +units=m +no_defs ")
    
    projected <- proj4::project(coords[, c("Easting", "Northing")], 
                                proj4string,
                                inverse = TRUE)
    lat_lon <- data.frame(lat = projected$y, lon = projected$x)
    
    lat_lon <- cbind(lat_lon, Station = coords$Station)
    
    # Write the coordinates file
    f_coords <- paste0("data/generated/mic_coordinates/", p, ".csv")
    f_loc_png <- paste0("data/generated/mic_locations/", p, ".png")
    f_loc_csv <- paste0("data/generated/mic_locations/", p, ".csv")
    write.table(coords, file = f_coords,
                row.names = FALSE, sep = ",")
    
    # Write the csv location file, to be modified later
    coords_matrix <- coords
    coords_matrix$Y <- NA
    coords_matrix$X <- NA
    #' Because of mismatches in file naming conventions, we need a separate
    #' station name entry that does not have padded zeroes. Ugh.
    stations_nonpadded <- paste0(rep(p, times = nrow(coords)),
                                 "-",
                                 seq(1, nrow(coords)))
    coords_matrix$Station_Nonpadded <- stations_nonpadded
    
    write.table(coords_matrix, file = f_loc_csv,
                row.names = FALSE, sep = ",")
    
    # Output the plot
    png(filename = f_loc_png, width = 6, height = 4, units = "in", res = 300)
    plot(lat_lon$lon, lat_lon$lat)
    text(lat_lon$lon, lat_lon$lat,labels = lat_lon$Station, cex = 0.5)
    dev.off()
    
  }
  i <- i + 1
}
