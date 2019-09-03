#' Get met station data from the ISD dataset
#' @description Obtain one or more years of meteorological data for a station
#' from the NCEI Integrated Surface Dataset (ISD).
#' @param station_id a station identifier composed of the station's USAF and
#' WBAN numbers, separated by a hyphen.
#' @param startyear the starting year for the collected data.
#' @param endyear the ending year for the collected data.
#' @param full_data include additional meteorological data found in the
#' dataset's additional data section?
#' @param add_data_report selecting TRUE will provide a data frame with
#' information on which additional data categories are available for the
#' selected station during the specified years.
#' @param select_additional_data a vector of categories for additional
#' meteorological data to include (instead of all available categories).
#' @param use_local_files option to use data files already available locally.
#' @param local_file_dir path to local meteorological data files.
#' @return Returns a data frame with 18 variables. Times are recorded 
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
#' @examples 
#' \dontrun{
#' # Obtain a listing of all stations within a bounding box and
#' # then isolate a single station and obtain a string with the
#' # \code{usaf} and \code{wban} identifiers.
#' # Pass that identifier string to the \code{get_isd_station_data}
#' # function to obtain a data frame of meteorological data for
#' # the year 2010
#' stations_within_domain <-
#'   get_isd_stations(
#'     lower_lat = 49.000,
#'     upper_lat = 49.500,
#'     lower_lon = -123.500,
#'     upper_lon = -123.000)
#'                         
#' cypress_bowl_snowboard_stn <-
#'   select_isd_station(
#'     stn_df = stations_within_domain,
#'     name = "cypress bowl snowboard")
#' 
#' cypress_bowl_snowboard_stn_met_data <-
#'   get_isd_station_data(
#'     station_id = cypress_bowl_snowboard_stn,
#'     startyear = 2010,
#'     endyear = 2010)
#'  
#' # Get a vector of available additional data categories for a station
#' # during the specied years
#' additional_data_categories <- 
#'   get_isd_station_data(
#'     station_id = "722315-53917",
#'     startyear = 2014,
#'     endyear = 2015,
#'     add_data_report = TRUE)
#'  
#' # Obtain two years of data from data files stored on disk (in this
#' # case, inside the package itself)
#' df_mandatory_data_local <- 
#'   get_isd_station_data(
#'     station_id = "999999-63897",
#'     startyear = 2013,
#'     endyear = 2014,
#'     use_local_files = TRUE,
#'     local_file_dir = system.file(package = "stationary"))
#' }
#' @import readr dplyr downloader progress
#' @importFrom stringr str_detect str_extract
#' @importFrom plyr round_any
#' @export
get_isd_station_data <- function(station_id,
                                 startyear,
                                 endyear,
                                 full_data = FALSE,
                                 add_data_report = FALSE,
                                 select_additional_data = NULL,
                                 use_local_files = FALSE,
                                 local_file_dir = NULL){
  
  # Check whether `startyear` and `endyear` are both numeric
  if (!is.numeric(startyear) | !is.numeric(endyear)) {
    stop("Please enter numeric values for the starting and ending years")
  }
  
  # Check whether `startyear` and `endyear` are in the correct order
  if (startyear > endyear) {
    stop("Please enter the starting and ending years in the correct order")
  }
  
  # Get the tz name
  tz_name <- 
    history_tbl %>%
    dplyr::filter(id == station_id) %>%
    dplyr::pull(tz_name)
  
  # # if 'gmt_offset' is positive, then also download year of data previous to
  # # beginning of series
  # if (gmt_offset > 0) startyear <- startyear - 1
  # 
  # # if 'gmt_offset' is negative, then also download year of data following the
  # # end of series
  # if (gmt_offset < 0 & year(Sys.time()) != endyear) endyear <- endyear + 1
  # 
  # if (isTRUE(use_local_files)) {
  #   
  #   for (i in startyear:endyear){
  #     if (i == startyear){
  #       data_files <- vector(mode = "character")
  #     }
  #     
  #     data_files <- 
  #       c(data_files,
  #         paste0(
  #           sprintf(
  #             "%06d",
  #             as.numeric(unlist(strsplit(station_id,
  #                                        "-"))[1])),
  #           "-",
  #           sprintf(
  #             "%05d",
  #             as.numeric(unlist(strsplit(station_id,
  #                                        "-"))[2])),
  #           "-", i, ".gz"))
  #   }
  #   
  #   # Verify that local files are available
  #   all_local_files_available <-
  #     all(file.exists(paste0(local_file_dir, "/", data_files)))
  # }
  
  if (use_local_files == FALSE) {
    
    # Create a temporary folder to deposit downloaded files
    temp_folder <- tempdir()
    
    # If a station ID string provided,
    # download the gzip-compressed data files for the years specified
    for (i in startyear:endyear){
      if (i == startyear){
        data_files <- vector(mode = "character")
      }
      
      data_file_to_download <- 
        paste0(
          sprintf("%06d",
                  as.numeric(unlist(strsplit(station_id, "-"))[1])),
          "-",
          sprintf("%05d",
                  as.numeric(unlist(strsplit(station_id, "-"))[2])),
          "-", i, ".gz")
      
      try(
        downloader::download(
          url = paste0("https://www1.ncdc.noaa.gov/pub/data/noaa/", i,
                       "/", data_file_to_download),
          destfile = file.path(temp_folder, data_file_to_download)
        ),
        silent = TRUE
      )
      
      if (file.info(
        file.path(temp_folder, data_file_to_download))$size > 1){
        
        data_files <- c(data_files, data_file_to_download)
      }
    }
  }
  
  if (isTRUE(add_data_report)) {
    
    # Create vector of additional data categories
    data_categories <-
      c("AA1", "AB1", "AC1", "AD1", "AE1",
        "AG1", "AH1", "AI1", "AJ1", "AK1",
        "AL1", "AM1", "AN1", "AO1", "AP1",
        "AU1", "AW1", "AX1", "AY1", "AZ1",
        "CB1", "CF1", "CG1", "CH1", "CI1",
        "CN1", "CN2", "CN3", "CN4", "CR1",
        "CT1", "CU1", "CV1", "CW1", "CX1",
        "CO1", "CO2", "ED1", "GA1", "GD1",
        "GF1", "GG1", "GH1", "GJ1", "GK1",
        "GL1", "GM1", "GN1", "GO1", "GP1",
        "GQ1", "GR1", "HL1", "IA1", "IA2",
        "IB1", "IB2", "IC1", "KA1", "KB1",
        "KC1", "KD1", "KE1", "KF1", "KG1",
        "MA1", "MD1", "ME1", "MF1", "MG1",
        "MH1", "MK1", "MV1", "MW1", "OA1",
        "OB1", "OC1", "OE1", "RH1", "SA1",
        "ST1", "UA1", "UG1", "UG2", "WA1",
        "WD1", "WG1")
    
    # Get additional data portions of records, exluding remarks
    for (i in 1:length(data_files)){
      
      if (use_local_files == FALSE){
        add_data <- readLines(file.path(temp_folder, data_files[i]))
      }
      
      if (use_local_files == TRUE){
        add_data <- readLines(file.path(local_file_dir, data_files[i]))
      }
      
      if (i == 1){
        all_add_data <- add_data
      }
      
      if (i > 1){
        all_add_data <- c(all_add_data, add_data)
      }
    }
    
    # Obtain data counts for all additional parameters
    for (i in 1:length(data_categories)){
      if (i == 1){
        data_categories_counts <-
          vector(mode = "numeric", length = length(data_categories))
      }
      
      data_categories_counts[i] <-
        sum(stringr::str_detect(all_add_data, data_categories[i]))
    }
    
    # Determine which data categories have data
    data_categories_available <-
      data_categories[which(data_categories_counts > 0)]
    
    # Get those data counts that are greater than 0
    data_categories_counts <-
      data_categories_counts[which(data_categories_counts > 0)]
    
    # Create a data frame composed of categories and their counts
    data_categories_df <- 
      data.frame(
        category = data_categories_available,
        total_count = data_categories_counts
      )
    
    return(data_categories_df)
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
  
  for (i in seq(data_files)){
    
    if (file.exists(data_files[i])){
      
      # Read data from mandatory data section of each file,
      # which is a fixed-width string
      data <- 
        readr::read_fwf(
          data_files[i],
          fwf_widths(column_widths),
          col_types = "ccciiiiiciicicciccicicccccccicicic"
        )
      
      # Remove select columns from data frame
      data <- 
        data[, c(2:8, 10:11, 13, 16, 19, 21, 29, 31, 33)]
      
      # Apply new names to the data frame columns
      names(data) <-
        c("usaf", "wban", "year", "month",
          "day", "hour", "minute", "lat", "lon",
          "elev", "wd", "ws", "ceil_hgt",
          "temp", "dew_point", "atmos_pres")
      
      # Correct the latitude values
      data$lat <- data$lat/1000
      
      # Correct the longitude values
      data$lon <- data$lon/1000
      
      # Correct the wind direction values
      data$wd <- ifelse(data$wd == 999, NA_integer_, data$wd)
      
      # Correct the wind speed values
      data$ws <- ifelse(data$ws == 9999, NA_real_, data$ws/10)
      
      # Correct the temperature values
      data$temp <- ifelse(data$temp == 9999, NA_real_, data$temp/10)
      
      # Correct the dew point values
      data$dew_point <- ifelse(data$dew_point == 9999, NA_real_, data$dew_point/10)
      
      # Correct the atmospheric pressure values
      data$atmos_pres <- 
        ifelse(data$atmos_pres == 99999, NA_real_, data$atmos_pres/10)
      
      # Correct the ceiling height values
      data$ceil_hgt <- ifelse(data$ceil_hgt == 99999, NA_integer_, data$ceil_hgt)
      
      # Calculate RH values using the August-Roche-Magnus approximation
      for (j in 1:nrow(data)){
        
        if (j == 1) rh <- vector("numeric")
        
        rh_j <- 
          ifelse(is.na(data$temp[j]) | is.na(data$dew_point[j]), NA,
                 100 * (exp((17.625 * data$dew_point[j]) /
                              (243.04 + data$dew_point[j]))/
                          exp((17.625 * (data$temp[j])) /
                                (243.04 + (data$temp[j])))))
        
        # Round data to the nearest 0.1
        rh_j <- round_any(as.numeric(rh_j), 0.1, f = round)
        
        rh <- c(rh, rh_j)
      }
      
      # Add RH values to the data frame
      data$rh <- rh
      
      if (i == 1) {
        large_data_frame <- data
      }
      
      if (i > 1) {
        large_data_frame <- dplyr::bind_rows(large_data_frame, data)
      }
    }
  }
  
  # Create POSIXct time values from the time elements
  large_data_frame$time <- 
    ISOdatetime(
      year = large_data_frame$year,
      month = large_data_frame$month,
      day = large_data_frame$day,
      hour = large_data_frame$hour,
      min = large_data_frame$minute,
      sec = 0,
      tz = "GMT"
    )
  
  # Adjust to local time if the time zone had been resolved
  if (!is.na(tz_name)) {
    
    tz_offsets <- 
      lutz::tz_offset(dt = as.Date(large_data_frame$time), tz = tz_name) %>%
      dplyr::pull(utc_offset_h)
    
    large_data_frame$tz_offset <- tz_offsets
    
    large_data_frame <- 
      large_data_frame %>%
      dplyr::mutate(time = dplyr::case_when(
        !is.na(tz_offset) ~ time + (3600 * tz_offset),
        TRUE ~ time
      ))
  }
  
  large_data_frame <-
    large_data_frame %>%
    dplyr::mutate(id = station_id) %>%
    dplyr::select(id, time, wd, ws, ceil_hgt, temp, dew_point, atmos_pres, rh)
  
  # # if 'gmt_offset' is positive, add back a year to 'startyear'
  # if (gmt_offset > 0) startyear <- startyear + 1
  # 
  # # if 'gmt_offset' is negative, subtract the added year from 'endyear'
  # if (gmt_offset < 0 & year(Sys.time()) != endyear) endyear <- endyear - 1
  
  # If additional data categories specified, then set 'full_data' to TRUE
  # to enter that conditional block
  if (!is.null(select_additional_data)) full_data <- TRUE
  
  if (full_data == FALSE){
    
    # # Filter data frame to only include data for requested years
    # large_data_frame <-
    #   large_data_frame %>%
    #   dplyr::filter(year >= startyear & year <= endyear)
    
    return(large_data_frame)
  }
  
  if (full_data == TRUE){
    
    # Get additional data portions of records, exluding remarks
    for (i in 1:length(data_files)){
      
      if (use_local_files == FALSE){
        
        add_data <- 
          readLines(data_files[i])
      }
      
      if (use_local_files == TRUE){
        
        add_data <- 
          readLines(data_files[i])
      }
      
      if (i == 1){
        all_add_data <- add_data
      }
      
      if (i > 1){
        all_add_data <- c(all_add_data, add_data)
      }
    }
    
    # Create vector of additional data categories
    data_categories <- additional_data_categories()
    
    expanded_column_names <- additional_data_fields()
    
    # Function for getting data from an additional data category
    get_df_from_category <- function(category_key,
                                     field_lengths,
                                     scale_factor,
                                     data_types,
                                     add_data) {
      
      # Parse string of characters representing data types
      if (class(data_types) == "character" &
          length(data_types) == 1 &
          all(unique(unlist(strsplit(data_types, ""))) %in% c("c", "n"))) {
        
        for (i in 1:nchar(data_types)){
          
          if (i == 1){
            subst_data_types <- vector(mode = "character")
            
            # Create a progress bar object
            pb <- progress_bar$new(
              format = "  processing :what [:bar] :percent",
              total = nchar(data_types))
            
          }
          subst_data_types <- 
            c(subst_data_types,
              ifelse(substr(data_types, i, i) == "n",
                     "numeric", "character"))
          
        }
        
        data_types <- subst_data_types
      }
      
      data_strings <- 
        stringr::str_extract(add_data, paste0(category_key, ".*"))
      
      for (i in 1:length(field_lengths)){
        
        if (i == 1){
          df_from_category <-
            as.data.frame(mat.or.vec(nr = length(data_strings),
                                     nc = length(field_lengths)))
          
          colnames(df_from_category) <- 
            paste(tolower(category_key),
                  rep = 1:length(field_lengths),
                  sep = "_")
          
          substr_start <- 4
          substr_end <- substr_start + (field_lengths[i] - 1)
        }
        
        if (i > 1){
          
          substr_start <- substr_end + 1
          substr_end <- substr_start + (field_lengths[i] - 1)
        }
        
        if (data_types[i] == "numeric"){
          
          for (j in 1:length(data_strings)){
            
            if (j == 1) data_column <- vector(mode = data_types[i])
            
            data_element <-
              ifelse(!is.na(data_strings[j]),
                     as.numeric(substr(data_strings[j],
                                       substr_start,
                                       substr_end))/scale_factor[i],
                     NA)
            
            data_column <- c(data_column, data_element)
          }
        }
        
        if (data_types[i] == "character"){
          
          for (j in 1:length(data_strings)){
            
            if (j == 1) data_column <- vector(mode = data_types[i])
            
            data_element <-
              ifelse(!is.na(data_strings[j]),
                     substr(data_strings[j],
                            substr_start,
                            substr_end),
                     NA)
            
            data_column <- c(data_column, data_element)
          }
        }
        
        df_from_category[, i] <- data_column
        
        # Add tick to progress bar
        pb$tick(tokens = list(what = category_key))
      }
      
      return(df_from_category)
    }
    
    # Determine which additional parameters have been measured
    for (i in 1:length(data_categories)){
      
      if (i == 1){
        data_categories_counts <-
          vector(mode = "numeric",
                 length = length(data_categories))
      }
      
      data_categories_counts[i] <-
        sum(str_detect(all_add_data, data_categories[i]))
    }
    
    # Filter those measured parameters and obtain string of identifiers
    significant_params <- data_categories[which(data_categories_counts >= 1)]
    
    # Filter the significantly available extra parameters by those specified
    if (!is.null(select_additional_data)){
      
      significant_params <-
        significant_params[which(significant_params %in%
                                   select_additional_data)]
    }
    
    # AA1 - liquid precipitation: period quantity, depth dimension
    if (data_categories[1] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AA1",
          c(2, 4, 1, 1),
          c(1, 10, NA, NA),
          "nncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AB1 - liquid precipitation: monthly total
    if (data_categories[2] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AB1",
          c(5, 1, 1),
          c(10, NA, NA),
          "ncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AC1 - precipitation observation history
    if (data_categories[3] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AC1",
          c(1, 1, 1),
          c(NA, NA, NA),
          "ccc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AD1 - liquid precipitation, greatest amount in 24 hours, for the month
    if (data_categories[4] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AD1",
          c(5, 1, 4, 4, 4, 1),
          c(10, NA, NA, NA, NA, NA),
          "nccccc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AG1 - precipitation estimated observation
    if (data_categories[6] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AG1",
          c(1, 3),
          c(NA, 1),
          "cn",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AH1 - liquid precipitation maximum short duration, for the month (1)
    if (data_categories[7] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AH1",
          c(3, 4, 1, 6, 1),
          c(1, 10, NA, NA, NA),
          "nnccc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AI1 - liquid precipitation maximum short duration, for the month (2)
    if (data_categories[8] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AI1",
          c(4, 1, 6, 1),
          c(10, NA, NA, NA),
          "nccc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AJ1 - snow depth
    if (data_categories[9] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AJ1",
          c(4, 1, 1, 6, 1, 1),
          c(1, NA, NA, 10, NA, NA),
          "nccncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AK1 - snow depth greatest depth on the ground, for the month
    if (data_categories[10] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AK1",
          c(4, 1, 6, 1),
          c(1, NA, NA, NA),
          "nccc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AL1 - snow accumulation
    if (data_categories[11] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AL1",
          c(2, 3, 1, 1),
          c(1, 1, NA, NA),
          "nncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AM1 - snow accumulation greatest amount in 24 hours, for the month
    if (data_categories[12] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AM1",
          c(4, 1, 4, 4, 4, 1),
          c(10, NA, NA, NA, NA, NA),
          "nccccc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AN1 - snow accumulation for the month
    if (data_categories[13] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AN1",
          c(3, 4, 1, 1),
          c(1, 10, NA, NA),
          "nncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AO1 - liquid precipitation
    if (data_categories[14] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AO1",
          c(2, 4, 1, 1),
          c(1, 10, NA, NA),
          "nncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AP1 - 15-minute liquid precipitation
    if (data_categories[15] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AP1",
          c(4, 1, 1),
          c(10, NA, NA),
          "ncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AW1 - present weather observation 
    if (data_categories[17] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AW1",
          c(2, 1),
          c(NA, NA),
          "cc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AX1 - past weather observation (1)
    if (data_categories[18] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AX1",
          c(2, 1, 2, 1),
          c(NA, NA, 1, NA),
          "ccnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AY1 - past weather observation (2)
    if (data_categories[19] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AY1",
          c(1, 1, 2, 1),
          c(NA, NA, 1, NA),
          "ccnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AZ1 - past weather observation (3)
    if (data_categories[20] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "AZ1",
          c(1, 1, 2, 1),
          c(NA, NA, 1, NA),
          "ccnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CB1 - subhourly observed liquid precipitation: secondary sensor
    if (data_categories[21] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CB1",
          c(2, 6, 1, 1),
          c(1, 10, NA, NA),
          "nncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CF1 - hourly fan speed
    if (data_categories[22] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CF1",
          c(4, 1, 1),
          c(10, NA, NA),
          "ncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CG1 - subhourly observed liquid precipitation: primary sensor
    if (data_categories[23] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CG1",
          c(6, 1, 1),
          c(10, NA, NA),
          "ncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CH1 - hourly/subhourly RH/temperatures
    if (data_categories[24] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CH1",
          c(2, 5, 1, 1, 4, 1, 1),
          c(1, 10, NA, NA, 10, NA, NA),
          "nnccncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CN3 - secondary hourly diagnostics (1)
    if (data_categories[28] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CN3",
          c(6, 1, 1, 6, 1, 1),
          c(10, NA, NA, 10, NA, NA),
          "nccncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CR1 - CRN control
    if (data_categories[30] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CR1",
          c(5, 1, 1),
          c(1000, NA, NA),
          "ncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CT1 - subhourly temperatures
    if (data_categories[31] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CT1",
          c(5, 1, 1),
          c(10, NA, NA),
          "ncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CU1 - hourly temperatures
    if (data_categories[32] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CU1",
          c(5, 1, 1, 4, 1, 1),
          c(10, NA, NA, 10, NA, NA),
          "nccncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CW1 - subhourly wetness
    if (data_categories[34] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CW1",
          c(5, 1, 1, 5, 1, 1),
          c(10, NA, NA, 10, NA, NA),
          "nccncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CO1 - network metadata
    if (data_categories[36] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CO1",
          c(2, 3),
          c(1, 1),
          "nn",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CO2 - US cooperative network element time offset
    if (data_categories[37] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "CO2",
          c(3, 5),
          c(NA, 10),
          "cn",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # ED1 - runway visual range
    if (data_categories[38] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "ED1",
          c(2, 1, 4, 1),
          c(0.1, NA, 1, NA),
          "ncnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GA1 - sky cover layer
    if (data_categories[39] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GA1",
          c(2, 1, 6, 1, 2, 1),
          c(NA, NA, 1, NA, NA, NA),
          "ccnccc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GD1 - sky cover summation state
    if (data_categories[40] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GD1",
          c(1, 2, 1, 6, 1, 1),
          c(NA, NA, NA, 1, NA, NA),
          "cccncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GG1 - below station cloud layer
    if (data_categories[42] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GG1",
          c(2, 1, 5, 1, 2, 1, 2, 1),
          c(NA, NA, 1, NA, NA, NA, NA, NA),
          "ccnccccc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GJ1 - sunshine observation (1)
    if (data_categories[44] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GJ1",
          c(4, 1),
          c(1, NA),
          "nc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GK1 - sunshine observation (2)
    if (data_categories[45] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GK1",
          c(3, 1),
          c(1, NA),
          "nc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GL1 - sunshine observation for the month
    if (data_categories[46] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GL1",
          c(5, 1),
          c(1, NA),
          "nc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GO1 - net solar radiation
    if (data_categories[49] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GO1",
          c(4, 4, 1, 4, 1, 4, 1),
          c(1, 1, NA, 1, NA, 1, NA),
          "nncncnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GQ1 - hourly solar angle
    if (data_categories[51] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GQ1",
          c(4, 4, 1, 4, 1),
          c(1, 10, NA, 10, NA),
          "nncnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GR1 - hourly extraterrestrial radiation
    if (data_categories[52] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "GR1",
          c(4, 4, 1, 4, 1),
          c(1, 1, NA, 1, NA),
          "nncnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # HL1 - hail data
    if (data_categories[53] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "HL1",
          c(3, 1),
          c(10, NA),
          "nc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # IA1 - ground surface data
    if (data_categories[54] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "IA1",
          c(2, 1),
          c(NA, NA),
          "cc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # IA2 - ground surface observation
    if (data_categories[55] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "IA2",
          c(3, 5, 1),
          c(10, 10, NA),
          "nnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # IB2 - hourly surface temperature sensor
    if (data_categories[57] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "IB2",
          c(5, 1, 1, 4, 1, 1),
          c(10, NA, NA, 10, NA, NA),
          "nccncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KA1 - temperature data
    if (data_categories[59] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KA1",
          c(3, 1, 5, 1),
          c(10, NA, 10, NA),
          "ncnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KB1 - average air temperature
    if (data_categories[60] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KB1",
          c(3, 1, 5, 1),
          c(10, NA, 10, NA),
          "ncnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KC1 - extreme air temperature for the month
    if (data_categories[61] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KC1",
          c(1, 1, 5, 6, 1),
          c(NA, NA, 10, NA, NA),
          "ccncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KD1 - heating/cooling degree days
    if (data_categories[62] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KD1",
          c(3, 1, 4, 1),
          c(1, NA, 1, NA),
          "ncnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KF1 - hourly calculated temperature
    if (data_categories[64] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KF1",
          c(5, 1),
          c(10, NA),
          "nc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KG1 - average dew point and wet bulb temperature
    if (data_categories[65] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "KG1",
          c(3, 1, 5, 1, 1),
          c(1, NA, 100, NA, NA),
          "ncncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MA1 - atmospheric pressure observation
    if (data_categories[66] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MA1",
          c(5, 1, 5, 1),
          c(10, NA, 10, NA),
          "ncnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MD1 - atmospheric pressure change
    if (data_categories[67] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MD1",
          c(1, 1, 3, 1, 4, 1),
          c(NA, NA, 10, NA, 10, NA),
          "ccncnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # ME1 - geopotential height isobaric level
    if (data_categories[68] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "ME1",
          c(1, 4, 1),
          c(NA, 1, NA),
          "cnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MF1 - atmospheric pressure observation (STP/SLP)
    if (data_categories[69] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MF1",
          c(5, 1, 5, 1),
          c(10, NA, 10, NA),
          "ncnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MG1 - atmospheric pressure observation
    if (data_categories[70] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MG1",
          c(5, 1, 5, 1),
          c(10, NA, 10, NA),
          "ncnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MV1 - present weather in vicinity observation
    if (data_categories[73] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MV1",
          c(2, 1),
          c(NA, NA),
          "cc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MW1 - present weather observation 
    if (data_categories[74] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "MW1",
          c(2, 1),
          c(NA, NA),
          "cc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # OA1 - supplementary wine observation 
    if (data_categories[75] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "OA1",
          c(1, 2, 4, 1),
          c(NA, 1, 10, NA),
          "cnnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # OC1 - wind gust observation
    if (data_categories[77] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "OC1",
          c(4, 1),
          c(10, NA),
          "nc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # OE1 - summary of day wind observation
    if (data_categories[78] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "OE1",
          c(1, 2, 5, 3, 4, 1),
          c(NA, 1, 100, 1, 10, NA),
          "cnnnnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # RH1 - relative humidity
    if (data_categories[79] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "RH1",
          c(3, 1, 3, 1, 1),
          c(1, NA, 1, NA, NA),
          "ncncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # SA1 - sea surface temperature observation
    if (data_categories[80] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "SA1",
          c(4, 1),
          c(10, NA),
          "nc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # UA1 - wave measurement
    if (data_categories[82] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "UA1",
          c(1, 2, 3, 1, 2, 1),
          c(NA, 1, 10, NA, NA, NA),
          "cnnccc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # UG1 - wave measurement primary swell
    if (data_categories[83] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "UG1",
          c(2, 3, 3, 1),
          c(1, 10, 1, NA),
          "nnnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # UG2 - wave measurement secondary swell
    if (data_categories[84] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "UG2",
          c(2, 3, 3, 1),
          c(1, 10, 1, NA),
          "nnnc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # WA1 - platform ice accretion
    if (data_categories[85] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "WA1",
          c(1, 3, 1, 1),
          c(NA, 10, NA, NA),
          "cncc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
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
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # WG1 - water surface ice historical observation
    if (data_categories[87] %in% significant_params){
      
      additional_data <-
        get_df_from_category(
          "WG1",
          c(2, 2, 2, 2, 2, 1),
          c(NA, 1, NA, NA, NA, NA),
          "cncccc",
          all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # # If the tz offset is 0, return the data frame without filtering it
    # if (gmt_offset == 0){
    #   return(large_data_frame) 
    # }
    
    # # Filter data frame to only include data for requested years
    # large_data_frame <- 
    #   dplyr::filter(large_data_frame, 
    #                 year >= startyear &
    #                   year <= endyear)
    
    return(large_data_frame)
  }
}
