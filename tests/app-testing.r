# ------------------------- #
#         Preamble
# ------------------------- #

library(fs)
library(move2)
library(purrr)
library(readr)

# Helpers
source("tests/app-testing-helpers.r")

# Read input datasets for testing
data_path <- "data/raw/"
input_files <- fs::dir_ls(path = data_path, regexp = ".rds") 
test_inputs <- purrr::map(input_files, readRDS)

names(test_inputs) <- basename(path_ext_remove(input_files))


# ---------------------------------------- #
# ----   Interactive RFunction testing  ----
# ---------------------------------------- #

# set up local environment to run RFunction interactively
set_interactive_testing()

output <- rFunction(
  data = test_inputs$input1_move2loc_LatLon, 
  local = TRUE, 
  sunriset = TRUE, 
  mean_solar = TRUE, 
  true_solar = TRUE
)

output$timestamp_local


output <- rFunction(
  data = test_inputs$input1_move2loc_Mollweide, 
  local = TRUE, 
  sunriset = TRUE, 
  mean_solar = TRUE, 
  true_solar = TRUE
)

output


# ---------------------------------------- #
# ----    Automated Unit testing        ----
# ---------------------------------------- #

testthat::test_file("tests/testthat/test_RFunction.R")



# ---------------------------------------- #
# ----    MoveApps SDK testing          ----
# ---------------------------------------- #

# -- I/O are move2 objects
mt_is_move2(test_inputs$input4_move2loc_LatLon)

run_sdk(
  data = test_inputs$input4_move2loc_LatLon, 
  sunriset = TRUE
)

output <- readRDS("data/output/output.rds"); 
mt_is_move2(output)


# -- Local timestamp
run_sdk(
  data = test_inputs$input4_move2loc_LatLon, 
  local = TRUE
)

output <- readRDS("data/output/output.rds"); output
output$local_tz[1:100]
output$timestamp_local[1:100]


# -- No selection
run_sdk(data = test_inputs$input4_move2loc_LatLon)
output <- readRDS("data/output/output.rds"); output
read_csv("data/output/data_wtime.csv")

# -- true solar, sunrise and sunset timestamps
run_sdk(
  data = test_inputs$input2_move2loc_LatLon, 
  sunriset = TRUE,
  true_solar = TRUE
)

output <- readRDS("data/output/output.rds"); output
"timestamp_mean_solar" %in% names(output) # mean solar not selected so shouldn't be present in output

