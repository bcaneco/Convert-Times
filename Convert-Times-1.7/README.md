# Convert Times

MoveApps

GitHub repository: *github.com/movestore/Convert-Times*

## Description
This App converts the data timestamps to (i) local timezones (with savings time), (ii) details of local times, (iii) mean solar time and/or (iv) true solar time. The values are added to the output and can be downloaded as .csv artefact. 

## Documentation
All timestamps of your data are (by selection) converted to local timezones with savings time at the locations of the data. Timezones are extracted from longitute and latitude by the tz_lookup_coords() function of the lutz package. In addition, the timestamps of sunrise and sunset of the day are provided (calculated with sunriset of the package 'maptools'). For each local timestamp it is also possible to have the following time components extracted: date, time, year, month, Julian day, calender week, weekday.

It is also possible to extract solar times of the data's timestamps. It is possible to select for mean or true solar times. Mean solar time is approximated by adjustment of 3.989 min per degree from longitute zero. It approximates solar noon at clock noon to ~20 min accuracy. True solar time is then calculated from mean solar time by use of the equation of time (see Yard et al. 2005. Ecological Modelling). The two solar time conversions are adapted from the function convert_UTC_to_solartime() in the R-package "USGS-R/streamMetabolizer" by Alison Appling.

### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
`data_wtime.csv`: csv-file of the complete data set with the selected converted timestamps added.

### Parameters 
`local`: Checkbox to select if timestamps shall be converted to local times and added to the dataset. Defaults to FALSE.

`local_details`: Checkbox to select if time components of the converted local times shall be added to the dataset. Defaults to FALSE.

`mean_solar`: Checkbox to select if timestamps shall be converted to mean solar time and added to the dataset. Defaults to FALSE.

`true_solar`: Checkbox to select if timestamps shall be converted to true solar time and added to the dataset. Defaults to FALSE.

### Null or error handling:
**Parameter `local`:** The default value FALSE will lead to no local times being added to the dataset. NULL is not possible.

**Parameter `local_detail`:** The default value FALSE will lead to no local time components being added to the dataset. NULL is not possible.

**Parameter `mean_solar`:** The default value FALSE will lead to no mean solar time being added to the dataset. NULL is not possible.

**Parameter `true_solar`:** The default value FALSE will lead to no true solar time being added to the dataset. NULL is not possible.

**Data:** The input dataset is not changed, but possibly extended by some attributes. If no time conversions are requested, the input dataset is returned. It cannot be empty.
