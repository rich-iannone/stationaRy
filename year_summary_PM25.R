year_summary_PM25 <- function(all_years = FALSE,
                              single_year = NULL,
                              year_range = NULL,
                              file_path = NULL,
                              quarter_bounds = c("01-01", "03-31",
                                                 "04-01", "06-30",
                                                 "07-01", "09-30",
                                                 "10-01", "12-31")) {

#
#   all_years <- FALSE
#   single_year <- NULL
#   year_range <- "1998-2012"
#   file_path <- "~/Documents/R (Working)"
#   quarter_bounds = c("01-01", "03-31",
#                      "04-01", "06-30",
#                      "07-01", "09-30",
#                      "10-01", "12-31")
#
#
#  test:
#  year_summary_PM25(single_year = 2001, file_path = "~/Documents/R (Working)")
#
  
  measure <- "PM25"
  
  file_path <- ifelse(is.null(file_path), getwd(), file_path)
  
  # Add require statement
  require(lubridate)
  
  # Generate the appropriate file list depending on the options chosen
  #
  # Generate file list for selected pollutant for all years
  if (all_years == TRUE & is.null(single_year) & is.null(year_range)) file_list <- 
    list.files(path = file_path, 
               pattern = "^[0-9][0-9][0-9][0-9][0-9A-Z]*PM25\\.csv")
  
  # If a year range of years is provided, capture start and end year boundaries
  if (all_years == FALSE & is.null(single_year) & !is.null(year_range)) {
    start_year_range <- substr(as.character(year_range), 1, 4)
    end_year_range <- substr(as.character(year_range), 6, 9)
    for (i in start_year_range:end_year_range) {
      nam <- paste("file_list", i, sep = ".")
      assign(nam, list.files(path = file_path, 
                             pattern = paste("^",i,"[0-9A-Z]*PM25\\.csv", sep = '')))
    }
    # Combine vector lists
    list <- vector("list", length(ls(pattern = "file_list.")))
    for (j in 1:length(ls(pattern = "file_list."))) {
      list[j] <- list(get(ls(pattern = "file_list.")[j]))
    }
    file_list <- unlist(list)
    # Remove temp objects
    rm(list)
    rm(i)
    rm(j)
    rm(nam)
    rm(list = ls(pattern = "file_list."))
  }
  
  # If 'single_year' specified, filter the list to only include objects of the specified year
  if (all_years == FALSE & !is.null(single_year) & is.null(year_range)) {
    assign("file_list", list.files(path = file_path, 
                                   pattern = paste("^",single_year,"[0-9A-Z]*PM25\\.csv",
                                                   sep = '')))
  }
  
  
  # Loop through reading in CSV files; convert time column back to POSIXct time objects
  for (i in 1:length(file_list)){
    df <- read.csv(file = paste(file_path, "/", file_list[i], sep = ''),
                   header = TRUE, stringsAsFactors = FALSE)
    df$time <- as.POSIXct(df$time)
    
    # get number of stations
    no_stations <- length(unique(df$STATION))
    
    # inspect dataset to verify the year 
    year <- round(mean(year(df$time)))
    
    # Determine number of days in year
    days_in_year <- yday(as.POSIXct(paste(year, "-12-31", sep = ''),
                                    origin = "1970-01-01", tz = "GMT"))
    
    # get method of PM25 collection (e.g., BAM, TEOM, SES, FDMS, BAM35, SHARP, etc.)
    method <- gsub("^[0-9][0-9][0-9][0-9]([A-Z0-9]*)PM25\\.csv", "\\1", file_list[i])
    
    # get vector list of stations for analysis
    station_list <- mat.or.vec(nr = no_stations, nc = 1)
    station_list <- unique(df$STATION)    
    
    # Initialize the output file for writing
    if (i == 1) {
      cat("Year,Pollutant,Method,NapsID,",
          "Valid_Daily_Averages,Annual_pm25_Average_Daily_24h_Average,Annual_pm25_98P,",
          "Q1.Complete_%,Q2.Complete_%,",
          "Q3.Complete_%,Q4.Complete_%,",
          "Is_98P_Valid,Annual_pm25_98P_Exceed,",
          "pm25_98P_flag",
          file = paste(measure,"_data_summary.csv", sep = ''), sep = '')
      cat("", file = paste(measure,"_data_summary.csv", sep = ''),
          sep = "\n", append = TRUE)}
    
    # The data required to calculate a PM2.5 24-hour metric value for a station includes:
    # i.  The daily average (midnight to midnight local time) PM2.5 concentration for each 
    #     day of a given year; and
    # ii. The annual average of the daily 24hr-PM2.5 for the given year
    #
    # Initialize matrix with (1) year, (2) day of year, (3) date, (4) number of dataset
    # rows in a day, (5) number of NA values in a day, (6) number of valid observations in
    # a day, and (7) daily average  
    pm25_daily_averages <- as.data.frame(mat.or.vec(nr = days_in_year, nc = 7))
    colnames(pm25_daily_averages) <- c("year", "day_of_year", "date", "rows_in_day", "NA_in_day",
                                       "valid_obs_in_day", "daily_average")
    
    # Loop through all stations in each file
    for (j in 1:length(station_list)){
      df.station <- subset(df, df$STATION == station_list[j])
      completeness_year <- 
        round(((nrow(df.station) - sum(is.na(df.station[,3])))/
                 ifelse(leap_year(year), 8784, 8760))
              *100,
              digits = 2)
      
      # Loop through all days in year and put calculated values in initialized data frame
      for (k in 1:days_in_year) {
        
        # inspect dataset to verify the year 
        year <- round(mean(year(df.station$time)))
        
        # Determine number of days in year
        days_in_year <- yday(as.POSIXct(paste(year, "-12-31", sep = ''),
                                        origin = "1970-01-01", tz = "GMT"))
        
        # Insert the year in the 'year' column
        pm25_daily_averages[k,1] <- year
        
        # Insert the day in the 'day' column
        pm25_daily_averages[k,2] <- k
        
        # Insert the date in the 'date' column
        pm25_daily_averages[k,3] <- as.POSIXct((k - 1) * 24 * 3600,
                                               origin = paste(year, "-01-01 00:00", sep = ''),
                                               tz = "GMT")
        
        # Calculate the data completeness as hours per day with a PM2.5 value
        #
        # Count the number of rows in dataset for a given day
        pm25_daily_averages[k,4] <- 
          nrow(subset(df.station,
                      time >= as.POSIXct(paste(year, "-01-01", sep = '')) +
                        ((k - 1) * (3600 * 24)) &
                        time < as.POSIXct(paste(year, "-01-01", sep = '')) +
                        ((k + 1 - 1) * (3600 * 24))))
        
        if(k == days_in_year) pm25_daily_averages[k,4] <-
          nrow(subset(df.station,
                      time >= as.POSIXct(paste(year, "-12-31", sep = '')) &
                        time < as.POSIXct(paste(year, "-12-31 23:59:59", sep = ''))))
        
        # Count the number of NA values in dataset for a given day
        pm25_daily_averages[k,5] <-
          sum(is.na(subset(df.station,
                           time >= as.POSIXct(paste(year, "-01-01", sep = '')) +
                             ((k - 1) * (3600 * 24)) &
                             time < as.POSIXct(paste(year, "-01-01", sep = '')) +
                             ((k + 1 - 1) * (3600 * 24)))[,3]))
        
        if(k == days_in_year) pm25_daily_averages[k,5] <-
          sum(is.na(subset(df.station,
                           time >= as.POSIXct(paste(year, "-12-31", sep = '')) &
                             time < as.POSIXct(paste(year, "-12-31 23:59:59", sep = '')))[,3]))
        
        # Calculate the number of valid measurements for a given day
        pm25_daily_averages[k,6] <- pm25_daily_averages[k,4] - pm25_daily_averages[k,5]
        
        # Calculate the daily average, put into column 7 ('daily_average')
        pm25_daily_averages[k,7] <- 
          ifelse(pm25_daily_averages[k,6] >= 18,
                 round(mean(subset(df.station,
                                   time >= as.POSIXct(paste(year, "-01-01", sep = '')) +
                                     ((k - 1) * (3600 * 24)) &
                                     time < as.POSIXct(paste(year, "-01-01", sep = '')) +
                                     ((k + 1 - 1) * (3600 * 24)))[,3],
                            na.rm = TRUE), digits = 1), NA)
        
        if(k == days_in_year) pm25_daily_averages[k,7] <-
          ifelse(pm25_daily_averages[k,6] >= 18,
                 round(mean(subset(df.station,
                                   time >= as.POSIXct(paste(year, "-12-31", sep = '')) &
                                     time < as.POSIXct(paste(year, "-12-31 23:59:59",
                                                             sep = '')))[,3],
                            na.rm = TRUE), digits = 1), NA)
        
        # Convert any NaN values in the data frame to NA for consistency
        pm25_daily_averages <- as.data.frame(rapply(pm25_daily_averages,
                                                    f = function(x) ifelse(is.nan(x), NA, x),
                                                    how = "replace"))
        
        # Close inner loop for station days
      }
      
      # Calculate the 98th percentile value of PM2.5 for the year
      #
      # Order all the daily 24hr-PM2.5 for a given year into an array from highest to lowest
      # concentrations, with equal values repeated as often as they occur.
      
      number_of_valid_pm25_daily_averages <- sum(!is.na(pm25_daily_averages$daily_average))
      
      pm25_daily_averages_sort_descending <-
        sort(pm25_daily_averages$daily_average, decreasing = TRUE, na.last = NA)
      
      # Calculate the number i.d, defined as follows,
      i.d <- 0.98 * number_of_valid_pm25_daily_averages
      
      # Remove the decimal portion of 'i.d', subtract integer from total values to obtain rank,
      # and look up the average value in the 'pm25_daily_averages_sort_descending' vector
      annual_pm25_98P <- 
        pm25_daily_averages_sort_descending[number_of_valid_pm25_daily_averages - floor(i.d)]
      
      # Determine whether the 98P value meets data completeness criteria and is valid
      #
      # For any given year, the annual 98P will be considered valid if the following two
      # criteria are satisfied:
      # i. At least 75% valid daily-24hr-PM2.5 in the year
      # ii. At least 60% valid daily-24hr-PM2.5 in each calendar quarter
      #
      # Calculate the percentage of valid daily-24hr-PM2.5 averages in the year, determine
      # whether 75% completeness is achieved
      
      data_complete_year <- ifelse(((number_of_valid_pm25_daily_averages/days_in_year) *
                                      100) >= 75, TRUE, FALSE)
      
      # Calculate the percentage completeness in each calendar quarter
      
      Q1 <- subset(pm25_daily_averages,
                   date >= as.POSIXct(paste(year, "-01-01", sep = ''),
                                      origin = "1970-01-01", tz = "GMT") &
                     date <= as.POSIXct(paste(year, "-03-31", sep = ''),
                                        origin = "1970-01-01", tz = "GMT"))
      
      Q2 <- subset(pm25_daily_averages,
                   date >= as.POSIXct(paste(year, "-04-01", sep = ''),
                                      origin = "1970-01-01", tz = "GMT") &
                     date <= as.POSIXct(paste(year, "-06-30", sep = ''),
                                        origin = "1970-01-01", tz = "GMT"))
      
      Q3 <- subset(pm25_daily_averages,
                   date >= as.POSIXct(paste(year, "-07-01", sep = ''),
                                      origin = "1970-01-01", tz = "GMT") &
                     date <= as.POSIXct(paste(year, "-09-30", sep = ''),
                                        origin = "1970-01-01", tz = "GMT"))
      
      Q4 <- subset(pm25_daily_averages,
                   date >= as.POSIXct(paste(year, "-10-01", sep = ''),
                                      origin = "1970-01-01", tz = "GMT") &
                     date <= as.POSIXct(paste(year, "-12-31", sep = ''),
                                        origin = "1970-01-01", tz = "GMT"))
      
      Q1.complete <- round((sum(!is.na(Q1$daily_average))/nrow(Q1)) * 100, digits = 1)
      Q2.complete <- round((sum(!is.na(Q2$daily_average))/nrow(Q2)) * 100, digits = 1)
      Q3.complete <- round((sum(!is.na(Q3$daily_average))/nrow(Q3)) * 100, digits = 1)
      Q4.complete <- round((sum(!is.na(Q4$daily_average))/nrow(Q4)) * 100, digits = 1)
      
      data_complete_quarter <- ifelse(Q1.complete >= 60 &
                                        Q2.complete >= 60 &
                                        Q3.complete >= 60 &
                                        Q4.complete >= 60,
                                      TRUE, FALSE)
      
      is_98P_valid <- ifelse(data_complete_year == TRUE &
                               data_complete_quarter == TRUE, TRUE, FALSE)
      
      does_annual_pm25_98P_exceed <- ifelse(annual_pm25_98P > 30, TRUE, FALSE)
      
      pm25_98P_flag <- ifelse(does_annual_pm25_98P_exceed == TRUE &
                                data_complete_year == TRUE &
                                data_complete_quarter == FALSE, "based on incomplete data", "")
      
      # Place values in row of output CSV file
      cat(year,",",measure,",",method,",",station_list[j],",",
          number_of_valid_pm25_daily_averages,",",
          annual_pm25_98P,",",
          Q1.complete,",",
          Q2.complete,",",
          Q3.complete,",",
          Q4.complete,",",
          is_98P_valid,",",
          does_annual_pm25_98P_exceed,",",
          pm25_98P_flag,      
          file = paste(measure,"_data_summary.csv", sep = ''),
          sep = "", append = TRUE)
      
      # Add linebreak to CSV file after writing line
      cat("", file = paste(measure,"_data_summary.csv", sep = ''),
          sep = "\n", append = TRUE)
      
      
      # Close inner for loop, looping through stations in a CSV file
    }
    
    # Close outer for loop, looping through reads of CSV files
  } 
  
  # Close function 
}
