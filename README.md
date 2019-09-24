
<!-- README.md is generated from README.Rmd. Please edit that file -->

# stationaRy <a href='http://rich-iannone.github.io/stationaRy/'><img src="man/figures/logo.svg" align="right" height="250px" /></a>

[![CRAN
status](https://www.r-pkg.org/badges/version/stationaRy)](https://CRAN.R-project.org/package=stationaRy)
[![Travis-CI Build
Status](https://travis-ci.org/rich-iannone/stationaRy.svg?branch=master)](https://travis-ci.org/rich-iannone/stationaRy)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/rich-iannone/stationaRy?branch=master&svg=true)](https://ci.appveyor.com/project/rich-iannone/stationaRy)
[![Codecov test
coverage](https://codecov.io/gh/rich-iannone/stationaRy/branch/master/graph/badge.svg)](https://codecov.io/gh/rich-iannone/stationaRy?branch=master)

## Overview

Get meteorological data from met stations located all over the world.
That’s what you can do with this **R** package. There are *LOTS* of
stations too (29,729 available in this dataset) and many have data that
go pretty far back in time.

### Retrieving Met Data with a `station_id`

Let’s get some met data from La Guardia Airport in New York City (the
station ID value is `"725030-14732"`). This station has a pretty long
history (starting operations in 1973) but we’ll just obtain data from
the years of 2017 and 2018.

``` r
lga_met_data <- 
  get_met_data(
    station_id = "725030-14732",
    years = 2017:2018
  )
```

``` r
lga_met_data
#> # A tibble: 17,520 x 10
#>    id    time                 temp    wd    ws atmos_pres dew_point    rh
#>    <chr> <dttm>              <dbl> <dbl> <dbl>      <dbl>     <dbl> <dbl>
#>  1 7250… 2017-01-01 00:00:00   7.2   230   5.7      1012.      -4.4  43.5
#>  2 7250… 2017-01-01 01:00:00   7.8   230   4.6      1012.      -3.9  43.4
#>  3 7250… 2017-01-01 02:00:00   7.2   230   3.6      1012.      -2.2  51.3
#>  4 7250… 2017-01-01 03:00:00   7.8   240   5.7      1013.      -3.3  45.4
#>  5 7250… 2017-01-01 04:00:00   7.8   240   4.6      1013.      -3.9  43.4
#>  6 7250… 2017-01-01 05:00:00   8.3   240   4.6      1014.      -4.4  40.4
#>  7 7250… 2017-01-01 06:00:00   8.3   250   5.1      1015.      -3.9  41.9
#>  8 7250… 2017-01-01 07:00:00   8.3   260   5.7      1016.      -3.3  43.8
#>  9 7250… 2017-01-01 08:00:00   8.3   240   5.1      1017.      -2.8  45.5
#> 10 7250… 2017-01-01 09:00:00   8.3   260   6.2      1019.      -2.8  45.5
#> # … with 17,510 more rows, and 2 more variables: ceil_hgt <dbl>,
#> #   visibility <dbl>
```

### Discovering Met Stations

At a minimum we need a station’s identifier to obtain its met data. We
can start the process of getting an identifier by accessing the entire
catalog of station metadata with the `get_station_metadata()` function.
The output tibble has station `id` values in the first column. Let’s get
a subset of stations from that: those stations that are located in
Norway.

``` r
stations_norway <- 
  get_station_metadata() %>%
  dplyr::filter(country == "NO")

stations_norway
#> # A tibble: 405 x 16
#>    id    usaf  wban  name  country state icao    lat   lon  elev begin_date
#>    <chr> <chr> <chr> <chr> <chr>   <chr> <chr> <dbl> <dbl> <dbl> <date>    
#>  1 0100… 0100… 99999 BOGU… NO      <NA>  ENRS   NA   NA     NA   2001-09-27
#>  2 0100… 0100… 99999 JAN … NO      <NA>  ENJA   70.9 -8.67   9   1931-01-01
#>  3 0100… 0100… 99999 ROST  NO      <NA>  <NA>   NA   NA     NA   1986-11-20
#>  4 0100… 0100… 99999 SORS… NO      <NA>  ENSO   59.8  5.34  48.8 1986-11-20
#>  5 0100… 0100… 99999 BRIN… NO      <NA>  <NA>   61.4  5.87 327   1987-01-17
#>  6 0100… 0100… 99999 RORV… NO      <NA>  <NA>   64.8 11.2   14   1987-01-16
#>  7 0100… 0100… 99999 FRIGG NO      <NA>  ENFR   60.0  2.25  48   1988-03-20
#>  8 0100… 0100… 99999 VERL… NO      <NA>  <NA>   80.0 16.2    8   1986-11-09
#>  9 0100… 0100… 99999 HORN… NO      <NA>  <NA>   77   15.5   12   1985-06-01
#> 10 0100… 0100… 99999 NY-A… NO      <NA>  ENAS   78.9 11.9    8   1973-01-01
#> # … with 395 more rows, and 5 more variables: end_date <date>,
#> #   begin_year <int>, end_year <int>, tz_name <chr>, years <list>
```

This table can be even more greatly reduced to isolate the stations of
interest. For example, we could elect to get only high-altitude stations
(above 1000 meters) in Norway.

``` r
norway_high_elev <-
  stations_norway %>% 
  dplyr::filter(elev > 1000)

norway_high_elev
#> # A tibble: 12 x 16
#>    id    usaf  wban  name  country state icao    lat   lon  elev begin_date
#>    <chr> <chr> <chr> <chr> <chr>   <chr> <chr> <dbl> <dbl> <dbl> <date>    
#>  1 0122… 0122… 99999 MANN… NO      <NA>  <NA>   62.4  7.77 1294  2010-03-15
#>  2 0123… 0123… 99999 HJER… NO      <NA>  <NA>   62.2  9.55 1012  2010-09-07
#>  3 0134… 0134… 99999 MIDT… NO      <NA>  <NA>   60.6  7.27 1162  2011-11-25
#>  4 0135… 0135… 99999 FINS… NO      <NA>  <NA>   60.6  7.53 1208  2003-03-30
#>  5 0135… 0135… 99999 FINS… NO      <NA>  <NA>   60.6  7.5  1224  1973-01-02
#>  6 0135… 0135… 99999 SAND… NO      <NA>  <NA>   60.2  7.48 1250  2004-01-07
#>  7 0136… 0136… 99999 JUVV… NO      <NA>  <NA>   61.7  8.37 1894  2009-06-26
#>  8 0136… 0136… 99999 SOGN… NO      <NA>  <NA>   61.6  8    1413  1979-03-01
#>  9 0137… 0137… 99999 KVIT… NO      <NA>  <NA>   61.5 10.1  1028  1973-01-01
#> 10 0143… 0143… 99999 MIDT… NO      <NA>  <NA>   59.8  6.98 1081  1973-01-01
#> 11 0144… 0144… 99999 BLAS… NO      <NA>  <NA>   59.3  6.87 1105. 1973-01-01
#> 12 0146… 0146… 99999 GAUS… NO      <NA>  <NA>   59.8  8.65 1804. 2014-06-05
#> # … with 5 more variables: end_date <date>, begin_year <int>,
#> #   end_year <int>, tz_name <chr>, years <list>
```

The station IDs from the tibble can be transformed into a vector of
station IDs with `dplyr::pull()`.

``` r
norway_high_elev %>% dplyr::pull(id)
#>  [1] "012200-99999" "012390-99999" "013460-99999" "013500-99999"
#>  [5] "013510-99999" "013520-99999" "013620-99999" "013660-99999"
#>  [9] "013750-99999" "014330-99999" "014400-99999" "014611-99999"
```

Suppose you’d like to collect several years of met data from a
particular station and fetch only the observations that meet some set of
conditions. Here’s an example of obtaining temperatures above 15 degrees
Celsius from the high-altitude `"JUVVASSHOE"` station in Norway and
adding a column with temperatures in degrees Fahrenheit.

``` r
station_data <- 
  get_station_metadata() %>%
  dplyr::filter(name == "JUVVASSHOE") %>%
  dplyr::pull(id) %>%
  get_met_data(years = 2011:2019)

high_temp_data <-
  station_data %>%
  dplyr::select(id, time, wd, ws, temp) %>% 
  dplyr::filter(temp > 16) %>%
  dplyr::mutate(temp_f = ((temp * (9/5)) + 32) %>% round(1)) %>%
  dplyr::arrange(dplyr::desc(temp_f))
```

``` r
high_temp_data
#> # A tibble: 50 x 6
#>    id           time                   wd    ws  temp temp_f
#>    <chr>        <dttm>              <dbl> <dbl> <dbl>  <dbl>
#>  1 013620-99999 2019-07-26 15:00:00   160     5  18.5   65.3
#>  2 013620-99999 2019-07-26 17:00:00   210     3  18.4   65.1
#>  3 013620-99999 2019-07-26 18:00:00   180     2  18.3   64.9
#>  4 013620-99999 2019-07-26 16:00:00   180     4  18.2   64.8
#>  5 013620-99999 2014-07-23 16:00:00   270     2  17.6   63.7
#>  6 013620-99999 2019-07-26 14:00:00   150     4  17.5   63.5
#>  7 013620-99999 2014-07-23 17:00:00   300     4  17.3   63.1
#>  8 013620-99999 2019-07-28 16:00:00   130     6  17.3   63.1
#>  9 013620-99999 2014-07-23 18:00:00   280     3  17.2   63  
#> 10 013620-99999 2018-07-04 15:00:00   340     2  17.2   63  
#> # … with 40 more rows
```

### Additional Data Fields

There can be a substantial amount of additional met data beyond wind
speed, ambient temperature, etc. However, these additional fields can
vary greatly across stations. These nomenclature for the additional
categories of data uses ‘two-letter + digit’ identifiers (e.g., `AA1`,
`GA1`, etc.). Within each category are numerous fields, where the
variables are coded as `[identifer]_[index]`). More information about
these additional data fields can be found in [this PDF
document](http://www1.ncdc.noaa.gov/pub/data/ish/ish-format-document.pdf).

To find out which categories of additional data fields are available for
a station, we can use the `station_coverage()` function. You’ll get a
tibble with the available additional categories and their counts over
the specified period.

``` r
additional_data_fields <-
  get_station_metadata() %>%
  dplyr::filter(name == "JUVVASSHOE") %>%
  dplyr::pull(id) %>%
  station_coverage(years = 2015)
```

``` r
additional_data_fields
#> # A tibble: 87 x 3
#>    id           category count
#>    <chr>        <chr>    <int>
#>  1 013620-99999 AA1          0
#>  2 013620-99999 AB1          0
#>  3 013620-99999 AC1          0
#>  4 013620-99999 AD1          0
#>  5 013620-99999 AE1          0
#>  6 013620-99999 AG1          0
#>  7 013620-99999 AH1          0
#>  8 013620-99999 AI1          0
#>  9 013620-99999 AJ1        194
#> 10 013620-99999 AK1          0
#> # … with 77 more rows
```

We can use **purrr**’s `map_df()` function to get additional data field
coverage for a subset of stations (those that are near sea level and
have data in 2019). With the `station_coverage()` function set to output
tibbles in `wide` mode (one row per station, field categories as
columns, and counts of observations as values), we can ascertain which
stations have the particular fields we need.

``` r
stns <- 
  get_station_metadata() %>%
  dplyr::filter(country == "NO", elev <= 5 & end_year == 2019)

coverage_tbl <- 
  purrr::map_df(
    seq(nrow(stns)),
    function(x) {
      stns %>%
        dplyr::pull(id) %>%
        .[[x]] %>%
        station_coverage(
          years = 2019,
          wide_tbl = TRUE
        )
    }
  )
```

``` r
coverage_tbl
#> # A tibble: 16 x 88
#>    id       AA1   AB1   AC1   AD1   AE1   AG1   AH1   AI1   AJ1   AK1   AL1
#>    <chr>  <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int>
#>  1 01023…     0     0     0     0     0     0     0     0     0     0     0
#>  2 01046…     0     0     0     0     0     0     0     0     0     0     0
#>  3 01049…  5764     0     0     0     0     0     0     0     0     0     0
#>  4 01107…  1040     0     0     0     0     0     0     0     0     0     0
#>  5 01139…     0     0     0     0     0     0     0     0     0     0     0
#>  6 01146…  5967     0     0     0     0     0     0     0     0     0     0
#>  7 01162…     1     0     0     0     0     0     0     0     0     0     0
#>  8 01167…   374     0     0     0     0     0     0     0   122     0     0
#>  9 01217…     0     0     0     0     0     0     0     0     0     0     0
#> 10 01225…     0     0     0     0     0     0     0     0     0     0     0
#> 11 01234…  1039     0     0     0     0     0     0     0     0     0     0
#> 12 01290…     0     0     0     0     0     0     0     0     0     0     0
#> 13 01332…  6240     0     0     0     0     0     0     0     0     0     0
#> 14 01355…  6077     0     0     0     0     0     0     0     0     0     0
#> 15 01467…     0     0     0     0     0     0     0     0     0     0     0
#> 16 01476…     0     0     0     0     0     0     0     0     0     0     0
#> # … with 76 more variables: AM1 <int>, AN1 <int>, AO1 <int>, AP1 <int>,
#> #   AU1 <int>, AW1 <int>, AX1 <int>, AY1 <int>, AZ1 <int>, CB1 <int>,
#> #   CF1 <int>, CG1 <int>, CH1 <int>, CI1 <int>, CN1 <int>, CN2 <int>,
#> #   CN3 <int>, CN4 <int>, CR1 <int>, CT1 <int>, CU1 <int>, CV1 <int>,
#> #   CW1 <int>, CX1 <int>, CO1 <int>, CO2 <int>, ED1 <int>, GA1 <int>,
#> #   GD1 <int>, GF1 <int>, GG1 <int>, GH1 <int>, GJ1 <int>, GK1 <int>,
#> #   GL1 <int>, GM1 <int>, GN1 <int>, GO1 <int>, GP1 <int>, GQ1 <int>,
#> #   GR1 <int>, HL1 <int>, IA1 <int>, IA2 <int>, IB1 <int>, IB2 <int>,
#> #   IC1 <int>, KA1 <int>, KB1 <int>, KC1 <int>, KD1 <int>, KE1 <int>,
#> #   KF1 <int>, KG1 <int>, MA1 <int>, MD1 <int>, ME1 <int>, MF1 <int>,
#> #   MG1 <int>, MH1 <int>, MK1 <int>, MV1 <int>, MW1 <int>, OA1 <int>,
#> #   OB1 <int>, OC1 <int>, OE1 <int>, RH1 <int>, SA1 <int>, ST1 <int>,
#> #   UA1 <int>, UG1 <int>, UG2 <int>, WA1 <int>, WD1 <int>, WG1 <int>
```

For the `"KAWAIHAE"` station in Hawaii, some interesting data fields are
available. In particular, its `SA1` category provides sea surface
temperature data, where the `sa1_1` and `sa1_2` variables represent the
sea surface temperature and its quality code.

Combining the use of `get_met_data()` with functions from **dplyr**, we
can create a table of the mean ambient and sea-surface temperatures by
month. The additional data is included in the met data table by using
the `add_fields` argument and specifying the `"SA1"` category (multiple
categories can be included).

``` r
kawaihae_sst <- 
  get_met_data(
    station_id = "997173-99999",
    years = 2017:2018,
    add_fields = "SA1"
  ) %>%
  dplyr::mutate(
    year = lubridate::year(time),
    month = lubridate::month(time)
  ) %>%
  dplyr::filter(sa1_2 == 1) %>%
  dplyr::group_by(year, month) %>%
  dplyr::summarize(
    avg_temp = mean(temp, na.rm = TRUE),
    avg_sst = mean(sa1_1, na.rm = TRUE)
  )
```

``` r
kawaihae_sst
#> # A tibble: 6 x 4
#> # Groups:   year [2]
#>    year month avg_temp avg_sst
#>   <dbl> <dbl>    <dbl>   <dbl>
#> 1  2017    12     24.0    25.7
#> 2  2018     1     23.8    25.2
#> 3  2018     2     23.7    25.1
#> 4  2018     3     23.8    25.0
#> 5  2018     4     25.6    26.3
#> 6  2018    12     26.5    25.9
```

## Installation

To install the development version of **stationaRy**, use the following:

``` r
install.packages("devtools")
remotes::install_github("rich-iannone/stationaRy")
```

If you encounter a bug, have usage questions, or want to share ideas to
make this package better, feel free to file an
[issue](https://github.com/rich-iannone/stationaRy/issues).

## License

MIT © Richard Iannone
