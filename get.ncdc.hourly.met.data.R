get.ncdc.hourly.met.data <- function(startyear,
                                     endyear,
                                     lower_lat = NULL,
                                     upper_lat = NULL,
                                     lower_long = NULL,
                                     upper_long = NULL,
                                     file_path = NULL){
  
  # Add require statements
  require(lubridate)
  require(plyr)
  require(stringr)
  
  # Check whether 'startyear' and 'endyear' are both provided
  if (is.null(startyear) | is.null(endyear)) {
    stop("Please enter starting and ending years for surface station data")
  } else { }
  
  # Check whether 'startyear' and 'endyear' are both numeric
  if (!is.numeric(startyear) | !is.numeric(endyear)) {
    stop("Please enter numeric values for the starting and ending years")
  } else { }
  
  # Check whether 'startyear' and 'endyear' are in the correct order
  if (startyear > endyear) {
    stop("Please enter the starting and ending years in the correct order")
  } else { }
  
  # Check whether 'staryear' and 'endyear' are within set bounds (1892 to current year)
  if (startyear < 1892 | endyear < 1892 | startyear > year(Sys.Date()) | endyear > year(Sys.Date())) {
    stop("Please enter the starting and ending years in the correct order")
  } else { }
  
  # Define time parameters
  NOAA_start_year <- startyear
  NOAA_end_year <- endyear
  
  # Get hourly surface data history CSV from NOAA/NCDC FTP
  file <- "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/ish-history.csv"
  
  repeat {
    try(download.file(file, "ish-history.csv", quiet = TRUE))
    if (file.info("ish-history.csv")$size > 0) { break }
  }
  
  # Read in the "ish-history" CSV file
  st <- read.csv("ish-history.csv")
  
  # Get formatted list of station names and elevations
  names(st)[c(3, 10)] <- c("NAME", "ELEV")
  st <- st[, -5]
  
  # Reintroduce the decimals in the latitude, longitude, and elevation
  st$LAT <- st$LAT/1000
  st$LON <- st$LON/1000
  st$ELEV <- st$ELEV/10
  
  # Recompose the years from the data file
  st$BEGIN <- as.numeric(substr(st$BEGIN, 1, 4))
  st$END <- as.numeric(substr(st$END, 1, 4))
  
  # Generate a list based on the domain location, also ignoring stations without
  # beginning years reported
  domain.list <- subset(st, st$LON >= lower_long & 
                          st$LON <= upper_long &
                          st$LAT >= lower_lat &
                          st$LAT <= upper_lat &
                          BEGIN <= NOAA_start_year &
                          END >= NOAA_end_year)
  
  # Initialize data frame for file status reporting
  outputs <- as.data.frame(matrix(NA, dim(domain.list)[1], 2))
  names(outputs) <- c("FILE", "STATUS")
  
  # Download the gzip-compressed data files for the years specified
  # Provide information on the number of records in data file retrieved 
  for (y in NOAA_start_year:NOAA_end_year) {
    y.domain.list <- domain.list[domain.list$BEGIN <= y & domain.list$END >= y, ]
    for (s in 1:dim(y.domain.list)[1]) {
      outputs[s, 1] <- paste(sprintf("%06d", y.domain.list[s,1]),
                             "-", sprintf("%05d", y.domain.list[s,2]),
                             "-", y, ".gz", sep = "")
      system(paste("curl -O ftp://ftp.ncdc.noaa.gov/pub/data/noaa/", y,
                   "/", outputs[s, 1], sep = ""))
      outputs[s, 2] <- ifelse(file.exists(outputs[s, 1]) == "TRUE", 'available', 'missing')
    }
  }
  
  # Generate report of stations and file transfers
  file_report <- cbind(y.domain.list, outputs)
  row.names(file_report) <- 1:nrow(file_report)
  
  # Extract all downloaded data files
  system("gunzip *.gz", intern = FALSE, ignore.stderr = TRUE)
  
  # Read data from files
  # Specific focus here on the fixed width portions ('Mandatory Data Section') of each file
  files <- list.files(pattern = "^[0-9]*-[0-9]*-[0-9]*$")
  column.widths <- c(4, 6, 5, 4, 2, 2, 2, 2, 1, 6,
                     7, 5, 5, 5, 4, 3, 1, 1, 4, 1,
                     5, 1, 1, 1, 6, 1, 1, 1, 5, 1,
                     5, 1, 5, 1)
  stations <- as.data.frame(matrix(NA, length(files), 6))
  names(stations) <- c("USAFID", "WBAN", "YR", "LAT", "LONG", "ELEV")
  
  for (i in 1:length(files)) {
    # Read data from mandatory data section of each file, which is a fixed-width string
    data <- read.fwf(files[i], column.widths)
    data <- data[, c(2:8, 10:11, 13, 16, 19, 21, 29, 31, 33)]
    names(data) <- c("USAFID", "WBAN", "YR", "M", "D", "HR", "MIN", "LAT", "LONG",
                     "ELEV", "WIND.DIR", "WIND.SPD", "CEIL.HGT", "TEMP", "DEW.POINT",
                     "ATM.PRES")
    
    # Recompose data and use consistent missing indicators of 9999 for missing data
    data$LAT <- data$LAT/1000
    data$LONG <- data$LONG/1000
    data$WIND.DIR <- ifelse(data$WIND.DIR == 999, 999, data$WIND.DIR)
    data$WIND.SPD <- ifelse(data$WIND.SPD > 100, 999.9, data$WIND.SPD/10)
    data$TEMP <-  ifelse(data$TEMP > 900, 999.9, round((data$TEMP/10) + 273.2, 1))
    data$DEW.POINT <- ifelse(data$DEW.POINT > 100, 999.9, data$DEW.POINT/10)
    data$ATM.PRES <- ifelse(data$ATM.PRES > 2000, 999.9, data$ATM.PRES/10)
    data$CEIL.HGT <- ifelse(data$CEIL.HGT == 99999, 999.9, round(data$CEIL.HGT*3.28084/100, 0))
    
    # Calculate the RH using the August-Roche-Magnus approximation
    RH <- ifelse(data$TEMP == 999.9 | data$DEW.POINT == 999.9, NA, 
                 100 * (exp((17.625 * data$DEW.POINT) / (243.04 + data$DEW.POINT))/
                          exp((17.625 * (data$TEMP - 273.2)) / (243.04 + (data$TEMP - 273.2)))))
    
    data$RH <- round_any(as.numeric(RH), 0.1, f = round)
    
    # Write CSV file for each station, combining data elements from the mandatory data
    # section and the additional data section
    write.csv(data, file = paste(files[i], ".csv", sep = ""), row.names = FALSE)
    
    # Create a data frame with summary data for each station
    stations[i, 1:3] <- data[1, 1:3]
    stations[i, 4:6] <- data[1, 8:10]
    
  }
  
  # Write the station data to a CSV file
  write.csv(stations, file = "stations.csv", row.names = FALSE)
  
}

