context("select_isd_stations")

test_that("select_isd_stations can return a station ID", {
  
  library(magrittr)
  
  cypress_bowl_snowboard_select_1 <- 
    get_isd_stations(lower_lat = 49.000,
                     upper_lat = 49.500,
                     lower_lon = -123.500,
                     upper_lon = -123.000) %>%
    select_isd_station(name = "cypress bowl snowboard")
  
  cypress_bowl_snowboard_select_2 <- 
    get_isd_stations(lower_lat = 49.000,
                     upper_lat = 49.500,
                     lower_lon = -123.500,
                     upper_lon = -123.000) %>%
    select_isd_station(name = "cypress bowl", number = 2)
  
  # Expect that each of the statements returns a station identifier string
  expect_match(cypress_bowl_snowboard_select_1, "[0-9]*?-[0-9]*?")
  expect_match(cypress_bowl_snowboard_select_2, "[0-9]*?-[0-9]*?")
  
  # Expect that each approach returns the same string
  expect_equal(cypress_bowl_snowboard_select_1,
               cypress_bowl_snowboard_select_2)
  
  # Perform a selection that returns multiple stations
  cypress_bowl_snowboard_select_multiple <- 
    get_isd_stations(lower_lat = 49.000,
                     upper_lat = 49.500,
                     lower_lon = -123.500,
                     upper_lon = -123.000) %>%
    select_isd_station(name = "cypress bowl")
  
  # Expect that an NA value is returned
  expect_is(cypress_bowl_snowboard_select_multiple, "logical")
  
  # Expect a particular message when multiple stations matched
  expect_message(get_isd_stations(lower_lat = 49.000,
                                  upper_lat = 49.500,
                                  lower_lon = -123.500,
                                  upper_lon = -123.000) %>%
                   select_isd_station(name = "cypress bowl"),
                 "Several stations matched.")
  
  # Use "select_isd_station" without any parameters
  no_search_terms <- get_isd_stations() %>% select_isd_station()
  
  # Expect that an NA value is returned when no values are provided
  expect_true(is.na(no_search_terms))
  
  # Expect a particular message when no values are provided
  expect_message(get_isd_stations() %>% select_isd_station(),
                 "No search terms provided")
  
  # Select a station by number from the unfiltered list of stations
  first_station <- get_isd_stations() %>% select_isd_station(number = 1)
  
  # Expect that the statement returns a station identifier string
  expect_match(first_station, "[0-9]*?-[0-9]*?")
  
  # Use "select_isd_station" with a station name that doesn't exist
  station_doesnt_exist <-
    get_isd_stations() %>% select_isd_station(name = "underwater")
  
  # Expect that an NA value is returned the station name doesn't match
  expect_true(is.na(station_doesnt_exist))
  
  # Expect a particular message when no station match occurs
  expect_message(get_isd_stations() %>% select_isd_station(name = "underwater"),
                 "No stations were matched with the supplied search term.")
})
