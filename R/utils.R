data_base_url <- function() {
  "https://www1.ncdc.noaa.gov/pub/data/noaa"
}

empty_met_tbl <- function() {
  
  dplyr::tibble(
    id = NA_character_,
    time = lubridate::ymd_hms("1970-01-01 00:00:00"),
    wd = NA_integer_,
    ws = NA_real_,
    ceil_hgt = NA_integer_,
    temp = NA_real_,
    dew_point = NA_real_,
    atmos_pres = NA_real_,
    rh = NA_real_
  )[-1, ]
}

get_tz_for_station <- function(station_id) {
  
  # Get the tz name in the local `history_tbl`
  station_info <- 
    history_tbl %>%
    dplyr::filter(id == station_id)
  
  # If it isn't found, try to get the tz name
  # from the remote `history_tbl`
  if (nrow(station_info) == 0) {
    station_info <- 
      get_history_tbl(perform_tz_lookup = TRUE) %>%
      dplyr::filter(id == station_id)
  }
  
  # If the station cannot be located in both
  # datasets, return NA; otherwise, get the
  # `tz_name`
  if (nrow(station_info) == 0) {
    
    tz_name <- NA_character_
    
  } else {
    
    tz_name <- 
      station_info %>%
      dplyr::pull(tz_name)
  }
  
  tz_name
}
