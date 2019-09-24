#' Get data from a meteorological station
#' 
#' Obtain one or more years of meteorological data for a particular station.
#' 
#' @param station_id A station identifier composed of the station's USAF and
#'   WBAN numbers, separated by a hyphen.
#' @param years The years for which station met data will be collected. If not
#'   specified then all records for all available years will be obtained for the
#'   station.
#' @param full_data Include all additional meteorological data found in the
#'   dataset's additional data section?
#' @param add_fields A vector of categories for additional meteorological data
#'   to include (instead of all available categories).
#' @param make_hourly Transforms data to force values to the start of each hour.
#'   All data is bucketed by hour and all missing hours are filled with `NA`s.
#'   This regularizes each year of data, where the number of records per year of
#'   data will be either 8760 or 8784 (depending on whether a year is a leap
#'   year). By default to this is `TRUE`.
#' @param local_file_dir Path to local meteorological data files. If specified,
#'   then data files will be downloaded to and retrieved from this location and
#'   not from the remote data store.
#' 
#' @return Returns a tibble with at least 10 variables. While times are recorded
#'   using the Universal Time Code (UTC) in the source data, they are adjusted
#'   here to local standard time for the station's locale.
#' \describe{
#' \item{id}{A character string identifying the fixed weather station
#' from the USAF Master Station Catalog identifier and the WBAN identifier.}
#' \item{time}{A datetime value representing the observation time.}
#' \item{temp}{Air temperature measured in degrees Celsius. Conversions to
#' degrees Fahrenheit may be calculated with `(temp * 9) / 5 + 32`.}
#' \item{wd}{The angle of wind direction, measured in a clockwise direction,
#' between true north and the direction from which the wind is blowing. For
#' example, `wd = 90` indicates the wind is blowing from due east. `wd = 225`
#' indicates the wind is blowing from the south west. The minimum value is `1`,
#' and the maximum value is `360`.}
#' \item{ws}{Wind speed in meters per second. Wind speed in feet per second can
#' be estimated by `ws * 3.28084`.}
#' \item{atmos_pres}{The air pressure in hectopascals relative to Mean Sea Level
#' (MSL).}
#' \item{dew_point}{The temperature in degrees Celsius to which a given parcel
#' of air must be cooled at constant pressure and water vapor content in order
#' for saturation to occur.}
#' \item{rh}{Relative humidity, measured as a percentage, as calculated using
#' the August-Roche-Magnus approximation.}
#' \item{ceil_hgt}{The height above ground level of the lowest cloud cover or
#' other obscuring phenomena amounting to at least 5/8 sky coverage. Measured in
#' meters. Unlimited height (no obstruction) is denoted by the value `22000`.}
#' \item{visibility}{The horizontal distance at which an object can be seen and
#' identified. Measured in meters. Values greater than `16000` are entered as
#'  `16000` (which constitutes 10 mile visibility).}
#' }
#' 
#' @examples 
#' \dontrun{
#' # Obtain two years of data from the
#' # met station with the ID value of
#' # "999999-63897" 
#' met_data <- 
#'   get_met_data(
#'     station_id = "999999-63897",
#'     years = 2013:2014
#'   )
#' }
#' 
#' @export
get_met_data <- function(station_id,
                         years = NULL,
                         full_data = FALSE,
                         add_fields = NULL,
                         make_hourly = TRUE,
                         local_file_dir = NULL) {
  
  # Check whether `years` is numeric
  if (!is.null(years) && !is.numeric(years)) {
    stop("Please provide numeric values for `years`.", call. = FALSE)
  }
  
  if (is.null(years)) {
    years <- 1800:2200
  }
  
  years <- sort(years)
  
  buffered_years <- years %>% get_buffered_years()
  
  if (isTRUE(full_data)) {
    add_fields <- NULL
  }
  
  # Get the time zone name
  tz_name <- get_tz_for_station(station_id)
  
  # If the time zone isn't available, then the station wasn't
  # found, so, an empty met table should be returned
  if (is.na(tz_name)) {
    message("The `station_id` provided (\"", station_id,
            "\") doesn't have a record in the `get_station_metadata()` table.")
    
    return(empty_met_tbl())
  }
  
  # Get a vector of data files that are stored in a local
  # directory (and download any necessary files)
  data_files <- 
    get_local_file_list(
      station_id = station_id,
      years = buffered_years,
      local_file_dir = local_file_dir
    )
  
  tbl <- empty_met_tbl()
  
  for (i in seq(data_files)) {
    
    # Read data from mandatory data section of each file,
    # which is a fixed-width string
    tbl_i <- 
      readr::read_fwf(
        data_files[i],
        readr::fwf_widths(column_widths()),
        col_types = "ccciiiiiciicicciccicicccicccicicic"
      )
    
    # Keep specific columns from the table
    tbl_i <- tbl_i[, c(4:8, 16, 19, 21, 25, 29, 31, 33)]
    
    # Apply names to the columns
    names(tbl_i) <-
      c(
        "year", "month", "day", "hour", "minute", "wd", "ws",
        "ceil_hgt", "visibility", "temp", "dew_point", "atmos_pres"
      )
    
    tbl_i <-
      tbl_i %>%
      dplyr::mutate(wd = dplyr::case_when(
        wd == 999 ~ NA_integer_,
        TRUE ~ wd
      )) %>%
      dplyr::mutate(ws = dplyr::case_when(
        ws == 9999 ~ NA_real_,
        TRUE ~ ws / 10
      )) %>%
      dplyr::mutate(temp = dplyr::case_when(
        temp == 9999 ~ NA_real_,
        TRUE ~ temp / 10
      )) %>%
      dplyr::mutate(dew_point = dplyr::case_when(
        dew_point == 9999 ~ NA_real_,
        TRUE ~ dew_point / 10
      )) %>%
      dplyr::mutate(atmos_pres = dplyr::case_when(
        atmos_pres == 99999 ~ NA_real_,
        TRUE ~ atmos_pres / 10
      )) %>%
      dplyr::mutate(ceil_hgt = dplyr::case_when(
        ceil_hgt == 99999 ~ NA_integer_,
        TRUE ~ ceil_hgt
      )) %>%
      dplyr::mutate(visibility = dplyr::case_when(
        visibility == 999999 ~ NA_integer_,
        TRUE ~ visibility
      )) %>%
      dplyr::mutate(
        rh = 100 * (
          exp((17.625 * dew_point) /(243.04 + dew_point)) /
            exp((17.625 * (temp)) / (243.04 + (temp)))
        ),
        rh = round(rh, 1)
      ) %>%
      dplyr::mutate(id = station_id) %>%
      dplyr::mutate(
        time = base::ISOdatetime(
          year = year,
          month = month,
          day = day,
          hour = hour,
          min = minute,
          sec = 0,
          tz = "GMT"
        )
      ) %>%
      dplyr::mutate(
        offset = lutz::tz_offset(
          dt = as.Date(time),
          tz = tz_name
        )$utc_offset_h
      ) %>%
      dplyr::mutate(
        time = dplyr::case_when(
          !is.na(offset) ~ time + (3600 * offset),
          TRUE ~ time
        )
      ) %>%
      dplyr::select(id, time, temp, wd, ws, atmos_pres, dew_point, rh, ceil_hgt, visibility)
    
    tbl <- dplyr::bind_rows(tbl, tbl_i)
  }
  
  if (is.null(add_fields) & full_data == FALSE) {
    
    if (isTRUE(make_hourly)) {
      
      tbl <-
        tbl %>%
        bucketize_data() %>%
        fill_missing_hours()
    }
    
    tbl <- 
      tbl %>%
      trim_tbl_to_years(years = years)
    
    return(tbl)
  }
  
  add_data <- c()
  
  # Get additional data portions of records, excluding remarks
  for (i in seq(data_files)){
    
    add_data <- 
      c(
        add_data,
        readLines(data_files[i]) %>%
          strsplit("REM") %>%
          vapply(function(x) x[[1]], character(1))
      )
  }
  
  add_data_tbl <- 
    tbl %>%
    dplyr::select(id, time) %>%
    dplyr::mutate(add_data = add_data)
  
  add_data_vec <- add_data_tbl %>% dplyr::pull(add_data)
  
  # Create vector of additional data categories
  data_categories <- field_categories() %>% toupper()
  
  data_categories_counts <- rep(0L, length(data_categories))

  # Determine which additional parameters have been measured
  for (i in seq_along(data_categories)) {
    
    data_categories_counts[i] <-
      stringr::str_detect(add_data_vec, data_categories[i]) %>% sum()
  }
  
  if (!inherits(full_data, "logical") && full_data == "report") {
    
    add_data_tbl <-
      add_data_tbl %>%
      trim_tbl_to_years(years = years)
    
    return(add_data_tbl)
  }
  
  # Filter those measured parameters and obtain string of identifiers
  data_categories <- data_categories[data_categories_counts >= 1]
  
  # Filter the significantly available extra parameters by those specified
  if (!is.null(add_fields)) {
    
    add_fields <- toupper(add_fields)
    add_fields <- data_categories[data_categories %in% add_fields]
  }
  
  if (length(add_fields) > 0) {
    
    for (field in add_fields) {
      
      tbl <- 
        tbl %>%
        bind_additional_data(
          add_data = add_data_vec,
          category_key = field
        )
    }
  }
  
  if (isTRUE(full_data)) {
    
    for (category in data_categories) {
      
      tbl <- 
        tbl %>%
        bind_additional_data(
          add_data = add_data_vec,
          category_key = category
        )
    }
  }
  
  if (isTRUE(make_hourly)) {
    
    tbl <-
      tbl %>%
      bucketize_data() %>%
      fill_missing_hours()
  }
  
  tbl %>% trim_tbl_to_years(years = years)
}
