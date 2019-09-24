# stationaRy 0.5.0

* Complete rewrite of package.

* Package now has the main function `get_met_data()`, where `get_station_metadata()` and `station_coverage()` provide information on the station and which additional data fields they have reported on.

* The `get_met_data()` function can bucketize observations so that even hourly observations are provided.

* Instead of needing to provide a range of years, any vector of `years` can be provided to `get_met_data()`.

* The `visibility` parameter is now provided in the standard set of station observations.

* A more reliable method of getting the local times for each station has been implemented.

* Meteorological data files can be collected in a directory after download for later reuse.

* Additional data fields, when requested, are processed much more quickly than in previous releases.

* Tibbles are now returned instead of data frames.

* A **pkgdown** site has been generated.

# stationaRy 0.3

* Removes the `get_tz_offset()` function, the large shapefile object, and the dependencies on the **lubridate**, **sp**, and **proj4** packages.

* Greater use of **dplyr** functions to greatly increase processing speed.

* Functions are resilient to missing years of data within year ranges provided.

# stationaRy 0.2

* Added function `get_ncdc_station_info()` to obtain data frame of all known met stations, and, to filter list of stations by geographic bounding box and/or by years of available data.

* Added function `select_ncdc_station()` to take the data frame produced by `get_ncdc_station_info()` and aid in obtaining a selection of a single station; the resulting identifier string can be passed to `get_ncdc_station_data()` to fetch data for the selected station.

# stationaRy 0.1

* Contains function `get_ncdc_station_data()` (to fetch data and create a data frame) and helper function `get_tz_offset()` (to determine time zone offset and correct times to local time).
