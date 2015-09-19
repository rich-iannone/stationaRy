<img src="inst/stationaRy_2x.png", width = 100%>

[![Travis-CI Build Status](https://travis-ci.org/rich-iannone/stationaRy.svg?branch=master)](https://travis-ci.org/rich-iannone/stationaRy) 
[![Issue Stats](http://issuestats.com/github/rich-iannone/stationaRy/badge/pr?style=flat)](http://issuestats.com/github/rich-iannone/stationaRy) 
[![Issue Stats](http://issuestats.com/github/rich-iannone/stationaRy/badge/issue?style=flat)](http://issuestats.com/github/rich-iannone/stationaRy) 
![](http://cranlogs.r-pkg.org/badges/grand-total/stationaRy?color=brightgreen) 
[![codecov.io](https://codecov.io/github/rich-iannone/stationaRy/coverage.svg?branch=master)](https://codecov.io/github/rich-iannone/stationaRy?branch=master) 

Get hourly meteorological data from a station located somewhere on Earth.

## Examples

Get data from a station in Norway (with a **USAF** value of 13860, and a **WBAN** value of 99999). Specify the `station_id` as a string in the format `[USAF]-[WBAN]`, and, provide beginning and ending years for data collection to `startyear` and `endyear`, respectively.

```R
library(stationaRy)

met_data <- get_isd_station_data(station_id = "13860-99999",
                                 startyear = 2009,
                                 endyear = 2010)
```

That's great if you know the `USAF` and `WBAN` numbers for a particular met station. Most of the time, however, you won't have this info. You can search for station metadata using the `get_isd_stations` function. Without providing any arguments, it gives you a data frame containing the entire dataset of stations. Currently, there are 27,446 rows in the dataset. Here are rows 250-255 from the dataset:

```R
library(stationaRy)

get_isd_stations()[250:255,]
```

```
Source: local data frame [6 x 16]

   usaf  wban                 name country state    lat   lon elev begin  end
1 13220 99999          FORDE-TEFRE      NO       61.467 5.917   64  1973 2015
2 13230 99999           BRINGELAND      NO       61.393 5.764  327  1984 2015
3 13250 99999           MODALEN II      NO       60.833 5.950  114  1973 2008
4 13260 99999          MODALEN III      NO       60.850 5.983  125  2008 2015
5 13270 99999 KVAMSKOGEN-JONSHOGDI      NO       60.383 5.967  455  2006 2015
6 13280 99999           KVAMSKOGEN      NO       60.400 5.917  408  1973 2006
Variables not shown: gmt_offset (dbl), time_zone_id (chr), country_name (chr),
  country_code (chr), iso3166_2_subd (chr), fips10_4_subd (chr)
```

This list can be greatly reduced to isolate the stations of interest. One way to do this is to specify a geographic bounding box using lat/lon values to specify the bounds. Let's try a bounding box located in the west coast of Canada. 

```R
library(stationaRy)

get_isd_stations(lower_lat = 49.000,
                 upper_lat = 49.500,
                 lower_lon = -123.500,
                 upper_lon = -123.000)
```

```
Source: local data frame [20 x 16]

     usaf  wban                      name country state    lat      lon   elev begin  end
1  710040 99999    CYPRESS BOWL FREESTYLE      CA       49.400 -123.200  969.0  2007 2010
2  710370 99999            POINT ATKINSON      CA       49.330 -123.265   35.0  2003 2015
3  710420 99999           DELTA BURNS BOG      CA       49.133 -123.000    3.0  2001 2015
4  711120 99999 RICHMOND OPERATION CENTRE      CA       49.167 -123.067   16.0  1980 2015
5  712010 99999  VANCOUVER HARBOUR CS  BC      CA       49.283 -123.117    3.0  1980 2015
6  712013 99999            VANCOUVER INTL      CA       49.183 -123.167    3.0  1988 1988
7  712025 99999          WEST VAN CYPRESS      CA       49.350 -123.183  161.0  1993 1995
8  712045 99999           SAND HEADS (LS)      CA       49.100 -123.300    1.0  1992 1995
9  712090 99999          SANDHEADS CS  BC      CA       49.100 -123.300     NA  2001 2015
10 712110 99999      HOWE SOUND - PAM ROC      CA       49.483 -123.300    5.0  1996 2015
11 715620 99999    CYPRESS BOWL SNOWBOARD      CA       49.383 -123.200 1180.0  2010 2010
12 716080 99999  VANCOUVER SEA ISLAND CCG      CA       49.183 -123.183    2.1  1982 2015
13 716930 99999        CYPRESS BOWL SOUTH      CA       49.383 -123.200  886.0  2007 2014
14 717840 99999      WEST VANCOUVER (AUT)      CA       49.350 -123.200  168.0  1995 2015
15 718903 99999                 PAM ROCKS      CA       49.483 -123.283    0.0  1987 1995
16 718920 99999            VANCOUVER INTL      CA       49.194 -123.184    4.3  1955 2015
17 718925 99999         VANCOUVER HARBOUR      CA       49.300 -123.117    5.0  1977 1980
18 718926 99999       VANCOUVER HARBOUR &      CA       49.300 -123.117    5.0  1979 1979
19 728920 99999            VANCOUVER INTL      CA       49.183 -123.167    3.0  1973 1977
20 728925 99999       VANCOUVER HARBOUR &      CA       49.300 -123.117    5.0  1976 1977
Variables not shown: gmt_offset (dbl), time_zone_id (chr), country_name (chr),
  country_code (chr), iso3166_2_subd (chr), fips10_4_subd (chr)
```

To put these stations on a viewable map, use a `magrittr` or `pipeR` pipe, to send the output data frame as input to the `map_isd_stations` function. Pipes are great, amirite?

```R
library(stationaRy)
library(magrittr)

get_isd_stations(lower_lat = 49.000,
                 upper_lat = 49.500,
                 lower_lon = -123.500,
                 upper_lon = -123.000) %>%
  map_isd_stations()
```

<img src="inst/stations_map.png", width = 100%>

Upon inspecting the data frame, you can reduce it to a single station by specifying it's name (or part of its name). In this example, we wish to get data from the `CYPRESS BOWL SNOWBOARD` station. This can be done by extending with `select_isd_station` and using the `name` argument to supply part of the station name.

```R
library(stationaRy)
library(magrittr)

get_isd_stations(lower_lat = 49.000,
                 upper_lat = 49.500,
                 lower_lon = -123.500,
                 upper_lon = -123.000) %>%
  select_isd_station(name = "cypress bowl")
```

```
Several stations matched. Provide a more specific search term.
Source: local data frame [3 x 16]

    usaf  wban                   name country state    lat    lon elev begin  end
1 710040 99999 CYPRESS BOWL FREESTYLE      CA       49.400 -123.2  969  2007 2010
2 715620 99999 CYPRESS BOWL SNOWBOARD      CA       49.383 -123.2 1180  2010 2010
3 716930 99999     CYPRESS BOWL SOUTH      CA       49.383 -123.2  886  2007 2014
Variables not shown: gmt_offset (dbl), time_zone_id (chr), country_name (chr),
  country_code (chr), iso3166_2_subd (chr), fips10_4_subd (chr)
[1] NA
```

As this function yielded a data frame with 3 stations (3 stations leading with `CYPRESS BOWL` in their station names), a set of strategies will be used to obtain single station. There are two ways to get a year of `CYPRESS BOWL SNOWBOARD` data for `2010`: (1) provide the full name of the station, or (2) use the data frame with multiple stations and specify the row of the target station.

```R
library(stationaRy)
library(magrittr)

cypress_bowl_snowboard_1 <- 
  get_isd_stations(lower_lat = 49.000,
                   upper_lat = 49.500,
                   lower_lon = -123.500,
                   upper_lon = -123.000) %>%
    select_isd_station(name = "cypress bowl snowboard") %>%
    get_isd_station_data(startyear = 2010, endyear = 2010)
    
cypress_bowl_snowboard_2 <- 
  get_isd_stations(lower_lat = 49.000,
                   upper_lat = 49.500,
                   lower_lon = -123.500,
                   upper_lon = -123.000) %>%
    select_isd_station(name = "cypress bowl", number = 2) %>%
    get_isd_station_data(startyear = 2010, endyear = 2010)
```

Both statements get the same met data (the `select_isd_station` function simply passes a `USAF`/`WBAN` string to `get_isd_station_data` via the `%>%` operator). Here's a bit of that met data:

```
Source: local data frame [711 x 18]

     usaf  wban year month day hour minute    lat      lon elev wd ws ceil_hgt temp
1  715620 99999 2010     1  28   16      0 50.633 -128.117  568 NA NA       NA  1.3
2  715620 99999 2010     1  28   22      0 50.633 -128.117  568 NA NA       NA  2.5
3  715620 99999 2010     1  29    4      0 50.633 -128.117  568 NA NA       NA  3.1
4  715620 99999 2010     1  29   10      0 50.633 -128.117  568 NA NA       NA  5.5
5  715620 99999 2010     1  29   16      0 50.633 -128.117  568 NA NA       NA  3.0
6  715620 99999 2010     1  29   22      0 50.633 -128.117  568 NA NA       NA  1.5
7  715620 99999 2010     1  30    4      0 50.633 -128.117  568 NA NA       NA  0.3
8  715620 99999 2010     1  30   10      0 50.633 -128.117  568 NA NA       NA  0.9
9  715620 99999 2010     1  30   16      0 50.633 -128.117  568 NA NA       NA  0.7
10 715620 99999 2010     1  30   22      0 50.633 -128.117  568 NA NA       NA -0.1
..    ...   ...  ...   ... ...  ...    ...    ...      ...  ... .. ..      ...  ...
Variables not shown: dew_point (dbl), atmos_pres (dbl), rh (dbl), time (time)
```

If you'd like to get weather data from a weather station at Tofino, BC, CA, it's possible to search using `tofino` as the value for the `name` argument in the `select_isd_stations` function.

```R
library(stationaRy)
library(magrittr)

get_isd_stations() %>%
  select_isd_station(name = "tofino")
```

```
Several stations matched. Provide a more specific search term.
Source: local data frame [4 x 16]

    usaf  wban           name country state    lat      lon elev begin  end
1 711060 94234 TOFINO AIRPORT      CA    BC 49.083 -125.767 24.0  1958 2015
2 711060 99999         TOFINO      CA       49.082 -125.773 24.4  2000 2004
3 741060 94234         TOFINO      CA       49.083 -125.767 20.0  1973 1977
4 999999 94234         TOFINO      CA       49.083 -125.767 24.1  1964 1972
Variables not shown: gmt_offset (dbl), time_zone_id (chr), country_name (chr),
  country_code (chr), iso3166_2_subd (chr), fips10_4_subd (chr)
[1] NA
```

A number of stations with `tofino` in its name were returned. If the first station in the returned data frame is desired, it can be selected with a slight modification to the `select_isd_station` call (using the `number` argument). Then, pipe the output to the `get_isd_station_data` function and supply the desired period of retrieval.

```R
library(stationaRy)
library(magrittr)

tofino_airport_2005_2010 <- 
  get_isd_stations() %>%
    select_isd_station(name = "tofino", number = 1) %>%
    get_isd_station_data(startyear = 2005, endyear = 2010)
```

That's gives you 34,877 rows of meteorological data from the Tofino Airport station:

```
Source: local data frame [34,877 x 18]

     usaf  wban year month day hour minute    lat      lon elev wd  ws ceil_hgt
1  711060 94234 2005     1   1    7      0 49.083 -125.767   24 NA 0.0     1500
2  711060 94234 2005     1   1    8      0 49.083 -125.767   24 NA 0.0     1500
3  711060 94234 2005     1   1    9      0 49.083 -125.767   24 NA 0.0     1500
4  711060 94234 2005     1   1   10      0 49.083 -125.767   24 NA 0.0     1200
5  711060 94234 2005     1   1   11      0 49.083 -125.767   24 80 1.5     1200
6  711060 94234 2005     1   1   12      0 49.083 -125.767   24 NA 0.0     1650
7  711060 94234 2005     1   1   13      0 49.083 -125.767   24 40 2.6     1650
8  711060 94234 2005     1   1   14      0 49.083 -125.767   24 50 3.6     1650
9  711060 94234 2005     1   1   15      0 49.083 -125.767   24 70 1.0      900
10 711060 94234 2005     1   1   16      0 49.083 -125.767   24 60 1.5     1650
..    ...   ...  ...   ... ...  ...    ...    ...      ...  ... .. ...      ...
Variables not shown: temp (dbl), dew_point (dbl), atmos_pres (dbl), rh (dbl), time
  (time)
```

Of course, **dplyr** works really well to work toward the data you need. Suppose you'd like to collect several years of met data from a particular station and get only a listing of parameters that meet some criterion. Here's an example of obtaining temperatures above 37 degrees Celsius from a particular station:

```R
library(stationaRy)
library(magrittr)
library(dplyr)

high_temps_at_bergen_point_stn <- 
  get_isd_stations() %>%
  select_isd_station(name = "bergen point") %>%
  get_isd_station_data(startyear = 2006, endyear = 2015) %>%
  select(time, wd, ws, temp) %>% 
  filter(temp > 37) %>%
  mutate(temp_f = (temp * (9/5)) + 32)
```

```
#> Source: local data frame [3 x 5]
#> 
#>                  time  wd  ws temp temp_f
#> 1 2012-07-18 12:00:00 230 1.5 37.2  98.96
#> 2 2012-07-18 13:00:00 220 2.6 37.8 100.04
#> 3 2012-07-18 14:00:00 230 4.1 37.9 100.22
```

There's actually a lot of extra met data, and it varies from station to station. These additional categories are denoted 'two-letter + digit' identifiers (e.g., `AA1`, `GA1`, etc.). More information about these observations can be found in [this PDF document](http://www1.ncdc.noaa.gov/pub/data/ish/ish-format-document.pdf).

To find out which categories are available for a station, set the `add_data_report` argument of the `get_isd_station_data` function to `TRUE`. This will provide a data frame with the available additional categories with their counts in the dataset.

```R
library(stationaRy)
library(magrittr)
library(dplyr)

get_isd_stations(startyear = 1970, endyear = 2015,
                 lower_lat = 49, upper_lat = 58,
                 lower_lon = -125, upper_lon = -120) %>%
  select_isd_station(name = "abbotsford") %>%
  get_isd_station_data(startyear = 2015,
                       endyear = 2015,
                       add_data_report = TRUE)
```

```
#>    category total_count
#> 1       AA1         744
#> 2       AC1         817
#> 3       AJ1           5
#> 4       AL1           4
#> 5       AY1         248
#> 6       CB1          27
#> 7       CF1         125
#> 8       CI1         560
#> 9       CT1         406
#> 10      CU1         478
#> 11      ED1          27
#> 12      GA1         778
#> 13      GD1        4514
#> 14      GF1        5664
#> 15      IA1           5
#> 16      KA1         744
#> 17      MA1        5748
#> 18      MD1         736
#> 19      MW1        1609
#> 20      OC1         324
#> 21      ST1          38
```

Want the rainfall in mm units for a particular month? Here's an example where rainfall amounts (over 6 hour periods) are summed for the month of June in 2015 for Abbotsford, BC, Canada. The `AA1` data category has to do with rainfall, and you can be include that data (where available) in the output data frame by using the `select_additional_data` argument and specifying which data categories you'd like. The `AA1_1` column is the duration in hours when the liquid precipitation was observed, and, the `AA1_2` column is quantity of rain in mm. The deft use of functions from the **dplyr** package makes this whole process less painful.

```R
library(stationaRy)
library(magrittr)
library(dplyr)

rainfall_6h_june2015 <- 
  get_isd_stations(startyear = 1970, endyear = 2015,
                   lower_lat = 49, upper_lat = 58,
                   lower_lon = -125, upper_lon = -120) %>%
    select_isd_station(name = "abbotsford") %>%
    get_isd_station_data(startyear = 2015,
                         endyear = 2015,
                         select_additional_data = "AA1") %>%
    filter(month == 6, aa1_1 == 6) %>% 
        select(aa1_2) %>% sum()
```

```
[1] 12.5  
```

## Installation

Want to try this? Make sure you have **R**, then, use this:

```R
devtools::install_github('rich-iannone/stationaRy')
```

or this:

```R
install.packages("stationaRy")
```

Thanks for installing. `:)`
