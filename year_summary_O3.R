# Function to obtain the:
# 1)  the 1-year average of the daily maximum 8-hour average ozone concentrations
# 2)	the annual 4th highest of daily maximum 8-hour average ozone concentrations



year_summary_O3 <- function(all_years = FALSE,
                             single_year = NULL,
                             year_range = NULL,
                             file_path = NULL,
                             quarter_bounds = c("04-01", "09-30")) {
  
  
  all_years <- FALSE
  single_year <- 1998
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
    
}