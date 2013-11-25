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

station_info <- read.csv(file = "station_info.csv", header = TRUE, stringsAsFactors = FALSE)
# Add 'Population' column to 'station_info' data frame
station_info$Population <- rep(-1, times = nrow(station_info))

populations <- read.csv(file = "Canada_population_area_2011.csv",
                        header = TRUE, stringsAsFactors = FALSE)

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
  pop <- populations[(1:dim(populations)[1])[tolower(populations[,1]) == city] ,4]
  station_info[i,8] <- ifelse(length(pop) == 0, -1, pop)
}

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
  latN <- 80
  latS <- 41
  longW <- -135 
  longE <- -50
} else { NULL }
  
# Determine the center of the map using the mid-points of the bounding lat/long coordinates
mid_pt_lat <- (latN + latS) / 2
mid_pt_long <- (longW + longE) / 2
  
# Define the map using the 'ggmap' package
the_map <- get_map(location = c(mid_pt_long, mid_pt_lat), zoom = 3,
                   maptype = 'hybrid')
  
map <- ggmap(the_map) + 
  geom_point(data = read.csv("station_info_plus.csv", header = TRUE),
             aes(x = read.csv("station_info_plus.csv", header = TRUE)$Longitude,
                 y = read.csv("station_info_plus.csv", header = TRUE)$Latitude),
             size = 3) +
    #geom_text(data = read.csv("station_info.csv", header = TRUE),
    #          aes(x = read.csv("station_info.csv", header = TRUE)$Longitude + 0.005, 
    #              y = read.csv("station_info.csv", header = TRUE)$Latitude, label = NapsID,
    #              hjust = 0, vjust = 0), size = 3) +
    #coord_equal() +
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
files <- ifelse(all_data = "TRUE" & is.null(pollutant),
                list.files(path = paste("./", subdir, "/", sep = ''), 
                pattern = "^[0-9a-zA-Z/.]*hly"), NULL)

# Get vector with list of all hourly files by pollutant
files <- ifelse(all_data = "TRUE" & !is.null(pollutant),
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

