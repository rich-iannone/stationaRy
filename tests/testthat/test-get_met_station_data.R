context("get_met_data")

test_that("The `get_met_data()` fcn returns correct number of columns", {
  
  # Get data frame of met data with just the mandatory fields
  df_mandatory_data <- 
    get_met_data(
      station_id = "722315-53917",
      years = 2014:2015,
      full_data = FALSE
    )
  
  # Get data frame of met data with both the mandatory fields and
  # additional fields for two categories: AA1 and AB1
  df_aa1_ab1 <- 
    get_met_data(
      station_id = "722315-53917",
      years = 2014:2015,
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
  
  met_tbl <- get_met_data(station_id = "999999-63897")
  
  met_tbl %>% expect_type("tbl_df")
  
  met_tbl %>% 
    dplyr::pull(id) %>%
    unique() %>%
    expect_equal("999999-63897")
})

test_that("The `station_coverage()` fcn can provide an additional data report", {
  
  # Get vector of available additional data categories for the station
  # during the specied years
  stn_coverage_tbl <- 
    station_coverage(
      station_id = "722315-53917",
      years = 2014:2015
    )
  
  # Expect that a tibble is returned
  expect_is(stn_coverage_tbl, "tbl_df")
  
  stn_coverage_tbl %>%
    dplyr::pull(id) %>%
    unique() %>%
    expect_equal("722315-53917")
  
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
      station_id = "722315-53917",
      years = 2014:2015,
      wide_tbl = TRUE
    )
  
  stn_coverage_wide %>%
    dplyr::pull(id) %>%
    unique() %>%
    expect_equal("722315-53917")
  
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
      station_id = "722315-53917",
      years = 2014:2015,
      grouping = "year"
    )
  
  stn_coverage_tbl_year %>%
    dplyr::pull(id) %>%
    unique() %>%
    expect_equal("722315-53917")
  
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
    expect_type("numeric")
  
  stn_coverage_tbl_year %>%
    dplyr::pull(count) %>%
    expect_type("integer")
  
  stn_coverage_tbl_month <- 
    station_coverage(
      station_id = "722315-53917",
      years = 2014:2015,
      grouping = "month"
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
    expect_type("numeric")
  
  stn_coverage_tbl_month %>%
    dplyr::pull(month) %>%
    expect_type("numeric")
  
  stn_coverage_tbl_month %>%
    dplyr::pull(count) %>%
    expect_type("integer")
  
  # Get an additional data report df from a local test file
  df_data_report_data_local_test <- 
    station_coverage(
      station_id = "999999-63897",
      years = 2014,
      use_local_files = TRUE,
      local_file_dir = system.file(package = "stationary")
    )
  
  # Expect the report to be a data frame
  expect_is(df_data_report_data_local_test, "tbl_df")
  
  # Expect a specific number of additional
  # data categories to be present
  expect_equal(nrow(df_data_report_data_local_test), 87)
  
  # Expect specific numbers of records for
  # each additional data category
  df_data_report_data_local_test$count[df_data_report_data_local_test$count != 0] %>%
    expect_equal(
      c(
        9105, 12, 12, 12, 12, 104940, 8757, 105084, 8757, 8757,
        8757, 8757, 8757, 105084, 8757, 8757, 105084, 105460, 9115, 12,
        12, 12, 12, 8750, 105084
      )
    )
})

test_that("The `get_met_data()` fcn can provide all additional data fields", { 
  
  # Get all possible data from the test station file
  df_data_additional_data_local_test <-
    get_met_data(
      station_id = "999999-63897",
      years = 2014,
      full_data = TRUE,
      use_local_files = TRUE,
      local_file_dir = system.file(package = "stationary")
    )

  # Expect that the resulting data frame will be very wide
  df_data_additional_data_local_test %>% ncol() %>% expect_equal(151)
})

test_that("The `get_station_metadata()` fcn provides the expected table", { 
  
  station_metadata <- get_station_metadata()
  
  station_metadata %>% expect_is("tbl_df")
  
  station_metadata %>%
    colnames() %>%
    expect_equal(
      c(
        "id", "usaf", "wban", "name", "country", "state", "icao", "lat", "lon",
        "elev", "begin_date", "end_date", "begin_year", "end_year", "tz_name"
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
        "integer", "integer", "character"
      )
    )
})

test_that("The `get_inventory_tbl()` fcn provides the expected table", {
  
  inventory_tbl <- get_inventory_tbl()
  
  inventory_tbl %>% expect_is("tbl_df")
  
  inventory_tbl %>%
    colnames() %>%
    expect_equal(
      c(
        "id", "usaf", "wban", "year",
        "jan", "feb", "mar", "apr", "may", "jun",
        "jul", "aug", "sep", "oct", "nov", "dec",
        "total"
      )
    )
  
  inventory_tbl %>%
    nrow() %>%
    expect_gt(25000)
  
  inventory_tbl %>%
    lapply(class) %>% unlist() %>% unname() %>%
    expect_equal(c(rep("character", 3), rep("integer", 14)))
})

test_that("The `get_history_tbl()` fcn provides the expected table", {
  
  history_tbl <- get_history_tbl()
  
  history_tbl %>% expect_is("tbl_df")
  
  history_tbl %>%
    colnames() %>%
    expect_equal(
      c(
        "id", "usaf", "wban", "name", "country", "state", "icao", "lat", "lon",
        "elev", "begin_date", "end_date", "begin_year", "end_year"
      )
    )
  
  history_tbl %>%
    nrow() %>%
    expect_gt(25000)
  
  history_tbl %>%
    lapply(class) %>% unlist() %>% unname() %>%
    expect_equal(
      c(
        rep("character", 7), rep("numeric", 3), "Date", "Date",
        "integer", "integer"
      )
    )
  
  history_tbl_with_tz <- get_history_tbl(perform_tz_lookup = TRUE)
  
  history_tbl_with_tz %>% expect_is("tbl_df")
  
  history_tbl_with_tz %>%
    colnames() %>%
    expect_equal(
      c(
        "id", "usaf", "wban", "name", "country", "state", "icao", "lat", "lon",
        "elev", "begin_date", "end_date", "begin_year", "end_year", "tz_name"
      )
    )
  
  history_tbl_with_tz %>%
    nrow() %>%
    expect_gt(25000)
  
  history_tbl_with_tz %>%
    lapply(class) %>% unlist() %>% unname() %>%
    expect_equal(
      c(
        rep("character", 7), rep("numeric", 3), "Date", "Date",
        "integer", "integer", "character"
      )
    )
})

test_that("Messages or errors occur in certain situations", {
  
  # Expect an error if the `station_id` isn't valid
  expect_error(
    get_met_data(
      station_id = "722315-53917"
    )
  )
  
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
