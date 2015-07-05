context("get_isd_station_data")

test_that("get_isd_station_data returns correct number of columns", {
  
  # Get data frame of met data with just the mandatory fields
  df_mandatory_data <- 
    get_isd_station_data(station_id = "722315-53917",
                         startyear = 2014,
                         endyear = 2015,
                         full_data = FALSE)
  
  # Get data frame of met data with both the mandatory fields and
  # additional fields as well
  df_full_data <- 
    get_isd_station_data(station_id = "722315-53917",
                         startyear = 2014,
                         endyear = 2015,
                         full_data = TRUE)
  
  # Get data frame of met data with both the mandatory fields and
  # additional fields for two categories: AA1 and AB1
  df_aa1_ab1 <- 
    get_isd_station_data(station_id = "722315-53917",
                         startyear = 2014,
                         endyear = 2015,
                         select_additional_data = c("AA1", "AB1"))
  
  # Expect that, for the mandatory met data df, the number of columns
  # will be exactly 18
  expect_equal(ncol(df_mandatory_data), 18L)
  
  # Expect that, for the df with both mandatory and additional data,
  # the number of columns will be exactly 114
  expect_equal(ncol(df_full_data), 114L)
  
  # Expect that, for the mandatory met data df, the column names will
  # be from a specified set
  expect_named(df_mandatory_data,
               c("usaf", "wban", "year", "month", "day", "hour", "minute",
                 "lat", "lon", "elev", "wd", "ws", "ceil_hgt", "temp",
                 "dew_point", "atmos_pres", "rh", "time"))
  
  # Expect that, for the df with both mandatory and additional data,
  # the column names for the additional data will match a specified format
  expect_match(colnames(df_full_data)[19:length(colnames(df_full_data))],
               "^[a-z][a-z][1-9]_([0-9]|[0-9][0-9])$")
  
})
