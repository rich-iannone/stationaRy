library(stationary)
library(sf)
library(usethis)

history_tbl <- stationary:::get_history_tbl(perform_tz_lookup = TRUE)

inventory_tbl <- stationary:::get_inventory_tbl()

usethis::use_data(
  history_tbl, inventory_tbl,
  internal = TRUE, overwrite = TRUE
)
