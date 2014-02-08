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

