#' Get listing of stations based on location or time bounds
#' @description Obtain a data frame containing information on hourly
#' meteorological station by searching via a geographical bounding box and/or
#' via time bounds for data availability.
#' @param startyear the starting year for the collected data.
#' @param endyear the ending year for the collected data.
#' @param lower_lat the lower bound of the latitude for a bounding box.
#' @param upper_lat the upper bound of the latitude for a bounding box.
#' @param lower_lon the lower bound of the longitude for a bounding box.
#' @param upper_lon the upper bound of the longitude for a bounding box.
#' @import downloader
#' @examples
#' \dontrun{
#' # Obtain a data frame with all available met stations
#' get_ncdc_station_info()
#' 
#' # Get a listing of met stations within a geographical
#' # bounding box
#' get_ncdc_station_info(lower_lat = 49.000,
#'                       upper_lat = 49.500,
#'                       lower_lon = -123.500,
#'                       upper_lon = -123.000)
#'  
#' # List all stations with data available for the 2005
#' # and 2006 years
#' get_ncdc_station_info(startyear = 2005,
#'                       endyear = 2006)
#' }
#' @export get_ncdc_station_info

get_ncdc_station_info <- function(startyear = NULL,
                                  endyear = NULL,
                                  lower_lat = NULL,
                                  upper_lat = NULL,
                                  lower_lon = NULL,
                                  upper_lon = NULL){
  
  # Get hourly surface data history CSV from NOAA/NCDC FTP
  file <- "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv"
  
  repeat {
    suppressWarnings(download(file, "isd-history.csv"))
    if (file.info("isd-history.csv")$size > 0) { break }
  }
  
  # Read in the "isd-history" CSV file
  st <- read.csv("isd-history.csv")
  
  # Get formatted list of station names and elevations
  names(st)[c(3, 9)] <- c("NAME", "ELEV")
  st <- st[, -6]
  
  BEGIN <- END <- "begin_end"
  
  # Recompose the years from the data file
  st$BEGIN <- as.numeric(substr(st$BEGIN, 1, 4))
  st$END <- as.numeric(substr(st$END, 1, 4))
  
  # If no filtering is performed, return entire data frame
  if (is.null(c(startyear, endyear,
                lower_lat, upper_lat,
                lower_lon, upper_lon))){
    
    return(st)
  }
  
  # If filtering by year only
  if (!is.null(c(startyear, endyear)) &
      is.null(c(lower_lat, upper_lat,
                lower_lon, upper_lon))){
    
    st <- subset(st, BEGIN <= startyear &
                   END >= endyear)
    
    row.names(st) <- NULL
    
    return(st)
  }
  
  # If filtering by bounding box only
  if (is.null(c(startyear, endyear)) &
      !is.null(c(lower_lat, upper_lat,
                 lower_lon, upper_lon))){
    
    st <- subset(st, st$LON >= lower_lon & 
                   st$LON <= upper_lon &
                   st$LAT >= lower_lat &
                   st$LAT <= upper_lat)
    
    row.names(st) <- NULL
    
    return(st)
  }
  
  # If filtering by date and bounding box
  if (!is.null(c(startyear, endyear,
                 lower_lat, upper_lat,
                 lower_lon, upper_lon))){
    
    st <- subset(st, st$LON >= lower_lon & 
                   st$LON <= upper_lon &
                   st$LAT >= lower_lat &
                   st$LAT <= upper_lat &
                   BEGIN <= startyear &
                   END >= endyear)
    
    row.names(st) <- NULL
    
    return(st)
  }
}
