# Function to obtain the:
# 1)  the 1-year average of the daily maximum 8-hour average ozone concentrations
# 2)	the annual 4th highest of daily maximum 8-hour average ozone concentrations



year_summary_O3 <- function(all_years = FALSE,
                             single_year = NULL,
                             year_range = NULL,
                             file_path = NULL,
                             quarter_bounds = c("01-01", "03-31",
                                                "04-01", "06-30",
                                                "07-01", "09-30",
                                                "10-01", "12-31")) {
  
  
  all_years <- FALSE
  single_year <- NULL
  year_range <- "1998-2012"
  file_path <- "~/Documents/R (Working)"
  quarter_bounds = c("01-01", "03-31",
                     "04-01", "06-30",
                     "07-01", "09-30",
                     "10-01", "12-31")
  
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
  
  
  
}