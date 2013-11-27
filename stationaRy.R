#-----------------------#

# Function for generating a NAPS station list from NAPS data files

generate_NAPS_stations <- function(year_start = 1974,
                                   year_end = 2011,
                                   subdir = NULL) {
  
# Define the sequence of year; pre-allocate an empty list of the length of the sequence
year_sequence <- seq(year_start, year_end, 1)
summaries <- vector("list", length(year_sequence))
  
# Create list of data frames and insert year as extra column for each df
# Read in the summary data from the Excel files from 1974-
# Add year to column of each data frame
for (i in year_sequence) {
  summaries[[i-year_sequence[1]+1]] <- 
    read.xls(paste(subdir, "/", "AnnualPercentDataAvailability",i,".xls", sep = ""), sheet = 2,
             method = "csv")
  summaries[[i-year_sequence[1]+1]]$year <- i
}
  
# Combine list of data frames using 'rbind.fill' function from the plyr packages
summaries.large.df <- rbind.fill(summaries)

# Create data frame, 'station_info" that shows just the station information
station_info <- merge(aggregate(year ~ NapsID, data = summaries.large.df, FUN = max),
                      summaries.large.df)
station_info$year <- NULL
station_info$O3 <- NULL
station_info$NO2 <- NULL
station_info$NO <- NULL
station_info$NOx <- NULL
station_info$SO2 <- NULL
station_info$CO <- NULL
station_info$TEOM.PM25 <- NULL
station_info$TEOM.PM10 <- NULL
station_info$BAM.PM25 <- NULL
station_info$SES.PM25 <- NULL
station_info$FDMS.PM25 <- NULL
station_info$BAM35.PM25 <- NULL
station_info$SHARP.PM25 <- NULL



# Write CSV file 'station_info.csv' to working directory
write.csv(station_info, file = "station_info.csv", row.names = FALSE)
station_info
}

#-----------------------#

# Function for taking "station_info.csv" and amending it with current census data
regenerate_NAPS_stations <- function(){

# Read CSV file "station_info.csv" (generated from 'generate_NAPS_stations' function)
station_info <- read.csv(file = "station_info.csv", header = TRUE, stringsAsFactors = FALSE)

# Read CSV file "Canada_population_area_2011.csv" (using Canada Census Data - 2011)
populations <- read.csv(file = "Canada_population_area_2011.csv",
                        header = TRUE, stringsAsFactors = FALSE)

# Add 'Population' column to 'station_info' data frame
station_info$Population <- rep(NA, times = nrow(station_info))

# Add 'Land_Area..km2' column to 'station_info' data frame
station_info$Land_Area..km2 <- rep(NA, times = nrow(station_info))

# Add 'STA_Province' column to 'station_info' data frame
station_info$STA_Province <- rep(NA, times = nrow(station_info))

# There is an issue with exact matching of place names
# Remove periods and apostrophes from city fields in both data frames
station_info$STA_City <- gsub("\\.", "", station_info$STA_City)
populations$Census_Subdivision <- gsub("\\.", "", populations$Census_Subdivision)

station_info$STA_City <- gsub("'", "", station_info$STA_City)
populations$Census_Subdivision <- gsub("'", "", populations$Census_Subdivision)

station_info$STA_City <- gsub(" [C|c]ity", "", station_info$STA_City)
populations$Census_Subdivision <- gsub(" [C|c]ity", "", populations$Census_Subdivision)

for (i in 1:nrow(station_info)) {
  city <- tolower(station_info[i,3])
  prov <- populations[(1:dim(populations)[1])[tolower(populations[,1]) == city] ,2]
  area <- populations[(1:dim(populations)[1])[tolower(populations[,1]) == city] ,3]
  pop <- populations[(1:dim(populations)[1])[tolower(populations[,1]) == city] ,4]
  station_info[i,8] <- as.integer(ifelse(length(pop) == 0, NA, pop))
  station_info[i,9] <- as.numeric(ifelse(length(pop) == 0, NA, area))
  station_info[i,10] <- ifelse(length(pop) == 0, NA, prov)
}

# Correct erroneous longitude value for station 64301 (Longwoods, ON)
station_info[417,5] <- -8.148056e+01 

# Correct erroneous longitude value for station 80801 (Pense, SK)
station_info[459,5] <- -1.049833e+02

# Attach a column ('STA_Class') to the data frame with categorical population ranges
# Use 'cut' to classify stations by population and to add factors
station_info$STA_Class <- cut(station_info$Population,
                              breaks = c(-Inf, 0, 100000, 500000, Inf),
                              labels = c("NU", "SU", "U", "LU"))

# Stations with population of NA are all remote, non-urban sites
# Target NA values generated from classification scheme and replace with "NU"
station_info$STA_Class[is.na(station_info$STA_Class)] <- "NU"

# Write CSV file 'station_info_plus.csv' to working directory
write.csv(station_info, file = "station_info_plus.csv", row.names = FALSE)
station_info
}

