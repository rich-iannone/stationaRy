<img src="inst/stationaRy_2x.png", width = 100%>

Want some tools to acquire and process meteorological and air quality monitoring station data? Well, you've come to the right repo. So far, because this is merely the beginning, there's only a few functions that get you data. These are:

- `get_ncdc_station_info`
- `select_ncdc_station`
- `get_ncdc_station_data` 

They will help you get the hourly met data you need from a met station located somewhere on earth.

## Examples

Get data from a station in Norway (**USAF**: 13860, **WBAN**: 99999):

```R
met_data <- get_ncdc_station_data(station_id = "13860-99999",
                                  startyear = 2009,
                                  endyear = 2010)
```

That's great if you know the `USAF` and `WBAN` numbers for a particular met station. Most of the time, however, you won't have this info. You can search for stations by using the `get_ncdc_station_info` function. By itself, it gives you a data frame with global station data. (As of June 15, 2015, there are 29,316 rows of station data.) Here are rows 250-255 of global met station list.

```R
get_ncdc_station_info()[250:255,]
```

```
#>      USAF  WBAN             NAME CTRY STATE    LAT    LON ELEV BEGIN  END
#> 250 12430 99999           SONGLI   NO       63.333  9.650  300  1973 1976
#> 251 12450 99999     OPPDAL-SETER   NO       62.600  9.667  606  1976 2015
#> 252 12480 99999       VALLERSUND   NO       63.850  9.733    4  1973 1975
#> 253 12500 99999 FOLLDAL-FREDHEIM   NO       62.133 10.000  694  2011 2015
#> 254 12520 99999  BERKAK-LYNGHOLT   NO       62.817 10.017  475  1973 2008
#> 255 12530 99999         SOKNEDAL   NO       62.950 10.183  299  2009 2015
```

You'll want to narrow this down. One way is to specify a geographic bounding box. Let's try the west coast of Canada. 

```R
get_ncdc_station_info(lower_lat = 49.000,
                      upper_lat = 49.500,
                      lower_lon = -123.500,
                      upper_lon = -123.000)
```

```
#>      USAF  WBAN                      NAME CTRY STATE    LAT      LON   ELEV BEGIN  END
#> 1  710040 99999    CYPRESS BOWL FREESTYLE   CA       49.400 -123.200  969.0  2007 2010
#> 2  710370 99999            POINT ATKINSON   CA       49.330 -123.265   35.0  2003 2015
#> 3  710420 99999           DELTA BURNS BOG   CA       49.133 -123.000    3.0  2001 2015
#> 4  711120 99999 RICHMOND OPERATION CENTRE   CA       49.167 -123.067   16.0  1980 2015
#> 5  712010 99999  VANCOUVER HARBOUR CS  BC   CA       49.283 -123.117    3.0  1980 2015
#> 6  712013 99999            VANCOUVER INTL   CA       49.183 -123.167    3.0  1988 1988
#> 7  712025 99999          WEST VAN CYPRESS   CA       49.350 -123.183  161.0  1993 1995
#> 8  712045 99999           SAND HEADS (LS)   CA       49.100 -123.300    1.0  1992 1995
#> 9  712090 99999          SANDHEADS CS  BC   CA       49.100 -123.300 -999.9  2001 2015
#> 10 712110 99999      HOWE SOUND - PAM ROC   CA       49.483 -123.300    5.0  1996 2015
#> 11 715620 99999    CYPRESS BOWL SNOWBOARD   CA       49.383 -123.200 1180.0  2010 2010
#> 12 716080 99999  VANCOUVER SEA ISLAND CCG   CA       49.183 -123.183    2.1  1982 2015
#> 13 716930 99999        CYPRESS BOWL SOUTH   CA       49.383 -123.200  886.0  2007 2014
#> 14 717840 99999      WEST VANCOUVER (AUT)   CA       49.350 -123.200  168.0  1995 2015
#> 15 718903 99999                 PAM ROCKS   CA       49.483 -123.283    0.0  1987 1995
#> 16 718920 99999            VANCOUVER INTL   CA       49.194 -123.184    4.3  1955 2015
#> 17 718925 99999         VANCOUVER HARBOUR   CA       49.300 -123.117    5.0  1977 1980
#> 18 718926 99999       VANCOUVER HARBOUR &   CA       49.300 -123.117    5.0  1979 1979
#> 19 728920 99999            VANCOUVER INTL   CA       49.183 -123.167    3.0  1973 1977
#> 20 728925 99999       VANCOUVER HARBOUR &   CA       49.300 -123.117    5.0  1976 1977
```

That's a lot of stations. Alright, I'll get my data from the `CYPRESS BOWL SNOWBOARD`, so this can be done:

