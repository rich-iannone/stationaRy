#' Find out which additional data fields a station has recorded
#' 
#' Get a tibble of information on which additional data fields a particular
#' station has during a specified year range.
#' 
#' @inheritParams get_met_data
#' @param wide_tbl A wide table of a single row for the station can be generated
#'   by setting this to `TRUE`. In this arrangement, additional data field
#'   categories will appear as columns (having counts of observations as values
#'   for the period of `years`). This is useful when collecting station coverage
#'   tables for multiple stations, since the rows can be safely bound together.
#'   By default, this is set to `FALSE`.
#' @param grouping An option to group and summarize counts of observations by
#'   `"year"` or by `"month"`. If these keywords aren't provided then
#'   summarization will occur over the entire period specified by `years`.
#'
#' @return A tibble.
#' 
#' @examples 
#' \dontrun{
#' # Obtain a coverage report of the
#' # additional data that the met
#' # station with the ID value of
#' # "999999-63897" has over a two-
#' # year period
#' met_data <- 
#'   station_coverage(
#'     station_id = "999999-63897",
#'     years = 2013:2014
#'   )
#' }
#' 
#' @export
station_coverage <- function(station_id,
                             years = NULL,
                             wide_tbl = FALSE,
                             grouping = NULL,
                             local_file_dir = NULL) {
  
  add_data_tbl <- 
    get_met_data(
      station_id,
      years = years,
      full_data = "report",
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
