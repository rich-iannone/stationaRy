generate.NAPS.df <- function(subdir = NULL,
                              year = NULL,
                              pollutant = NULL,
                              type = NULL,
                              NapsID = NULL,
                              all_data = FALSE,
                              write_to_CSV = TRUE) {
  
  # Add require statements
  require(gdata)
  
  # Function for generating CSV files from NAPS hourly (.hly) data files
  # Assumes that the files reside somewhere under ~ (the user's Home folder)
  
  # Pollutant can be "PM25", "O3", "NO2", etc., it essentially needs to be available
  # in the filename of the NAPS hourly (.hly) data files
  
  # Get vector with list of all hourly files
  files <- ifelse(all_data == "TRUE" & is.null(pollutant),
                  list.files(path = paste("~", subdir, sep = ''), 
                             pattern = "^[0-9a-zA-Z/.]*hly"), NULL)
  
  # Get vector with list of all hourly files by pollutant
  files <- ifelse(all_data == "TRUE" & !is.null(pollutant),
                  list.files(path = paste("~", subdir, sep = ''), 
                             pattern = "^[0-9]*", pollutant, ".hly"), NULL)
  
  # Get vector with list of hourly files selected by year
  files <- ifelse(!is.null(year) & all_data == FALSE,
                  list.files(path = paste("~", subdir, sep = ''), 
                             pattern = paste("^", year, "[0-9a-zA-Z/.]*hly", sep = '')), NULL)
  
  # Get vector with list of hourly files selected by year and pollutant
  files <- ifelse(!is.null(year) & !is.null(pollutant) & all_data == FALSE,
                  list.files(path = paste("~", subdir, sep = ''), 
                             pattern = paste("^", year, "[a-zA-Z0-9]*",
                                             pollutant, ".hly", sep = '')), NULL)

  # Specify column widths for text fields in each hourly file
  column.widths <- c(3, 6, 4, 2, 2,
                     4, 4, 4, 4, 4,
                     4, 4, 4, 4, 4,
                     4, 4, 4, 4, 4,
                     4, 4, 4, 4, 4,
                     4, 4, 4, 4, 4,
                     4, 4)
  
  # Generate yearly data frames from each hourly data file
  for (i in 1:length(files)){
    
    # If the option to write yearly data to CSV is not chosen, need to collect yearly data
    # in a large data frame that spans the range of years selected; initialize an empty
    # data frame and sucessively use the rbind function to append df data
    
    if (write_to_CSV == FALSE){
      if (i == 1){
        large_df <- data.frame()
      }
    }
    
    data <- read.fwf(paste("~", subdir, "/", files[i], sep = ""), column.widths)
    data <- data[, c(1:32)]
    names(data) <- c("POLLUT.CODE", "STATION", "YR", "M", "D", "D.AVG", "D.MIN", "D.MAX", 
                     "H1", "H2", "H3", "H4", "H5", "H6", "H7", "H8", "H9", "H10", "H11",
                     "H12", "H13", "H14", "H15", "H16", "H17", "H18", "H19", "H20", "H21",
                     "H22", "H23", "H24")
    
    # Duplicate each row to make 24 duplicates
    data <- data[rep(1:((nrow(data)) - 1), each = 24), ]
    
    # Reset the rownames
    row.names(data) <- NULL
    
    # Collapse the hourly values into one per line by selectively moving the correct one to a
    # new column called 'conc'
    conc <- mat.or.vec(nr = nrow(data), nc = 1)
    hours <- mat.or.vec(nr = nrow(data), nc = 1)
    for (j in seq(from = 0, to = (nrow(data)-1), by = 24)) {
      for (k in 1:24) {
        conc[j + k] <- round(data[j + k, k + 8], digits = 2)
        hours[j + k] <- k - 1
      }
    }
    
    # Assign a column name for concentration based on the namesake pollutant (from filename)
    data <- within(data,{
      assign(gsub("^[0-9][0-9][0-9][0-9]([A-Z0-9]*)\\.hly$", "\\1.conc", files[i]), conc) 
    })
    data$H <- hours
    
    # Drop extraneous columns
    data <- data[ , -grep("^H[0-9]+", names(data))]
    data <- data[ , -grep("^D\\.[A-Z]*", names(data))]
    
    # Replace missing (-999) values with NA
    data[,6] <- unknownToNA(data[,6], -999.0)
    
    # Generate time object of class "POSIXct" and place in data frame
    time <- ISOdatetime(data$YR, data$M, data$D, data$H, min = 0, sec = 0, tz = "")
    data$time <- time
    
    # Drop columns with date/time values
    data$YR <- NULL
    data$M <- NULL
    data$D <- NULL
    data$H <- NULL
    
    # Write data to a CSV
    write.csv(data, file = paste(gsub("hly", "csv", files[i])), row.names = FALSE)
    
    # Clean up
    rm(data)
    rm(conc)
    rm(hours)
    rm(time)
    
    # Close the loop
  }
  
  # Close the function
}
