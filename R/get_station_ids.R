#' Get station ids
#' @description Obtain the station ids needed as input for the \code{get_isd_station_data} function. 
#' @param stn_df a data frame of stations that is obtained with (and often
#' filtered by) the \code{get_isd_stations} function.
#' @importFrom tidyr unite_
#' 
#' @return Returns a character vector of length \code{nrow{stn_df}). 
#' 
#' @examples
#' \dontrun{
#' # Get the listing of all ISD met stations in France
#' library(dplyr)
#' df = get_isd_stations() %>% 
#'   filter(country=="FR")
#'  
#' # Get the related station ids
#' ids = get_station_ids(df)
#' 
#' # Get the data 
#' get_isd_station_data(station_id = ids, 
#'                      full_data = TRUE, 
#'                      startyear = 2013, 
#'                      endyear = 2014)

#' }
#' @export get_station_ids
#'
get_station_ids <-
function(stn_df)
{
  stn_df = tidyr::unite_(stn_df, col = "station_id", from = c("usaf", "wban"), sep = "-")
  return(stn_df[[1]])
}
