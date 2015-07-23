context("get_isd_stations")

test_that("get_isd_stations returns a correct data frame", {
  
  # Obtain a data frame with all available met stations
  all_isd_stations <- get_isd_stations()
  
  # Get a listing of all ISD met stations within a geographical
  # bounding box
  isd_stations_bbox <-
    get_isd_stations(lower_lat = 49.000,
                     upper_lat = 49.500,
                     lower_lon = -123.500,
                     upper_lon = -123.000)
  
  # List all ISD stations with data available for the 2005
  # and 2006 years
  isd_stations_year_range <- 
    get_isd_stations(startyear = 2005,
                     endyear = 2006)
  
  # Get a listing of all ISD met stations within a geographical
  # bounding box
  isd_stations_bbox <-
    get_isd_stations(lower_lat = 49.000,
                     upper_lat = 49.500,
                     lower_lon = -123.500,
                     upper_lon = -123.000)
  
  # List all ISD stations with data available for the 2005
  # and 2006 years, and, within a geographical bounding box
  isd_stations_bbox_year_range <- 
    get_isd_stations(lower_lat = 49.000,
                     upper_lat = 49.500,
                     lower_lon = -123.500,
                     upper_lon = -123.000,
                     startyear = 2005,
                     endyear = 2006)
  
  # For all four function calls, expect that data frames are returned
  expect_is(all_isd_stations, "tbl_df")
  expect_is(isd_stations_bbox, "tbl_df")
  expect_is(isd_stations_year_range, "tbl_df")
  expect_is(isd_stations_bbox_year_range, "tbl_df")
  
  # For all three function calls, expect that some rows are returned
  expect_more_than(nrow(all_isd_stations), 10L)
  expect_more_than(nrow(isd_stations_bbox), 10L)
  expect_more_than(nrow(isd_stations_year_range), 10L)
  expect_more_than(nrow(isd_stations_bbox_year_range), 5L)
  
  # Expect that more filtering leads to less stations
  expect_less_than(nrow(isd_stations_bbox),
                   nrow(all_isd_stations))
  
  expect_less_than(nrow(isd_stations_bbox),
                   nrow(isd_stations_year_range))
  
  expect_less_than(nrow(isd_stations_bbox_year_range),
                   nrow(isd_stations_year_range))
  
  expect_less_than(nrow(isd_stations_bbox_year_range),
                   nrow(isd_stations_bbox))
})