#-----------------------#

# Function for mapping stations
map_station_list <- function(all_stations = TRUE,
                             latN = NULL,
                             latS = NULL,
                             longW = NULL,
                             longE = NULL) {

require(ggmap)
require(raster)
  
if (all_stations == TRUE) {
  latN <- 82
  latS <- 45
  longW <- -135 
  longE <- -50
} else { NULL }
  
# Determine the center of the map using the mid-points of the bounding lat/long coordinates
mid_pt_lat <- (latN + latS) / 2
mid_pt_long <- (longW + longE) / 2
  
# Define the map using the 'ggmap' package
the_map <- get_map(location = c(mid_pt_long, mid_pt_lat), zoom = 3,
                   maptype = 'roadmap')
  
map <- ggmap(the_map, legend = "right") + 
  geom_point(data = read.csv("station_info_plus.csv", header = TRUE),
             aes(x = read.csv("station_info_plus.csv", header = TRUE)$Longitude,
                 y = read.csv("station_info_plus.csv", header = TRUE)$Latitude,
                 colour = factor(read.csv("station_info_plus.csv", header = TRUE)$STA_Class)),
             size = 2) +
    #geom_text(data = read.csv("station_info.csv", header = TRUE),
    #          aes(x = read.csv("station_info.csv", header = TRUE)$Longitude + 0.005, 
    #              y = read.csv("station_info.csv", header = TRUE)$Latitude, label = NapsID,
    #              hjust = 0, vjust = 0), size = 3) +
    #coord_equal() +
  scale_colour_discrete(name = "Class of Station") +
  labs(x = "Longitude") +
  labs(y = "Latitude") +
  labs(title = "Plot of NAPS Stations")
map
}

#-----------------------#

