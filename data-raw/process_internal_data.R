library(stationary)
library(sf)
library(usethis)

history_tbl <- stationary:::get_history_tbl(perform_tz_lookup = TRUE)

usethis::use_data(
  history_tbl,
  internal = TRUE, overwrite = TRUE
)
