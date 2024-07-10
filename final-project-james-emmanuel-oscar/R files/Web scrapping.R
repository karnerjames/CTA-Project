library(tidyverse)
library(dplyr)
library(shiny)
library(readr)
library(RSocrata)

setwd("~/Documents/GitHub/final-project-james-emmanuel-oscar")

#buses and trains ridership
bus_monthly_rides_by_route <- read.socrata("https://data.cityofchicago.org/resource/bynn-gwxy.csv")
el_monthly_rides <- read.socrata("https://data.cityofchicago.org/resource/t2rn-p8d7.csv")

app_token = "McU7C6WWMLHTsRt7Qr2w32sFw"
email     = "gemmher@uchicago.edu"
secret_token  = "ASPmemRsb6QXFfhMR2zbM_etGJ3zbfhGHO2s" 

#Map Folders (shapefiles)
#Chicago Regions: "Boundaries - Planning Regions"
#Bus Routes:      "CTA_BusRoutes__2_" 
#Train Stops:     "CTARailLines"
