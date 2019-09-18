bucketize_data <- function(x) {
  
  summary_cols <- names(x) %>% base::setdiff("time")
  
  x %>%
    dplyr::mutate(
      hour_bin = lubridate::round_date(time, unit = "hour")
    ) %>%
    dplyr::group_by(hour_bin) %>%
    dplyr::summarize_at(
      .vars = summary_cols,
      .funs = function(x) {
        
        if (inherits(x, "character")) {
          x <- sort(x)[1]
        } else if (inherits(x, "numeric")) {
          x <- suppressWarnings(min(x, na.rm = TRUE))
          x[is.infinite(x)] <- NA_real_
        } else if (inherits(x, "integer")) {
          x <- suppressWarnings(min(x, na.rm = TRUE))
          x[is.infinite(x)] <- NA_integer_
        } else if (inherits(x, "POSIXct")) {
          x <- x[1]
        }
        
        x
      }
    ) %>%
    dplyr::select(id, time = hour_bin, dplyr::everything())
}

fill_missing_hours <- function(x) {
  
  station_id <- 
    x %>%
    dplyr::pull(id) %>%
    unique()
  
  years <- 
    x %>%
    dplyr::mutate(year = lubridate::year(time)) %>%
    dplyr::pull(year) %>%
    sort() %>%
    unique()
  
  x_empty <- x[0, ]
  
  hour_series <-
    seq(
      lubridate::ymd_hms(paste0(years[1], "-01-01 00:00:00")),
      lubridate::ymd_hms(paste0(years[length(years)], "-01-01 00:00:00")) +
        lubridate::years(1) - lubridate::hours(1),
      3600
    )
  
  hour_series <- hour_series[!(hour_series %in% x$time)]
  
  x_empty %>%
    dplyr::bind_rows(dplyr::tibble(time = hour_series)) %>%
    dplyr::mutate(id = station_id) %>%
    dplyr::bind_rows(x) %>%
    dplyr::arrange(time)
}
