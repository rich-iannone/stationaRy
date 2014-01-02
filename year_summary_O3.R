year_summary_O3 <- function(all_years = FALSE,
                            single_year = NULL,
                            year_range = NULL,
                            file_path = NULL,
                            quarter_bounds = c("04-01", "09-30")) {
  
  
  all_years <- FALSE
  single_year <- 2009
  year_range <- NULL
  file_path <- "~/Documents/R (Working)"
  quarter_bounds = c("04-01", "09-30")
  
  # 
  #  test:
  #  year_summary_O3(single_year = 2001, file_path = "~/Documents/R (Working)")
  #
  
  measure <- "O3"
  
  file_path <- ifelse(is.null(file_path), getwd(), file_path)
  
  # Add require statement
  require(lubridate)
  
  # Generate the appropriate file list depending on the options chosen
  #
  # Generate file list for selected pollutant for all years
  if (all_years == TRUE & is.null(single_year) & is.null(year_range)) file_list <- 
    list.files(path = file_path, 
               pattern = "^[0-9][0-9][0-9][0-9][0-9A-Z]*O3\\.csv")
  
  # If a year range of years is provided, capture start and end year boundaries
  if (all_years == FALSE & is.null(single_year) & !is.null(year_range)) {
    start_year_range <- substr(as.character(year_range), 1, 4)
    end_year_range <- substr(as.character(year_range), 6, 9)
    for (i in start_year_range:end_year_range) {
      nam <- paste("file_list", i, sep = ".")
      assign(nam, list.files(path = file_path, 
                             pattern = paste("^",i,"[0-9A-Z]*O3\\.csv", sep = '')))
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
                                   pattern = paste("^",single_year,"[0-9A-Z]*O3\\.csv",
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
    
    # Determine number of hours in year
    hours_in_year <- days_in_year * 24
    
    # get vector list of stations for analysis
    station_list <- mat.or.vec(nr = no_stations, nc = 1)
    station_list <- unique(df$STATION)    
    
    # Initialize the output file for writing
    if (i == 1) {
      cat("Year,Pollutant,NapsID,",
          "Annual_O3_Average_Daily_8_hr_Max,",
          "Annual_O3_4th_Highest,",
          "Q2_Q3.Complete_%,",
          "Is_Annual_O3_4th_Highest_Valid,Annual_O3_4th_Highest_Exceed,",
          "Annual_O3_4th_Highest_Flag",
          file = paste(measure,"_data_summary.csv", sep = ''), sep = '')
      cat("", file = paste(measure,"_data_summary.csv", sep = ''),
          sep = "\n", append = TRUE) }
    
    # The data required to calculate the annual 4th highest daily 8hr-O3-max value for a
    #station includes:
    # i. The daily maximum 8-hour average ozone concentration for each day of the year
    # ii. The annual 4th highest daily 8hr-O3-max for a given year
    #
    # Initialize matrix with (1) year, (2) day of year, (3) the date, 
    # (4) number of dataset rows in a day, (5) number of NA values in a day,
    # (6) number of valid observations in a day, and (7) maximum of ozone daily 8-hour
    # rolling averages 
    O3_max_daily_8hr_rolling_averages <- as.data.frame(mat.or.vec(nr = days_in_year, nc = 7))
    colnames(O3_max_daily_8hr_rolling_averages) <- c("year", "day_of_year",
                                                     "date", "rows_in_day", "NA_in_day",
                                                     "valid_obs_in_day",
                                                     "O3_max_daily_8hr_rolling_average")
    
    # Loop through all stations in each file
    for (j in 1:length(station_list)){
      df.station <- subset(df, df$STATION == station_list[j])
      completeness_year <- 
        round(((nrow(df.station) - sum(is.na(df.station[,3])))/
                 ifelse(leap_year(year), 8784, 8760))
              *100,
              digits = 2)
      
      # Initialize data frame for ozone daily 8-hr rolling averages
      O3_8hr_rolling_averages <- as.data.frame(mat.or.vec(nr = hours_in_year, nc = 8))
      colnames(O3_8hr_rolling_averages) <- c("year", "day_of_year", "hour_of_day",
                                             "date", "rows_in_8hr_period",
                                             "NA_in_8hr_period",
                                             "valid_obs_in_8hr_period",
                                             "O3_8hr_rolling_average")
      class(O3_8hr_rolling_averages$date) = c('POSIXt','POSIXct')
      
      for (m in 1:7) {
        
        # Get year of 8-hour averaging period
        O3_8hr_rolling_averages[m, 1] <- year
        
        # Get day of year for 8-hour averaging period
        O3_8hr_rolling_averages[m, 2] <- yday(as.POSIXct(paste(year, "-01-01", sep = '')) +
                                                ((m - 1) * 3600))
        
        # Get hour of day for 8-hour averaging period
        O3_8hr_rolling_averages[m, 3] <- hour(as.POSIXct(paste(year, "-01-01", sep = '')) +
                                                ((m - 1) * 3600))
        
        # Get date for 8-hour averaging period
        O3_8hr_rolling_averages[m, 4] <- as.POSIXct(paste(year, "-01-01", sep = '')) +
          ((m - 1) * 3600)
        
        # Set to NA: (1) count of rows in dataset for a given 8-hour averaging period,
        #            (2) count of NA values in dataset for a given 8-hour averaging period
        #            (3) count of valid measurements for a given 8-hour averaging period
        #            (4) average ozone concentration for a given 8-hour averaging period
        O3_8hr_rolling_averages[m, 5] <- NA
        O3_8hr_rolling_averages[m, 6] <- NA
        O3_8hr_rolling_averages[m, 7] <- NA
        O3_8hr_rolling_averages[m, 8] <- NA
      }
      
      for (m in 8:hours_in_year) {
        
        # Get year of 8-hour averaging period
        O3_8hr_rolling_averages[m, 1] <- year(as.POSIXct(paste(year, "-01-01", sep = '')) +
                                                ((m - 1) * 3600))
        
        # Get day of year for 8-hour averaging period
        O3_8hr_rolling_averages[m, 2] <- yday(as.POSIXct(paste(year, "-01-01", sep = '')) +
                                                ((m - 1) * 3600))
        
        # Get hour of day for 8-hour averaging period
        O3_8hr_rolling_averages[m, 3] <- hour(as.POSIXct(paste(year, "-01-01", sep = '')) +
                                                ((m - 1) * 3600))
        
        # Get date for 8-hour averaging period
        O3_8hr_rolling_averages[m, 4] <- as.POSIXct(paste(year, "-01-01", sep = '')) +
          ((m - 1) * 3600)
        
        # Count the number of rows in dataset for a given 8-hour averaging period
        O3_8hr_rolling_averages[m, 5] <-
          nrow(subset(df.station,
                      time <= as.POSIXct(paste(year, "-01-01", sep = '')) +
                        ((m - 1) * 3600) &
                        time >= as.POSIXct(paste(year, "-01-01", sep = '')) +
                        ((m - 8) * 3600)))
        
        
        # Count the number of NA values in dataset for a given 8-hour averaging period
        O3_8hr_rolling_averages[m, 6] <- 
          sum(is.na(subset(df.station,
                           time <= as.POSIXct(paste(year, "-01-01", sep = '')) +
                             ((m - 1) * 3600) &
                             time >= as.POSIXct(paste(year, "-01-01", sep = '')) +
                             ((m - 8) * 3600)  
          )[,3]))
        
        # Calculate the number of valid measurements for a given 8-hour averaging period
        O3_8hr_rolling_averages[m, 7] <- O3_8hr_rolling_averages[m, 5] -
          O3_8hr_rolling_averages[m, 6]
        
        # Calculate the average ozone concentration for a given 8-hour averaging period
        O3_8hr_rolling_averages[m, 8] <- 
          ifelse(O3_8hr_rolling_averages[m, 7] >= 6,
                 round(mean(subset(df.station,
                                   time <= as.POSIXct(paste(year, "-01-01", sep = '')) +
                                     ((m - 1) * 3600) &
                                     time >= as.POSIXct(paste(year, "-01-01", sep = '')) +
                                     ((m - 8) * 3600)
                 )[,3],
                            na.rm = TRUE), digits = 1), NA)
      }
      
      # Initialize matrix with (1) year, (2) day of year, (3) the date, 
      # (4) number of dataset rows in a day, (5) number of NA values in a day,
      # (6) number of valid observations in a day, and (7) maximum of ozone daily 8-hour
      # rolling averages 
      O3_max_daily_8hr_rolling_averages <- as.data.frame(mat.or.vec(nr = days_in_year, nc = 7))
      colnames(O3_max_daily_8hr_rolling_averages) <- c("year", "day_of_year",
                                                       "date", "rows_in_day", "NA_in_day",
                                                       "valid_obs_in_day",
                                                       "O3_max_daily_8hr_rolling_average")
      class(O3_max_daily_8hr_rolling_averages$date) = c('Date')
      
      # Loop through all days in year and put calculated values in initialized data frame
      for (k in 1:days_in_year) {
        
        # Insert the year in the 'year' column
        O3_max_daily_8hr_rolling_averages[k,1] <- year
        
        # Insert the day of year in the 'day_of_year' column
        O3_max_daily_8hr_rolling_averages[k,2] <- k
        
        # Insert the date in the 'date' column
        O3_max_daily_8hr_rolling_averages[k,3] <- as.Date(subset(O3_8hr_rolling_averages, 
                                                             day_of_year == k)[,4][1])
        
        # Count the number of rows in dataset for a day      
        O3_max_daily_8hr_rolling_averages[k,4] <- nrow(subset(O3_8hr_rolling_averages, 
                                                    day_of_year == k))
        
        # Count the number of NA values for the O3 8hr rolling average in the dataset
        # for a given day
        O3_max_daily_8hr_rolling_averages[k,5] <-
          sum(is.na(subset(O3_8hr_rolling_averages, 
                           day_of_year == k)[,8]))
        
        # Calculate the number of valid measurements for a given day
        O3_max_daily_8hr_rolling_averages[k,6] <-
          O3_max_daily_8hr_rolling_averages[k,4] - O3_max_daily_8hr_rolling_averages[k,5]
        
        # Calculate the maximum of 8-hour daily average, put into column 7
        # ('O3_max_daily_8hr_rolling_average')
        O3_max_daily_8hr_rolling_averages[k,7] <- 
          ifelse(O3_max_daily_8hr_rolling_averages[k,6] >= 18,
                 round(mean(subset(O3_8hr_rolling_averages, day_of_year == k)[,8],
                            na.rm = TRUE), digits = 1), NA)
        
        # Close inner loop for station days
      }
      
      # Convert any NaN values in the data frame to NA for consistency
      O3_max_daily_8hr_rolling_averages <- 
        as.data.frame(rapply(O3_max_daily_8hr_rolling_averages,
                             f = function(x) ifelse(is.nan(x), NA, x),
                             how = "replace"))
      
      # Calculate the annual average of the highest daily 8hr-O3-max for the year
      average_annual_of_daily_8hr_O3_max <- 
        round(mean(O3_8hr_rolling_averages$O3_8hr_rolling_average,
                   na.rm = TRUE), digits = 1)
      
      # Calculate the 4th highest daily 8hr-O3-max for the year by conducting a decreasing
      # sort of the maximum of daily rolling 8-hr averages and then accessing the 4th item in
      # that vector list
      
      O3_8hr_rolling_averages_sort_descending <-
        sort(O3_8hr_rolling_averages$O3_8hr_rolling_average, decreasing = TRUE, na.last = NA)
      
      annual_4th_highest_daily_8hr_O3_max <- O3_8hr_rolling_averages_sort_descending[4]
      
      
      # Determine number of valid daily 8hr-O3-max in the combined 2nd and 3rd quarters
      # (April 1 to September 30) - Fix this day 91-274
      number_of_valid_O3_daily_averages <- 
        sum(!is.na(subset(
          O3_max_daily_8hr_rolling_averages,
          O3_max_daily_8hr_rolling_averages$day_of_year >= 91 & 
            O3_max_daily_8hr_rolling_averages$day_of_year <= 274)[,7]))
      
      # Determine the percentage of days with valid daily 8hr-O3-max values in the
      # April 1 to September 30 period
      percent_valid_O3_daily_averages <- 
        (number_of_valid_O3_daily_averages / 184) * 100

      # Set the data completeness boolean to TRUE if the percentage of valid days in the
      # specified period is greater than or equal to 75%
      data_complete_year <- 
        ifelse(percent_valid_O3_daily_averages >= 75, TRUE, FALSE)
      
      does_annual_4th_highest_daily_8hr_O3_max_exceed <- 
        ifelse(annual_4th_highest_daily_8hr_O3_max > 30, TRUE, FALSE)
      
      annual_4th_highest_daily_8hr_O3_max_flag <- 
        ifelse(does_annual_4th_highest_daily_8hr_O3_max_exceed == TRUE &
                 data_complete_year == FALSE, "based on incomplete data", "")
      
      # Place values in row of output CSV file
      #cat(year,",",measure,",",station_list[j],",",
      cat(year,",",measure,",",station_list[j],",",
          average_annual_of_daily_8hr_O3_max,",",
          annual_4th_highest_daily_8hr_O3_max,",",
          percent_valid_O3_daily_averages,",",
          data_complete_year,",",
          does_annual_4th_highest_daily_8hr_O3_max_exceed,",",
          annual_4th_highest_daily_8hr_O3_max_flag,      
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