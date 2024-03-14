library(move2)
library(withr)
library(rlang)
library(lubridate)

if(rlang::is_interactive()){
  library(testthat)
  source("tests/app-testing-helpers.r")
  set_interactive_testing()
  
}

# Load test data
input1 <- readRDS(test_path("../../data/raw/input1_move2loc_LatLon.rds"))
input1_Moll <- readRDS(test_path("../../data/raw/input1_move2loc_Mollweide.rds"))
input3 <- readRDS(test_path("../../data/raw/input3_move2loc_LatLon.rds"))


test_that("Output complies with input selections", {
  
  withr::local_envvar("APP_ARTIFACTS_DIR"="../../data/output/")
  
  # local time
  out <- rFunction(data = input1, local = TRUE)  
  expect_contains(names(out), c("timestamp_local", "local_tz"))
  expect_false(any(c("timestamp_true_solar", "timestamp_mean_solar", "sunrise_timestamp") %in% names(out)))
  
  # sunrise and sunset timestamps
  out <- rFunction(data = input3, sunriset = TRUE)  
  expect_contains(names(out), c("sunrise_timestamp", "sunset_timestamp"))
  expect_false(any(c("timestamp_true_solar", "timestamp_mean_solar", "timestamp_local") %in% names(out)))
  
  
  # local time details and mean solar timestamps
  out <- rFunction(data = input1, local_details = TRUE, mean_solar = TRUE)  
  expect_contains(names(out), c("timestamp_mean_solar", "yday", "weekday", "date", "local_tz"))
  expect_false(any(c("timestamp_true_solar", "sunrise_timestamp") %in% names(out)))
  
  # No selections
  out <- rFunction(data = input3) 
  expect_equal(ncol(input3), ncol(out))
  
})



test_that("App handles data with projected locations correctly", {
  
  withr::local_envvar("APP_ARTIFACTS_DIR"="../../data/output/")
  
  out_latlon <- rFunction(data = input1, local = TRUE, sunriset = TRUE, mean_solar = TRUE)
  out_Mollweide_proj <- rFunction(data = input1_Moll, sunriset = TRUE,local = TRUE,  mean_solar = TRUE) 
  
  expect_equal(out_latlon$local_tz, out_Mollweide_proj$local_tz)
  expect_equal(out_latlon$timestamp_local, out_Mollweide_proj$timestamp_local)
  expect_equal(out_latlon$timestamp_mean_solar, out_Mollweide_proj$timestamp_mean_solar)
  expect_equal(out_latlon$sunrise_timestamp, out_Mollweide_proj$sunrise_timestamp)
  expect_equal(out_latlon$sunset_timestamp, out_Mollweide_proj$sunset_timestamp)
})




test_that("App handles locations falling in geo-political disputed areas", {
  
  withr::local_envvar("APP_ARTIFACTS_DIR"="../../data/output/")
  
  expect_warning(
    out <- rFunction(data = input3, local = TRUE),
    regexp = "Some points are in areas with more than one time zone defined"
  )
  
  expect_true(sum(is.na(out$local_tz)) == 0)
})



test_that("Expected local timezone is attributed", {
  
  withr::local_envvar("APP_ARTIFACTS_DIR"="../../data/output/")
  
  out <- rFunction(data = input1, local = TRUE)
  expect_true(lubridate::tz(out$timestamp_local) == "Europe/Rome")
  
  
})



test_that("Sunset, Sunrise, mean solar and true solar timestamps are provided in UTC", {
  
  withr::local_envvar("APP_ARTIFACTS_DIR"="../../data/output/")
  
  out <- rFunction(data = input1, sunriset = TRUE, mean_solar = TRUE, true_solar = TRUE)
  
  expect_true(lubridate::tz(out$sunrise_timestamp) == "UTC")
  expect_true(lubridate::tz(out$sunset_timestamp) == "UTC")
  expect_true(lubridate::tz(out$timestamp_mean_solar) == "UTC")
  expect_true(lubridate::tz(out$timestamp_true_solar) == "UTC")

})
