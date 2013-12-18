
year_summary_PM25 <- function(all_years = FALSE,
                             single_year = NULL,
                             year_range = NULL,
                             file_path = NULL,
                             quarter_bounds = c("01-01 00:00", "03-31 23:00",
                                                "04-01 00:00", "06-30 23:00",
                                                "07-01 00:00", "09-30 23:00",
                                                "10-01 00:00", "12-31 23:00")) {
  
  measure <- "PM25"
  
  all_years <- FALSE
  single_year <- NULL
  year_range <- "2001-2003"
  file_path <- "~/Documents/R (Working)"
  quarter_bounds = c("01-01 00:00", "03-31 23:00",
                     "04-01 00:00", "06-30 23:00",
                     "07-01 00:00", "09-30 23:00",
                     "10-01 00:00", "12-31 23:00")
  # 
  #  test:
  #  year_summary_CSV(pollutant = "NO", file_path = "~/Documents/R (Working)")
  #
  
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
    
    