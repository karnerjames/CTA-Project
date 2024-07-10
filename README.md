# final-project-james-emmanuel-oscar
final-project-james-emmanuel-oscar created by GitHub Classroom

# Data and Programming for Public Policy II - R Programming PPHA 30536

## Final Project: Reproducible Research
## CTA Ridership changes in Chicago due to the COVID-19 pandemic

### James Karner, Oscar Cuadros and Emmanuel Hernandez

## Research Question

 *Were there variations in how CTA ridership was affected by the COVID-19 Pandemic throughout Chicago?*

During the lockdowns of the COVID-19 Pandemic in 2020, the CTA transportation system lost most of its users, compromising its feasibility and sustainability. The Pandemic also decreased the number of buses and train operators, which impacted the frequency and reliability of the system. There are 3,152 full-time bus operators and 741 rail operators, 108 fewer than at the start of the Pandemic. 

As ridership increases, many organizations and commuters have expressed frustration with the ghost buses and trains. We want to understand if these changes in ridership, decreasing during the Pandemic and increasing after, have been experienced across different parts in the city. 


## Approach and coding

Our analysis aims to provide further insight into how various regions of Chicago may have responded differently in ridership numbers on CTA buses and trains since the COVID-19 Pandemic. The data used in this analysis was pulled from the City of Chicago Data Portal. The CTA train ridership numbers were provided by CTA train stations, and the bus ridership by the route. However, due to the proximity of CTA train locations, in order to provide the best visual display of ridership trends for CTA trains, we utilized the Chicago planning regions map, which divides the city into seven areas (Central, Far South, Southeast, Southwest, West, Northwest, and North). The ridership data available for bus routes, on the other hand, was provided with shapefiles that map the entire bus route instead of individual bus stops. For these visuals, bus routes were mapped over the Chicago regions, and the routes were shaded on a color scale based on ridership numbers instead of the region area.

We used data from the Chicago Data Portal: 
  - Monthly Bus Ridership: https://data.cityofchicago.org/Transportation/CTA-Ridership-Bus-Routes-Monthly-Day-Type-Averages/bynn-gwxy
  - Monthly Train Ridership:https://data.cityofchicago.org/Transportation/CTA-Ridership-L-Station-Entries-Monthly-Day-Type-A/t2rn-p8d7 
  - Chicago Regions Shapefile:https://data.cityofchicago.org/Community-Economic-Development/Boundaries-Planning-Regions/spyv-p8fk
  - L Stops Shapefile: https://data.cityofchicago.org/Transportation/CTA-System-Information-List-of-L-Stops-Map/zbnc-zirh
  - Bus Stops Shapefile: https://data.cityofchicago.org/Transportation/CTA-Bus-Routes-Shapefile/d5bx-dr8z

CTAction.org for the text processing:
  - Late train and buses report: https://www.ctaction.org/reports

### Train Ridership Analysis

The CTA has data on ridership numbers all the way down to daily totals. It also provides the train line(s) that the station services and other identification information. Another factor for why we displayed ridership data by region instead of the train line was because many stations service a variety of lines, and there seems to be some potential for duplicates that may or not be accurate data. This was seen explicitly when combining the dataset that included rider numbers and the station shapefile dataset. The shapefile dataset had only 147 stations, and the rider dataset had 300. Many of these can be explained by old/closed stations that are no longer showing rider numbers. However, others that do have some rider numbers seem to be missing from the shapefile and are hence lost in our analysis. This would need  further investigation to identify why some stations are missing from the shapefile and its overall effect on the analysis. Addtionally, CTA Station locations might service areas outside of that station area (Belmont and Fullerton or Roosevelt), meaning that we do not know exactly where commuters are going to and from. Our analysis combined the train ridership dataset with the train station shapefile. Once we had the geometry with the train station ridership numbers, we were able to merge with the regaional area shapefile and include a column that indicated which region each station was in. This was used to both map data and eventually run our OLS analysis with.

Generally speaking, our analysis does not show a major difference between the regions in response to COVID-19 in ridership numbers. While there are variations between regions already experienced prior to the Pandemic, areas have all seemed to have responded in a similar way in ridership numbers since 2020. One way to provide further analysis beyond the overall number of riders would be to show the same analysis on the percentage change from 2020 to 2022 instead. This might show a more accurate depiction of the variation of change than the overall rider numbers. Still, both the bar graph showing changes from 2019 through 2022 and the map with variations of the same years appear to indicate any major differences in trends since the Pandemic by region. 


