#' Display a maps of selected stations from the ISD dataset
#' @description Display a map of selected meteorological stations
#' from the NCEI Integrated Surface Dataset (ISD).
#' @param stations a data frame with station data, typically subset from the
#' data frame provided by the \code{get_isd_stations} function.
#' @import dplyr
#' @importFrom leaflet leaflet addTiles addCircles clearBounds
#' @return a Leaflet map in the RStudio Viewer
#' @examples
#' \dontrun{
#' library(magrittr)
#' 
#' # Select stations using a bounding box and map the stations
#' get_isd_stations(lower_lat = 49.000,
#'                  upper_lat = 49.500,
#'                  lower_lon = -123.500,
#'                  upper_lon = -123.000) %>%
#'   map_isd_stations()
#' }
#' @export map_isd_stations

map_isd_stations <- function(stations){
  
  if (!inherits(stations, "tbl_df")) leaflet() %>% addTiles()
  
  if (inherits(stations, "tbl_df")){
    
    popup <- 
      paste0(stations$name, "<br>",
             ifelse(is.na(stations$country_code),
                    "", stations$country_code),
             " ",
             ifelse(is.na(stations$iso3166_2_subd),
                    "", stations$iso3166_2_subd),
             "<br>",
             ifelse(is.na(stations$begin),
                    "", stations$begin),
             " - ",
             ifelse(is.na(stations$end),
                    "", stations$end))
    
    leaflet() %>% addTiles() %>%
      addCircles(lng = stations$lon,
                 lat = stations$lat,
                 opacity = 0.3,
                 popup = popup) %>%
      clearBounds()
  }
}
