#' Get met station data from the ISD dataset
#' @description Obtain one or more years of meteorological data for a station
#' from the NCEI Integrated Surface Dataset (ISD).
#' @param station_id a station identifier composed of the station's USAF and
#' WBAN numbers, separated by a hyphen.
#' @param startyear the starting year for the collected data.
#' @param endyear the ending year for the collected data.
#' @importFrom plyr round_any
#' @import dplyr
#' @import readr
#' @import stringr
#' @import lubridate
#' @import downloader
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
#' }
#' @export get_isd_station_data

get_isd_station_data <- function(station_id,
                                 startyear,
                                 endyear){
  
  usaf <- wban <- year <- NA
  
  if (is.null(startyear) | is.null(endyear)) {
    stop("Please enter starting and ending years for surface station data")
  }
  
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
  
  # Create a temporary folder to deposit downloaded files
  temp_folder <- tempdir()
  
  # Download the gzip-compressed data files for the years specified
  data_files_downloaded <- vector(mode = "character")
  
  for (i in startyear:endyear){
    
    if (i == startyear){
      
      data_files_downloaded <- vector(mode = "character")
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
      
      data_files_downloaded <- c(data_files_downloaded,
                                 data_file_to_download)
    }
  }
  
  # Define column widths for fixed-width data in mandatory section of
  # ISD data file
  column_widths <- c(4, 6, 5, 4, 2, 2, 2, 2, 1, 6,
                     7, 5, 5, 5, 4, 3, 1, 1, 4, 1,
                     5, 1, 1, 1, 6, 1, 1, 1, 5, 1,
                     5, 1, 5, 1)
  
  for (i in 1:length(data_files_downloaded)){
    
    if (file.exists(file.path(temp_folder,
                              data_files_downloaded[i]))){
      
      # Read data from mandatory data section of each file,
      # which is a fixed-width string
      data <- 
        read_fwf(file.path(temp_folder,
                           data_files_downloaded[i]),
                 fwf_widths(column_widths))
      
      # Remove select columns from data frame
      data <- data[, c(2:8, 10:11, 13, 16, 19, 21, 29, 31, 33)]
      
      # Apply new names to the data frame columns
      names(data) <-
        c("usaf", "wban", "year", "month", "day", "hour", "minute",
          "lat", "lon", "elev", "wd", "ws", "ceil_hgt",
          "temp", "dew_point", "atmos_pres")
      
      #
      # Recompose data and use NAs for missing data
      #
      
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
        
        rh_j <- round_any(as.numeric(rh_j), 0.1, f = round)
        
        rh <- c(rh, rh_j)
      }
      
      data$rh <- rh
      
      if (i == 1){
        large_data_frame <- data
      }
      
      if (i > 1){
        large_data_frame <- rbind(large_data_frame, data)
      }
    }
  }
  
  # Create POSIXct times
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
  large_data_frame$min <- minute(large_data_frame$time)
  
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
  
  # Filter data frame to only include data for requested years
  large_data_frame <- filter(large_data_frame, year >= startyear &
                               year <= endyear)
  
  return(large_data_frame)
  
  # Get additional data portions of records, exluding remarks
  for (i in 1:length(data_files_downloaded)){
    add_data <- 
      readLines(file.path(temp_folder,
                          data_files_downloaded[i]))
    
    add_data <- unlist(str_extract_all(add_data, "ADD.*?REM"))
    
    if (i == 1){
      all_add_data <- add_data
    }
    
    if (i > 1){
      all_add_data <- c(all_add_data, add_data)
    }
  }
  
  data_attributes <-
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
  
  # Function for getting data from an additional data category
  get_df_from_category <- function(category_key,
                                   field_lengths,
                                   scale_factor,
                                   data_types,
                                   add_data){
    
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
    }
    
    return(df_from_category)
  }
  
  # Determine which additional parameters have been measured
  for (i in 1:length(data_attributes)){
    
    if (i == 1){
      data_attributes_counts <-
        vector(mode = "numeric",
               length = length(data_attributes))
    }
    
    data_attributes_counts[i] <-
      sum(str_detect(all_add_data, data_attributes[i]))
  }
  
  # Filter those measured parameters and obtain string of identifiers
  significant_params <- data_attributes[which(data_attributes_counts > 20)]
  
  # AA1 - liquid precipitation: period quantity, depth dimension
  if (data_attributes[1] %in% significant_params){
    
    aa1 <-
      get_df_from_category(category_key = "AA1",
                           field_lengths = c(2, 4, 1, 1),
                           scale_factor = c(1, 10, NA, NA),
                           data_types = c("numeric", "numeric",
                                          "character", "character"),
                           add_data = all_add_data)
  }
  
  # AB1 - liquid precipitation: monthly total
  if (data_attributes[2] %in% significant_params){
    
    ab1 <-
      get_df_from_category(category_key = "AB1",
                           field_lengths = c(5, 1, 1),
                           scale_factor = c(10, NA, NA),
                           data_types = c("numeric", "character",
                                          "character"),
                           add_data = all_add_data)
    
  }
  
  # AC1 - precipitation observation history
  
  # AD1 - liquid precipitation, greatest amount in 24 hours, for the month
  
  # AE1 - liquid precipitation, number of days with specific amounts, for the month
  
  # AG1 - precipitation estimated observation
  
  # AH1 - liquid precipitation maximum short duration, for the month (1)
  
  # AI1 - liquid precipitation maximum short duration, for the month (2)
  
  # AJ1 - snow depth
  
  # AK1 - snow depth greatest depth on the ground, for the month
  
  # AL1 - snow accumulation
  
  # AM1 - snow accumulation greatest amount in 24 hours, for the month
  
  # AN1 - snow accumulation for the month
  
  # AO1 - liquid precipitation
  
  # AP1 - 15-minute liquid precipitation
  
  # AU1 - present weather observation
  
  # AW1 - present weather observation 
  
  # AX1 - past weather observation (1)
  
  # AY1 - past weather observation (2)
  
  # AZ1 - past weather observation (3)
  
  # CB1 - subhourly observed liquid precipitation: secondary sensor
  
  # CF1 - hourly fan speed
  
  # CG1 - subhourly observed liquid precipitation: primary sensor
  
  # CH1 - hourly/subhourly RH/temperatures
  
  # CI1 - hourly RH/temperatures
  
  # CN1 - hourly battery voltage
  
  # CN2 - hourly diagnostics
  
  # CN3 - secondary hourly diagnostics (1)
  
  # CN4 - secondary hourly diagnostics (2)
  
  # CR1 - CRN control
  
  # CT1 - subhourly temperatures
  
  # CU1 - hourly temperatures
  
  # CV1 - hourly temperature extremes
  
  # CW1 - subhourly wetness
  
  # CX1 - hourly geonor vibrating wire summary
  
  # CO1 - network metadata
  
  # CO2 - US cooperative network element time offset
  
  # ED1 - runway visual range
  
  # GA1 - sky cover layer
  
  # GD1 - sky cover summation state
  
  # GF1 - sky condition observation
  
  # GG1 - below station cloud layer
  
  # GH1 - hourly solar radiation
  
  # GJ1 - sunshine observation (1)
  
  # GK1 - sunshine observation (2)
  
  # GL1 - sunshine observation for the month
  
  # GM1 - solar irradiance
  
  # GN1 - solar radiation
  
  # GO1 - net solar radiation
  
  # GP1 - modeled solar irradiance
  
  # GQ1 - hourly solar angle
  
  # GR1 - hourly extraterrestrial radiation
  
  # HL1 - hail data
  
  # IA1 - ground surface data
  
  # IA2 - ground surface observation
  
  # IB1 - hourly surface temperature
  
  # IB2 - hourly surface temperature sensor
  
  # KA1 - temperature data
  
  # KB1 - average air temperature
  
  # KC1 - extreme air temperature for the month
  
  # KD1 - heating/cooling degree days
  
  # KE1 - extreme temperatures, number of days exceeding criteria, for the month
  
  # KF1 - hourly calculated temperature
  
  # KG1 - average dew point and wet bulb temperature
  
  # MA1 - atmospheric pressure observation
  
  # MD1 - atmospheric pressure change
  
  # ME1 - geopotential height isobaric level
  
  # MF1 - atmospheric pressure observation (STP/SLP)
  
  # MG1 - atmospheric pressure observation
  
  # MH1 - atmospheric pressure observation for the month (1)
  
  # MH2 - atmospheric pressure observation for the month (2)
  
  # MV1 - present weather in vicinity
  
  # MW1 - present weather observation 
  
  # OA1 - supplementary wine observation 
  
  # OB1 - hourly/sub-hourly wind section
  
  # OC1 - wind gust observation
  
  # OE1 - summary of day wind observation
  
  # RH1 - relative humidity
  
  # SA1 - sea surface temperature observation
  
  # ST1 - soil temperature
  
  # UA1 - wave measurement
  
  # UG1 - wave measurement primary swell
  
  # WA1 - platform ice accretion
  
  # WD1 - water surface ice observation
  
  # WG1 - water surface ice historical observation
  
  
  
}
