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
})
