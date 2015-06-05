<img src="inst/stationaRy_2x.png", width = 100%>

Want some tools to acquire and process meteorological and air quality monitoring station data? Well, you've come to the right repo. So far, because this is merely the beginning, there's really only one function that gets you data. It's `get_ncdc_station_data`. It basically gets you hourly met data from a met station. Located somewhere on earth. You need a station identifier (composed of the station's USAF and WBAN numbers, separated by a hyphen) to get the function to know from which station you'd like data. Provide a range of years with the `startyear` and `endyear` arguments.

Okay, okay... I know it's crude, but, it will get better. Soon, there'll be ways to query which stations are available. And when data is available. For now, however, that's just not there. There's a total absence of good user experience. `:(`
