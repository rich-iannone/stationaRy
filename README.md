<img src="inst/stationaRy_2x.png", width = 100%>

[![Travis-CI Build Status](https://travis-ci.org/rich-iannone/stationaRy.svg?branch=master)](https://travis-ci.org/rich-iannone/stationaRy) 
[![Issue Stats](http://issuestats.com/github/rich-iannone/stationaRy/badge/pr?style=flat)](http://issuestats.com/github/rich-iannone/stationaRy) 
[![Issue Stats](http://issuestats.com/github/rich-iannone/stationaRy/badge/issue?style=flat)](http://issuestats.com/github/rich-iannone/stationaRy) 
[![codecov.io](https://codecov.io/github/rich-iannone/stationaRy/coverage.svg?branch=master)](https://codecov.io/github/rich-iannone/stationaRy?branch=master)![](http://cranlogs.r-pkg.org/badges/grand-total/stationaRy?color=brightgreen) 

Want some tools to acquire and process meteorological data? Well, you've come to the right repo. So far there's only a few functions that get you data. These are:

- `get_isd_stations`
- `select_isd_station`
- `get_isd_station_data` 

They will help you get the hourly met data you need from a met station located somewhere on Earth.

## Examples

Get data from a station in Norway (**USAF**: 13860, **WBAN**: 99999):

```R
library(stationaRy)

met_data <- get_isd_station_data(station_id = "13860-99999",
                                 startyear = 2009,
                                 endyear = 2010)
```

That's great if you know the `USAF` and `WBAN` numbers for a particular met station. Most of the time, however, you won't have this info. You can search for stations by using the `get_isd_stations` function. By itself, it gives you a data frame with global station data. (As of June 15, 2015, there are 27,446 rows of station data.) Here are rows 250-255 of global met station list.

```R
library(stationaRy)

get_isd_stations()[250:255,]
```

```
Source: local data frame [6 x 15]

   usaf  wban                 name country state    lat   lon elev begin  end
1 13220 99999          FORDE-TEFRE      NO       61.467 5.917   64  1973 2015
2 13230 99999           BRINGELAND      NO       61.393 5.764  327  1984 2015
3 13250 99999           MODALEN II      NO       60.833 5.950  114  1973 2008
4 13260 99999          MODALEN III      NO       60.850 5.983  125  2008 2015
5 13270 99999 KVAMSKOGEN-JONSHOGDI      NO       60.383 5.967  455  2006 2015
6 13280 99999           KVAMSKOGEN      NO       60.400 5.917  408  1973 2006
Variables not shown: gn_gmtoffset (dbl), rawoffset (dbl), time_zone_id (chr),
  country_name (chr), country_code (chr)
```

You'll want to narrow this down. One way is to specify a geographic bounding box. Let's try the west coast of Canada. 

```R
library(stationaRy)

get_isd_stations(lower_lat = 49.000,
                 upper_lat = 49.500,
                 lower_lon = -123.500,
                 upper_lon = -123.000)
```

```
Source: local data frame [20 x 15]

     usaf  wban                      name country state    lat      lon   elev begin
1  710040 99999    CYPRESS BOWL FREESTYLE      CA       49.400 -123.200  969.0  2007
2  710370 99999            POINT ATKINSON      CA       49.330 -123.265   35.0  2003
3  710420 99999           DELTA BURNS BOG      CA       49.133 -123.000    3.0  2001
4  711120 99999 RICHMOND OPERATION CENTRE      CA       49.167 -123.067   16.0  1980
5  712010 99999  VANCOUVER HARBOUR CS  BC      CA       49.283 -123.117    3.0  1980
6  712013 99999            VANCOUVER INTL      CA       49.183 -123.167    3.0  1988
7  712025 99999          WEST VAN CYPRESS      CA       49.350 -123.183  161.0  1993
8  712045 99999           SAND HEADS (LS)      CA       49.100 -123.300    1.0  1992
9  712090 99999          SANDHEADS CS  BC      CA       49.100 -123.300     NA  2001
10 712110 99999      HOWE SOUND - PAM ROC      CA       49.483 -123.300    5.0  1996
11 715620 99999    CYPRESS BOWL SNOWBOARD      CA       49.383 -123.200 1180.0  2010
12 716080 99999  VANCOUVER SEA ISLAND CCG      CA       49.183 -123.183    2.1  1982
13 716930 99999        CYPRESS BOWL SOUTH      CA       49.383 -123.200  886.0  2007
14 717840 99999      WEST VANCOUVER (AUT)      CA       49.350 -123.200  168.0  1995
15 718903 99999                 PAM ROCKS      CA       49.483 -123.283    0.0  1987
16 718920 99999            VANCOUVER INTL      CA       49.194 -123.184    4.3  1955
17 718925 99999         VANCOUVER HARBOUR      CA       49.300 -123.117    5.0  1977
18 718926 99999       VANCOUVER HARBOUR &      CA       49.300 -123.117    5.0  1979
19 728920 99999            VANCOUVER INTL      CA       49.183 -123.167    3.0  1973
20 728925 99999       VANCOUVER HARBOUR &      CA       49.300 -123.117    5.0  1976
Variables not shown: end (dbl), gn_gmtoffset (dbl), rawoffset (dbl), time_zone_id
  (chr), country_name (chr), country_code (chr)
```

That's a lot of stations. Alright, I'll get my data from the `CYPRESS BOWL SNOWBOARD`, so this can be done:

```R
library(stationaRy)

get_isd_stations(lower_lat = 49.000,
                 upper_lat = 49.500,
                 lower_lon = -123.500,
                 upper_lon = -123.000) %>%
  select_isd_station(name = "cypress bowl")
```

```
Several stations matched. Provide a more specific search term.
Source: local data frame [3 x 15]

    usaf  wban                   name country state    lat    lon elev begin  end
1 710040 99999 CYPRESS BOWL FREESTYLE      CA       49.400 -123.2  969  2007 2010
2 715620 99999 CYPRESS BOWL SNOWBOARD      CA       49.383 -123.2 1180  2010 2010
3 716930 99999     CYPRESS BOWL SOUTH      CA       49.383 -123.2  886  2007 2014
Variables not shown: gn_gmtoffset (dbl), rawoffset (dbl), time_zone_id (chr),
  country_name (chr), country_code (chr)
[1] NA
```

Damn. Didn't notice those other `CYPRESS BOWL`s. That's okay, I'll try again and there's two ways to get a year of its data (`2010`):

```R
library(stationaRy)

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
head(cypress_bowl_snowboard_1)
```

```
Source: local data frame [6 x 18]

    usaf  wban year month day hour minute    lat      lon elev wd ws ceil_hgt temp
1 715620 99999 2010     1  29    0      0 50.633 -128.117  568 NA NA       NA  1.3
2 715620 99999 2010     1  29    6      0 50.633 -128.117  568 NA NA       NA  2.5
3 715620 99999 2010     1  29   12      0 50.633 -128.117  568 NA NA       NA  3.1
4 715620 99999 2010     1  29   18      0 50.633 -128.117  568 NA NA       NA  5.5
5 715620 99999 2010     1  30    0      0 50.633 -128.117  568 NA NA       NA  3.0
6 715620 99999 2010     1  30    6      0 50.633 -128.117  568 NA NA       NA  1.5
Variables not shown: dew_point (dbl), atmos_pres (dbl), rh (dbl), time (time)
```

Moving west, I think Tofino is nice. I'd like to get it's weather data. Let's just make sure we can target that station.

```R
library(stationaRy)

get_isd_stations() %>%
  select_isd_station(name = "tofino")
```

```
Several stations matched. Provide a more specific search term.
Source: local data frame [4 x 15]

    usaf  wban           name country state    lat      lon elev begin  end gn_gmtoffset
1 711060 94234 TOFINO AIRPORT      CA    BC 49.083 -125.767 24.0  1958 2015           -8
2 711060 99999         TOFINO      CA       49.082 -125.773 24.4  2000 2004           -8
3 741060 94234         TOFINO      CA       49.083 -125.767 20.0  1973 1977           -8
4 999999 94234         TOFINO      CA       49.083 -125.767 24.1  1964 1972           -8
Variables not shown: rawoffset (dbl), time_zone_id (chr), country_name (chr),
  country_code (chr)
[1] NA
```

Quite a few variants of the Tofino station. Let's choose the airport one. Seems to have a long record. It's the first one in that list. And I'd like the data from 2005 to 2010.

```R
library(stationaRy)

tofino_airport_2005_2010 <- 
  get_isd_stations() %>%
    select_isd_station(name = "tofino", number = 1) %>%
    get_isd_station_data(startyear = 2005, endyear = 2010)
```

That's gives you 34,877 rows of Tofino Airport meteorological data.

Of course, **dplyr** works really well with this sort of data:

```R
library(stationaRy)
library(dplyr)

bergen_point_met <- 
  get_isd_stations() %>%
  select_isd_station(name = "bergen point") %>%
  get_isd_station_data(startyear = 2006, endyear = 2015)

high_temps <- 
  select(bergen_point_met, time, wd, ws, temp) %>% 
  filter(temp > 37) %>%
  mutate(temp_f = (temp * (9/5)) + 32)

high_temps
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
