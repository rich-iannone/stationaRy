#' Get station IDs
#' @description Obtain the station IDs needed as input
#' for the \code{get_isd_station_data} function. 
#' @param stn_df a data frame of stations that is obtained
#' with (and often filtered by) the \code{get_isd_stations}
#' function.
#' @return Returns a character vector of length 
#' \code{nrow{stn_df}). 
#' @examples
#' \dontrun{
#' library(dplyr)
#' 
#' # Get a listing of all station IDs in France
#' df <- 
#'   get_isd_stations() %>% 
#'   filter(country == "FR")
#'  
#' # Get the related station IDs
#' ids <- get_station_ids(df)
#' 
#' # Get the data
#' get_isd_station_data(
#'   station_id = ids, 
#'   full_data = TRUE, 
#'   startyear = 2013, 
#'   endyear = 2014)
#' }
#' @importFrom tidyr unite_
#' @export get_station_ids
get_station_ids <- function(stn_df) {
  
  stn_df <- 
    tidyr::unite_(
      stn_df, 
      col = "station_id", 
      from = c("usaf", "wban"), 
      sep = "-")
  
  return(stn_df[[1]])
}
