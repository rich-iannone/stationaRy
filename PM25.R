
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

    
    