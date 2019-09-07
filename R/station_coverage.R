#' @export
station_coverage <- function(station_id,
                             years,
                             wide_tbl = FALSE,
                             use_local_files = FALSE,
                             local_file_dir = NULL) {
  
  data_categories_counts <- 
    get_met_data(
      station_id,
      years = years,
      full_data = "report",
      use_local_files = use_local_files,
      local_file_dir = local_file_dir
    )
  
  data_categories <- field_categories() %>% toupper()
  
  # Determine which data categories have data
  data_categories_available <- data_categories[data_categories_counts > 0]
  
  # Get those data counts that are greater than 0
  data_categories_counts <- data_categories_counts[data_categories_counts > 0]
  
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
