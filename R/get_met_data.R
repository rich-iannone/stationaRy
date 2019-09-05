#' Get data from a meteorological station
#' 
#' Obtain one or more years of meteorological data for a station
#' from the NCEI Integrated Surface Dataset (ISD).
#' 
#' @param station_id A station identifier composed of the station's USAF and
#' WBAN numbers, separated by a hyphen.
#' @param startyear The starting year for the collected data.
#' @param endyear The ending year for the collected data.
#' @param full_data Include additional meteorological data found in the
#' dataset's additional data section?
#' @param add_fields A vector of categories for additional
#' meteorological data to include (instead of all available categories).
#' @param use_local_files Option to use data files already available locally.
#' @param local_file_dir Path to local meteorological data files.
#' 
#' @return Returns a tibble with 18 variables. Times are recorded 
#' using the Universal Time Code (UTC) in the source data. Times are adjusted
#' to local standard time for the station's locale.
#' \describe{
#'   \item{usaf}{A character string identifying the fixed weather 
#'     station from the USAF Master Station Catalog.
#'     USAF is an acronym for United States Air Force.}
#'   \item{wban}{A character string for the fixed weather
#'     station NCDC WBAN identifier.  
#'     NCDC is an acronym for National Climatic Data Center. 
#'     WBAN is an acronym for Weather Bureau, Air Force and Navy.}
#'   \item{year}{A numeric, four digit value giving the year of the 
#'     observation.}
#'   \item{month}{A numeric value (one or two digits) giving the month
#'     of the observation.}
#'   \item{day}{A numeric value (one or two digits) giving the day of the 
#'     month of the observation.}
#'   \item{hour}{A numeric value (one or two digits) giving the hour of 
#'     the observation.}
#'   \item{minute}{A numeric value (one or two digits) giving the minute 
#'     of the hour in which the observation was recorded.}
#'   \item{lat}{Latitude (degrees) rounded to three decimal places.}
#'   \item{lon}{Longitude (degrees) rounded to three decimal places.}
#'   \item{elev}{Numeric value for the elevation as measured in meters. 
#'     The minimum value is -400 with a maximum of 8850. Elevation in feet
#'     can be approximated by \code{elev * 3.28084}}
#'   \item{wd}{The angle of wind direction, measured in a clockwise 
#'     direction, between true north and the direction from which
#'     the wind is blowing. For example, \code{wd = 90} indicates the 
#'     wind is blowing from due east. \code{wd = 225} indicates the 
#'     wind is blowing from the south west. The minimum value is 1, and the
#'     maximum value is 360.}
#'   \item{ws}{Wind speed in meters per second.  Wind speed in feet per 
#'     second can be estimated by \code{ws * 3.28084}}
#'   \item{ceil_hgt}{The height above ground level of the lowest clould cover
#'     or other obscuring phenomena amounting to at least 5/8 sky 
#'     coverate.  Measured in meters.  Unlimited height (no obstruction)
#'     is denoted by the value 22000}
#'   \item{temp}{Air temperature measured in degrees Celsius. Conversions 
#'     to degrees Farenheit may be calculated with 
#'     \code{(temp * 9) / 5 + 32}}.
#'   \item{dew_point}{The temperature in degrees Celsius to which a 
#'     given parcel of air must be cooled at constant pressure and 
#'     water vapor content in order for saturation to occur.}
#'   \item{atmos_pres}{The air pressure in hectopascals relative to 
#'     Mean Sea Level (MSL)}
#'   \item{rh}{Relative humidity, measured as a percentage,
#'     as calculated using the August-Roche-Magnus approximation}
#'   \item{time}{A POSIXct object with the date-time of the observation.}
#' }
#' 
#' @source 
#' \url{http://www.ncdc.noaa.gov/isd}\cr
#' \url{http://www1.ncdc.noaa.gov/pub/data/ish/ish-format-document.pdf}
#' 
#' Calculating Humidity: \cr
#' \url{https://en.wikipedia.org/wiki/Clausius\%E2\%80\%93Clapeyron_relation#Meteorology_and_climatology}
#'
#'@examples 
#' \dontrun{
#' # Obtain two years of data from data files stored on disk (in this
#' # case, inside the package itself)
#' df_mandatory_data_local <- 
#'   get_met_data(
#'     station_id = "999999-63897",
#'     startyear = 2013,
#'     endyear = 2014,
#'     use_local_files = TRUE,
#'     local_file_dir = system.file(package = "stationary")
#'   )
#' }
#' 
#' @export
get_met_data <- function(station_id,
                         startyear,
                         endyear,
                         full_data = FALSE,
                         add_fields = NULL,
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
  
  # Define column widths for fixed-width data in the mandatory section of
  # the ISD data files
  column_widths <- 
    c(4, 6, 5, 4, 2, 2, 2, 2, 1, 6,
      7, 5, 5, 5, 4, 3, 1, 1, 4, 1,
      5, 1, 1, 1, 6, 1, 1, 1, 5, 1,
      5, 1, 5, 1)
  
  if (use_local_files) {
    
    data_files <- file.path(local_file_dir, data_files)
    
  } else {
    
    data_files <- file.path(temp_folder, data_files)
  }
  
  tbl <- dplyr::tibble()
  
  for (i in seq(data_files)){
    
    if (file.exists(data_files[i])){
      
      # Read data from mandatory data section of each file,
      # which is a fixed-width string
      tbl_i <- 
        readr::read_fwf(
          data_files[i],
          readr::fwf_widths(column_widths),
          col_types = "ccciiiiiciicicciccicicccccccicicic"
        )
      
      # Remove specific columns from data frame
      tbl_i <- 
        tbl_i[, c(2:8, 10:11, 13, 16, 19, 21, 29, 31, 33)]
      
      # Apply new names to the data frame columns
      names(tbl_i) <-
        c("usaf", "wban", "year", "month",
          "day", "hour", "minute", "lat", "lon",
          "elev", "wd", "ws", "ceil_hgt",
          "temp", "dew_point", "atmos_pres")
      
      tbl_i <-
        tbl_i %>%
        dplyr::mutate(lat = lat/1000, lon = lon/1000) %>%
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
        dplyr::mutate(
          rh = 100 * (
            exp((17.625 * dew_point) /(243.04 + dew_point)) /
              exp((17.625 * (temp)) / (243.04 + (temp)))
          )
        )
      
      tbl <- dplyr::bind_rows(tbl, tbl_i)
    }
  }
  
  # Create POSIXct time values from the time elements
  tbl$time <- 
    ISOdatetime(
      year = tbl$year,
      month = tbl$month,
      day = tbl$day,
      hour = tbl$hour,
      min = tbl$minute,
      sec = 0,
      tz = "GMT"
    )
  
  # Adjust to local time if the time zone had been resolved
  if (!is.na(tz_name)) {
    
    tz_offsets <- 
      lutz::tz_offset(dt = as.Date(tbl$time), tz = tz_name) %>%
      dplyr::pull(utc_offset_h)
    
    tbl$tz_offset <- tz_offsets
    
    tbl <- 
      tbl %>%
      dplyr::mutate(time = dplyr::case_when(
        !is.na(tz_offset) ~ time + (3600 * tz_offset),
        TRUE ~ time
      ))
  }
  
  tbl <-
    tbl %>%
    dplyr::mutate(id = station_id) %>%
    dplyr::select(id, time, wd, ws, ceil_hgt, temp, dew_point, atmos_pres, rh)
  
  
  
  # If additional data categories specified, then set 'full_data' to TRUE
  # to enter that conditional block
  if (!is.null(add_fields)) {
    full_data <- TRUE
  }
  
  if (full_data == FALSE){
    return(tbl)
  }
  
  if (isTRUE(full_data)){
    
    add_data <- c()
    
    # Get additional data portions of records, excluding remarks
    for (i in seq(data_files)){
      
      if (use_local_files == FALSE){
        
        add_data_i <- readLines(data_files[i])
      }
      
      if (use_local_files == TRUE){
        
        add_data_i <- readLines(data_files[i])
      }
      
      add_data <- 
        c(
          add_data,
          add_data_i %>%
            strsplit("REM") %>%
            vapply(function(x) x[[1]], character(1))
        )
    }
    
    # Create vector of additional data categories
    data_categories <- field_categories()
    
    expanded_column_names <- additional_data_fields()
    
    # Determine which additional parameters have been measured
    for (i in seq(data_categories)){
      
      if (i == 1){
        data_categories_counts <-
          vector(mode = "numeric",
                 length = length(data_categories))
      }
      
      data_categories_counts[i] <-
        sum(stringr::str_detect(add_data, data_categories[i]))
    }
    
    # Filter those measured parameters and obtain string of identifiers
    significant_params <- data_categories[which(data_categories_counts >= 1)]
    
    # Filter the significantly available extra parameters by those specified
    if (!is.null(add_fields)){
      
      significant_params <-
        significant_params[which(significant_params %in% add_fields)]
    }
    
    # AA1 - liquid precipitation: period quantity, depth dimension
    if (data_categories[1] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          category_key = "AA1",
          field_lengths = c(2, 4, 1, 1),
          scale_factor = c(1, 10, NA, NA),
          data_types =  "nncc",
          add_data = add_data
        )
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AB1 - liquid precipitation: monthly total
    if (data_categories[2] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AB1",
          c(5, 1, 1),
          c(10, NA, NA),
          "ncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AC1 - precipitation observation history
    if (data_categories[3] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AC1",
          c(1, 1, 1),
          c(NA, NA, NA),
          "ccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AD1 - liquid precipitation, greatest amount in 24 hours, for the month
    if (data_categories[4] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AD1",
          c(5, 1, 4, 4, 4, 1),
          c(10, NA, NA, NA, NA, NA),
          "nccccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AE1 - liquid precipitation, number of days with specific 
    # amounts, for the month
    if (data_categories[5] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AE1",
          c(2, 1, 2, 1, 2, 1, 2, 1),
          rep(NA, 8),
          "cccccccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AG1 - precipitation estimated observation
    if (data_categories[6] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AG1",
          c(1, 3),
          c(NA, 1),
          "cn",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AH1 - liquid precipitation maximum short duration, for the month (1)
    if (data_categories[7] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AH1",
          c(3, 4, 1, 6, 1),
          c(1, 10, NA, NA, NA),
          "nnccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AI1 - liquid precipitation maximum short duration, for the month (2)
    if (data_categories[8] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AI1",
          c(4, 1, 6, 1),
          c(10, NA, NA, NA),
          "nccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AJ1 - snow depth
    if (data_categories[9] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AJ1",
          c(4, 1, 1, 6, 1, 1),
          c(1, NA, NA, 10, NA, NA),
          "nccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AK1 - snow depth greatest depth on the ground, for the month
    if (data_categories[10] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AK1",
          c(4, 1, 6, 1),
          c(1, NA, NA, NA),
          "nccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AL1 - snow accumulation
    if (data_categories[11] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AL1",
          c(2, 3, 1, 1),
          c(1, 1, NA, NA),
          "nncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AM1 - snow accumulation greatest amount in 24 hours, for the month
    if (data_categories[12] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AM1",
          c(4, 1, 4, 4, 4, 1),
          c(10, NA, NA, NA, NA, NA),
          "nccccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AN1 - snow accumulation for the month
    if (data_categories[13] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AN1",
          c(3, 4, 1, 1),
          c(1, 10, NA, NA),
          "nncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AO1 - liquid precipitation
    if (data_categories[14] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AO1",
          c(2, 4, 1, 1),
          c(1, 10, NA, NA),
          "nncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AP1 - 15-minute liquid precipitation
    if (data_categories[15] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AP1",
          c(4, 1, 1),
          c(10, NA, NA),
          "ncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AU1 - present weather observation
    if (data_categories[16] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AU1",
          c(1, 1, 2, 1, 1, 1, 1),
          c(NA, NA, NA, NA,
            NA, NA, NA),
          "ccccccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AW1 - present weather observation 
    if (data_categories[17] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AW1",
          c(2, 1),
          c(NA, NA),
          "cc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AX1 - past weather observation (1)
    if (data_categories[18] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AX1",
          c(2, 1, 2, 1),
          c(NA, NA, 1, NA),
          "ccnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AY1 - past weather observation (2)
    if (data_categories[19] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AY1",
          c(1, 1, 2, 1),
          c(NA, NA, 1, NA),
          "ccnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # AZ1 - past weather observation (3)
    if (data_categories[20] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AZ1",
          c(1, 1, 2, 1),
          c(NA, NA, 1, NA),
          "ccnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CB1 - subhourly observed liquid precipitation: secondary sensor
    if (data_categories[21] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CB1",
          c(2, 6, 1, 1),
          c(1, 10, NA, NA),
          "nncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CF1 - hourly fan speed
    if (data_categories[22] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CF1",
          c(4, 1, 1),
          c(10, NA, NA),
          "ncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CG1 - subhourly observed liquid precipitation: primary sensor
    if (data_categories[23] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CG1",
          c(6, 1, 1),
          c(10, NA, NA),
          "ncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CH1 - hourly/subhourly RH/temperatures
    if (data_categories[24] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CH1",
          c(2, 5, 1, 1, 4, 1, 1),
          c(1, 10, NA, NA, 10, NA, NA),
          "nnccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CI1 - hourly RH/temperatures
    if (data_categories[25] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CI1",
          c(5, 1, 1, 5, 1, 1,
            5, 1, 1, 5, 1, 1),
          c(10, NA, NA, 10, NA, NA,
            10, NA, NA, 10, NA, NA),
          "nccnccnccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CN1 - hourly battery voltage
    if (data_categories[26] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CN1",
          c(4, 1, 1, 4, 1, 1,
            4, 1, 1),
          c(10, NA, NA, 10, NA, NA,
            10, NA, NA),
          "nccnccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CN2 - hourly diagnostics
    if (data_categories[27] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CN2",
          c(5, 1, 1, 5, 1, 1,
            2, 1, 1),
          c(10, NA, NA, 10, NA, NA,
            1, NA, NA),
          "nccnccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CN3 - secondary hourly diagnostics (1)
    if (data_categories[28] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CN3",
          c(6, 1, 1, 6, 1, 1),
          c(10, NA, NA, 10, NA, NA),
          "nccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CN4 - secondary hourly diagnostics (2)
    if (data_categories[29] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CN4",
          c(1, 1, 1, 1, 1, 1,
            3, 1, 1, 3, 1, 1),
          c(NA, NA, NA, NA, NA, NA,
            10, NA, NA, 10, NA, NA),
          "ccccccnccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CR1 - CRN control
    if (data_categories[30] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CR1",
          c(5, 1, 1),
          c(1000, NA, NA),
          "ncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CT1 - subhourly temperatures
    if (data_categories[31] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CT1",
          c(5, 1, 1),
          c(10, NA, NA),
          "ncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CU1 - hourly temperatures
    if (data_categories[32] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CU1",
          c(5, 1, 1, 4, 1, 1),
          c(10, NA, NA, 10, NA, NA),
          "nccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CV1 - hourly temperature extremes
    if (data_categories[33] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CV1",
          c(5, 1, 1, 4, 1, 1,
            5, 1, 1, 4, 1, 1),
          c(10, NA, NA, NA, NA, NA,
            10, NA, NA, NA, NA, NA),
          "ncccccnccccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CW1 - subhourly wetness
    if (data_categories[34] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CW1",
          c(5, 1, 1, 5, 1, 1),
          c(10, NA, NA, 10, NA, NA),
          "nccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CX1 - hourly geonor vibrating wire summary
    if (data_categories[35] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CX1",
          c(6, 1, 1, 4, 1, 1,
            4, 1, 1, 4, 1, 1),
          c(10, NA, NA, 1, NA, NA,
            1, NA, NA, 1, NA, NA),
          "nccnccnccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CO1 - network metadata
    if (data_categories[36] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CO1",
          c(2, 3),
          c(1, 1),
          "nn",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # CO2 - US cooperative network element time offset
    if (data_categories[37] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CO2",
          c(3, 5),
          c(NA, 10),
          "cn",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # ED1 - runway visual range
    if (data_categories[38] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "ED1",
          c(2, 1, 4, 1),
          c(0.1, NA, 1, NA),
          "ncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GA1 - sky cover layer
    if (data_categories[39] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GA1",
          c(2, 1, 6, 1, 2, 1),
          c(NA, NA, 1, NA, NA, NA),
          "ccnccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GD1 - sky cover summation state
    if (data_categories[40] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GD1",
          c(1, 2, 1, 6, 1, 1),
          c(NA, NA, NA, 1, NA, NA),
          "cccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GF1 - sky condition observation
    if (data_categories[41] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GF1",
          c(2, 2, 1, 2, 1, 2, 1,
            5, 1, 2, 1, 2, 1),
          c(NA, NA, NA, NA, NA, NA, NA,
            1, NA, NA, NA, NA, NA),
          "cccccccnccccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GG1 - below station cloud layer
    if (data_categories[42] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GG1",
          c(2, 1, 5, 1, 2, 1, 2, 1),
          c(NA, NA, 1, NA, NA, NA, NA, NA),
          "ccnccccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GH1 - hourly solar radiation
    if (data_categories[43] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GH1",
          c(5, 1, 1, 5, 1, 1,
            5, 1, 1, 5, 1, 1),
          c(10, NA, NA, 10, NA, NA,
            10, NA, NA, 10, NA, NA),
          "nccnccnccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GJ1 - sunshine observation (1)
    if (data_categories[44] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GJ1",
          c(4, 1),
          c(1, NA),
          "nc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GK1 - sunshine observation (2)
    if (data_categories[45] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GK1",
          c(3, 1),
          c(1, NA),
          "nc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GL1 - sunshine observation for the month
    if (data_categories[46] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GL1",
          c(5, 1),
          c(1, NA),
          "nc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GM1 - solar irradiance
    if (data_categories[47] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GM1",
          c(4, 4, 2, 1, 4, 2, 1,
            4, 2, 1, 4, 1),
          c(1, 1, NA, NA, 1, NA, NA,
            1, NA, NA, 1, NA),
          "nnccnccnccnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GN1 - solar radiation
    if (data_categories[48] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GN1",
          c(4, 4, 2, 1, 4, 2, 1,
            4, 2, 1, 4, 1),
          c(1, 1, NA, NA, 1, NA, NA,
            1, NA, NA, 1, NA),
          "nnccnccnccnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GO1 - net solar radiation
    if (data_categories[49] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GO1",
          c(4, 4, 1, 4, 1, 4, 1),
          c(1, 1, NA, 1, NA, 1, NA),
          "nncncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GP1 - modeled solar irradiance
    if (data_categories[50] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GP1",
          c(4, 4, 2, 3, 4, 2,
            3, 4, 2, 3),
          c(1, 1, NA, 1, 1, NA,
            1, 1, NA, 1),
          "nncnncnncn",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GQ1 - hourly solar angle
    if (data_categories[51] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GQ1",
          c(4, 4, 1, 4, 1),
          c(1, 10, NA, 10, NA),
          "nncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # GR1 - hourly extraterrestrial radiation
    if (data_categories[52] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GR1",
          c(4, 4, 1, 4, 1),
          c(1, 1, NA, 1, NA),
          "nncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # HL1 - hail data
    if (data_categories[53] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "HL1",
          c(3, 1),
          c(10, NA),
          "nc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # IA1 - ground surface data
    if (data_categories[54] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "IA1",
          c(2, 1),
          c(NA, NA),
          "cc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # IA2 - ground surface observation
    if (data_categories[55] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "IA2",
          c(3, 5, 1),
          c(10, 10, NA),
          "nnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # IB1 - hourly surface temperature
    if (data_categories[56] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "IB1",
          c(5, 1, 1, 5, 1, 1,
            5, 1, 1, 4, 1, 1),
          c(10, NA, NA, 10, NA, NA,
            10, NA, NA, 10, NA, NA),
          "nccnccnccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # IB2 - hourly surface temperature sensor
    if (data_categories[57] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "IB2",
          c(5, 1, 1, 4, 1, 1),
          c(10, NA, NA, 10, NA, NA),
          "nccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # IC1 - ground surface observation - pan evaporation
    if (data_categories[58] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "IC1",
          c(2, 4, 1, 1, 3, 1, 1,
            4, 1, 1, 4, 1, 1),
          c(1, 1, NA, NA, 100, NA, NA,
            10, NA, NA, 10, NA, NA),
          "nnccnccnccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # KA1 - temperature data
    if (data_categories[59] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KA1",
          c(3, 1, 5, 1),
          c(10, NA, 10, NA),
          "ncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # KB1 - average air temperature
    if (data_categories[60] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KB1",
          c(3, 1, 5, 1),
          c(10, NA, 10, NA),
          "ncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # KC1 - extreme air temperature for the month
    if (data_categories[61] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KC1",
          c(1, 1, 5, 6, 1),
          c(NA, NA, 10, NA, NA),
          "ccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # KD1 - heating/cooling degree days
    if (data_categories[62] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KD1",
          c(3, 1, 4, 1),
          c(1, NA, 1, NA),
          "ncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # KE1 - extreme temperatures, number of days exceeding criteria, for the month
    if (data_categories[63] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KE1",
          c(2, 1, 2, 1,
            2, 1, 2, 1),
          c(1, NA, 1, NA,
            1, NA, 1, NA),
          "ncncncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # KF1 - hourly calculated temperature
    if (data_categories[64] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KF1",
          c(5, 1),
          c(10, NA),
          "nc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # KG1 - average dew point and wet bulb temperature
    if (data_categories[65] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KG1",
          c(3, 1, 5, 1, 1),
          c(1, NA, 100, NA, NA),
          "ncncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # MA1 - atmospheric pressure observation
    if (data_categories[66] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MA1",
          c(5, 1, 5, 1),
          c(10, NA, 10, NA),
          "ncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # MD1 - atmospheric pressure change
    if (data_categories[67] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MD1",
          c(1, 1, 3, 1, 4, 1),
          c(NA, NA, 10, NA, 10, NA),
          "ccncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # ME1 - geopotential height isobaric level
    if (data_categories[68] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "ME1",
          c(1, 4, 1),
          c(NA, 1, NA),
          "cnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # MF1 - atmospheric pressure observation (STP/SLP)
    if (data_categories[69] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MF1",
          c(5, 1, 5, 1),
          c(10, NA, 10, NA),
          "ncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # MG1 - atmospheric pressure observation
    if (data_categories[70] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MG1",
          c(5, 1, 5, 1),
          c(10, NA, 10, NA),
          "ncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # MH1 - atmospheric pressure observation - average station pressure
    # for the month
    if (data_categories[71] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MH1",
          c(5, 1, 5, 1),
          c(10, NA, 10, NA),
          "ncnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # MK1 - atmospheric pressure observation - maximum sea level pressure
    # for the month
    if (data_categories[72] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MK1",
          c(5, 6, 1, 5, 6, 1),
          c(10, NA, NA, 10, NA, NA),
          "nccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # MV1 - present weather in vicinity observation
    if (data_categories[73] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MV1",
          c(2, 1),
          c(NA, NA),
          "cc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # MW1 - present weather observation 
    if (data_categories[74] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MW1",
          c(2, 1),
          c(NA, NA),
          "cc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # OA1 - supplementary wine observation 
    if (data_categories[75] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "OA1",
          c(1, 2, 4, 1),
          c(NA, 1, 10, NA),
          "cnnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # OB1 - hourly/sub-hourly wind section
    if (data_categories[76] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "OB1",
          c(3, 4, 1, 1, 3, 1, 1,
            5, 1, 1, 5, 1, 1),
          c(1, 10, NA, NA, 1, NA, NA,
            100, NA, NA, 100, NA, NA),
          "nnccnccnccncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # OC1 - wind gust observation
    if (data_categories[77] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "OC1",
          c(4, 1),
          c(10, NA),
          "nc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # OE1 - summary of day wind observation
    if (data_categories[78] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "OE1",
          c(1, 2, 5, 3, 4, 1),
          c(NA, 1, 100, 1, 10, NA),
          "cnnnnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # RH1 - relative humidity
    if (data_categories[79] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "RH1",
          c(3, 1, 3, 1, 1),
          c(1, NA, 1, NA, NA),
          "ncncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # SA1 - sea surface temperature observation
    if (data_categories[80] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "SA1",
          c(4, 1),
          c(10, NA),
          "nc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # ST1 - soil temperature
    if (data_categories[81] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "ST1",
          c(1, 5, 1, 4, 1,
            2, 1, 1, 1),
          c(NA, 10, NA, 10, NA,
            NA, NA, NA, NA),
          "cncnccccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # UA1 - wave measurement
    if (data_categories[82] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "UA1",
          c(1, 2, 3, 1, 2, 1),
          c(NA, 1, 10, NA, NA, NA),
          "cnnccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # UG1 - wave measurement primary swell
    if (data_categories[83] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "UG1",
          c(2, 3, 3, 1),
          c(1, 10, 1, NA),
          "nnnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # UG2 - wave measurement secondary swell
    if (data_categories[84] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "UG2",
          c(2, 3, 3, 1),
          c(1, 10, 1, NA),
          "nnnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # WA1 - platform ice accretion
    if (data_categories[85] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "WA1",
          c(1, 3, 1, 1),
          c(NA, 10, NA, NA),
          "cncc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # WD1 - water surface ice observation
    if (data_categories[86] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "WD1",
          c(2, 3, 2, 1, 1, 1,
            2, 1, 3, 3, 1),
          c(NA, 1, NA, NA, NA, NA,
            NA, NA, 1, 1, NA),
          "cnccccccnnc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # WG1 - water surface ice historical observation
    if (data_categories[87] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "WG1",
          c(2, 2, 2, 2, 2, 1),
          c(NA, 1, NA, NA, NA, NA),
          "cncccc",
          add_data)
      
      tbl <- dplyr::bind_cols(tbl, additional_data)
    }
    
    # # If the tz offset is 0, return the data frame without filtering it
    # if (gmt_offset == 0){
    #   return(tbl) 
    # }
    
    # # Filter data frame to only include data for requested years
    #  tbl <- 
    #   dplyr::filter(tbl, 
    #                 year >= startyear &
    #                   year <= endyear)
    
    return(tbl)
  }
}

# Function for getting data from an additional data category
get_df_from_category <- function(category_key,
                                 field_lengths,
                                 scale_factor,
                                 data_types,
                                 add_data) {
  
  # Create a progress bar object
  pb <- 
    progress::progress_bar$new(
      format = "  processing :what [:bar] :percent",
      total  = nchar(data_types)
    )
  
  column_names <- paste0(category_key %>% tolower(), "_", seq(field_lengths))
  
  dtypes <- c()
  
  for (i in seq(nchar(data_types))) {
    
    dtypes <- 
      c(dtypes, ifelse(substr(data_types, i, i) == "n", "numeric", "character"))
  }
  
  data_strings <- 
    add_data %>%
    stringr::str_extract(paste0(category_key, ".*"))
  
  res_list <- list()
  
  for (i in seq(field_lengths)){
    
    if (i == 1) {
      substr_start <- 4
      substr_end <- substr_start + (field_lengths[i] - 1)
    } else {
      substr_start <- substr_end + 1
      substr_end <- substr_start + (field_lengths[i] - 1)
    }
    
    if (dtypes[i] == "numeric") {
      
      data_column <- rep(NA_real_, length(data_strings))
      
      for (j in seq(data_strings)) {
        
        if (!is.na(data_strings[j])) {
          
          data_column[j] <-
            (substr(data_strings[j], substr_start, substr_end) %>%
               as.numeric()) / scale_factor[i]
        }
      }
    }
    
    if (dtypes[i] == "character"){
      
      data_column <- rep(NA_character_, length(data_strings))
      
      for (j in seq(data_strings)) {
        
        if (!is.na(data_strings[j])) {
          data_column[j] <- 
            substr(data_strings[j], substr_start, substr_end)
        }
      }
    }
    
    res_list <- res_list %>% append(list(data_column))
    
    # Add tick to progress bar
    pb$tick(tokens = list(what = category_key))
  }
  
  names(res_list) <- column_names
  
  res_list %>% dplyr::as_tibble()
}
