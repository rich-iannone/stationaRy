#' Get listing of ISD stations based on location or time bounds
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
#' @import dplyr
#' @examples
#' \dontrun{
#' # Obtain a data frame with all available met stations
#' get_isd_stations()
#' 
#' # Get a listing of all ISD met stations within a geographical
#' # bounding box
#' get_isd_stations(lower_lat = 49.000,
#'                  upper_lat = 49.500,
#'                  lower_lon = -123.500,
#'                  upper_lon = -123.000)
#'  
#' # List all ISD stations with data available for the 2005
#' # and 2006 years
#' get_isd_stations(startyear = 2005,
#'                  endyear = 2006)
#' }
#' @export get_isd_stations

get_isd_stations <- function(startyear = NULL,
                             endyear = NULL,
                             lower_lat = NULL,
                             upper_lat = NULL,
                             lower_lon = NULL,
                             upper_lon = NULL){
  
  gn_gmtoffset <- begin <- lon <- lat <- NA
  
  # Load the 'combined' data frame
  load(system.file("stations.rda", package = "stationaRy"))
  
  # Subset by those stations that have GMT offset values
  combined <- filter(combined, !is.na(gn_gmtoffset))
  
  # Set '-999.9' values for elevation to NA
  combined[which(combined$elev == -999.9), 8] <- NA
  
  # Transform data frame to a dplyr tbl
  combined <- as.tbl(combined)
  
  # If no filtering is performed, return entire data frame
  if (is.null(c(startyear, endyear,
                lower_lat, upper_lat,
                lower_lon, upper_lon))){
    
    return(combined)
  }
  
  # If filtering by year only
  if (!is.null(c(startyear, endyear)) &
      is.null(c(lower_lat, upper_lat,
                lower_lon, upper_lon))){
    
    combined <- 
      filter(combined, 
             begin <= startyear &
               end >= endyear)
    
    row.names(combined) <- NULL
    
    return(combined)
  }
  
  # If filtering by bounding box only
  if (is.null(c(startyear, endyear)) &
      !is.null(c(lower_lat, upper_lat,
                 lower_lon, upper_lon))){
    
    combined <- 
      filter(combined,
             lon >= lower_lon & 
               lon <= upper_lon &
               lat >= lower_lat &
               lat <= upper_lat)
    
    row.names(combined) <- NULL
    
    return(combined)
  }
  
  # If filtering by date and bounding box
  if (!is.null(c(startyear, endyear,
                 lower_lat, upper_lat,
                 lower_lon, upper_lon))){
    
    combined <- 
      filter(combined,
             lon >= lower_lon & 
               lon <= upper_lon &
               lat >= lower_lat &
               lat <= upper_lat &
               begin <= startyear &
               end >= endyear)
    
    row.names(combined) <- NULL
    
    return(combined)
  }
}
