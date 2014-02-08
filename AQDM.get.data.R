# Script for asynchronous data access from the EPA Air Quality Data Mart
#
#

# Add require statement
require(RCurl)

# Get the start year and the end year for the data retrieval
start_year <- 1998
end_year <- 2012

# Access URI stub for obtaining monitoring station metadata in CSV form
URI_stub_station_metadata_CSV <- "http://www.epa.gov/airexplorer/"

# Access URI stub for EPA air quality data
URI_stub_AQSDM_query <- "https://ofmext.epa.gov/AQDMRS/ws/"

# Create vector list of available AQ parameters
AQ_parameters <- c("CO", "NO2", "Ozone", "PM10", "PM25")

# Get updated station data for each of the monitoring networks
for (i in 1:length(AQ_parameters)) {
  download.file(paste(URI_stub_station_metadata_CSV, AQ_parameters[i], sep = ''),
                paste("./data/", AQ_parameters[i], ".csv", sep = ''))
}                          

# Create data frame for the NO2 parameter
NO2_station_metadata <- read.csv(paste("./data/", AQ_parameters[2], ".csv", sep = ''),
                                 header = TRUE, stringsAsFactors = FALSE)

# Create data frame for the ozone parameter
ozone_station_metadata <- read.csv(paste("./data/", AQ_parameters[3], ".csv", sep = ''),
                                   header = TRUE, stringsAsFactors = FALSE)

# Filter list of stations by latitude and longitude bounding boxes
# (decimal degrees: lat_N, lat_S, long_W, long_E)
number_of_bounding_boxes <- 4
box_1 <- c(49.0, 44.5, -125.0, -95.1)
box_2 <- c(49.0, 43.5, -95.1, -89.0)
box_3 <- c(48.0, 37.5, -89.0, -78.8)
box_4 <- c(48.0, 39.5, -78.8, -66.6)

#----------------
# NO2 stations
#----------------

# Create subsets of the 'NO2_station_metadata' data frame by each bounding box
NO2_station_metadata.subset.1 <-
  subset(NO2_station_metadata,
         NO2_station_metadata$Latitude <= box_1[1] &
           NO2_station_metadata$Latitude >= box_1[2] &
           NO2_station_metadata$Longitude >= box_1[3] &
           NO2_station_metadata$Longitude <= box_1[4])

NO2_station_metadata.subset.2 <-
  subset(NO2_station_metadata,
         NO2_station_metadata$Latitude <= box_2[1] &
           NO2_station_metadata$Latitude >= box_2[2] &
           NO2_station_metadata$Longitude >= box_2[3] &
           NO2_station_metadata$Longitude <= box_2[4])

NO2_station_metadata.subset.3 <-
  subset(NO2_station_metadata,
         NO2_station_metadata$Latitude <= box_3[1] &
           NO2_station_metadata$Latitude >= box_3[2] &
           NO2_station_metadata$Longitude >= box_3[3] &
           NO2_station_metadata$Longitude <= box_3[4])

NO2_station_metadata.subset.4 <-
  subset(NO2_station_metadata,
         NO2_station_metadata$Latitude <= box_4[1] &
           NO2_station_metadata$Latitude >= box_4[2] &
           NO2_station_metadata$Longitude >= box_4[3] &
           NO2_station_metadata$Longitude <= box_4[4])

# Combine the 4 subsets by bounding box into one subset
NO2_station_metadata.subset.a <- rbind(NO2_station_metadata.subset.1,
                                       NO2_station_metadata.subset.2,
                                       NO2_station_metadata.subset.3,
                                       NO2_station_metadata.subset.4)

# Filter those stations that have start dates before the requested start year
NO2_station_metadata.subset.b <-
  subset(NO2_station_metadata.subset.a,
         as.numeric(gsub("[0-9][0-9][A-Z][A-Z][A-Z]([0-9][0-9][0-9][0-9]).*",
                         "\\1", NO2_station_metadata.subset.a$Monitor.Start.Date,
                         perl = TRUE)) < start_year)

# Continue to filter those stations, this time with last sample dates occuring after the
# requested start date
NO2_station_metadata.subset.b <-
  subset(NO2_station_metadata.subset.b,
         as.numeric(gsub("[0-9][0-9][A-Z][A-Z][A-Z]([0-9][0-9][0-9][0-9]).*",
                         "\\1", NO2_station_metadata.subset.b$Last.Sample.Date,
                         perl = TRUE)) > end_year)

# Select only stations using FEM or FRM methodology
NO2_station_metadata.subset.c <-
  subset(NO2_station_metadata.subset.b, NO2_station_metadata.subset.b$FRM.FEM. == "Yes")

