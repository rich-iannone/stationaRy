#' Get listing of stations based on location or time bounds
#' @description Obtain a data frame containing information on hourly meteorological station by searching via a geographical bounding box and/or via time bounds for data availability.
#' @param startyear the starting year for the collected data.
#' @param endyear the ending year for the collected data.
#' @param lower_lat the lower bound of the latitude for a bounding box.
#' @param upper_lat the upper bound of the latitude for a bounding box.
#' @param lower_lon the lower bound of the longitude for a bounding box.
#' @param upper_lon the upper bound of the longitude for a bounding box.
#' @import downloader
#' @export get_ncdc_station_info

get_ncdc_station_info <- function(startyear = NULL,
                                  endyear = NULL,
                                  lower_lat = NULL,
                                  upper_lat = NULL,
                                  lower_lon = NULL,
                                  upper_lon = NULL){
  
  if (is.null(startyear) | is.null(endyear)) {
    stop("Please enter starting and ending years for surface station data")
  }
  
  # Check whether 'startyear' and 'endyear' are both numeric
  if (!is.numeric(startyear) | !is.numeric(endyear)) {
    stop("Please enter numeric values for the starting and ending years")
  }
  
  # Check whether 'startyear' and 'endyear' are in the correct order
  if (startyear > endyear) {
    stop("Please enter the starting and ending years in the correct order")
  }
  
  # Check whether 'staryear' and 'endyear' are within set bounds
  if (startyear < 1892 | endyear < 1892 | 
      startyear > year(Sys.Date()) | endyear > year(Sys.Date())) {
    stop("Please enter the starting and ending years in the correct order")
  }
  
  # Get hourly surface data history CSV from NOAA/NCDC FTP
  file <- "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv"
  
  repeat {
    try(download(file, "isd-history.csv", quiet = TRUE))
    if (file.info("isd-history.csv")$size > 0) { break }
  }
  
  # Read in the "isd-history" CSV file
  st <- read.csv("isd-history.csv")
  
  # Get formatted list of station names and elevations
  names(st)[c(3, 9)] <- c("NAME", "ELEV")
  st <- st[, -6]
  
  # Recompose the years from the data file
  st$BEGIN <- as.numeric(substr(st$BEGIN, 1, 4))
  st$END <- as.numeric(substr(st$END, 1, 4))
  
  
  st <- subset(st, st$LON >= lower_long & 
                 st$LON <= upper_long &
                 st$LAT >= lower_lat &
                 st$LAT <= upper_lat &
                 BEGIN <= startyear &
                 END >= endyear)
  
  return(st)
}
