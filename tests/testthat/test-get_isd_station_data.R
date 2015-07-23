context("get_isd_station_data")

test_that("get_isd_station_data returns correct number of columns", {
  
  # Get data frame of met data with just the mandatory fields
  df_mandatory_data <- 
    get_isd_station_data(station_id = "722315-53917",
                         startyear = 2014,
                         endyear = 2015,
                         full_data = FALSE)
  
  #   # Get data frame of met data with both the mandatory fields and
  #   # additional fields as well
  #   df_full_data <- 
  #     get_isd_station_data(station_id = "722315-53917",
  #                          startyear = 2014,
  #                          endyear = 2015,
  #                          full_data = TRUE)
  
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
  # the number of columns will be greater than 100
  # expect_greater_than(ncol(df_full_data), 100L)
  
  # Expect that, for the df with both mandatory and two additional data
  # categories, the number of columns will be exactly 25
  expect_equal(ncol(df_aa1_ab1), 25L)
  
  # Expect that, for the mandatory met data df, the column names will
  # be from a specified set
  expect_named(df_mandatory_data,
               c("usaf", "wban", "year", "month", "day", "hour", "minute",
                 "lat", "lon", "elev", "wd", "ws", "ceil_hgt", "temp",
                 "dew_point", "atmos_pres", "rh", "time"))
  
  # Expect that, for the df with both mandatory and additional data,
  # the column names for the additional data will match a specified format
  #   expect_match(colnames(df_full_data)[19:length(colnames(df_full_data))],
  #                "^[a-z][a-z][1-9]_([0-9]|[0-9][0-9])$")
  
})

test_that("get_isd_station_data can provide an additional data report", {
  
  # Get vector of available additional data categories for the station
  # during the specied years
  additional_data_categories <- 
    get_isd_station_data(station_id = "722315-53917",
                         startyear = 2014,
                         endyear = 2015,
                         add_data_report = TRUE)
  
  # Expect that a data frame is returned
  expect_true(class(additional_data_categories) == "data.frame")
  
})

test_that("error messages are provided in certain situations", {
  
  # Expect an error if numeric values aren't provided for both
  # "startyear" and "endyear"
  expect_error(
    get_isd_station_data(station_id = "722315-53917",
                         startyear = "2010",
                         endyear = "2014")
  )
  
  # Expect an error if values aren't provided at all for both
  # "startyear" and "endyear"
  expect_error(
    get_isd_station_data(station_id = "722315-53917")
  )
  
})
