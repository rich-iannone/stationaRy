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
#' @importFrom plyr round_any
#' @importFrom lubridate year month mday hour minute
#' @import dplyr
#' @import readr
#' @importFrom stringr str_detect str_extract
#' @import downloader
#' @import progress
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
#' 
#' @examples 
#' \dontrun{
#' # Obtain a listing of all stations within a bounding box and
#' # then isolate a single station and obtain a string with the
#' # \code{usaf} and \code{wban} identifiers.
#' # Pass that identifier string to the \code{get_isd_station_data}
#' # function to obtain a data frame of meteorological data for
#' # the year 2010
#' stations_within_domain <-
#'   get_isd_stations(lower_lat = 49.000,
#'                    upper_lat = 49.500,
#'                    lower_lon = -123.500,
#'                    upper_lon = -123.000)
#'                         
#' cypress_bowl_snowboard_stn <-
#'   select_isd_station(stn_df = stations_within_domain,
#'                      name = "cypress bowl snowboard")
#' 
#' cypress_bowl_snowboard_stn_met_data <-
#'   get_isd_station_data(station_id = cypress_bowl_snowboard_stn,
#'                        startyear = 2010,
#'                        endyear = 2010)
#'  
#' # Get a vector of available additional data categories for a station
#' # during the specied years
#' additional_data_categories <- 
#'   get_isd_station_data(station_id = "722315-53917",
#'                        startyear = 2014,
#'                        endyear = 2015,
#'                        add_data_report = TRUE)
#'  
#' # Obtain two years of data from data files stored on disk (in this
#' # case, inside the package itself)
#' df_mandatory_data_local <- 
#'   get_isd_station_data(
#'     station_id = "999999-63897",
#'     startyear = 2013,
#'     endyear = 2014,
#'     use_local_files = TRUE,
#'     local_file_dir = system.file(package = "stationaRy")
#' )
#' }
#' @export get_isd_station_data

