library(tidyverse)
library(dplyr)
library(shiny)
library(readr)
library(sf)
library(lubridate)
library(RSocrata)
library(cowplot)
library(huxtable)

library(gridExtra)

install.packages("gridExtra")

setwd("C:/Users/jkkar/OneDrive - The Chicago Community Trust/Desktop/GitHubDesktop/final-project-james-emmanuel-oscar")

#creating path and reading in shapefiles and dataset (was losing data when reading in with API key)
path <- "C:/Users/jkkar/OneDrive - The Chicago Community Trust/Desktop/GitHubDesktop/final-project-james-emmanuel-oscar/Shapefiles/CTARailLines"

path_1 <- "C:/Users/jkkar/OneDrive - The Chicago Community Trust/Desktop/GitHubDesktop/final-project-james-emmanuel-oscar/Shapefiles/Boundaries - Planning Regions"

path_2 <- "C:/Users/jkkar/OneDrive - The Chicago Community Trust/Desktop/GitHubDesktop/final-project-james-emmanuel-oscar/Data"

train_shape <- st_read(file.path(path, "CTARailLines.shp"))

planning_regions_shape <- st_read(file.path(path_1, "geo_export_9c184723-9896-42c6-b7f7-717afc2a8bb1.shp"))

cta_el_monthly_rides_by_station <- read_csv(file.path(path_2, "CTA_-_Ridership_-__L__Station_Entries_-_Monthly_Day-Type_Averages___Totals.csv"))

#combining shapefiles for train stations and chicago regions to map
train_shape <- train_shape %>%
  rename("stationame" = "LONGNAME")

joined <- cta_el_monthly_rides_by_station %>%
  left_join(train_shape, by = "stationame")

joined_shape <- st_sf(joined, geometry = joined$geometry)

joined_shape[c('Month', 'Day', 'Year')] <- str_split_fixed(joined_shape$month_beginning, '/', 3)

joined_shape <- st_transform(joined_shape, 3857)

planning_regions_shape <- st_transform(planning_regions_shape, 3857)

region_joined_shape <- st_intersection(joined_shape, planning_regions_shape)

#Graphing monthly ridership by region for past 4 years:

options(scipen = 999)
monthly_rides_by_region <- region_joined_shape %>%
  filter(Year == "2019" | Year == "2020" | Year == "2021" | Year == "2022") %>%
  ggplot(aes(x = Month, y = monthtotal, fill = Year)) +
  geom_col(position = position_dodge()) +
  facet_wrap(vars(region_nam)) +
  labs(y = "Total Monthly Rides") +
  ggtitle("Monthly Ridership by Region")

save_plot("monthly_rides_by_region.png", monthly_rides_by_region)

# Function to map regional rides by input year:
region_rides <- region_joined_shape %>%
  select(stationame, monthtotal, Month, Year, LINES, region_nam) %>%
  st_set_geometry(NULL) %>%
  group_by(region_nam, Month, Year) %>%
  summarise(monthly_rides = sum(monthtotal))

annual_region_rides <- function(input_year) {
  
  region_df <- region_rides %>%
    filter(Year == input_year) %>%
    group_by(region_nam) %>%
    summarise(annual_total = sum(monthly_rides))
  
  region_df <- planning_regions_shape %>%
    left_join(region_df, by = "region_nam")
  
  ggplot() +
    geom_sf(data = region_df, aes(fill = annual_total)) +
    scale_fill_continuous(high = "#132B43", low = "#56B1F7") +
    ggtitle(paste0(input_year), " Total Rides By Region") +
    theme(rect = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank())
  
}


annual_2019_rides_by_region <- annual_region_rides(2019)
annual_2021_rides_by_region <- annual_region_rides(2021)


save_plot("annual_2019_rides_by_region.png", annual_2019_rides_by_region)
save_plot("annual_2021_rides_by_region.png", annual_2021_rides_by_region)

#manipulating data to show change in ridership by region 
#April through July between 2020 and 2022

region_rides_diff <- pivot_wider(
    region_rides,
    names_from = "Year",
    values_from = "monthly_rides"
    ) %>%
    filter(Month == "04" | Month == "05" | Month == "06" | Month == "07") %>%
    mutate(change_since_pandemic = `2022` - `2020`) %>%
    group_by(region_nam) %>%
    summarise(Rider_Increase = sum(change_since_pandemic))

region_rides_diff <- planning_regions_shape %>%
  left_join(region_rides_diff, by = "region_nam")


increase_in_rides_by_region <- ggplot() +
  geom_sf(data = region_rides_diff, aes(fill = Rider_Increase)) +
  scale_fill_continuous(high = "#132B43", low = "#56B1F7") +
  ggtitle("Increase in Total Rides By Region \n 2020 to 2022 | April - July") +
  theme(rect = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank())

save_plot("increase_in_rides_by_region.png", increase_in_rides_by_region)



#Running difference in difference between pre and post pandemic for North and Far South Regions:

ols_data <- region_rides %>%
  mutate(Month = as.numeric(Month), Year = as.numeric(Year)) %>%
  filter(region_nam == "NORTH" | region_nam == "FAR SOUTH") %>%
  filter(Year == 2019 & Month > 3 | Year == 2020 & Month < 3 | Year == 2020 & Month > 3 | Year== 2021 & Month < 5) %>%
  mutate(post = if_else(Year == 2019 & Month > 3 | Year == 2020 & Month < 3, 0, 1), 
         treatment = if_else(region_nam == "NORTH", 1, 0))

OLS <- lm(ols_data, formula = monthly_rides ~ post + treatment + post*treatment)
summary(OLS)
ols_summary <- huxtable::huxreg(OLS)

png("ols_summary.png")
p<-tableGrob(ols_summary)
grid.arrange(p)
dev.off()
