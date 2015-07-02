context("get_isd_station_data")

test_that("get_isd_station_data returns correct number of columns", {
  
  expect_equal(ncol(get_isd_station_data(station_id = "722315-53917",
                                         startyear = 2014,
                                         endyear = 2015,
                                         full_data = FALSE)),
               18)
  
})
