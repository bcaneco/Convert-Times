# Add Local and Solar Time

MoveApps

GitHub repository: *github.com/movestore/Convert-Times*

## Description
This App calculates local information about the time, including (i) the local timestamp and timezone, (ii) local time components, (iii) time of local sunrise and sunset, (iv) mean solar time and/or (v) true solar time. The values are added to the output and can be downloaded as a .csv artefact. 

## Documentation
The timestamp and location of each record in your data are used to calculate local timezones. Timezones are identified from longitute and latitude with the tz_lookup_coords() function of the [lutz](https://cran.r-project.org/web/packages/lutz/index.html) package and include Daylight Savings Time where applicable. In addition, the timestamps of sunrise and sunset of the day are provided (calculated with the sunriset function in the [maptools](https://cran.r-project.org/web/packages/maptools/index.html) package). For each local timestamp it is also possible to have the following time components extracted: date, time, year, month, Julian day, calender week, weekday. All calculations assume that the input data provide timestamp in UTC and locations in the WGS85 coordinate reference system.

It is also possible to calculate [solar times](https://en.wikipedia.org/wiki/Solar_time). It is possible to select mean and/or true (apparent) solar times. Mean solar time is approximated by adjustment of 3.989 min per degree from longitute zero. It approximates solar noon at clock noon to ~20 min accuracy. True solar time is then calculated from mean solar time by use of the equation of time (see [Yard et al., 2005](https://doi.org/10.1016/j.ecolmodel.2004.07.027)). The two solar time conversions are adapted from the function convert_UTC_to_solartime() in the R package [USGS-R/streamMetabolizer](https://github.com/USGS-R/streamMetabolizer) described in [Appling et al. (2018)](https://doi.org/10.1002/2017JG004140).

### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
`data_wtime.csv`: csv file of the complete dataset with the local time information added, based on the selected settings. All timestamps are provided in the format `yyyy-MM-dd HH:mm:ss`. The sunrise, sunset, mean solar and true solar times are reported in UTC. The sunrise and sunset are provided for the sunrise and sunset between which the local timestamp falls. The local time components are based on the local time.

### Settings
Local time (`local`): Checkbox to select if timestamps shall be converted to local times and added to the dataset. Defaults to FALSE.

Local time details (`local_details`): Checkbox to select if time components of the converted local times shall be added to the dataset. Defaults to FALSE.

Sunrise and sunset (`sunriset`): Checkbox to select if the time of local sunrise and sunset shall be added to the dataset. Defaults to FALSE.

Mean solar time (`mean_solar`): Checkbox to select if timestamps shall be converted to mean solar time and added to the dataset. Defaults to FALSE.

True solar time (`true_solar`): Checkbox to select if timestamps shall be converted to true solar time and added to the dataset. Defaults to FALSE.

### Null or error handling:
**Parameter `local`:** The default value FALSE will lead to no local times being added to the dataset. NULL is not possible.

**Parameter `local_detail`:** The default value FALSE will lead to no local time components being added to the dataset. NULL is not possible.

**Parameter `mean_solar`:** The default value FALSE will lead to no mean solar time being added to the dataset. NULL is not possible.

**Parameter `true_solar`:** The default value FALSE will lead to no true solar time being added to the dataset. NULL is not possible.

**Data:** The input dataset is not changed, but possibly extended by some attributes. If no time conversions are requested, the input dataset is returned. It cannot be empty.

