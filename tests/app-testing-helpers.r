

# /////////////////////////////////////////////////////////////////////////////
## helper to set interactive testing of main App RFunction (e.g. in testthat 
## interactive mode,  on on any given script)
##
set_interactive_testing <- function(){
  
  source("RFunction.R")
  source("src/common/logger.R")
  source("src/io/app_files.R")
  
  Sys.setenv("APP_ARTIFACTS_DIR"="./data/output/")
  
  options(dplyr.width = Inf)
}






## /////////////////////////////////////////////////////////////////////////////
# helper to run SDK testing with different settings
run_sdk <- function(data,
                    local=FALSE,
                    local_details=FALSE,
                    sunriset=FALSE,
                    mean_solar=FALSE,
                    true_solar=FALSE){
  
  require(jsonlite)
  is.numeric(data) # little tripper to force error when object passed on to data doesn't exists
  
  # get environmental variables specified in .env
  dotenv::load_dot_env(".env")
  app_config_file <- Sys.getenv("CONFIGURATION_FILE")
  source_file <- Sys.getenv("SOURCE_FILE")
  
  # store default app configuration
  dflt_app_config <- jsonlite::fromJSON(app_config_file)
  # get default input data
  dflt_dt <- readRDS(source_file)
  
  # set configuration to specified inputs
  new_app_config <- dflt_app_config
  new_app_config$local <- local
  new_app_config$local_details <- local_details
  new_app_config$sunriset <- sunriset
  new_app_config$mean_solar <- mean_solar
  new_app_config$true_solar <- true_solar
  
  # overwrite config file with current inputs
  write(
    jsonlite::toJSON(new_app_config, pretty = TRUE, auto_unbox = TRUE), 
    file = app_config_file
  )
  
  # overwrite app's source file with current input data
  saveRDS(data, source_file)
  
  # run SDK for the current settings
  try(source("sdk.R"))
  
  # reset to default config and data
  write(
    jsonlite::toJSON(dflt_app_config,  pretty = TRUE, auto_unbox = TRUE), 
    file = app_config_file
  )
  saveRDS(dflt_dt, source_file)
  
  invisible()
}



