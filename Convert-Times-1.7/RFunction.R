library('move')
library('lubridate')
library('lutz')
library('sf')
library('maptools')

rFunction <- function(data,local=FALSE,local_details=FALSE,mean_solar=FALSE,true_solar=FALSE)
{

  Sys.setenv(tz="UTC")
  
  if (local==FALSE & local_details==FALSE & mean_solar==FALSE & true_solar==FALSE) logger.info("You have not selected any timestamp conversion. The original dataset will be returned and provided as csv output.")
  
  data.csv <- as.data.frame(data)
  names(data.csv) <- make.names(names(data.csv),allow_=FALSE)
  location.long <- coordinates(data)[,1]
  location.lat <- coordinates(data)[,2]
  if (("individual.taxon.canonical.name" %in% names(data.csv))==FALSE & "taxon.canonical.name" %in% names(data.csv)) names(data.csv)[which(names(data.csv)=="taxon.canonical.name")] <- "individual.taxon.canonical.name"
  if (("location.long" %in% names(data.csv))==FALSE) data.csv <- data.frame(data.csv,location.long,location.lat)
  
  other_names <- which(names(data.csv) %in% c("trackId","timestamp","location.long","location.lat","sensor","individual.taxon.canonical.name")==FALSE)
  data.csv <- cbind(data.csv[c("trackId","timestamp","location.long","location.lat","sensor","individual.taxon.canonical.name")],data.csv[,other_names])
  
  # add sunrise and sunset times of the day
  sunrise_timestamp <- sunriset(coordinates(data),timestamps(data),direction="sunrise",POSIXct.out=TRUE)$time
  sunset_timestamp <- sunriset(coordinates(data),timestamps(data),direction="sunset",POSIXct.out=TRUE)$time 
  
  data@data <- cbind(data@data,sunrise_timestamp,sunset_timestamp)
  data.csv <- cbind(data.csv,sunrise_timestamp,sunset_timestamp)
  
  # ask the cache and/or Google for the timezone at these coordinates
  tz_info <- tz_lookup_coords(coordinates(data)[,2], coordinates(data)[,1], method = "accurate")
  
  #return in daylight local
  if(local==TRUE) 
  {
    logger.info("You have selected to add local timestamps.")
    timestamp_local <- apply(data.frame(timestamps(data),tz_info), 1, function(x) as.character(lubridate::with_tz(x[1], x[2])))
    data@data <- cbind(data@data,timestamp_local,"local_tz"=tz_info)
    data.csv <- cbind(data.csv,timestamp_local,"local_timezone"=tz_info)
  }
  if (local_details==TRUE)
  {
    logger.info("You have selected to add detailed time information of the local timestamps.")
    timestamp_local <- apply(data.frame(timestamps(data),tz_info), 1, function(x) as.character(lubridate::with_tz(x[1], tzone=x[2])))
    timestamp_local[which(nchar(timestamp_local)==10)] <- paste(timestamp_local[which(nchar(timestamp_local)==10)],"00:00:00") #adapt midnight format
    timestamp_local_PX <- as.POSIXct(timestamp_local,format="%Y-%m-%d %H:%M:%S") #note that UTC here is technically not correct, but this way can calculate local time details
    date <- as.Date(timestamp_local_PX)
    
    time <- strftime(timestamp_local_PX, format="%H:%M:%S")
    year <- year(timestamp_local_PX)
    month <- months(as.POSIXct(timestamp_local_PX))
    yday <- as.numeric(strftime(timestamp_local_PX, format = "%j"))
    calender_week <- as.numeric(strftime(timestamp_local_PX, format = "%V"))
    weekday <- weekdays(as.POSIXct(timestamp_local_PX))
    data@data <- cbind(data@data,date,time,year,month,weekday,yday,calender_week)
    data.csv <- cbind(data.csv,date,time,year,month,weekday,yday,calender_week)
  }
  if (mean_solar==TRUE)
  {
    logger.info("You have selected to add mean solar time timestamps.")
    # reference to convert_UTC_to_solartime function by Alison Appling (USGS)
    time.adjustment <- 239.34 * coordinates(data)[,1] #in secs --> 3.989 minutes = 239.34 seconds per degree
    timestamp_mean_solar <- as.character(timestamps(data) + as.difftime(time.adjustment,units="secs")) #add seconds to the UTC time
    data@data <- cbind(data@data,timestamp_mean_solar)
    data.csv <- cbind(data.csv,timestamp_mean_solar)
  }
  if (true_solar==TRUE)
  {
    logger.info("You ahve selected to add true solar time timestamps.")
    time.adjustment <- 239.34 * coordinates(data)[,1] #in secs --> 3.989 minutes = 239.34 seconds per degree
    timestamp_mean_solar <- timestamps(data) + as.difftime(time.adjustment,units="secs") #add seconds to the UTC time
    # Use the equation of time to compute the discrepancy between apparent and
    # mean solar time. E is in minutes.
    jday <- as.numeric(strftime(timestamp_mean_solar, format = "%j")) -1
    E <- 9.87*sin(((2*360*(jday-81))/365)/180*pi) - 7.53*cos(((360*(jday-81))/365)/180*pi) - 1.5*sin(((360*(jday-81))/365)/180*pi)
    timestamp_true_solar <- timestamp_mean_solar + as.difftime(E,units="mins")
    data@data <- cbind(data@data,timestamp_true_solar)
    data.csv <- cbind(data.csv,timestamp_true_solar)
  }    

  write.csv(data.csv, file = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"data_wtime.csv"),row.names=FALSE)
  #write.csv(data.csv, file = "data_wtime.csv",row.names=FALSE)
  
  result <- data
  return(result)
}

  
  
  
  
  
  
  
  
  
  
