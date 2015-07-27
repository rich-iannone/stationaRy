context("map_isd_stations")

test_that("map_isd_stations returns a map object", {
  
  library(magrittr)
  
  # Create a Leaflet map
  stations_map <-
    get_isd_stations(lower_lat = 49.000,
                     upper_lat = 49.500,
                     lower_lon = -123.500,
                     upper_lon = -123.000) %>%
    map_isd_stations()
  
  # Expect that the "stations_map" object inherits from both "leaflet"
  # and "htmlwidget"
  expect_is(stations_map, c("leaflet", "htmlwidget"))
})