# Function for generating CSV files from NAPS hourly (.hly) data files
generate_NAPS_CSV <- function(subdir = NULL,
                              year = NULL,
                              pollutant = NULL,
                              type = NULL,
                              NapsID = NULL,
                              all_data = FALSE) {

# Get vector with list of all hourly files
files <- ifelse(all_data == "TRUE" & is.null(pollutant),
                list.files(path = paste("./", subdir, "/", sep = ''), 
                pattern = "^[0-9a-zA-Z/.]*hly"), NULL)

# Get vector with list of all hourly files by pollutant
files <- ifelse(all_data == "TRUE" & !is.null(pollutant),
                list.files(path = paste("./", subdir, "/", sep = ''), 
                           pattern = "^[0-9]*", pollutant, ".hly"), NULL)

# Get vector with list of hourly files selected by year
files <- ifelse(!is.null(year) & all_data == FALSE,
                list.files(path = paste("./", subdir, "/", sep = ''), 
                pattern = paste("^", year, "[0-9a-zA-Z/.]*hly", sep = '')), NULL)

# Get vector with list of hourly files selected by year and pollutant
files <- ifelse(!is.null(year) & !is.null(pollutant) & all_data == FALSE,
                list.files(path = paste("./", subdir, "/", sep = ''), 
                           pattern = paste("^", year, pollutant, ".hly", sep = '')), NULL)

# Specify column widths for text fields in each hourly file
column.widths <- c(3, 6, 4, 2, 2,
                   4, 4, 4, 4, 4,
                   4, 4, 4, 4, 4,
                   4, 4, 4, 4, 4,
                   4, 4, 4, 4, 4,
                   4, 4, 4, 4, 4,
                   4, 4)

# Generate yearly data frames from each hourly data file
for (i in 1:length(files)) {
data <- read.fwf(paste("NAPS/", files[i], sep = ""), column.widths)
data <- data[, c(1:32)]
names(data) <- c("POLLUT.CODE", "STATION", "YR", "M", "D", "D.AVG", "D.MIN", "D.MAX", 
                 "H1", "H2", "H3", "H4", "H5", "H6", "H7", "H8", "H9", "H10", "H11",
                 "H12", "H13", "H14", "H15", "H16", "H17", "H18", "H19", "H20", "H21",
                 "H22", "H23", "H24")

# Duplicate each row to make 24 duplicates
data <- data[rep(1:((nrow(data)) - 1), each = 24), ]

# Reset the rownames
row.names(data) <- NULL

# Collapse the hourly values into one per line by selectively moving the correct one to a
# new column called 'conc'
conc <- mat.or.vec(nr = nrow(data), nc = 1)
hours <- mat.or.vec(nr = nrow(data), nc = 1)
for (j in seq(from = 0, to = (nrow(data)-1), by = 24)) {
  for (k in 1:24) {
  conc[j + k] <- round(data[j + k, k + 8], digits = 2)
  hours[j + k] <- k - 1
  }
}

# Assign a column name for concentration based on the namesake pollutant (from filename)
data <- within(data,{
  assign(gsub("^[0-9][0-9][0-9][0-9]([A-Z0-9]*)\\.hly$", "\\1.conc", files[i]), conc) 
})
data$H <- hours

# Drop extraneous columns
data <- data[ , -grep("^H[0-9]+", names(data))]
data <- data[ , -grep("^D\\.[A-Z]*", names(data))]

# Replace missing (-999) values with NA
require(gdata)
data[,6] <- unknownToNA(data[,6], -999.0)

# Generate time object of class "POSIXct" and place in data frame
time <- ISOdatetime(data$YR, data$M, data$D, data$H, min = 0, sec = 0, tz = "")
data$time <- time

# Drop columns with date/time values
data$YR <- NULL
data$M <- NULL
data$D <- NULL
data$H <- NULL

# Write data to a CSV
write.csv(data, file = paste(gsub("hly", "csv", files[i])), row.names = FALSE)

# Clean up
rm(data)
rm(conc)
rm(hours)
rm(time)
}
}

#-----------------------#




