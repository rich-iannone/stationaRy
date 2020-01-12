context("get_met_data")

test_that("The `get_met_data()` fcn returns correct number of columns", {
  
  # Get a tibble of met data with just the standard fields
  df_standard_data <- 
    get_met_data(
      station_id = "710633-99999",
      years = 2014:2015,
      make_hourly = FALSE,
      local_file_dir = system.file(package = "stationaRy")
    )
  
  # Get a tibble of met data with both the standard fields and
  # additional fields (for the two categories of AA1 and AB1)
  df_add_data <- 
    get_met_data(
      station_id = "710633-99999",
      years = 2014:2015,
      add_fields = c("GF1", "MA1"),
      make_hourly = FALSE,
      local_file_dir = system.file(package = "stationaRy")
    )
  
  # Expect that, for the standard met data df, the number of columns
  # will be exactly 10
  df_standard_data %>% ncol() %>% expect_equal(10)
  
  # Expect that, for the df with both mandatory and two additional data
  # categories, the number of columns will be `27`
  df_add_data %>% ncol() %>% expect_equal(27)
  
  # Expect that, for the mandatory met data df, the column names will
  # be from a specified set
  expect_named(
    df_standard_data,
    c("id", "time", "temp", "wd", "ws", "atmos_pres",
      "dew_point","rh", "ceil_hgt", "visibility")
  )
  
  df_standard_data %>% expect_type("list")
  df_add_data %>% expect_type("list")
  
  expect_is(df_standard_data, "tbl_df")
  expect_is(df_add_data, "tbl_df")
  
  df_standard_data %>%
    dplyr::pull(id) %>%
    unique() %>%
    expect_equal("710633-99999")
  
  df_add_data %>%
    dplyr::pull(id) %>%
    unique() %>%
    expect_equal("710633-99999")
})

test_that("The `station_coverage()` fcn can provide an additional data report", {
  
  # Get vector of available additional data categories for the station
  # during the specified years
  stn_coverage_tbl <- 
    station_coverage(
      station_id = "710633-99999",
      years = 2014:2015,
      local_file_dir = system.file(package = "stationaRy")
    )
  
  expect_is(stn_coverage_tbl, "tbl_df")
  stn_coverage_tbl %>% expect_type("list")
  
  stn_coverage_tbl %>%
    dplyr::pull(id) %>%
    unique() %>%
    expect_equal("710633-99999")
  
  stn_coverage_tbl %>%
    dplyr::pull(category) %>%
    expect_equal(field_categories() %>% toupper())
  
  stn_coverage_tbl %>%
    dplyr::pull(count) %>%
    expect_type("integer")
  
  stn_coverage_tbl %>%
    nrow() %>%
    expect_equal(87)
  
  stn_coverage_wide <- 
    station_coverage(
      station_id = "710633-99999",
      years = 2014:2015,
      wide_tbl = TRUE,
      local_file_dir = system.file(package = "stationaRy")
    )
  
  stn_coverage_wide %>%
    dplyr::pull(id) %>%
    unique() %>%
    expect_equal("710633-99999")
  
  stn_coverage_wide %>%
    colnames() %>%
    expect_equal(c("id", field_categories() %>% toupper()))
  
  stn_coverage_wide %>%
    nrow() %>%
    expect_equal(1)
  
  stn_coverage_wide %>%
    dplyr::pull(AA1) %>%
    expect_type("integer")
  
  stn_coverage_tbl_year <- 
    station_coverage(
      station_id = "710633-99999",
      years = 2014:2015,
      grouping = "year",
      local_file_dir = system.file(package = "stationaRy")
    )

  stn_coverage_tbl_year %>%
    dplyr::pull(id) %>%
    unique() %>%
    expect_equal("710633-99999")
  
  stn_coverage_tbl_year %>%
    colnames() %>%
    expect_equal(c("id", "year", "category", "count"))
  
  stn_coverage_tbl_year %>%
    nrow() %>%
    expect_equal(174)
  
  stn_coverage_tbl_year %>%
    dplyr::pull(category) %>%
    expect_type("character")
  
  stn_coverage_tbl_year %>%
    dplyr::pull(year) %>%
    expect_is("numeric")
  
  stn_coverage_tbl_year %>%
    dplyr::pull(count) %>%
    expect_type("integer")
  
  stn_coverage_tbl_month <- 
    station_coverage(
      station_id = "710633-99999",
      years = 2014:2015,
      grouping = "month",
      local_file_dir = system.file(package = "stationaRy")
    )
  
  stn_coverage_tbl_month %>%
    colnames() %>%
    expect_equal(c("id", "year", "month", "category", "count"))
  
  stn_coverage_tbl_month %>%
    nrow() %>%
    expect_equal(2088)
  
  stn_coverage_tbl_month %>%
    dplyr::pull(category) %>%
    expect_type("character")
  
  stn_coverage_tbl_month %>%
    dplyr::pull(year) %>%
    expect_is("numeric")
  
  stn_coverage_tbl_month %>%
    dplyr::pull(month) %>%
    expect_is("numeric")
  
  stn_coverage_tbl_month %>%
    dplyr::pull(count) %>%
    expect_type("integer")
})

test_that("The `get_met_data()` fcn can provide all additional data fields", { 
  
  # Get all possible data from the test station file
  df_all_add_data <-
    get_met_data(
      station_id = "710633-99999",
      years = 2014,
      full_data = TRUE,
      local_file_dir = system.file(package = "stationaRy")
    )
  
  # Expect that the resulting tibble will be very wide
  df_all_add_data %>% ncol() %>% expect_gt(40)
})

test_that("The `get_station_metadata()` fcn provides the expected table", { 
  
  station_metadata <- get_station_metadata()
  
  station_metadata %>% expect_is("tbl_df")
  
  station_metadata %>%
    colnames() %>%
    expect_equal(
      c(
        "id", "usaf", "wban", "name", "country", "state", "icao",
        "lat", "lon", "elev", "begin_date", "end_date",
        "begin_year", "end_year", "tz_name", "years"
      )
    )
  
  station_metadata %>%
    nrow() %>%
    expect_gt(25000)
  
  station_metadata %>%
    lapply(class) %>% unlist() %>% unname() %>%
    expect_equal(
      c(
        rep("character", 7), rep("numeric", 3), "Date", "Date",
        "integer", "integer", "character", "list"
      )
    )
})

test_that("Messages or errors occur in certain situations", {
  
  expect_message(
    get_met_data(
      station_id = "008411-99999",
      years = 2015
    ),
    "The `station_id` provided ")
  
  suppressMessages(
    get_met_data(
      station_id = "008411-99999",
      years = 2015
    ) %>% expect_equivalent(empty_met_tbl())
  )
  
  expect_error(
    get_met_data(
      station_id = "008411-99999",
      years = "2015"
    )
  )
})
