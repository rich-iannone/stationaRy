#' @export
station_coverage <- function(station_id,
                             startyear,
                             endyear,
                             wide_tbl = FALSE,
                             use_local_files = FALSE,
                             local_file_dir = NULL) {
  
  # Check whether `startyear` and `endyear` are both numeric
  if (!is.numeric(startyear) | !is.numeric(endyear)) {
    stop("Please enter numeric values for the starting and ending years")
  }
  
  # Check whether `startyear` and `endyear` are in the correct order
  if (startyear > endyear) {
    stop("Please enter the starting and ending years in the correct order")
  }
  
  years <- seq(startyear, endyear, by = 1)
  
  # Get the tz name
  tz_name <- 
    history_tbl %>%
    dplyr::filter(id == station_id) %>%
    dplyr::pull(tz_name)
  
  if (use_local_files == FALSE) {
    
    years_available <-
      inventory_tbl %>%
      dplyr::filter(id == station_id) %>%
      dplyr::pull(year)
    
    years_intersected <- 
      years_available %>%
      base::intersect(years)
    
    if (length(years_intersected) == 0) {
      stop("The station provided doesn't have data for the years requested:\n")
    }
    
    files_required <- paste0(station_id, "-", years_intersected, ".gz")
    
    # Create a temporary folder to deposit downloaded files
    temp_folder <- tempdir()
    
    # If a station ID is provided, download the
    # gzip-compressed data files for the years specified
    data_files <- c()
    for (i in seq_along(files_required)){
      
      try(
        downloader::download(
          url = file.path(data_base_url(), years_intersected[i], files_required[i]),
          destfile = file.path(temp_folder, files_required[i])
        ),
        silent = TRUE
      )
      
      if (file.info(
        file.path(temp_folder, files_required[i]))$size > 1){
        
        data_files <- c(data_files, files_required[i])
      }
    }
    
  } else {
    
    years_available <-
      inventory_tbl %>%
      dplyr::filter(id == station_id) %>%
      dplyr::pull(year)
    
    years_intersected <- 
      years_available %>%
      base::intersect(years)
    
    if (length(years_intersected) == 0) {
      stop("The station provided doesn't have data for the years requested:\n")
    }
    
    files_required <- paste0(station_id, "-", years_intersected, ".gz")
    
    # If a station ID is provided, determine whether the
    # gzip-compressed data files for the years specified
    # are available at the `local_file_dir`
    data_files <- c()
    for (i in seq_along(files_required)){
      
      if (file.info(
        file.path(local_file_dir, files_required[i]))$size > 1){
        
        data_files <- c(data_files, files_required[i])
      }
    }
  }
  
  
  # Create vector of additional data categories
  data_categories <- field_categories()
  
  add_data <- c()
  
  # Get additional data portions of records, excluding remarks
  for (i in seq_along(data_files)){
    
    if (use_local_files == FALSE){
      add_data_i <- readLines(file.path(temp_folder, data_files[i]))
    }
    
    if (use_local_files == TRUE){
      add_data_i <- readLines(file.path(local_file_dir, data_files[i]))
    }
    
    add_data <- 
      c(
        add_data,
        add_data_i %>%
          strsplit("REM") %>%
          vapply(function(x) x[[1]], character(1))
      )
  }
  
  # Obtain data counts for all additional parameters
  for (i in seq(data_categories)){
    if (i == 1){
      data_categories_counts <-
        vector(mode = "numeric", length = length(data_categories))
    }
    
    data_categories_counts[i] <-
      sum(stringr::str_detect(add_data, data_categories[i]))
  }
  
  # Determine which data categories have data
  data_categories_available <-
    data_categories[which(data_categories_counts > 0)]
  
  # Get those data counts that are greater than 0
  data_categories_counts <-
    data_categories_counts[which(data_categories_counts > 0)]
  
  # Create a data frame composed of categories and their counts
  data_categories_tbl <- 
    dplyr::tibble(
      id = station_id,
      category = data_categories_available,
      total_count = data_categories_counts
    )
  
  if (isTRUE(wide_tbl)) {
    
    data_categories_tbl <- 
      data_categories_tbl %>% 
      tidyr::spread(key = category, value = total_count)
    
  }
  data_categories_tbl
}
