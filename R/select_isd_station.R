#' Select a single ISD station for data retrieval
#' @description After filtering the list of global meteorological stations
#' using \code{get_isd_stations} there may be several stations returned, 
#' so this function provides a means for selecting a single station from what 
#' may be a list of several stations.
#' @param stn_df a data frame of stations that is obtained with (and often
#' filtered by) the \code{get_isd_stations} function.
#' @param number the row number of the station listing for which station data 
#' should be returned.
#' @param name the partial name of the station for which station data should 
#' be returned.
#' 
#' @return Returns a data frame of ISD stations as documented in 
#'   \code{\link{get_isd_stations}}.
#'   
#' @seealso
#'   \code{\link{get_isd_stations}}
#'   
#' @examples 
#' \dontrun{
#' # Obtain a listing of all stations within a bounding box and
#' # then isolate a single station and obtain a string with the
#' # \code{USAF} and \code{WBAN} identifiers
#' stations_within_domain <-
#'   get_isd_stations(lower_lat = 49.000,
#'                    upper_lat = 49.500,
#'                    lower_lon = -123.500,
#'                    upper_lon = -123.000)
#'                    
#' cypress_bowl_snowboard_stn <-
#'   select_isd_station(stn_df = stations_within_domain,
#'                      name = "cypress bowl snowboard")
#' }
#' @export select_isd_station

select_isd_station <- function(stn_df,
                               number = NULL,
                               name = NULL){
  
  # Ensure that the search words for the station name are lowercase
  if (!is.null(name)){
    name <- tolower(name)
  }
  
  # If neither any number nor name provided, return NA
  if (is.null(number) & is.null(name)){
    
    message("No search terms provided.")
    
    return(NA)
  }
  
  # If just the number provided, create the 'station_id' string from
  # the USAF and WBAN from the row corresponding the the number
  if (!is.null(number) & is.null(name)){
    
    station_id <- paste0(stn_df[number,1], "-",
                         stn_df[number,2])
    
    return(station_id)
  }
  
  # If the name is provided, filter the data frame by that name
  if (!is.null(name)){
    
    station_name <- 
      gsub("  ", " ",
           tolower(as.character(as.data.frame(stn_df$name)[[1]])))
    
    re.escape <- function(strings){
      
      vals <- c("\\\\", "\\[", "\\]", "\\(", "\\)", 
                "\\{", "\\}", "\\^", "\\$", "\\*", 
                "\\+", "\\?", "\\.", "\\|")
      
      replace.vals <- paste0("\\\\", vals)
      
      for (i in seq_along(vals)){
        
        strings <- gsub(vals[i], replace.vals[i], strings)
      }
      
      strings
    }
    
    name <- re.escape(strings = name)
    
    any_matched_stations <- any(grepl(name, station_name))
    
    if (any_matched_stations == FALSE){
      
      message("No stations were matched with the supplied search term.")
      
      return(NA)
    }
    
    if (any_matched_stations == TRUE){
      
      number_of_matched_stations <-
        sum(grepl(name, station_name))
      
      if (number_of_matched_stations == 1){
        
        number <- which(grepl(name, station_name))
        
        station_id <- paste0(stn_df[number,1], "-",
                             stn_df[number,2])
        
        return(station_id)
      }
      
      if (number_of_matched_stations > 1){
        
        if (!is.null(number)){
          
          numbers <- which(grepl(name, station_name))
          
          stn_df <- stn_df[numbers, ]
          
          row.names(stn_df) <- NULL
          
          station_id <- paste0(stn_df[number,1], "-",
                               stn_df[number,2])
          
          return(station_id)
        }
        
        message("Several stations matched. Provide a more specific search term.")
        
        print(stn_df[which(grepl(name, station_name)),])
        
        return(NA)
      }
    }
  }
}
