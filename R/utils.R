data_base_url <- function() {
  "https://www1.ncdc.noaa.gov/pub/data/noaa"
}

empty_met_tbl <- function() {
  
  dplyr::tibble(
    id = NA_character_,
    time = lubridate::ymd_hms("1970-01-01 00:00:00"),
    temp = NA_real_,
    wd = NA_integer_,
    ws = NA_real_,
    atmos_pres = NA_real_,
    dew_point = NA_real_,
    rh = NA_real_,
    ceil_hgt = NA_integer_,
    visibility = NA_integer_
  )[-1, ]
}

get_buffered_years <- function(years) {
  
  buffered_years <- c()
  for (year in years) {
    buffered_years <-
      c(buffered_years, seq(year - 1, year + 1, 1))
  }
  buffered_years %>% unique()
}

trim_tbl_to_years <- function(tbl, years) {
  
  tbl %>%
    dplyr::mutate(year = lubridate::year(time)) %>%
    dplyr::filter(year %in% years) %>%
    dplyr::select(-year)
}

# Define column widths of the fixed-width data
# in the mandatory section of the data files
column_widths <- function() {
  
  c(
    4, 6, 5, 4, 2, 2, 2, 2, 1, 6, 7, 5, 5, 5, 4, 3, 1,
    1, 4, 1, 5, 1, 1, 1, 6, 1, 1, 1, 5, 1, 5, 1, 5, 1
  )
}

get_tz_for_station <- function(station_id) {
  
  # Get the tz name in the local `history_tbl`
  station_info <- 
    history_tbl %>%
    dplyr::filter(id == station_id)
  
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

get_years_available_for_station <- function(station_id) {
  
  history_tbl %>%
    dplyr::filter(id == station_id) %>%
    dplyr::pull(years) %>%
    unlist()
}

get_local_file_list <- function(station_id,
                                years,
                                local_file_dir) {
  
  years_available <- get_years_available_for_station(station_id = station_id)

  years_intersected <- years_available %>% base::intersect(years)
  
  if (length(years_intersected) == 0) {
    #stop("The station provided doesn't have data for the years requested:\n")
    return(character(0))
  }
  
  if (is.null(local_file_dir)) {
    # Create a temporary folder to deposit downloaded files
    file_dir <- tempdir()
  } else {
    # Use an existing folder and scan for files from that
    file_dir <- local_file_dir
  }
  
  # Get a vector of file names required
  files_required <- paste0(station_id, "-", years_intersected, ".gz")
  
  # If a station ID is provided, determine whether the
  # gzip-compressed data files for the years specified
  # are available at the `local_file_dir`
  data_files <- c()
  for (i in seq_along(files_required)){
    
    if (!(files_required[i] %in% list.files(file_dir))) {
      
      try(
        downloader::download(
          url = file.path(data_base_url(), years_intersected[i], files_required[i]),
          destfile = file.path(file_dir, files_required[i])
        ),
        silent = TRUE
      )
    }
    
    if (file.info(file.path(file_dir, files_required[i]))$size > 1) {
      data_files <- c(data_files, files_required[i])
    }
  }
  
  file.path(file_dir, data_files)
}
