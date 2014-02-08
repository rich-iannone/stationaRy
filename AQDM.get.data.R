# Script for asynchronous data access from the EPA Air Quality Data Mart
#
#

# Add require statement
require(RCurl)

# Get the start year and the end year for the data retrieval
start_year <- 1998
end_year <- 2012
