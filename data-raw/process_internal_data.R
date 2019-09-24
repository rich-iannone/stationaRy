library(stationaRy)
library(sf)
library(usethis)

history_tbl <- stationaRy:::get_history_tbl(perform_tz_lookup = TRUE)

usethis::use_data(
  history_tbl,
  internal = TRUE, overwrite = TRUE
)
