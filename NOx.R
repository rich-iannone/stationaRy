
year_summary_NOx <- function(all_years = FALSE,
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
  #  year_summary_PM25(single_year = 2001, file_path = "~/Documents/R (Working)")
  #
  
  measure <- "NOx"
  
  
}