context("get_met_data")

test_that("The `get_met_data()` fcn returns correct number of columns", {
  
  # Get data frame of met data with just the mandatory fields
  df_mandatory_data <- 
    get_met_data(
      station_id = "722315-53917",
      startyear = 2014,
      endyear = 2015,
      full_data = FALSE
    )
  
  # Get data frame of met data with both the mandatory fields and
  # additional fields for two categories: AA1 and AB1
  df_aa1_ab1 <- 
    get_met_data(
      station_id = "722315-53917",
      startyear = 2014,
      endyear = 2015,
      add_fields = c("AA1", "AB1")
    )
  
  # Expect that, for the mandatory met data df, the number of columns
  # will be exactly 9
  df_mandatory_data %>% ncol() %>% expect_equal(9)
  
  # Expect that, for the df with both mandatory and two additional data
  # categories, the number of columns will be 16
  df_aa1_ab1 %>% ncol() %>% expect_equal(16)
  
  # Expect that, for the mandatory met data df, the column names will
  # be from a specified set
  expect_named(
    df_mandatory_data,
    c("id", "time", "wd", "ws", "ceil_hgt", "temp",
      "dew_point", "atmos_pres", "rh")
  )
})

test_that("The `get_met_data()` fcn can provide an additional data report", {
  
  # Get vector of available additional data categories for the station
  # during the specied years
  additional_data_categories <- 
    get_met_data(
      station_id = "722315-53917",
      startyear = 2014,
      endyear = 2015,
      add_data_report = TRUE
    )
  
  # Expect that a tibble is returned
  expect_is(
    additional_data_categories, "tbl_df")
})

test_that("Error messages are provided in certain situations", {
  
  # Expect an error if numeric values aren't provided for both
  # "startyear" and "endyear"
  expect_error(
    get_met_data(
      station_id = "722315-53917",
      startyear = "2010",
      endyear = "2014"
    )
  )
  
  # Expect an error if values aren't provided at all for both
  # "startyear" and "endyear"
  expect_error(
    get_met_data(
      station_id = "722315-53917"
    )
  )
  
  # Expect an error if the "startyear" is later than the "endyear"
  expect_error(
    get_met_data(
      station_id = "722315-53917",
      startyear = 2014,
      endyear = 2010
    )
  )
  
  # Get an additional data report df from a local test file
  df_data_report_data_local_test <- 
    get_met_data(
      station_id = "999999-63897",
      startyear = 2015,
      endyear = 2015,
      use_local_files = TRUE,
      local_file_dir = system.file(package = "stationary"),
      add_data_report = TRUE
    )
  
  # Expect the report to be a data frame
  expect_is(df_data_report_data_local_test, "tbl_df")
  
  # Expect a specific number of additional
  # data categories to be present
  expect_equal(nrow(df_data_report_data_local_test), 25)
  
  # Expect specific numbers of records for
  # each additional data category
  df_data_report_data_local_test$total_count %>%
    expect_equal(
      c(
        4498, 6, 6, 6, 6, 51817, 4325, 51889, 4325, 4325,
        4325, 4325, 4325, 51889, 4325, 4325, 51889, 52075,
        4503, 6, 6, 6, 6, 4312, 51889
      )
    )
  
  # Get all possible data from the test station file
  df_data_additional_data_local_test <- 
    get_met_data(
      station_id = "999999-63897",
      startyear = 2015,
      endyear = 2015,
      full_data = TRUE,
      use_local_files = TRUE,
      local_file_dir = system.file(package = "stationary")
    )
  
  # Expect that the resulting data frame will be very wide
  df_data_additional_data_local_test %>% ncol() %>% expect_equal(151)
})