### Buses Ridership Analysis

The CTA bus ridership data is presented by the route. Routes can cross different regions and neighborhoods; therefore, we decided to analyze the routes on a region map and see if there were any differences by routes that might provide some insight into regional differences still. Similarly to trains, we do not have the information about the amount of people using buses at each stop of the routes and because these routes cross zones, actual rider differences between zones are hard to accurately capture and display. For the coding, the first step was to merge the routes with the ridership values. The variable "year" was type changed in different steps in order to plot it in different ways. Some observations were dropped out because they did not have data for the five years we analyzed. We needed to transform the data for the percentage and decile analysis. For plotting the data, we used a function to make it easier to select different years. 

Plots show us critical changes in ridership behavior during the Covid-19 Pandemic, especially between 2019 and 2020. Bus ridership decreased by around 50% in absolute terms, a tendency that an essential share of bus services shared. In a few cases, bus ridership grew but at low rates.However, ridership changes were not homogeneous across the city but heterogeneous and highly differentiated by regions. When analyzing percentile and decile changes over time, it is clear that northern routes were the most negatively impacted by the Covid-19 Pandemic in Chicago during 2019 and 2020. The first decile group (i.e., bus routes with the highest rates of ridership decrease) presented a range change of users from -800% to -300%. On the other hand, the 10th decile only changed from -64% to 13%. Northern bus routes are in the lowest deciles. 



### Complaints Analysis

CTA has a complaint system that is not available to the public. We looked for other sources of complaints as we were looking to analyze what commuters thought about the reduction of service in both trains and buses. CTAction.org is a non-profit that advocates for the improvement of the public transport system and, through their website, collect reports on late train and buses. We used a sample of those complaints from august to September 2020 that they published on their website. First, we tried to use web scrapping to collect the data, but because it was a hyperlink to a google drive file, we could only download it as an excel spreadsheet. We cleaned the data to only include the comments which were open text. Not all observations had comments, and some only had information about the route or station that had some late issues. 

In total, there are more train reports than buses, and we think this might be related to different commuters because the train only serves certain areas, and those areas could be more likely to use apps and websites for complaints. We ran the three sentiment analysis presented in class (NRC, AFINN, and BING). Although they were not extremely different, we included them all to support the idea that the differences in the number of complaints between buses and trains are not related to the transportation type. 

It is interesting that "anticipation" is the most common sentiment for both kinds of comments, and it shows the prevalence of time-related ideas expressed in these complaints. We might expect to see "sadness" and "trust" with high frequency, but it was surprising to see "anger" and "disgust" in the lower frequency sentiments. "Joy" and "positive" sentiments are frequent, and it might be the case that some sarcastic comments can be read as such. Future research might be worthy of understanding these models used and finding other models that fit better for this purpose. 

### OLS model

We will use a difference-in-difference method to estimate the impact of the Covid-19 pandemic between south and north regions (treatment) on train usage by citizens (outcome) betweem 2019 and 2020. Using official data, we created a dummy variable called “treatment,” which is 1 when the value represents a northern region and 0 when it means a southern one. Additionally, we created the variable “post,” that is, 1 when facing a Covid-19 period and 0 when having a pre-pandemic period. The interaction coefficient is represented by “treatment”*”post”.  As user-level trends in the last 20 years have not changed dramatically between regions, we argue that common trend assumption is accomplished. 

Formally,

Number_of_users = Intercept + B1(Treatment) + B2(Post) + B3(Treatment x Post) + error_term

Ceteris paribus, the North region had more than 2.7 million users than the South. We find both economically and statistically significant coefficients at 95% of confidence. Additionally, when we estimate its interaction during a pandemic period, it decreases to -2.2 million users, which is an economical and statistically significant coefficient too. This value is excellent proof of what we saw graphically in maps: the Northern side of Chicago was the most impacted by the Covid-19 pandemic. 

In conclusion, the Covid-19 pandemic directly affected the transportation system of Chicago as a whole, but some regions were critically affected compared with others. This brief study should be a starting point for future research regarding how the pandemic affected urban transportation in big cities.

