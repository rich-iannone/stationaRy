context("get_met_data")

test_that("The `get_met_data()` fcn returns correct number of columns", {
  
  # Get a tibble of met data with just the standard fields
  df_mandatory_data <- 
    get_met_data(
      station_id = "722315-53917",
      years = 2014:2015,
      full_data = FALSE,
      make_hourly = FALSE
    )
  
  # Get a tibble of met data with both the standard fields and
  # additional fields (for the two categories of AA1 and AB1)
  df_aa1_ab1 <- 
    get_met_data(
      station_id = "722315-53917",
      years = 2014:2015,
      add_fields = c("AA1", "AB1"),
      make_hourly = FALSE
    )
  
  # Expect that, for the mandatory met data df, the number of columns
  # will be exactly 10
  df_mandatory_data %>% ncol() %>% expect_equal(10)
  
  # Expect that, for the df with both mandatory and two additional data
  # categories, the number of columns will be 17
  df_aa1_ab1 %>% ncol() %>% expect_equal(17)
  
  # Expect that, for the mandatory met data df, the column names will
  # be from a specified set
  expect_named(
    df_mandatory_data,
    c("id", "time", "temp", "wd", "ws", "atmos_pres",
      "dew_point","rh", "ceil_hgt", "visibility")
  )
  
  met_tbl <- 
    get_met_data(
      station_id = "999999-63897",
      years = 2008,
      make_hourly = FALSE
    )
  
  met_tbl %>% expect_type("list")
  
  met_tbl %>% 
    dplyr::pull(id) %>%
    unique() %>%
    expect_equal("999999-63897")
})

test_that("The `station_coverage()` fcn can provide an additional data report", {
  
  # Get vector of available additional data categories for the station
  # during the specified years
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
    expect_is("numeric")
  
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
  tbl_additional_data_fields <-
    get_met_data(
      station_id = "725030-14732",
      years = 2014,
      full_data = TRUE,
      make_hourly = FALSE
    )
  
  # Expect that the resulting tibble will be very wide
  tbl_additional_data_fields %>% ncol() %>% expect_gt(170)
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

test_that("Messages or errors occur in certain situations", {
  
  get_met_data(
    station_id = "722315-539173",
    make_hourly = FALSE
  ) %>%
    nrow() %>%
    expect_equal(0)
  
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