# Get unique set of 'AQS.Site.ID' values for NO2 monitoring stations
AQS_Site_ID_NO2 <- unique(NO2_station_metadata.subset.c$AQS.Site.ID)

# Get count of unique stations for NO2
AQS_Site_ID_NO2.count <- length(AQS_Site_ID_NO2) # 54 stations

#----------------
# Ozone stations
#----------------

# Create subsets of the 'ozone_station_metadata' data frame by each bounding box
ozone_station_metadata.subset.1 <-
  subset(ozone_station_metadata,
         ozone_station_metadata$Latitude <= box_1[1] &
           ozone_station_metadata$Latitude >= box_1[2] &
           ozone_station_metadata$Longitude >= box_1[3] &
           ozone_station_metadata$Longitude <= box_1[4])

ozone_station_metadata.subset.2 <-
  subset(ozone_station_metadata,
         ozone_station_metadata$Latitude <= box_2[1] &
           ozone_station_metadata$Latitude >= box_2[2] &
           ozone_station_metadata$Longitude >= box_2[3] &
           ozone_station_metadata$Longitude <= box_2[4])

ozone_station_metadata.subset.3 <-
  subset(ozone_station_metadata,
         ozone_station_metadata$Latitude <= box_3[1] &
           ozone_station_metadata$Latitude >= box_3[2] &
           ozone_station_metadata$Longitude >= box_3[3] &
           ozone_station_metadata$Longitude <= box_3[4])

ozone_station_metadata.subset.4 <-
  subset(ozone_station_metadata,
         ozone_station_metadata$Latitude <= box_4[1] &
           ozone_station_metadata$Latitude >= box_4[2] &
           ozone_station_metadata$Longitude >= box_4[3] &
           ozone_station_metadata$Longitude <= box_4[4])

# Combine the 4 subsets by bounding box into one subset
ozone_station_metadata.subset.a <- rbind(ozone_station_metadata.subset.1,
                                         ozone_station_metadata.subset.2,
                                         ozone_station_metadata.subset.3,
                                         ozone_station_metadata.subset.4)

# Filter those stations that have start dates before the requested start year
ozone_station_metadata.subset.b <-
  subset(ozone_station_metadata.subset.a,
         as.numeric(gsub("[0-9][0-9][A-Z][A-Z][A-Z]([0-9][0-9][0-9][0-9]).*",
                         "\\1", ozone_station_metadata.subset.a$Monitor.Start.Date,
                         perl = TRUE)) < start_year)

# Continue to filter those stations, this time with last sample dates occuring after the
# requested start date
ozone_station_metadata.subset.b <-
  subset(ozone_station_metadata.subset.b,
         as.numeric(gsub("[0-9][0-9][A-Z][A-Z][A-Z]([0-9][0-9][0-9][0-9]).*",
                         "\\1", ozone_station_metadata.subset.b$Last.Sample.Date,
                         perl = TRUE)) > end_year)

# Select only stations using FEM or FRM methodology
ozone_station_metadata.subset.c <-
  subset(ozone_station_metadata.subset.b, ozone_station_metadata.subset.b$FRM.FEM. == "Yes")

# Get unique set of 'AQS.Site.ID' values for ozone monitoring stations
AQS_Site_ID_ozone <- unique(ozone_station_metadata.subset.c$AQS.Site.ID)

# Get count of unique stations for ozone
AQS_Site_ID_ozone.count <- length(AQS_Site_ID_ozone) # 232 stations

#------------------------------------------------
# Query the AQS Data Mart for hourly station data
#------------------------------------------------

# The AQS Site ID is a combination of the (1) state code, (2) county code, and (3) site ID
# Here is a function to extract each element

AQS.Site.ID.element <- function(AQS_Site_ID,
                                element){
  
  if (element == "state_code"){
    return(unlist(strsplit(AQS_Site_ID, split = "-"))[1])
  }
  
  if (element == "county_code"){
    return(unlist(strsplit(AQS_Site_ID, split = "-"))[2])
  }
  
  if (element == "site_ID"){
    return(unlist(strsplit(AQS_Site_ID, split = "-"))[3])
  }  
}


# Generate a collection of URLs to query NO2 data

URI_collection_NO2 <- mat.or.vec(nr = AQS_Site_ID_NO2.count * (end_year - start_year + 1),
                                 nc = 1) # 810 URIs

# Username and password for API access
user <- user
pw <- pw

# Format of data requested is a Data Mart CSV file
format <- "DMCSV"

# The parameter codes for NO2 and ozone
param_NO2 <- "42602"
param_ozone <- "44201"

