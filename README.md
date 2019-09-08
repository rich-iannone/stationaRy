
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Travis-CI Build
Status](https://travis-ci.org/rich-iannone/stationary.svg?branch=master)](https://travis-ci.org/rich-iannone/stationary)

# stationary <img src="man/figures/logo.svg" align="right" height="250px" />

Get hourly meteorological data from met stations all over the world.
That’s what you can do with this **R** package. There are *LOTS* of
stations too (29,729 available in this dataset) and many have data that
goes way back.

Let’s get some met data from La Guardia Airport\! (the ID value for that
one is `"725030-14732"`). This station has a pretty long history
(starting operations in 1973) but we’ll just grab data from the years of
2017 and 2018.

``` r
lga_met_data <- 
  get_met_data(
    station_id = "725030-14732",
    years = 2017:2018
  )
```

``` r
lga_met_data
#> # A tibble: 28,262 x 9
#>    id    time                   wd    ws ceil_hgt  temp dew_point
#>    <chr> <dttm>              <int> <dbl>    <int> <dbl>     <dbl>
#>  1 7250… 2017-01-01 00:51:00   230   4.6     1402   7.8      -3.9
#>  2 7250… 2017-01-01 01:00:00   230   4.6       NA   7.8      -3.9
#>  3 7250… 2017-01-01 01:51:00   230   3.6     2591   7.2      -2.2
#>  4 7250… 2017-01-01 02:51:00   240   5.7     3048   7.8      -3.3
#>  5 7250… 2017-01-01 03:51:00   240   4.6    22000   7.8      -3.9
#>  6 7250… 2017-01-01 04:00:00   240   4.6       NA   7.8      -3.9
#>  7 7250… 2017-01-01 04:51:00   240   4.6     1524   8.3      -4.4
#>  8 7250… 2017-01-01 05:51:00   250   5.1    22000   8.3      -3.9
#>  9 7250… 2017-01-01 06:51:00   260   5.7    22000   8.3      -3.3
#> 10 7250… 2017-01-01 07:00:00   260   5.7       NA   8.3      -3.3
#> # … with 28,252 more rows, and 2 more variables: atmos_pres <dbl>,
#> #   rh <dbl>
```

There are lots of stations and we at least need an identifier to access
the met data. We can examine station metadata using the
`get_station_metadata()` function (which has those ID values in the
first column). Let’s get all of the stations located in Norway.

``` r
stations_norway <- 
  get_station_metadata() %>%
  filter(country == "NO")

stations_norway
#> # A tibble: 405 x 15
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
#> # … with 395 more rows, and 4 more variables: end_date <date>,
#> #   begin_year <int>, end_year <int>, tz_name <chr>
```

This table can be greatly reduced to isolate the stations of interest.
For example, with `dplyr::filter()` we could get only high-altitude
stations (above 1000 meters) in Norway.

``` r
norway_high_elev <-
  stations_norway %>% 
  filter(elev > 1000)

norway_high_elev
#> # A tibble: 12 x 15
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
#> # … with 4 more variables: end_date <date>, begin_year <int>,
#> #   end_year <int>, tz_name <chr>
```

The station IDs from the tibble can be transformed into a vector of
station IDs with `dplyr::pull()`.

``` r
norway_high_elev %>% pull(id)
#>  [1] "012200-99999" "012390-99999" "013460-99999" "013500-99999"
#>  [5] "013510-99999" "013520-99999" "013620-99999" "013660-99999"
#>  [9] "013750-99999" "014330-99999" "014400-99999" "014611-99999"
```

Suppose you’d like to collect several years of met data from a
particular station and get only a listing of parameters that meet some
criterion. Here’s an example of obtaining temperatures above 15 degrees
Celsius from the high-altitude `"JUVVASSHOE"` station in Norway:

``` r
station_data <- 
  get_station_metadata() %>%
  filter(name == "JUVVASSHOE") %>%
  pull(id) %>%
  get_met_data(years = 2011:2019)

high_temp_data <-
  station_data %>%
  select(id, time, wd, ws, temp) %>% 
  filter(temp > 16) %>%
  mutate(temp_f = ((temp * (9/5)) + 32) %>% round(1)) %>%
  arrange(desc(temp_f))
```

``` r
high_temp_data
#> # A tibble: 50 x 6
#>    id           time                   wd    ws  temp temp_f
#>    <chr>        <dttm>              <int> <dbl> <dbl>  <dbl>
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

There can actually be a lot of additional met data beyond wind speed,
temperatures, etc. It can vary greatly depending on the selected
station. These additional categories are denoted ‘two-letter + digit’
identifiers (e.g., `AA1`, `GA1`, etc.). Within each category are
numerous variables (coded as `[identifer]_[index]`). More information
about these variables can be found in [this PDF
document](http://www1.ncdc.noaa.gov/pub/data/ish/ish-format-document.pdf).

To find out which categories of additional met fields are available for
a station, use the `station_coverage()` function. You’ll get a tibble
with the available additional categories and their counts over the
specified period.

``` r
# Get information on which additional met data
# fields are available at the Juvvasshoe station
additional_data_fields <-
  get_station_metadata() %>%
  filter(name == "JUVVASSHOE") %>%
  pull(id) %>%
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
  filter(country == "NO", elev <= 5 & end_year == 2019)

coverage_tbl <- 
  purrr::map_df(
    seq(nrow(stns)),
    function(x) {
      stns %>%
        pull(id) %>%
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
#>  3 01049…  5409     0     0     0     0     0     0     0     0     0     0
#>  4 01107…   976     0     0     0     0     0     0     0     0     0     0
#>  5 01139…     0     0     0     0     0     0     0     0     0     0     0
#>  6 01146…  5620     0     0     0     0     0     0     0     0     0     0
#>  7 01162…     1     0     0     0     0     0     0     0     0     0     0
#>  8 01167…   347     0     0     0     0     0     0     0   120     0     0
#>  9 01217…     0     0     0     0     0     0     0     0     0     0     0
#> 10 01225…     0     0     0     0     0     0     0     0     0     0     0
#> 11 01234…   975     0     0     0     0     0     0     0     0     0     0
#> 12 01290…     0     0     0     0     0     0     0     0     0     0     0
#> 13 01332…  5859     0     0     0     0     0     0     0     0     0     0
#> 14 01355…  5701     0     0     0     0     0     0     0     0     0     0
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
# Get the average ambient temperature and the
# average sea-surface temperatures (sst) from
# the "KAWAIHAE" station for every available month
kawaihae_sst <- 
  get_met_data(
    station_id = "997173-99999",
    years = 2017:2018,
    add_fields = "SA1"
  ) %>%
  mutate(
    year = lubridate::year(time),
    month = lubridate::month(time)
  ) %>%
  filter(sa1_2 == 1) %>%
  group_by(year, month) %>%
  summarize(
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

To install the development version of **stationary**, use the following:

``` r
remotes::install_github("rich-iannone/stationary")
```

## Code of Conduct

Please note that the ‘stationary’ project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to
this project, you agree to abide by its terms.

## License

MIT © Richard Iannone