```R
get_ncdc_station_info(lower_lat = 49.000,
                      upper_lat = 49.500,
                      lower_lon = -123.500,
                      upper_lon = -123.000) %>>%
  select_ncdc_station(name = "cypress bowl")
```

```
Several stations matched. Provide a more specific search term.
#>      USAF  WBAN                   NAME CTRY STATE    LAT    LON ELEV BEGIN  END
#> 1  710040 99999 CYPRESS BOWL FREESTYLE   CA       49.400 -123.2  969  2007 2010
#> 11 715620 99999 CYPRESS BOWL SNOWBOARD   CA       49.383 -123.2 1180  2010 2010
#> 13 716930 99999     CYPRESS BOWL SOUTH   CA       49.383 -123.2  886  2007 2014
#> [1] NA
```

Damn. Didn't notice those other `CYPRESS BOWL`s. That's okay, I'll try again and there's two ways to get a year of its data (`2010`):

```R
library(pipeR)

cypress_bowl_snowboard_1 <- 
  get_ncdc_station_info(lower_lat = 49.000,
                        upper_lat = 49.500,
                        lower_lon = -123.500,
                        upper_lon = -123.000) %>>%
    select_ncdc_station(name = "cypress bowl snowboard") %>>%
    get_ncdc_station_data(startyear = 2010, endyear = 2010)
    
cypress_bowl_snowboard_2 <- 
  get_ncdc_station_info(lower_lat = 49.000,
                        upper_lat = 49.500,
                        lower_lon = -123.500,
                        upper_lon = -123.000) %>>%
    select_ncdc_station(name = "cypress bowl", number = 2) %>>%
    get_ncdc_station_data(startyear = 2010, endyear = 2010)
```

Both statements get the same met data (the `select_ncdc_station` function simply passes a `USAF`/`WBAN` string to `get_ncdc_station_data` via **pipeR**'s `%>>%` operator). Here's a bit of that met data:

```
head(cypress_bowl_snowboard_1)
```

```
  usaf_id  wban year month day hour minute    lat      lon elev wd ws 
1  715620 99999 2010     1  29    0      0 50.633 -128.117  568 NA NA
2  715620 99999 2010     1  29    6      0 50.633 -128.117  568 NA NA 
3  715620 99999 2010     1  29   12      0 50.633 -128.117  568 NA NA 
4  715620 99999 2010     1  29   18      0 50.633 -128.117  568 NA NA 
5  715620 99999 2010     1  30    0      0 50.633 -128.117  568 NA NA
6  715620 99999 2010     1  30    6      0 50.633 -128.117  568 NA NA

  ceiling_height temp dew_point atmos_pres   rh                time 
1             NA  1.3       0.3         NA 93.0 2010-01-28 16:00:00
2             NA  2.5      -0.7         NA 79.4 2010-01-28 22:00:00
3             NA  3.1      -3.2         NA 63.3 2010-01-29 04:00:00
4             NA  5.5      -6.4         NA 42.0 2010-01-29 10:00:00
5             NA  3.0       2.0         NA 93.1 2010-01-29 16:00:00
6             NA  1.5       1.0         NA 96.5 2010-01-29 22:00:00
```

Moving west, I think Tofino is nice. I'd like to get it's weather data. Let's just make sure we can target that station.

```R
library(pipeR)

get_ncdc_station_info() %>>%
  select_ncdc_station(name = "tofino")
```

```
#> Several stations matched. Provide a more specific search term.
#>         USAF  WBAN           NAME CTRY STATE    LAT      LON ELEV BEGIN  END
#> 15638 711060 94234 TOFINO AIRPORT   CA    BC 49.083 -125.767 24.0  1958 2015
#> 15639 711060 99999         TOFINO   CA       49.082 -125.773 24.4  2000 2004
#> 21397 741060 94234         TOFINO   CA       49.083 -125.767 20.0  1973 1977
#> 29273 999999 94234         TOFINO   CA       49.083 -125.767 24.1  1964 1972
#> [1] NA
```

Quite a few variants of the Tofino station. Let's choose the airport one. Seems to have a long record. It's the first one in that list. And I'd like the data from 2005 to 2010.

```R
library(pipeR)

tofino_airport_2005_2010 <- 
  get_ncdc_station_info() %>>%
    select_ncdc_station(name = "tofino", number = 1) %>>%
    get_ncdc_station_data(startyear = 2005, endyear = 2010)
```

That's gives you 34,877 rows of Tofino Airport meteorological data.

## Installation

Want to try this? Make sure you have **R**, then, use this:

```R
devtools::install_github('rich-iannone/stationaRy')
```

Thanks for installing. `:)`