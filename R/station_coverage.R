#' @export
station_coverage <- function(station_id,
                             years,
                             wide_tbl = FALSE,
                             grouping = NULL,
                             use_local_files = FALSE,
                             local_file_dir = NULL) {
  
  add_data_tbl <- 
    get_met_data(
      station_id,
      years = years,
      full_data = "report",
      use_local_files = use_local_files,
      local_file_dir = local_file_dir
    )
  
  add_data_vec <- add_data_tbl %>% dplyr::pull(add_data)
  
  add_data_tbl <-
    add_data_tbl %>%
    dplyr::select(-add_data)
  
  data_categories <- field_categories() %>% toupper()
  
  for (i in seq_along(data_categories)) {
    
    counts <-
      stringr::str_detect(add_data_vec, data_categories[i]) %>%
      as.integer()
    
    add_data_tbl[, data_categories[i]] <- counts
  }
  
  summarized_cols <- colnames(add_data_tbl) %>% base::setdiff(c("id", "time"))

  if (is.null(grouping)) {
    
    add_data_tbl <- 
      add_data_tbl %>%
      dplyr::group_by() %>%
      dplyr::summarize_at(summarized_cols, sum) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(id = station_id) %>%
      dplyr::select(id, dplyr::everything())
  }
  
  if (!is.null(grouping) && grouping == "year") {
    
    add_data_tbl <- 
      add_data_tbl %>%
      dplyr::mutate(year = lubridate::year(time)) %>%
      dplyr::group_by(year) %>%
      dplyr::summarize_at(summarized_cols, sum) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(id = station_id) %>%
      dplyr::select(id, dplyr::everything())
  }
  
  if (!is.null(grouping) && grouping == "month") {
    
    add_data_tbl <- 
      add_data_tbl %>%
      dplyr::mutate(
        year = lubridate::year(time),
        month = lubridate::month(time)
      ) %>%
      dplyr::group_by(year, month) %>%
      dplyr::summarize_at(summarized_cols, sum) %>%
      dplyr::ungroup() %>% 
      dplyr::mutate(id = station_id) %>%
      dplyr::select(id, dplyr::everything())
  }
  
  if (!isTRUE(wide_tbl)) {
    
    add_data_tbl <- 
      add_data_tbl %>%
      tidyr::gather(key = "category", value = "count", summarized_cols)
  }
  
  add_data_tbl
}
