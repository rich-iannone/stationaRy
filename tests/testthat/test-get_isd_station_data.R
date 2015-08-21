context("get_isd_station_data")

test_that("get_isd_station_data returns correct number of columns", {
  
  # Get data frame of met data with just the mandatory fields
  df_mandatory_data <- 
    get_isd_station_data(station_id = "722315-53917",
                         startyear = 2014,
                         endyear = 2015,
                         full_data = FALSE)
  
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
  
  # Expect that, for the df with both mandatory and two additional data
  # categories, the number of columns will be greater than 18
  expect_more_than(ncol(df_aa1_ab1), 18L)
  
  # Expect that, for the mandatory met data df, the column names will
  # be from a specified set
  expect_named(df_mandatory_data,
               c("usaf", "wban", "year", "month", "day", "hour", "minute",
                 "lat", "lon", "elev", "wd", "ws", "ceil_hgt", "temp",
                 "dew_point", "atmos_pres", "rh", "time"))
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
  expect_error(get_isd_station_data(station_id = "722315-53917"))
  
  # Expect an error if the "startyear" is later than the "endyear"
  expect_error(
    get_isd_station_data(station_id = "722315-53917",
                         startyear = 2014,
                         endyear = 2010)
  )
  
  # Get an additional data report df from a local test file
  df_data_report_data_local_test <- 
    get_isd_station_data(
      station_id = "000000-00000",
      startyear = 2015,
      endyear = 2015,
      use_local_files = TRUE,
      local_file_dir = system.file(package = "stationaRy"),
      add_data_report = TRUE
    )
  
  # Expect the report to be a data frame
  expect_is(df_data_report_data_local_test, "data.frame")
  
  # Expect all possible additional data categories to be present
  expect_equal(nrow(df_data_report_data_local_test), 85L)
  
  # Expect one record for each additional data category
  expect_true(all(df_data_report_data_local_test$total_count == 2))
  
  # Get all possible data from the test station file
  df_data_additional_data_local_test <- 
    get_isd_station_data(
      station_id = "000000-00000",
      startyear = 2015,
      endyear = 2015,
      full_data = TRUE,
      use_local_files = TRUE,
      local_file_dir = system.file(package = "stationaRy")
    )
  
  # Expect that the resulting data frame will be very wide
  expect_more_than(ncol(df_data_additional_data_local_test), 400L)
  
  # Expect a single row of data in the data frame
  expect_equal(nrow(df_data_additional_data_local_test), 2L)
})
