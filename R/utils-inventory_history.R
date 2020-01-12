#nocov start

get_inventory_tbl <- function() {
  
  file_location <- file.path(data_base_url(), "isd-inventory.csv")
  
  temp_file <- tempfile(fileext = ".csv")
  
  downloader::download(url = file_location, destfile = temp_file)
  
  tbl <- readr::read_csv(file = temp_file, col_types = "cciiiiiiiiiiiii")
  
  colnames(tbl) <- colnames(tbl) %>% tolower()
  
  tbl %>%
    dplyr::mutate(
      total = jan + feb + mar + apr + may + jun + jul + aug + sep + oct + nov + dec
    ) %>%
    dplyr::arrange(usaf, wban, year) %>%
    dplyr::mutate(id = paste0(usaf, "-", wban)) %>%
    dplyr::select(id, dplyr::everything())
}

get_history_tbl <- function(perform_tz_lookup = FALSE) {
  
  file_location <- file.path(data_base_url(), "isd-history.csv")
  
  temp_file <- tempfile(fileext = ".csv")
  
  downloader::download(url = file_location, destfile = temp_file)
  
  tbl <- readr::read_csv(file = temp_file, col_types = "ccccccnnncc")
  
  colnames(tbl) <- 
    c(
      "usaf", "wban", "name", "country", "state", "icao",
      "lat", "lon", "elev", "begin_date", "end_date"
    )
  
  tbl <-
    tbl %>%
    dplyr::mutate(id = paste0(usaf, "-", wban)) %>%
    dplyr::mutate(
      begin_date = lubridate::ymd(begin_date),
      end_date = lubridate::ymd(end_date),
      begin_year = lubridate::year(begin_date) %>% as.integer(),
      end_year = lubridate::year(end_date) %>% as.integer()
    ) %>%
    dplyr::arrange(usaf, wban) %>%
    dplyr::select(id, dplyr::everything())
  
  if (isTRUE(perform_tz_lookup)) {
    
    tbl <- 
      suppressWarnings(
        tbl %>%
          dplyr::mutate(tz_name = dplyr::case_when(
            !is.na(lat) & !is.na(lon) ~ lutz::tz_lookup_coords(
              lat = lat,
              lon = lon,
              method = "accurate",
              warn = FALSE
            ),
            TRUE ~ NA_character_)
          ) %>%
          dplyr::mutate(tz_name = dplyr::case_when(
            grepl("; ", tz_name) ~ (strsplit(tz_name, "; ") %>% unlist())[1],
            TRUE ~ tz_name
          ))
      )
  }
  
  years_per_station <- 
    get_inventory_tbl() %>%
    dplyr::select(id, year) %>%
    dplyr::group_by(id) %>%
    dplyr::summarize(years = list(year))
  
  tbl <-
    tbl %>%
    dplyr::left_join(years_per_station, by = "id")
    
  tbl
}

#nocov end

station_data_files <- function(inventory_tbl,
                               id) {
  
  id_ <- id
  
  if (inherits(inventory_tbl, "tbl_df")) {
    tbl <- inventory_tbl
  } else if (inherits(inventory_tbl, "character")) {
    
    if (grepl(".csv$", inventory_tbl)) {
      tbl <- readr::read_csv(inventory_tbl)
    } else {
      stop("The inventory table file must be a CSV.", call. = FALSE)
    }
  }
  
  tbl <- 
    tbl %>%
    dplyr::filter(id == id_)
  
  if (nrow(tbl) == 0) {
    return(character(0))
  }
  
  tbl %>%    
    dplyr::mutate(file = paste0(year, "/", id, "-", year, ".gz")) %>%
    dplyr::pull(file)
}

station_data_years <- function(inventory_tbl,
                               id) {
  
  id_ <- id
  
  if (inherits(inventory_tbl, "tbl_df")) {
    tbl <- inventory_tbl
  } else if (inherits(inventory_tbl, "character")) {
    
    if (grepl(".csv$", inventory_tbl)) {
      tbl <- readr::read_csv(inventory_tbl)
    } else {
      stop("The inventory table file must be a CSV.", call. = FALSE)
    }
  }
  
  tbl <- 
    tbl %>%
    dplyr::filter(id == id_)
  
  if (nrow(tbl) == 0) {
    return(integer(0))
  }
  
  tbl %>% dplyr::pull(year)
}

all_station_ids <- function(inventory_tbl) {
  
  if (inherits(inventory_tbl, "tbl_df")) {
    tbl <- inventory_tbl
  } else if (inherits(inventory_tbl, "character")) {
    
    if (grepl(".csv$", inventory_tbl)) {
      tbl <- readr::read_csv(inventory_tbl)
    } else {
      stop("The inventory table file must be a CSV.", call. = FALSE)
    }
  }
  
  tbl %>% 
    dplyr::pull(id) %>%
    unique()
}
