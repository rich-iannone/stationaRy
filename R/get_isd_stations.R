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
#' @import dplyr
#' 
#' @return Returns a data frame with 16 columns.
#' \describe{
#'   \item{usaf}{A character string identifying the fixed weather 
#'     station from the USAF Master Station Catalog.
#'     USAF is an acronym for United States Air Force.}
#'   \item{wban}{A character string for the fixed weather
#'     station NCDC WBAN identifier.  
#'     NCDC is an acronym for National Climatic Data Center. 
#'     WBAN is an acronym for Weather Bureau, Air Force and Navy.}
#'   \item{name}{A character string with the station name.}
#'   \item{country}{A character string with the two character country 
#'     code where the station is located. Not identical to \code{country_code}.}
#'   \item{state}{Character string of the two character abbreviation of a US 
#'     state (when applicable).}
#'   \item{lat}{Latitude (degrees) rounded to three decimal places.}
#'   \item{lon}{Longitude (degrees) rounded to three decimal places.}
#'   \item{elev}{Numeric value for the elevation as measured in meters. 
#'     The minimum value is -400 with a maximum of 8850. Elevation in feet
#'     can be approximated by \code{elev * 3.28084}}
#'   \item{begin}{The earliest year for which data are available.}
#'   \item{end}{The latest year for which data are available.}
#'   \item{gn_gmtoffset}{A time zone offset.}
#'   \item{rawoffset}{A time zone offset.  I'm not entirely sure how this 
#'     differs from \code{gn_gmtoffset}.}
#'   \item{time_zone_id}{Time zone identifier}
#'   \item{country_name}{Character string giving the name of the country 
#'     where the station is located.}
#'   \item{country_code}{A character string with the two character country 
#'     code where the station is located.  This is not identical to the 
#'     \code{country} column.  At first glance, this column appears to resemble
#'     the country more accurately than \code{country}.}
#' }
#' 
#' @source 
#' \url{http://www.ncdc.noaa.gov/isd}\cr
#' Source needed for column descriptions.
#' 
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