get_isd_station_data <- function(station_id,
                                 startyear,
                                 endyear,
                                 full_data = FALSE,
                                 add_data_report = FALSE,
                                 select_additional_data = NULL,
                                 use_local_files = FALSE,
                                 local_file_dir = NULL){
  
  usaf <- wban <- year <- NA
  
  # Check whether 'startyear' and 'endyear' are both numeric
  if (!is.numeric(startyear) | !is.numeric(endyear)) {
    stop("Please enter numeric values for the starting and ending years")
  }
  
  # Check whether 'startyear' and 'endyear' are in the correct order
  if (startyear > endyear) {
    stop("Please enter the starting and ending years in the correct order")
  }
  
  # Obtain the GMT offset value for this ISD station
  gmt_offset <- 
    as.numeric(filter(get_isd_stations(),
                      usaf == as.numeric(unlist(strsplit(station_id,
                                                         "-"))[1]),
                      wban == as.numeric(unlist(strsplit(station_id,
                                                         "-"))[2]))[,11])
  
  # if 'gmt_offset' is positive, then also download year of data previous to
  # beginning of series
  if (gmt_offset > 0) startyear <- startyear - 1
  
  # if 'gmt_offset' is negative, then also download year of data following the
  # end of series
  if (gmt_offset < 0 & year(Sys.time()) != endyear) endyear <- endyear + 1
  
  if (use_local_files == TRUE){
    
    for (i in startyear:endyear){
      
      if (i == startyear){
        
        data_files <- vector(mode = "character")
      }
      
      data_files <- 
        c(data_files,
          paste0(sprintf("%06d",
                         as.numeric(unlist(strsplit(station_id,
                                                    "-"))[1])),
                 "-",
                 sprintf("%05d",
                         as.numeric(unlist(strsplit(station_id,
                                                    "-"))[2])),
                 "-", i, ".gz"))
    }
    
    # Verify that local files are available
    all_local_files_available <-
      all(file.exists(paste0(local_file_dir, "/", data_files)))
  }
  
  if (use_local_files == FALSE){
    
    # Create a temporary folder to deposit downloaded files
    temp_folder <- tempdir()
    
    # If a station ID string provided,
    # download the gzip-compressed data files for the years specified
    for (i in startyear:endyear){
      
      if (i == startyear){
        
        data_files <- vector(mode = "character")
      }
      
      data_file_to_download <- 
        paste0(sprintf("%06d",
                       as.numeric(unlist(strsplit(station_id,
                                                  "-"))[1])),
               "-",
               sprintf("%05d",
                       as.numeric(unlist(strsplit(station_id,
                                                  "-"))[2])),
               "-", i, ".gz")
      
      try(download(url = paste0("ftp://ftp.ncdc.noaa.gov/pub/data/noaa/", i,
                                "/", data_file_to_download),
                   destfile = file.path(temp_folder, data_file_to_download)),
          silent = TRUE)
      
      if (file.info(file.path(temp_folder,
                              data_file_to_download))$size > 1){
        
        data_files <- c(data_files,
                        data_file_to_download)
      }
    }
  }
  
  if (add_data_report == TRUE){
    
    # Create vector of additional data categories
    data_categories <-
      c("AA1", "AB1", "AC1", "AD1", "AE1", "AG1", "AH1", "AI1", "AJ1",
        "AK1", "AL1", "AM1", "AN1", "AO1", "AP1", "AU1", "AW1", "AX1",
        "AY1", "AZ1", "CB1", "CF1", "CG1", "CH1", "CI1", "CN1", "CN2",
        "CN3", "CN4", "CR1", "CT1", "CU1", "CV1", "CW1", "CX1", "CO1",
        "CO2", "ED1", "GA1", "GD1", "GF1", "GG1", "GH1", "GJ1", "GK1",
        "GL1", "GM1", "GN1", "GO1", "GP1", "GQ1", "GR1", "HL1", "IA1",
        "IA2", "IB1", "IB2", "IC1", "KA1", "KB1", "KC1", "KD1", "KE1",
        "KF1", "KG1", "MA1", "MD1", "ME1", "MF1", "MG1", "MH1", "MK1",
        "MV1", "MW1", "OA1", "OB1", "OC1", "OE1", "RH1", "SA1", "ST1",
        "UA1", "UG1", "UG2", "WA1", "WD1", "WG1")
    
    # Get additional data portions of records, exluding remarks
    for (i in 1:length(data_files)){
      
      if (use_local_files == FALSE){
        
        add_data <- 
          readLines(file.path(temp_folder,
                              data_files[i]))
      }
      
      if (use_local_files == TRUE){
        
        add_data <- 
          readLines(file.path(local_file_dir,
                              data_files[i]))
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
          vector(mode = "numeric",
                 length = length(data_categories))
      }
      
      data_categories_counts[i] <-
        sum(str_detect(all_add_data, data_categories[i]))
    }
    
    # Determine which data categories have data
    data_categories_available <-
      data_categories[which(data_categories_counts > 0)]
    
    # Get those data counts that are greater than 0
    data_categories_counts <-
      data_categories_counts[which(data_categories_counts > 0)]
    
    # Create a data frame composed of categories and their counts
    data_categories_df <- 
      data.frame(category = data_categories_available,
                 total_count = data_categories_counts)
    
    return(data_categories_df)
  }
  
  # Define column widths for fixed-width data in the mandatory section of
  # the ISD data files
  column_widths <- 
    c(4, 6, 5, 4, 2, 2, 2, 2, 1, 6,
      7, 5, 5, 5, 4, 3, 1, 1, 4, 1,
      5, 1, 1, 1, 6, 1, 1, 1, 5, 1,
      5, 1, 5, 1)
  
  if (use_local_files == TRUE){
    
    data_files <- file.path(local_file_dir,
                            data_files)
  }
  
  if (use_local_files == FALSE){
    
    data_files <- file.path(temp_folder,
                            data_files)
  }
  
  for (i in 1:length(data_files)){
    
    if (file.exists(data_files[i])){
      
      # Read data from mandatory data section of each file,
      # which is a fixed-width string
      data <- 
        read_fwf(data_files[i],
                 fwf_widths(column_widths),
                 col_types = "ccciiiiiciicicciccicicccccccicicic")
      
      # Remove select columns from data frame
      data <- data[, c(2:8, 10:11, 13, 16, 19, 21, 29, 31, 33)]
      
      # Apply new names to the data frame columns
      names(data) <-
        c("usaf", "wban", "year", "month", "day", "hour", "minute",
          "lat", "lon", "elev", "wd", "ws", "ceil_hgt",
          "temp", "dew_point", "atmos_pres")
      
      # Correct the latitude values
      data$lat <- data$lat/1000
      
      # Correct the longitude values
      data$lon <- data$lon/1000
      
      # Correct the wind direction values
      data$wd <- 
        ifelse(data$wd == 999, NA, data$wd)
      
      # Correct the wind speed values
      data$ws <- 
        ifelse(data$ws == 9999, NA, data$ws/10)
      
      # Correct the temperature values
      data$temp <- 
        ifelse(data$temp == 9999, NA, data$temp/10)
      
      # Correct the dew point values
      data$dew_point <- 
        ifelse(data$dew_point == 9999, NA, data$dew_point/10)
      
      # Correct the atmospheric pressure values
      data$atmos_pres <- 
        ifelse(data$atmos_pres == 99999, NA, data$atmos_pres/10)
      
      # Correct the ceiling height values
      data$ceil_hgt <- 
        ifelse(data$ceil_hgt == 99999, NA, data$ceil_hgt)
      
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
      
      if (i == 1){
        large_data_frame <- data
      }
      
      if (i > 1){
        large_data_frame <- bind_rows(large_data_frame, data)
      }
    }
  }
  
  # Create POSIXct time values from the time elements
  large_data_frame$time <- 
    ISOdatetime(year = large_data_frame$year,
                month = large_data_frame$month,
                day = large_data_frame$day,
                hour = large_data_frame$hour,
                min = large_data_frame$minute,
                sec = 0,
                tz = "GMT") + (gmt_offset * 3600)
  
  # Update time component columns to reflect corrected dates/times
  large_data_frame$year <- year(large_data_frame$time)
  large_data_frame$month <- month(large_data_frame$time) 
  large_data_frame$day <- mday(large_data_frame$time)
  large_data_frame$hour <- hour(large_data_frame$time)
  large_data_frame$minute <- minute(large_data_frame$time)
  
  # Ensure that data frame columns are correctly classed
  large_data_frame$usaf <- as.character(large_data_frame$usaf)
  large_data_frame$wban <- as.character(large_data_frame$wban) 
  large_data_frame$year <- as.numeric(large_data_frame$year)
  large_data_frame$month <- as.numeric(large_data_frame$month)
  large_data_frame$day <- as.numeric(large_data_frame$day)
  large_data_frame$hour <- as.numeric(large_data_frame$hour)
  large_data_frame$minute <- as.numeric(large_data_frame$minute)
  large_data_frame$lat <- as.numeric(large_data_frame$lat)
  large_data_frame$lon <- as.numeric(large_data_frame$lon)
  large_data_frame$elev <- as.numeric(large_data_frame$elev)
  large_data_frame$wd <- as.numeric(large_data_frame$wd)
  large_data_frame$ws <- as.numeric(large_data_frame$ws)
  large_data_frame$ceil_hgt <- as.numeric(large_data_frame$ceil_hgt)
  large_data_frame$temp <- as.numeric(large_data_frame$temp)
  large_data_frame$dew_point <- as.numeric(large_data_frame$dew_point)
  large_data_frame$atmos_pres <- as.numeric(large_data_frame$atmos_pres)
  large_data_frame$rh <- as.numeric(large_data_frame$rh)
  
  # if 'gmt_offset' is positive, add back a year to 'startyear'
  if (gmt_offset > 0) startyear <- startyear + 1
  
  # if 'gmt_offset' is negative, subtract the added year from 'endyear'
  if (gmt_offset < 0 & year(Sys.time()) != endyear) endyear <- endyear - 1
  
  # If additional data categories specified, then set 'full_data' to TRUE
  # to enter that conditional block
  if (!is.null(select_additional_data)) full_data <- TRUE
  
  if (full_data == FALSE){
    
    # Filter data frame to only include data for requested years
    large_data_frame <- filter(large_data_frame, year >= startyear &
                                 year <= endyear)
    
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
    data_categories <-
      c("AA1", "AB1", "AC1", "AD1", "AE1", "AG1", "AH1", "AI1", "AJ1",
        "AK1", "AL1", "AM1", "AN1", "AO1", "AP1", "AU1", "AW1", "AX1",
        "AY1", "AZ1", "CB1", "CF1", "CG1", "CH1", "CI1", "CN1", "CN2",
        "CN3", "CN4", "CR1", "CT1", "CU1", "CV1", "CW1", "CX1", "CO1",
        "CO2", "ED1", "GA1", "GD1", "GF1", "GG1", "GH1", "GJ1", "GK1",
        "GL1", "GM1", "GN1", "GO1", "GP1", "GQ1", "GR1", "HL1", "IA1",
        "IA2", "IB1", "IB2", "IC1", "KA1", "KB1", "KC1", "KD1", "KE1",
        "KF1", "KG1", "MA1", "MD1", "ME1", "MF1", "MG1", "MH1", "MK1",
        "MV1", "MW1", "OA1", "OB1", "OC1", "OE1", "RH1", "SA1", "ST1",
        "UA1", "UG1", "UG2", "WA1", "WD1", "WG1")
    
    expanded_column_names <-
      list(
        "AA1" = c("aa1_liq_precip_period_quantity",
                  "aa1_liq_precip_depth_dimension",
                  "aa1_liq_precip_condition_code",
                  "aa1_liq_precip_quality_code"),
        "AB1" = c("ab1_liq_precip_monthly_depth_dimension",
                  "ab1_liq_precip_monthly_condition_code",
                  "ab1_liq_precip_monthly_quality_code"),
        "AC1" = c("ac1_precip_obs_history_duration_code",
                  "ac1_precip_obs_history_characteristic_code",
                  "ac1_precip_obs_history_quality_code"),
        "AD1" = c("ad1_liq_precip_greatest_amt_24h_month_depth_dimension",
                  "ad1_liq_precip_greatest_amt_24h_month_condition_code",
                  "ad1_liq_precip_greatest_amt_24h_month_dates",
                  "ad1_liq_precip_greatest_amt_24h_month_quality_code"),
        "AE1" = c("ae1_liq_precip_number_days_amt_month__01inch",
                  "ae1_liq_precip_number_days_amt_month__01inch_quality_code",
                  "ae1_liq_precip_number_days_amt_month__10inch",
                  "ae1_liq_precip_number_days_amt_month__10inch_quality_code",
                  "ae1_liq_precip_number_days_amt_month__50inch",
                  "ae1_liq_precip_number_days_amt_month__50inch_quality_code",
                  "ae1_liq_precip_number_days_amt_month_1_00inch",
                  "ae1_liq_precip_number_days_amt_month_1_00inch_quality_code"),
        "AG1" = c("ag1_precip_est_obs_discrepancy_code",
                  "ag1_precip_est_obs_est_water_depth_dimension"),
        "AH1" = c("ah1_liq_precip_max_short_dur_month_period_quantity",
                  "ah1_liq_precip_max_short_dur_month_depth_dimension",
                  "ah1_liq_precip_max_short_dur_month_condition_code",
                  "ah1_liq_precip_max_short_dur_month_end_date_time",
                  "ah1_liq_precip_max_short_dur_month_quality_code"),
        "AI1" = c("ai1_liq_precip_max_short_dur_month_period_quantity",
                  "ai1_liq_precip_max_short_dur_month_depth_dimension",
                  "ai1_liq_precip_max_short_dur_month_condition_code",
                  "ai1_liq_precip_max_short_dur_month_end_date_time",
                  "ai1_liq_precip_max_short_dur_month_quality_code"),
        "AJ1" = c("aj1_snow_depth_dimension",
                  "aj1_snow_depth_condition_code",
                  "aj1_snow_depth_quality_code",
                  "aj1_snow_depth_equiv_water_depth_dimension",
                  "aj1_snow_depth_equiv_water_condition_code",
                  "aj1_snow_depth_equiv_water_quality_code"),
        "AK1" = c("ak1_snow_depth_greatest_depth_month_depth_dimension",
                  "ak1_snow_depth_greatest_depth_month_condition_code",
                  "ak1_snow_depth_greatest_depth_month_dates_occurrence",
                  "ak1_snow_depth_greatest_depth_month_quality_code"),
        "AL1" = c("al1_snow_accumulation_period_quantity",
                  "al1_snow_accumulation_depth_dimension",
                  "al1_snow_accumulation_condition_code",
                  "al1_snow_accumulation_quality_code"),
        "AM1" = c("am1_snow_accumulation_greatest_amt_24h_month_depth_dimension",
                  "am1_snow_accumulation_greatest_amt_24h_month_condition_code",
                  "am1_snow_accumulation_greatest_amt_24h_month_dates_occurrence_1",
                  "am1_snow_accumulation_greatest_amt_24h_month_dates_occurrence_2",
                  "am1_snow_accumulation_greatest_amt_24h_month_dates_occurrence_3",
                  "am1_snow_accumulation_greatest_amt_24h_month_quality_code"),
        "AN1" = c("an1_snow_accumulation_month_period_quantity",
                  "an1_snow_accumulation_month_depth_dimension",
                  "an1_snow_accumulation_month_condition_code",
                  "an1_snow_accumulation_month_quality_code"),
        "AO1" = c("ao1_liq_precip_period_quantity_minutes",
                  "ao1_liq_precip_depth_dimension",
                  "ao1_liq_precip_condition_code",
                  "ao1_liq_precip_quality_code"),
        "AP1" = c("ap1_15_min_liq_precip_hpd_gauge_value_45_min_prior",
                  "ap1_15_min_liq_precip_hpd_gauge_value_30_min_prior",
                  "ap1_15_min_liq_precip_hpd_gauge_value_15_min_prior",
                  "ap1_15_min_liq_precip_hpd_gauge_value_at_obs_time"),
        "AU1" = c("au1_present_weather_obs_intensity_code",
                  "au1_present_weather_obs_descriptor_code",
                  "au1_present_weather_obs_precipitation_code",
                  "au1_present_weather_obs_obscuration_code",
                  "au1_present_weather_obs_other_weather_phenomena_code",
                  "au1_present_weather_obs_combination_indicator_code",
                  "au1_present_weather_obs_quality_code"),
        "AW1" = c("aw1_present_weather_obs_aut_weather_report_1",
                  "aw1_present_weather_obs_aut_weather_report_2",
                  "aw1_present_weather_obs_aut_weather_report_3",
                  "aw1_present_weather_obs_aut_weather_report_4"),
        "AX1" = c("ax1_past_weather_obs_atmos_condition_code",
                  "ax1_past_weather_obs_quality_manual_atmos_condition_code",
                  "ax1_past_weather_obs_period_quantity",
                  "ax1_past_weather_obs_period_quality_code"),
        "AY1" = c("ay1_past_weather_obs_manual_occurrence_identifier",
                  "ay1_past_weather_obs_quality_manual_atmos_condition_code",
                  "ay1_past_weather_obs_period_quantity",
                  "ay1_past_weather_obs_period_quality_code"),
        "AZ1" = c("az1_past_weather_obs_aut_occurrence_identifier",
                  "az1_past_weather_obs_quality_aut_atmos_condition_code",
                  "az1_past_weather_obs_period_quantity",
                  "az1_past_weather_obs_period_quality_code"),
        "CB1" = c("cb1_subhrly_obs_liq_precip_2_sensor_period_quantity",
                  "cb1_subhrly_obs_liq_precip_2_sensor_precip_liq_depth",
                  "cb1_subhrly_obs_liq_precip_2_sensor_qc_quality_code",
                  "cb1_subhrly_obs_liq_precip_2_sensor_flag_quality_code"),
        "CF1" = c("cf1_hrly_fan_speed_rate",
                  "cf1_hrly_fan_qc_quality_code",
                  "cf1_hrly_fan_flag_quality_code"),
        "CG1" = c("cg1_subhrly_obs_liq_precip_1_sensor_precip_liq_depth",
                  "cg1_subhrly_obs_liq_precip_1_sensor_qc_quality_code",
                  "cg1_subhrly_obs_liq_precip_1_sensor_flag_quality_code"),
        "CH1" = c("ch1_hrly_subhrly_rh_temp_period_quantity",
                  "ch1_hrly_subhrly_temp_avg_air_temp",
                  "ch1_hrly_subhrly_temp_qc_quality_code",
                  "ch1_hrly_subhrly_temp_flag_quality_code",
                  "ch1_hrly_subhrly_rh_avg_rh",
                  "ch1_hrly_subhrly_rh_qc_quality_code",
                  "ch1_hrly_subhrly_rh_flag_quality_code"),
        "CI1" = c("ci1_hrly_rh_temp_min_hrly_temp",
                  "ci1_hrly_rh_temp_min_hrly_temp_qc_quality_code",
                  "ci1_hrly_rh_temp_min_hrly_temp_flag_quality_code",
                  "ci1_hrly_rh_temp_max_hrly_temp",
                  "ci1_hrly_rh_temp_max_hrly_temp_qc_quality_code",
                  "ci1_hrly_rh_temp_max_hrly_temp_flag_quality_code",
                  "ci1_hrly_rh_temp_std_dev_hrly_temp",
                  "ci1_hrly_rh_temp_std_dev_hrly_temp_qc_quality_code",
                  "ci1_hrly_rh_temp_std_dev_hrly_temp_flag_quality_code",
                  "ci1_hrly_rh_temp_std_dev_hrly_rh",
                  "ci1_hrly_rh_temp_std_dev_hrly_rh_qc_quality_code",
                  "ci1_hrly_rh_temp_std_dev_hrly_rh_flag_quality_code"),
        "CN1" = c("cn1_hrly_batvol_sensors_transm_avg_voltage",
                  "cn1_hrly_batvol_sensors_transm_avg_voltage_qc_quality_code",
                  "cn1_hrly_batvol_sensors_transm_avg_voltage_flag_quality_code",
                  "cn1_hrly_batvol_full_load_avg_voltage",
                  "cn1_hrly_batvol_full_load_avg_voltage_qc_quality_code",
                  "cn1_hrly_batvol_full_load_avg_voltage_flag_quality_code",
                  "cn1_hrly_batvol_datalogger_avg_voltage",
                  "cn1_hrly_batvol_datalogger_avg_voltage_qc_quality_code",
                  "cn1_hrly_batvol_datalogger_avg_voltage_flag_quality_code"),
        "CN2" = c("cn2_hrly_diagnostic_equipment_temp",
                  "cn2_hrly_diagnostic_equipment_temp_qc_quality_code",
                  "cn2_hrly_diagnostic_equipment_temp_flag_quality_code",
                  "cn2_hrly_diagnostic_geonor_inlet_temp",
                  "cn2_hrly_diagnostic_geonor_inlet_temp_qc_quality_code",
                  "cn2_hrly_diagnostic_geonor_inlet_temp_flag_quality_code",
                  "cn2_hrly_diagnostic_datalogger_opendoor_time",
                  "cn2_hrly_diagnostic_datalogger_opendoor_time_qc_quality_code",
                  "cn2_hrly_diagnostic_datalogger_opendoor_time_flag_quality_code"),
        "CN3" = c("cn3_hrly_diagnostic_reference_resistor_avg_resistance",
                  "cn3_hrly_diagnostic_reference_resistor_avg_resistance_qc_quality_code",
                  "cn3_hrly_diagnostic_reference_resistor_avg_resistance_flag_quality_code",
                  "cn3_hrly_diagnostic_datalogger_signature_id",
                  "cn3_hrly_diagnostic_datalogger_signature_id_qc_quality_code",
                  "cn3_hrly_diagnostic_datalogger_signature_id_flag_quality_code"),
        "CN4" = c("cn4_hrly_diagnostic_liq_precip_gauge_flag_bit",
                  "cn4_hrly_diagnostic_liq_precip_gauge_flag_bit_qc_quality_code",
                  "cn4_hrly_diagnostic_liq_precip_gauge_flag_bit_flag_quality_code",
                  "cn4_hrly_diagnostic_doorflag_field",
                  "cn4_hrly_diagnostic_doorflag_field_qc_quality_code",
                  "cn4_hrly_diagnostic_doorflag_field_flag_quality_code",
                  "cn4_hrly_diagnostic_forward_transmitter_rf_power",
                  "cn4_hrly_diagnostic_forward_transmitter_rf_power_qc_quality_code",
                  "cn4_hrly_diagnostic_forward_transmitter_rf_power_flag_quality_code",
                  "cn4_hrly_diagnostic_reflected_transmitter_rf_power",
                  "cn4_hrly_diagnostic_reflected_transmitter_rf_power_qc_quality_code",
                  "cn4_hrly_diagnostic_reflected_transmitter_rf_power_flag_quality_code"),
        "CR1" = c("cr1_control_section_datalogger_version_number",
                  "cr1_control_section_datalogger_version_number_qc_quality_code",
                  "cr1_control_section_datalogger_version_number_flag_quality_code"),
        "CT1" = c("ct1_subhrly_temp_avg_air_temp",
                  "ct1_subhrly_temp_avg_air_temp_qc_quality_code",
                  "ct1_subhrly_temp_avg_air_temp_flag_quality_code"),
        "CU1" = c("cu1_hrly_temp_avg_air_temp",
                  "cu1_hrly_temp_avg_air_temp_qc_quality_code",
                  "cu1_hrly_temp_avg_air_temp_flag_quality_code",
                  "cu1_hrly_temp_avg_air_temp_st_dev",
                  "cu1_hrly_temp_avg_air_temp_st_dev_qc_quality_code",
                  "cu1_hrly_temp_avg_air_temp_st_dev_flag_quality_code"),
        "CV1" = c("cv1_hrly_temp_min_air_temp",
                  "cv1_hrly_temp_min_air_temp_qc_quality_code",
                  "cv1_hrly_temp_min_air_temp_flag_quality_code",
                  "cv1_hrly_temp_min_air_temp_time",
                  "cv1_hrly_temp_min_air_temp_time_qc_quality_code",
                  "cv1_hrly_temp_min_air_temp_time_flag_quality_code",
                  "cv1_hrly_temp_max_air_temp",
                  "cv1_hrly_temp_max_air_temp_qc_quality_code",
                  "cv1_hrly_temp_max_air_temp_flag_quality_code",
                  "cv1_hrly_temp_max_air_temp_time",
                  "cv1_hrly_temp_max_air_temp_time_qc_quality_code",
                  "cv1_hrly_temp_max_air_temp_time_flag_quality_code"),
        "CW1" = c("cw1_subhrly_wetness_wet1_indicator",
                  "cw1_subhrly_wetness_wet1_indicator_qc_quality_code",
                  "cw1_subhrly_wetness_wet1_indicator_flag_quality_code",
                  "cw1_subhrly_wetness_wet2_indicator",
                  "cw1_subhrly_wetness_wet2_indicator_qc_quality_code",
                  "cw1_subhrly_wetness_wet2_indicator_flag_quality_code"),
        "CX1" = c("cx1_hourly_geonor_vib_wire_total_precip",
                  "cx1_hourly_geonor_vib_wire_total_precip_qc_quality_code",
                  "cx1_hourly_geonor_vib_wire_total_precip_flag_quality_code",
                  "cx1_hourly_geonor_vib_wire_freq_avg_precip",
                  "cx1_hourly_geonor_vib_wire_freq_avg_precip_qc_quality_code",
                  "cx1_hourly_geonor_vib_wire_freq_avg_precip_flag_quality_code",
                  "cx1_hourly_geonor_vib_wire_freq_min_precip",
                  "cx1_hourly_geonor_vib_wire_freq_min_precip_qc_quality_code",
                  "cx1_hourly_geonor_vib_wire_freq_min_precip_flag_quality_code",
                  "cx1_hourly_geonor_vib_wire_freq_max_precip",
                  "cx1_hourly_geonor_vib_wire_freq_max_precip_qc_quality_code",
                  "cx1_hourly_geonor_vib_wire_freq_max_precip_flag_quality_code"),
        "CO1" = c("co1_network_metadata_climate_division_number",
                  "co1_network_metadata_utc_lst_time_conversion"),
        "CO2" = c("co2_us_network_cooperative_element_id",
                  "co2_us_network_cooperative_time_offset"),
        "ED1" = c("ed1_runway_vis_range_obs_direction_angle",
                  "ed1_runway_vis_range_obs_runway_designator_code",
                  "ed1_runway_vis_range_obs_vis_dimension",
                  "ed1_runway_vis_range_obs_quality_code"),
        "GA1" = c("ga1_sky_cover_layer_coverage_code",
                  "ga1_sky_cover_layer_coverage_quality_code",
                  "ga1_sky_cover_layer_base_height",
                  "ga1_sky_cover_layer_base_height_quality_code",
                  "ga1_sky_cover_layer_cloud_type",
                  "ga1_sky_cover_layer_cloud_type_quality_code"),
        "GD1" = c("gd1_sky_cover_summation_state_coverage_1",
                  "gd1_sky_cover_summation_state_coverage_2",
                  "gd1_sky_cover_summation_state_coverage_quality_code",
                  "gd1_sky_cover_summation_state_height",
                  "gd1_sky_cover_summation_state_height_quality_code",
                  "gd1_sky_cover_summation_state_characteristic_code"),
        "GF1" = c("gf1_sky_condition_obs_total_coverage",
                  "gf1_sky_condition_obs_total_opaque_coverage",
                  "gf1_sky_condition_obs_total_coverage_quality_code",
                  "gf1_sky_condition_obs_total_lowest_cloud_cover",
                  "gf1_sky_condition_obs_total_lowest_cloud_cover_quality_code",
                  "gf1_sky_condition_obs_low_cloud_genus",
                  "gf1_sky_condition_obs_low_cloud_genus_quality_code",
                  "gf1_sky_condition_obs_lowest_cloud_base_height",
                  "gf1_sky_condition_obs_lowest_cloud_base_height_quality_code",
                  "gf1_sky_condition_obs_mid_cloud_genus",
                  "gf1_sky_condition_obs_mid_cloud_genus_quality_code",
                  "gf1_sky_condition_obs_high_cloud_genus",
                  "gf1_sky_condition_obs_high_cloud_genus_quality_code"),
        "GG1" = c("gg1_below_stn_cloud_layer_coverage",
                  "gg1_below_stn_cloud_layer_coverage_quality_code",
                  "gg1_below_stn_cloud_layer_top_height",
                  "gg1_below_stn_cloud_layer_top_height_quality_code",
                  "gg1_below_stn_cloud_layer_type",
                  "gg1_below_stn_cloud_layer_type_quality_code",
                  "gg1_below_stn_cloud_layer_top",
                  "gg1_below_stn_cloud_layer_top_quality_code"),
        "GH1" = c("gh1_hrly_solar_rad_hrly_avg_solarad",
                  "gh1_hrly_solar_rad_hrly_avg_solarad_qc_quality_code",
                  "gh1_hrly_solar_rad_hrly_avg_solarad_flag_quality_code",
                  "gh1_hrly_solar_rad_min_solarad",
                  "gh1_hrly_solar_rad_min_solarad_qc_quality_code",
                  "gh1_hrly_solar_rad_min_solarad_flag_quality_code",
                  "gh1_hrly_solar_rad_max_solarad",
                  "gh1_hrly_solar_rad_max_solarad_qc_quality_code",
                  "gh1_hrly_solar_rad_max_solarad_flag_quality_code",
                  "gh1_hrly_solar_rad_std_dev_solarad",
                  "gh1_hrly_solar_rad_std_dev_solarad_qc_quality_code",
                  "gh1_hrly_solar_rad_std_dev_solarad_flag_quality_code"),
        "GJ1" = c("gj1_sunshine_obs_duration",
                  "gj1_sunshine_obs_duration_quality_code"),
        "GK1" = c("gk1_sunshine_obs_pct_possible_sunshine",
                  "gk1_sunshine_obs_pct_possible_quality_code"),
        "GL1" = c("gl1_sunshine_obs_duration",
                  "gl1_sunshine_obs_duration_quality_code"),
        "GM1" = c("gm1_solar_irradiance_time_period",
                  "gm1_solar_irradiance_global_irradiance",
                  "gm1_solar_irradiance_global_irradiance_data_flag",
                  "gm1_solar_irradiance_global_irradiance_quality_code",
                  "gm1_solar_irradiance_direct_beam_irradiance",
                  "gm1_solar_irradiance_direct_beam_irradiance_data_flag",
                  "gm1_solar_irradiance_direct_beam_irradiance_quality_code",
                  "gm1_solar_irradiance_diffuse_irradiance",
                  "gm1_solar_irradiance_diffuse_irradiance_data_flag",
                  "gm1_solar_irradiance_diffuse_irradiance_quality_code",
                  "gm1_solar_irradiance_uvb_global_irradiance",
                  "gm1_solar_irradiance_uvb_global_irradiance_data_flag",
                  "gm1_solar_irradiance_uvb_global_irradiance_quality_code"),
        "GN1" = c("gn1_solar_rad_time_period",
                  "gn1_solar_rad_upwelling_global_solar_rad",
                  "gn1_solar_rad_upwelling_global_solar_rad_quality_code",
                  "gn1_solar_rad_downwelling_thermal_ir_rad",
                  "gn1_solar_rad_downwelling_thermal_ir_rad_quality_code",
                  "gn1_solar_rad_upwelling_thermal_ir_rad",
                  "gn1_solar_rad_upwelling_thermal_ir_rad_quality_code",
                  "gn1_solar_rad_par",
                  "gn1_solar_rad_par_quality_code",
                  "gn1_solar_rad_solar_zenith_angle",
                  "gn1_solar_rad_solar_zenith_angle_quality_code"),
        "GO1" = c("go1_net_solar_rad_time_period",
                  "go1_net_solar_rad_net_solar_radiation",
                  "go1_net_solar_rad_net_solar_radiation_quality_code",
                  "go1_net_solar_rad_net_ir_radiation",
                  "go1_net_solar_rad_net_ir_radiation_quality_code",
                  "go1_net_solar_rad_net_radiation",
                  "go1_net_solar_rad_net_radiation_quality_code"),
        "GP1" = c("gp1_modeled_solar_irradiance_data_time_period",
                  "gp1_modeled_solar_irradiance_global_horizontal",
                  "gp1_modeled_solar_irradiance_global_horizontal_src_flag",
                  "gp1_modeled_solar_irradiance_global_horizontal_uncertainty",
                  "gp1_modeled_solar_irradiance_direct_normal",
                  "gp1_modeled_solar_irradiance_direct_normal_src_flag",
                  "gp1_modeled_solar_irradiance_direct_normal_uncertainty",
                  "gp1_modeled_solar_irradiance_diffuse_normal",
                  "gp1_modeled_solar_irradiance_diffuse_normal_src_flag",
                  "gp1_modeled_solar_irradiance_diffuse_normal_uncertainty",
                  "gp1_modeled_solar_irradiance_diffuse_horizontal",
                  "gp1_modeled_solar_irradiance_diffuse_horizontal_src_flag",
                  "gp1_modeled_solar_irradiance_diffuse_horizontal_uncertainty"),
        "GQ1" = c("gq1_hrly_solar_angle_time_period",
                  "gq1_hrly_solar_angle_mean_zenith_angle",
                  "gq1_hrly_solar_angle_mean_zenith_angle_quality_code",
                  "gq1_hrly_solar_angle_mean_azimuth_angle",
                  "gq1_hrly_solar_angle_mean_azimuth_angle_quality_code"),
        "GR1" = c("gr1_hrly_extraterrestrial_rad_time_period",
                  "gr1_hrly_extraterrestrial_rad_horizontal",
                  "gr1_hrly_extraterrestrial_rad_horizontal_quality_code",
                  "gr1_hrly_extraterrestrial_rad_normal",
                  "gr1_hrly_extraterrestrial_rad_normal_quality_code"),
        "HL1" = c("hl1_hail_size",
                  "hl1_hail_size_quality_code"),
        "IA1" = c("ia1_ground_surface_obs_code",
                  "ia1_ground_surface_obs_code_quality_code"),
        "IA2" = c("ia2_ground_surface_obs_min_temp_time_period",
                  "ia2_ground_surface_obs_min_temp",
                  "ia2_ground_surface_obs_min_temp_quality_code"),
        "IB1" = c("ib1_hrly_surface_temp",
                  "ib1_hrly_surface_temp_qc_quality_code",
                  "ib1_hrly_surface_temp_flag_quality_code",
                  "ib1_hrly_surface_min_temp",
                  "ib1_hrly_surface_min_temp_qc_quality_code",
                  "ib1_hrly_surface_min_temp_flag_quality_code",
                  "ib1_hrly_surface_max_temp",
                  "ib1_hrly_surface_max_temp_qc_quality_code",
                  "ib1_hrly_surface_max_temp_flag_quality_code",
                  "ib1_hrly_surface_std_temp",
                  "ib1_hrly_surface_std_temp_qc_quality_code",
                  "ib1_hrly_surface_std_temp_flag_quality_code"),
        "IB2" = c("ib2_hrly_surface_temp_sb",
                  "ib2_hrly_surface_temp_sb_qc_quality_code",
                  "ib2_hrly_surface_temp_sb_flag_quality_code",
                  "ib2_hrly_surface_temp_sb_std",
                  "ib2_hrly_surface_temp_sb_std_qc_quality_code",
                  "ib2_hrly_surface_temp_sb_std_flag_quality_code"),
        "IC1" = c("ic1_grnd_surface_obs_pan_evap_time_period",
                  "ic1_grnd_surface_obs_pan_evap_wind",
                  "ic1_grnd_surface_obs_pan_evap_wind_condition_code",
                  "ic1_grnd_surface_obs_pan_evap_wind_quality_code",
                  "ic1_grnd_surface_obs_pan_evap_data",
                  "ic1_grnd_surface_obs_pan_evap_data_condition_code",
                  "ic1_grnd_surface_obs_pan_evap_data_quality_code",
                  "ic1_grnd_surface_obs_pan_max_water_data",
                  "ic1_grnd_surface_obs_pan_max_water_data_condition_code",
                  "ic1_grnd_surface_obs_pan_max_water_data_quality_code",
                  "ic1_grnd_surface_obs_pan_min_water_data",
                  "ic1_grnd_surface_obs_pan_min_water_data_condition_code",
                  "ic1_grnd_surface_obs_pan_min_water_data_quality_code"),
        "KA1" = c("ka1_extreme_air_temp_time_period",
                  "ka1_extreme_air_temp_code",
                  "ka1_extreme_air_temp_high_or_low",
                  "ka1_extreme_air_temp_high_or_low_quality_code"),
        "KB1" = c("kb1_avg_air_temp_time_period",
                  "kb1_avg_air_temp_code",
                  "kb1_avg_air_temp_air_temp",
                  "kb1_avg_air_temp_air_temp_quality_code"),
        "KC1" = c("kc1_extreme_air_temp_monthly_code",
                  "kc1_extreme_air_temp_monthly_condition_code",
                  "kc1_extreme_air_temp_monthly_temp",
                  "kc1_extreme_air_temp_monthly_date",
                  "kc1_extreme_air_temp_monthly_temp_quality_code"),
        "KD1" = c("kd1_heat_cool_deg_days_time_period",
                  "kd1_heat_cool_deg_days_code",
                  "kd1_heat_cool_deg_days_value",
                  "kd1_heat_cool_deg_days_quality_code"),
        "KE1" = c("ke1_extreme_temp_number_days_max_32f_or_lower",
                  "ke1_extreme_temp_number_days_max_32f_or_lower_quality_code",
                  "ke1_extreme_temp_number_days_max_90f_or_higher",
                  "ke1_extreme_temp_number_days_max_90f_or_higher_quality_code",
                  "ke1_extreme_temp_number_days_min_32f_or_lower",
                  "ke1_extreme_temp_number_days_min_32f_or_lower_quality_code",
                  "ke1_extreme_temp_number_days_min_0f_or_lower",
                  "ke1_extreme_temp_number_days_min_0f_or_lower_quality_code"),
        "KF1" = c("kf1_hrly_calc_temp",
                  "kf1_hrly_calc_temp_quality_code"),
        "KG1" = c("kg1_avg_dp_wb_temp_time_period",
                  "kg1_avg_dp_wb_temp_code",
                  "kg1_avg_dp_wb_temp",
                  "kg1_avg_dp_wb_temp_derived_code",
                  "kg1_avg_dp_wb_temp_quality_code"),
        "MA1" = c("ma1_atmos_p_obs_altimeter_setting_rate",
                  "ma1_atmos_p_obs_altimeter_quality_code",
                  "ma1_atmos_p_obs_stn_pressure_rate",
                  "ma1_atmos_p_obs_stn_pressure_rate_quality_code"),
        "MD1" = c("md1_atmos_p_change_tendency_code",
                  "md1_atmos_p_change_tendency_code_quality_code",
                  "md1_atmos_p_change_3_hr_quantity",
                  "md1_atmos_p_change_3_hr_quantity_quality_code",
                  "md1_atmos_p_change_24_hr_quantity",
                  "md1_atmos_p_change_24_hr_quantity_quality_code"),
        "ME1" = c("me1_geopotential_hgt_isobaric_lvl_code",
                  "me1_geopotential_hgt_isobaric_lvl_height",
                  "me1_geopotential_hgt_isobaric_lvl_height_quality_code"),
        "MF1" = c("mf1_atmos_p_obs_stp_avg_stn_pressure_day",
                  "mf1_atmos_p_obs_stp_avg_stn_pressure_day_quality_code",
                  "mf1_atmos_p_obs_stp_avg_sea_lvl_pressure_day",
                  "mf1_atmos_p_obs_stp_avg_sea_lvl_pressure_day_quality_code"),
        "MG1" = c("mg1_atmos_p_obs_avg_stn_pressure_day",
                  "mg1_atmos_p_obs_avg_stn_pressure_day_quality_code",
                  "mg1_atmos_p_obs_avg_sea_lvl_pressure_day",
                  "mg1_atmos_p_obs_avg_sea_lvl_pressure_day_quality_code"),
        "MH1" = c("mh1_atmos_p_obs_avg_stn_pressure_month",
                  "mh1_atmos_p_obs_avg_stn_pressure_month_quality_code",
                  "mh1_atmos_p_obs_avg_sea_lvl_pressure_month",
                  "mh1_atmos_p_obs_avg_sea_lvl_pressure_month_quality_code"),
        "MK1" = c("mk1_atmos_p_obs_max_sea_lvl_pressure_month",
                  "mk1_atmos_p_obs_max_sea_lvl_pressure_date_time",
                  "mk1_atmos_p_obs_max_sea_lvl_pressure_quality_code",
                  "mk1_atmos_p_obs_min_sea_lvl_pressure_month",
                  "mk1_atmos_p_obs_min_sea_lvl_pressure_date_time",
                  "mk1_atmos_p_obs_min_sea_lvl_pressure_quality_code"),
        "MV1" = c("mv1_present_weather_obs_condition_code",
                  "mv1_present_weather_obs_condition_code_quality_code"),
        "MW1" = c("mw1_present_weather_obs_manual_occurrence_condition_code",
                  "mw1_present_weather_obs_manual_occurrence_condition_code_quality_code"),
        "OA1" = c("oa1_suppl_wind_obs_type",
                  "oa1_suppl_wind_obs_time_period",
                  "oa1_suppl_wind_obs_speed_rate",
                  "oa1_suppl_wind_obs_speed_rate_quality_code"),
        "OB1" = c("ob1_hly_subhrly_wind_avg_time_period",
                  "ob1_hly_subhrly_wind_max_gust",
                  "ob1_hly_subhrly_wind_max_gust_quality_code",
                  "ob1_hly_subhrly_wind_max_gust_flag",
                  "ob1_hly_subhrly_wind_max_dir",
                  "ob1_hly_subhrly_wind_max_dir_quality_code",
                  "ob1_hly_subhrly_wind_max_dir_flag",
                  "ob1_hly_subhrly_wind_max_stdev",
                  "ob1_hly_subhrly_wind_max_stdev_quality_code",
                  "ob1_hly_subhrly_wind_max_stdev_flag",
                  "ob1_hly_subhrly_wind_max_dir_stdev",
                  "ob1_hly_subhrly_wind_max_dir_stdev_quality_code",
                  "ob1_hly_subhrly_wind_max_dir_stdev_flag"),
        "OC1" = c("oc1_wind_gust_obs_speed_rate",
                  "oc1_wind_gust_obs_speed_rate_quality_code"),
        "OE1" = c("oe1_summary_of_day_wind_obs_type",
                  "oe1_summary_of_day_wind_obs_time_period",
                  "oe1_summary_of_day_wind_obs_speed_rate",
                  "oe1_summary_of_day_wind_obs_dir",
                  "oe1_summary_of_day_wind_obs_time_occurrence",
                  "oe1_summary_of_day_wind_obs_quality_code"),
        "RH1" = c("rh1_relative_humidity_time_period",
                  "rh1_relative_humidity_code",
                  "rh1_relative_humidity_percentage",
                  "rh1_relative_humidity_derived_code",
                  "rh1_relative_humidity_quality_code"),
        "SA1" = c("sa1_sea_surf_temp",
                  "sa1_sea_surf_temp_quality_code"),
        "ST1" = c("st1_soil_temp_type",
                  "st1_soil_temp_soil_temp",
                  "st1_soil_temp_soil_temp_quality_code",
                  "st1_soil_temp_depth",
                  "st1_soil_temp_depth_quality_code",
                  "st1_soil_temp_soil_cover",
                  "st1_soil_temp_soil_cover_quality_code",
                  "st1_soil_temp_sub_plot",
                  "st1_soil_temp_sub_plot_quality_code"),
        "UA1" = c("ua1_wave_meas_method_code",
                  "ua1_wave_meas_wave_period_quantity",
                  "ua1_wave_meas_wave_height_dimension",
                  "ua1_wave_meas_quality_code",
                  "ua1_wave_meas_sea_state_code",
                  "ua1_wave_meas_sea_state_code_quality_code"),
        "UG1" = c("ug1_wave_meas_primary_swell_time_period",
                  "ug1_wave_meas_primary_swell_height_dimension",
                  "ug1_wave_meas_primary_swell_dir_angle",
                  "ug1_wave_meas_primary_swell_quality_code"),
        "UG2" = c("ug2_wave_meas_secondary_swell_time_period",
                  "ug2_wave_meas_secondary_swell_height_dimension",
                  "ug2_wave_meas_secondary_swell_dir_angle",
                  "ug2_wave_meas_secondary_swell_quality_code"),
        "WA1" = c("wa1_platform_ice_accr_source_code",
                  "wa1_platform_ice_accr_thickness_dimension",
                  "wa1_platform_ice_accr_tendency_code",
                  "wa1_platform_ice_accr_quality_code"),
        "WD1" = c("wd1_water_surf_ice_obs_edge_bearing_code",
                  "wd1_water_surf_ice_obs_uniform_conc_rate",
                  "wd1_water_surf_ice_obs_non_uniform_conc_rate",
                  "wd1_water_surf_ice_obs_ship_rel_pos_code",
                  "wd1_water_surf_ice_obs_ship_penetrability_code",
                  "wd1_water_surf_ice_obs_ice_trend_code",
                  "wd1_water_surf_ice_obs_development_code",
                  "wd1_water_surf_ice_obs_growler_bergy_bit_pres_code",
                  "wd1_water_surf_ice_obs_growler_bergy_bit_quantity",
                  "wd1_water_surf_ice_obs_iceberg_quantity",
                  "wd1_water_surf_ice_obs_quality_code"),
        "WG1" = c("wg1_water_surf_ice_hist_obs_edge_distance",
                  "wg1_water_surf_ice_hist_obs_edge_orient_code",
                  "wg1_water_surf_ice_hist_obs_form_type_code",
                  "wg1_water_surf_ice_hist_obs_nav_effect_code",
                  "wg1_water_surf_ice_hist_obs_quality_code")
      )
    
    # Function for getting data from an additional data category
    get_df_from_category <- function(category_key,
                                     field_lengths,
                                     scale_factor,
                                     data_types,
                                     add_data){
      
      # Parse string of characters representing data types
      if (class(data_types) == "character" &
          length(data_types) == 1 &
          all(unique(unlist(strsplit(data_types, ""))) %in% c("c", "n"))){
        
        for (i in 1:nchar(data_types)){
          
          if (i == 1){
            subst_data_types <- vector(mode = "character")
            
            # Create a progress bar object
            pb <- progress_bar$new(
              format = "  processing :what [:bar] :percent",
              total = nchar(data_types))
            
          }
          subst_data_types <- c(subst_data_types,
                                ifelse(substr(data_types, i, i) == "n",
                                       "numeric", "character"))
          
        }
        
        data_types <- subst_data_types
      }
      
      data_strings <- str_extract(add_data, paste0(category_key, ".*"))
      
      for (i in 1:length(field_lengths)){
        
        if (i == 1){
          df_from_category <-
            as.data.frame(mat.or.vec(nr = length(data_strings),
                                     nc = length(field_lengths)))
          colnames(df_from_category) <- paste(tolower(category_key),
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
        
        df_from_category[,i] <- data_column
        
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
        get_df_from_category(category_key = "AA1",
                             field_lengths = c(2, 4, 1, 1),
                             scale_factor = c(1, 10, NA, NA),
                             data_types = "nncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AB1 - liquid precipitation: monthly total
    if (data_categories[2] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AB1",
                             field_lengths = c(5, 1, 1),
                             scale_factor = c(10, NA, NA),
                             data_types = "ncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AC1 - precipitation observation history
    if (data_categories[3] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AC1",
                             field_lengths = c(1, 1, 1),
                             scale_factor = c(NA, NA, NA),
                             data_types = "ccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AD1 - liquid precipitation, greatest amount in 24 hours, for the month
    if (data_categories[4] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AD1",
                             field_lengths = c(5, 1, 4, 4, 4, 1),
                             scale_factor = c(10, NA, NA, NA, NA, NA),
                             data_types = "nccccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AE1 - liquid precipitation, number of days with specific amounts, for the month
    if (data_categories[5] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AE1",
                             field_lengths = c(2, 1, 2, 1, 2, 1, 2, 1),
                             scale_factor = rep(NA, 8),
                             data_types = "cccccccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AG1 - precipitation estimated observation
    if (data_categories[6] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AG1",
                             field_lengths = c(1, 3),
                             scale_factor = c(NA, 1),
                             data_types = "cn",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AH1 - liquid precipitation maximum short duration, for the month (1)
    if (data_categories[7] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AH1",
                             field_lengths = c(3, 4, 1, 6, 1),
                             scale_factor = c(1, 10, NA, NA, NA),
                             data_types = "nnccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AI1 - liquid precipitation maximum short duration, for the month (2)
    if (data_categories[8] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AI1",
                             field_lengths = c(4, 1, 6, 1),
                             scale_factor = c(10, NA, NA, NA),
                             data_types = "nccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AJ1 - snow depth
    if (data_categories[9] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AJ1",
                             field_lengths = c(4, 1, 1, 6, 1, 1),
                             scale_factor = c(1, NA, NA, 10, NA, NA),
                             data_types = "nccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AK1 - snow depth greatest depth on the ground, for the month
    if (data_categories[10] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AK1",
                             field_lengths = c(4, 1, 6, 1),
                             scale_factor = c(1, NA, NA, NA),
                             data_types = "nccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AL1 - snow accumulation
    if (data_categories[11] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AL1",
                             field_lengths = c(2, 3, 1, 1),
                             scale_factor = c(1, 1, NA, NA),
                             data_types = "nncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AM1 - snow accumulation greatest amount in 24 hours, for the month
    if (data_categories[12] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AM1",
                             field_lengths = c(4, 1, 4, 4, 4, 1),
                             scale_factor = c(10, NA, NA, NA, NA, NA),
                             data_types = "nccccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AN1 - snow accumulation for the month
    if (data_categories[13] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AN1",
                             field_lengths = c(3, 4, 1, 1),
                             scale_factor = c(1, 10, NA, NA),
                             data_types = "nncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AO1 - liquid precipitation
    if (data_categories[14] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AO1",
                             field_lengths = c(2, 4, 1, 1),
                             scale_factor = c(1, 10, NA, NA),
                             data_types = "nncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AP1 - 15-minute liquid precipitation
    if (data_categories[15] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AP1",
                             field_lengths = c(4, 1, 1),
                             scale_factor = c(10, NA, NA),
                             data_types = "ncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AU1 - present weather observation
    if (data_categories[16] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AU1",
                             field_lengths = c(1, 1, 2, 1, 1, 1, 1),
                             scale_factor = c(NA, NA, NA, NA,
                                              NA, NA, NA),
                             data_types = "ccccccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AW1 - present weather observation 
    if (data_categories[17] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AW1",
                             field_lengths = c(2, 1),
                             scale_factor = c(NA, NA),
                             data_types = "cc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AX1 - past weather observation (1)
    if (data_categories[18] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AX1",
                             field_lengths = c(2, 1, 2, 1),
                             scale_factor = c(NA, NA, 1, NA),
                             data_types = "ccnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AY1 - past weather observation (2)
    if (data_categories[19] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AY1",
                             field_lengths = c(1, 1, 2, 1),
                             scale_factor = c(NA, NA, 1, NA),
                             data_types = "ccnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # AZ1 - past weather observation (3)
    if (data_categories[20] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "AZ1",
                             field_lengths = c(1, 1, 2, 1),
                             scale_factor = c(NA, NA, 1, NA),
                             data_types = "ccnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CB1 - subhourly observed liquid precipitation: secondary sensor
    if (data_categories[21] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CB1",
                             field_lengths = c(2, 6, 1, 1),
                             scale_factor = c(1, 10, NA, NA),
                             data_types = "nncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CF1 - hourly fan speed
    if (data_categories[22] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CF1",
                             field_lengths = c(4, 1, 1),
                             scale_factor = c(10, NA, NA),
                             data_types = "ncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CG1 - subhourly observed liquid precipitation: primary sensor
    if (data_categories[23] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CG1",
                             field_lengths = c(6, 1, 1),
                             scale_factor = c(10, NA, NA),
                             data_types = "ncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CH1 - hourly/subhourly RH/temperatures
    if (data_categories[24] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CH1",
                             field_lengths = c(2, 5, 1, 1, 4, 1, 1),
                             scale_factor = c(1, 10, NA, NA, 10, NA, NA),
                             data_types = "nnccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CI1 - hourly RH/temperatures
    if (data_categories[25] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CI1",
                             field_lengths = c(5, 1, 1, 5, 1, 1,
                                               5, 1, 1, 5, 1, 1),
                             scale_factor = c(10, NA, NA, 10, NA, NA,
                                              10, NA, NA, 10, NA, NA),
                             data_types = "nccnccnccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CN1 - hourly battery voltage
    if (data_categories[26] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CN1",
                             field_lengths = c(4, 1, 1, 4, 1, 1,
                                               4, 1, 1),
                             scale_factor = c(10, NA, NA, 10, NA, NA,
                                              10, NA, NA),
                             data_types = "nccnccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CN2 - hourly diagnostics
    if (data_categories[27] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CN2",
                             field_lengths = c(5, 1, 1, 5, 1, 1,
                                               2, 1, 1),
                             scale_factor = c(10, NA, NA, 10, NA, NA,
                                              1, NA, NA),
                             data_types = "nccnccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CN3 - secondary hourly diagnostics (1)
    if (data_categories[28] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CN3",
                             field_lengths = c(6, 1, 1, 6, 1, 1),
                             scale_factor = c(10, NA, NA, 10, NA, NA),
                             data_types = "nccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CN4 - secondary hourly diagnostics (2)
    if (data_categories[29] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CN4",
                             field_lengths = c(1, 1, 1, 1, 1, 1,
                                               3, 1, 1, 3, 1, 1),
                             scale_factor = c(NA, NA, NA, NA, NA, NA,
                                              10, NA, NA, 10, NA, NA),
                             data_types = "ccccccnccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CR1 - CRN control
    if (data_categories[30] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CR1",
                             field_lengths = c(5, 1, 1),
                             scale_factor = c(1000, NA, NA),
                             data_types = "ncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CT1 - subhourly temperatures
    if (data_categories[31] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CT1",
                             field_lengths = c(5, 1, 1),
                             scale_factor = c(10, NA, NA),
                             data_types = "ncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CU1 - hourly temperatures
    if (data_categories[32] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CU1",
                             field_lengths = c(5, 1, 1, 4, 1, 1),
                             scale_factor = c(10, NA, NA, 10, NA, NA),
                             data_types = "nccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CV1 - hourly temperature extremes
    if (data_categories[33] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CV1",
                             field_lengths = c(5, 1, 1, 4, 1, 1,
                                               5, 1, 1, 4, 1, 1),
                             scale_factor = c(10, NA, NA, NA, NA, NA,
                                              10, NA, NA, NA, NA, NA),
                             data_types = "ncccccnccccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CW1 - subhourly wetness
    if (data_categories[34] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CW1",
                             field_lengths = c(5, 1, 1, 5, 1, 1),
                             scale_factor = c(10, NA, NA, 10, NA, NA),
                             data_types = "nccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CX1 - hourly geonor vibrating wire summary
    if (data_categories[35] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CX1",
                             field_lengths = c(6, 1, 1, 4, 1, 1,
                                               4, 1, 1, 4, 1, 1),
                             scale_factor = c(10, NA, NA, 1, NA, NA,
                                              1, NA, NA, 1, NA, NA),
                             data_types = "nccnccnccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CO1 - network metadata
    if (data_categories[36] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CO1",
                             field_lengths = c(2, 3),
                             scale_factor = c(1, 1),
                             data_types = "nn",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # CO2 - US cooperative network element time offset
    if (data_categories[37] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "CO2",
                             field_lengths = c(3, 5),
                             scale_factor = c(NA, 10),
                             data_types = "cn",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # ED1 - runway visual range
    if (data_categories[38] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "ED1",
                             field_lengths = c(2, 1, 4, 1),
                             scale_factor = c(0.1, NA, 1, NA),
                             data_types = "ncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GA1 - sky cover layer
    if (data_categories[39] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GA1",
                             field_lengths = c(2, 1, 6, 1, 2, 1),
                             scale_factor = c(NA, NA, 1, NA, NA, NA),
                             data_types = "ccnccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GD1 - sky cover summation state
    if (data_categories[40] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GD1",
                             field_lengths = c(1, 2, 1, 6, 1, 1),
                             scale_factor = c(NA, NA, NA, 1, NA, NA),
                             data_types = "cccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GF1 - sky condition observation
    if (data_categories[41] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GF1",
                             field_lengths = c(2, 2, 1, 2, 1, 2, 1,
                                               5, 1, 2, 1, 2, 1),
                             scale_factor = c(NA, NA, NA, NA, NA, NA, NA,
                                              1, NA, NA, NA, NA, NA),
                             data_types = "cccccccnccccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GG1 - below station cloud layer
    if (data_categories[42] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GG1",
                             field_lengths = c(2, 1, 5, 1, 2, 1, 2, 1),
                             scale_factor = c(NA, NA, 1, NA, NA, NA, NA, NA),
                             data_types = "ccnccccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GH1 - hourly solar radiation
    if (data_categories[43] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GH1",
                             field_lengths = c(5, 1, 1, 5, 1, 1,
                                               5, 1, 1, 5, 1, 1),
                             scale_factor = c(10, NA, NA, 10, NA, NA,
                                              10, NA, NA, 10, NA, NA),
                             data_types = "nccnccnccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GJ1 - sunshine observation (1)
    if (data_categories[44] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GJ1",
                             field_lengths = c(4, 1),
                             scale_factor = c(1, NA),
                             data_types = "nc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GK1 - sunshine observation (2)
    if (data_categories[45] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GK1",
                             field_lengths = c(3, 1),
                             scale_factor = c(1, NA),
                             data_types = "nc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GL1 - sunshine observation for the month
    if (data_categories[46] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GL1",
                             field_lengths = c(5, 1),
                             scale_factor = c(1, NA),
                             data_types = "nc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GM1 - solar irradiance
    if (data_categories[47] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GM1",
                             field_lengths = c(4, 4, 2, 1, 4, 2, 1,
                                               4, 2, 1, 4, 1),
                             scale_factor = c(1, 1, NA, NA, 1, NA, NA,
                                              1, NA, NA, 1, NA),
                             data_types = "nnccnccnccnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GN1 - solar radiation
    if (data_categories[48] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GN1",
                             field_lengths = c(4, 4, 2, 1, 4, 2, 1,
                                               4, 2, 1, 4, 1),
                             scale_factor = c(1, 1, NA, NA, 1, NA, NA,
                                              1, NA, NA, 1, NA),
                             data_types = "nnccnccnccnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GO1 - net solar radiation
    if (data_categories[49] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GO1",
                             field_lengths = c(4, 4, 1, 4, 1, 4, 1),
                             scale_factor = c(1, 1, NA, 1, NA, 1, NA),
                             data_types = "nncncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GP1 - modeled solar irradiance
    if (data_categories[50] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GP1",
                             field_lengths = c(4, 4, 2, 3, 4, 2,
                                               3, 4, 2, 3),
                             scale_factor = c(1, 1, NA, 1, 1, NA,
                                              1, 1, NA, 1),
                             data_types = "nncnncnncn",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GQ1 - hourly solar angle
    if (data_categories[51] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GQ1",
                             field_lengths = c(4, 4, 1, 4, 1),
                             scale_factor = c(1, 10, NA, 10, NA),
                             data_types = "nncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # GR1 - hourly extraterrestrial radiation
    if (data_categories[52] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "GR1",
                             field_lengths = c(4, 4, 1, 4, 1),
                             scale_factor = c(1, 1, NA, 1, NA),
                             data_types = "nncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # HL1 - hail data
    if (data_categories[53] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "HL1",
                             field_lengths = c(3, 1),
                             scale_factor = c(10, NA),
                             data_types = "nc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # IA1 - ground surface data
    if (data_categories[54] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "IA1",
                             field_lengths = c(2, 1),
                             scale_factor = c(NA, NA),
                             data_types = "cc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # IA2 - ground surface observation
    if (data_categories[55] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "IA2",
                             field_lengths = c(3, 5, 1),
                             scale_factor = c(10, 10, NA),
                             data_types = "nnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # IB1 - hourly surface temperature
    if (data_categories[56] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "IB1",
                             field_lengths = c(5, 1, 1, 5, 1, 1,
                                               5, 1, 1, 4, 1, 1),
                             scale_factor = c(10, NA, NA, 10, NA, NA,
                                              10, NA, NA, 10, NA, NA),
                             data_types = "nccnccnccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # IB2 - hourly surface temperature sensor
    if (data_categories[57] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "IB2",
                             field_lengths = c(5, 1, 1, 4, 1, 1),
                             scale_factor = c(10, NA, NA, 10, NA, NA),
                             data_types = "nccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # IC1 - ground surface observation - pan evaporation
    if (data_categories[58] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "IC1",
                             field_lengths = c(2, 4, 1, 1, 3, 1, 1,
                                               4, 1, 1, 4, 1, 1),
                             scale_factor = c(1, 1, NA, NA, 100, NA, NA,
                                              10, NA, NA, 10, NA, NA),
                             data_types = "nnccnccnccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KA1 - temperature data
    if (data_categories[59] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "KA1",
                             field_lengths = c(3, 1, 5, 1),
                             scale_factor = c(10, NA, 10, NA),
                             data_types = "ncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KB1 - average air temperature
    if (data_categories[60] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "KB1",
                             field_lengths = c(3, 1, 5, 1),
                             scale_factor = c(10, NA, 10, NA),
                             data_types = "ncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KC1 - extreme air temperature for the month
    if (data_categories[61] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "KC1",
                             field_lengths = c(1, 1, 5, 6, 1),
                             scale_factor = c(NA, NA, 10, NA, NA),
                             data_types = "ccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KD1 - heating/cooling degree days
    if (data_categories[62] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "KD1",
                             field_lengths = c(3, 1, 4, 1),
                             scale_factor = c(1, NA, 1, NA),
                             data_types = "ncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KE1 - extreme temperatures, number of days exceeding criteria, for the month
    if (data_categories[63] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "KE1",
                             field_lengths = c(2, 1, 2, 1,
                                               2, 1, 2, 1),
                             scale_factor = c(1, NA, 1, NA,
                                              1, NA, 1, NA),
                             data_types = "ncncncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KF1 - hourly calculated temperature
    if (data_categories[64] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "KF1",
                             field_lengths = c(5, 1),
                             scale_factor = c(10, NA),
                             data_types = "nc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # KG1 - average dew point and wet bulb temperature
    if (data_categories[65] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "KG1",
                             field_lengths = c(3, 1, 5, 1, 1),
                             scale_factor = c(1, NA, 100, NA, NA),
                             data_types = "ncncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MA1 - atmospheric pressure observation
    if (data_categories[66] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "MA1",
                             field_lengths = c(5, 1, 5, 1),
                             scale_factor = c(10, NA, 10, NA),
                             data_types = "ncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MD1 - atmospheric pressure change
    if (data_categories[67] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "MD1",
                             field_lengths = c(1, 1, 3, 1, 4, 1),
                             scale_factor = c(NA, NA, 10, NA, 10, NA),
                             data_types = "ccncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # ME1 - geopotential height isobaric level
    if (data_categories[68] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "ME1",
                             field_lengths = c(1, 4, 1),
                             scale_factor = c(NA, 1, NA),
                             data_types = "cnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MF1 - atmospheric pressure observation (STP/SLP)
    if (data_categories[69] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "MF1",
                             field_lengths = c(5, 1, 5, 1),
                             scale_factor = c(10, NA, 10, NA),
                             data_types = "ncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MG1 - atmospheric pressure observation
    if (data_categories[70] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "MG1",
                             field_lengths = c(5, 1, 5, 1),
                             scale_factor = c(10, NA, 10, NA),
                             data_types = "ncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MH1 - atmospheric pressure observation - average station pressure
    # for the month
    if (data_categories[71] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "MH1",
                             field_lengths = c(5, 1, 5, 1),
                             scale_factor = c(10, NA, 10, NA),
                             data_types = "ncnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MK1 - atmospheric pressure observation - maximum sea level pressure
    # for the month
    if (data_categories[72] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "MK1",
                             field_lengths = c(5, 6, 1, 5, 6, 1),
                             scale_factor = c(10, NA, NA, 10, NA, NA),
                             data_types = "nccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MV1 - present weather in vicinity observation
    if (data_categories[73] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "MV1",
                             field_lengths = c(2, 1),
                             scale_factor = c(NA, NA),
                             data_types = "cc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # MW1 - present weather observation 
    if (data_categories[74] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "MW1",
                             field_lengths = c(2, 1),
                             scale_factor = c(NA, NA),
                             data_types = "cc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # OA1 - supplementary wine observation 
    if (data_categories[75] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "OA1",
                             field_lengths = c(1, 2, 4, 1),
                             scale_factor = c(NA, 1, 10, NA),
                             data_types = "cnnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # OB1 - hourly/sub-hourly wind section
    if (data_categories[76] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "OB1",
                             field_lengths = c(3, 4, 1, 1, 3, 1, 1,
                                               5, 1, 1, 5, 1, 1),
                             scale_factor = c(1, 10, NA, NA, 1, NA, NA,
                                              100, NA, NA, 100, NA, NA),
                             data_types = "nnccnccnccncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # OC1 - wind gust observation
    if (data_categories[77] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "OC1",
                             field_lengths = c(4, 1),
                             scale_factor = c(10, NA),
                             data_types = "nc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # OE1 - summary of day wind observation
    if (data_categories[78] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "OE1",
                             field_lengths = c(1, 2, 5, 3, 4, 1),
                             scale_factor = c(NA, 1, 100, 1, 10, NA),
                             data_types = "cnnnnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # RH1 - relative humidity
    if (data_categories[79] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "RH1",
                             field_lengths = c(3, 1, 3, 1, 1),
                             scale_factor = c(1, NA, 1, NA, NA),
                             data_types = "ncncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # SA1 - sea surface temperature observation
    if (data_categories[80] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "SA1",
                             field_lengths = c(4, 1),
                             scale_factor = c(10, NA),
                             data_types = "nc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # ST1 - soil temperature
    if (data_categories[81] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "ST1",
                             field_lengths = c(1, 5, 1, 4, 1,
                                               2, 1, 1, 1),
                             scale_factor = c(NA, 10, NA, 10, NA,
                                              NA, NA, NA, NA),
                             data_types = "cncnccccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # UA1 - wave measurement
    if (data_categories[82] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "UA1",
                             field_lengths = c(1, 2, 3, 1, 2, 1),
                             scale_factor = c(NA, 1, 10, NA, NA, NA),
                             data_types = "cnnccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # UG1 - wave measurement primary swell
    if (data_categories[83] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "UG1",
                             field_lengths = c(2, 3, 3, 1),
                             scale_factor = c(1, 10, 1, NA),
                             data_types = "nnnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # UG2 - wave measurement secondary swell
    if (data_categories[84] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "UG2",
                             field_lengths = c(2, 3, 3, 1),
                             scale_factor = c(1, 10, 1, NA),
                             data_types = "nnnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # WA1 - platform ice accretion
    if (data_categories[85] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "WA1",
                             field_lengths = c(1, 3, 1, 1),
                             scale_factor = c(NA, 10, NA, NA),
                             data_types = "cncc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # WD1 - water surface ice observation
    if (data_categories[86] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "WD1",
                             field_lengths = c(2, 3, 2, 1, 1, 1,
                                               2, 1, 3, 3, 1),
                             scale_factor = c(NA, 1, NA, NA, NA, NA,
                                              NA, NA, 1, 1, NA),
                             data_types = "cnccccccnnc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # WG1 - water surface ice historical observation
    if (data_categories[87] %in% significant_params){
      
      additional_data <-
        get_df_from_category(category_key = "WG1",
                             field_lengths = c(2, 2, 2, 2, 2, 1),
                             scale_factor = c(NA, 1, NA, NA, NA, NA),
                             data_types = "cncccc",
                             add_data = all_add_data)
      
      large_data_frame <- bind_cols(large_data_frame, additional_data)
    }
    
    # If the tz offset is 0, return the data frame without filtering it
    if (gmt_offset == 0){
      
      return(large_data_frame) 
    }
    
    # Filter data frame to only include data for requested years
    large_data_frame <- filter(large_data_frame, year >= startyear &
                                 year <= endyear)
    
    return(large_data_frame)
  }
}