# Generate data completeness statistics from processed NAPS data files
generate_data_complete_CSV <- function(pollutant = NULL,
                                       all_years = TRUE,
                                       file_path = NULL) {

# file_path <- "~/Documents/R (Working)"
# pollutant <- "NO"
# 
#  test:
#  generate_data_complete_CSV(pollutant = "NO", file_path = "~/Documents/R (Working)")
#
  
file_path <- ifelse(is.null(file_path), getwd(), file_path)
  
require(lubridate)

if (pollutant == "O3") {
  file_list <- list.files(path = file_path, pattern = "^[0-9][0-9][0-9][0-9]O3\\.csv") 
} else if (pollutant == "NO") {
  file_list <- list.files(path = file_path, pattern = "^[0-9][0-9][0-9][0-9]NO\\.csv")   
} else if (pollutant == "NO2") {
  file_list <- list.files(path = file_path, pattern = "^[0-9][0-9][0-9][0-9]NO2\\.csv")
} else if (pollutant == "PM25") {
  file_list <- list.files(path = file_path, pattern = "^[0-9][0-9][0-9][0-9][0-9A-Z]*PM25\\.csv")
} else if (pollutant == "PM10") {
  file_list <- list.files(path = file_path, pattern = "^[0-9][0-9][0-9][0-9][0-9A-Z]*PM10\\.csv")
} else {stop("No data selected.")}

# Loop through reading in CSV files; convert time column back to POSIXct time objects
for (i in 1:length(file_list)){
df <- read.csv(file = paste(file_path, "/", file_list[i], sep = ''),
               header = TRUE, stringsAsFactors = FALSE)
df$time <- as.POSIXct(df$time)

# get number of stations
no_stations <- length(unique(df$STATION))

# get year
year <- round(mean(year(df$time)))

# get compound measured
pollutant <- gsub("([A-Z0-9]*)\\.conc","\\1",colnames(df)[3])

# get vector list of stations
station_list <- mat.or.vec(nr = no_stations, nc = 1)
station_list <- unique(df$STATION)

# For each station determine the data completeness for the year
# Initialize file for writing
cat("Year,Pollutant,NapsID,Data_Y%,",
    "Data_Q1%,Data_Q2%,",
    "Data_Q3%,Data_Q4%",
    file = paste(year,"_",pollutant,"_data_completeness.csv", sep = ''), sep = '')
cat("", file = paste(year,"_",pollutant,"_data_completeness.csv", sep = ''),
    sep = "\n", append = TRUE)
for (j in 1:length(station_list)){
  df.station <- subset(df, df$STATION == station_list[j])
  completeness_year <- 
        round(((nrow(df.station) - sum(is.na(df.station[,3])))/
                ifelse(leap_year(year), 8784, 8760))
                *100,
                digits = 2)
  
  rows.Q1 <- nrow(subset(df.station,
                      time >= as.POSIXct(paste(year, "-01-01 00:00", sep = '')) &
                      time <= as.POSIXct(paste(year, "-03-31 23:00", sep = ''))))
  NA.Q1 <- sum(is.na(subset(df.station,
                      time >= as.POSIXct(paste(year, "-01-01 00:00", sep = '')) &
                      time <= as.POSIXct(paste(year, "-03-31 23:00", sep = '')))[,3]))
  hours.Q1 <- as.integer(as.POSIXct(paste(year, "-03-31 23:00", sep = ''))-
                         as.POSIXct(paste(year, "-01-01 00:00", sep = '')))*24
  completeness.Q1 <- round(((rows.Q1 - NA.Q1)/hours.Q1)*100, digits = 2)
  
  rows.Q2 <- nrow(subset(df.station,
                      time >= as.POSIXct(paste(year, "-04-01 00:00", sep = '')) &
                      time <= as.POSIXct(paste(year, "-06-30 23:00", sep = ''))))
  NA.Q2 <- sum(is.na(subset(df.station,
                      time >= as.POSIXct(paste(year, "-04-01 00:00", sep = '')) &
                      time <= as.POSIXct(paste(year, "-06-30 23:00", sep = '')))[,3]))
  hours.Q2 <- as.integer(as.POSIXct(paste(year, "-06-30 23:00", sep = ''))-
                         as.POSIXct(paste(year, "-04-01 00:00", sep = '')))*24
  completeness.Q2 <- round(((rows.Q2 - NA.Q2)/hours.Q2)*100, digits = 2)

  rows.Q3 <- nrow(subset(df.station,
                      time >= as.POSIXct(paste(year, "-07-01 00:00", sep = '')) &
                      time <= as.POSIXct(paste(year, "-09-30 23:00", sep = ''))))
  NA.Q3 <- sum(is.na(subset(df.station,
                      time >= as.POSIXct(paste(year, "-07-01 00:00", sep = '')) &
                      time <= as.POSIXct(paste(year, "-09-30 23:00", sep = '')))[,3]))
  hours.Q3 <- as.integer(as.POSIXct(paste(year, "-09-30 23:00", sep = ''))-
                         as.POSIXct(paste(year, "-07-01 00:00", sep = '')))*24
  completeness.Q3 <- round(((rows.Q3 - NA.Q3)/hours.Q3)*100, digits = 2)
  
  rows.Q4 <- nrow(subset(df.station,
                      time >= as.POSIXct(paste(year, "-10-01 00:00", sep = '')) &
                      time <= as.POSIXct(paste(year, "-12-31 23:00", sep = ''))))
  NA.Q4 <- sum(is.na(subset(df.station,
                      time >= as.POSIXct(paste(year, "-10-01 00:00", sep = '')) &
                      time <= as.POSIXct(paste(year, "-12-31 23:00", sep = '')))[,3]))
  hours.Q4 <- as.integer(as.POSIXct(paste(year, "-12-31 23:00", sep = ''))-
                         as.POSIXct(paste(year, "-10-01 00:00", sep = '')))*24
  completeness.Q4 <- round(((rows.Q4 - NA.Q4)/hours.Q4)*100, digits = 2)

  cat(year,",",pollutant,",",station_list[j],",",completeness_year,",",
      completeness.Q1,",",completeness.Q2,",",completeness.Q3,",",completeness.Q4,
      file = paste(year,"_",pollutant,"_data_completeness.csv", sep = ''),
      sep = "", append = TRUE)
  cat("", file = paste(year,"_",pollutant,"_data_completeness.csv", sep = ''),
      sep = "\n", append = TRUE)
}
}
}
