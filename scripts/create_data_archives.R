library(stationary)
library(tidyverse)
library(here)

output_dir <- here::here("data-cached")

inventory_tbl <- stationary:::get_inventory_tbl()

all_stations <- stationary:::all_station_ids(inventory_tbl = inventory_tbl)

get_data_for_year <- function(id, year) {
  
  get_isd_station_data(
    station_id = id,
    startyear = year,
    endyear = year)
}

for (station in all_stations) {
  
  if (!(paste0(station, ".csv") %in% list.files(output_dir))) {
    
    data_years <- 
      stationary:::station_data_years(
        inventory_tbl = inventory_tbl,
        id = station
      )
    
    station_data <- dplyr::tibble()
    
    for (year in data_years) {
      
      station_data <-
        dplyr::bind_rows(
          station_data,
          get_data_for_year(id = station, year = year)
        )
    }
    
    station_data %>%
      readr::write_csv(path = file.path(output_dir, paste0(station, ".csv")))
    
    Sys.sleep(2)
  }
}
