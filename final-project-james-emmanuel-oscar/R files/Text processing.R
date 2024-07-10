library(tidyverse)
library(tidytext)

rm(list = ls())
setwd("~/Documents/GitHub/final-project-james-emmanuel-oscar/Data")

#Using the comments on the complaints from the organization ctaction.org we are
#going to run a sentiment analysis and compare the differences between the two, 
#buses and trains. 

#separating buses and trains complaints from the excel file
complaints_buses <- readxl::read_excel("Aug-SeptCTAdata.xlsx", sheet = 1)
complaints_trains <- readxl::read_excel("Aug-SeptCTAdata.xlsx", sheet = 2)

#giving column names
colnames(complaints_buses) <- c("date", "route", "delay", "comments")
colnames(complaints_trains) <- c("date", "station", "region", "delay", "comments")

#around 50% of the complaints do not have a comment, so we will drop NAs from the
#comments and prepare the comments for the sentiment analysis

bus_comments <- complaints_buses %>% 
  drop_na(comments) %>%
  subset(select = -c(date, route, delay))

train_comments <- complaints_trains %>% 
  drop_na(comments) %>%
  subset(select = -c(date, station, region, delay))

#sentiment analysis for bus and train comments

cta_complaints <- list(bus_comments, train_comments)
text_complaints <- list()
tibble_complaints <- list()
word_tokens_cta_comp <- list()
no_sw_compl <- list()

for (i in seq_along(cta_complaints)) {
  text_complaints[[i]] <- paste(unlist(cta_complaints[[i]][["comments"]]), collapse =" ")
  tibble_complaints[[i]] <- tibble(text = text_complaints[[i]])
  word_tokens_cta_comp[[i]] <- unnest_tokens(tibble_complaints[[i]], word_tokens, text, token = "words")
  no_sw_compl[[i]] <- anti_join(word_tokens_cta_comp[[i]], stop_words, by = c("word_tokens" = "word"))
}

view(no_sw_compl[[2]])

no_sw_compl[[1]]$type <- "buses"
no_sw_compl[[2]]$type <- "trains"


#loading the sentiment analysis models
sentiment_nrc <- get_sentiments("nrc")
sentiment_afinn <- get_sentiments("afinn")
sentiment_bing <- get_sentiments("bing")

#adding the sentiment analysis models

complaints_nrc <- list()
complaints_afinn <- list()
complaints_bing <- list()

for (i in seq_along(no_sw_compl)) {
  complaints_nrc[[i]] <- left_join(no_sw_compl[[i]], sentiment_nrc, by = c("word_tokens" = "word"))
  complaints_afinn[[i]] <- left_join(no_sw_compl[[i]], sentiment_afinn, by = c("word_tokens" = "word"))
  complaints_bing[[i]] <- left_join(no_sw_compl[[i]], sentiment_bing, by = c("word_tokens" = "word"))
}

view(complaints_nrc[[2]])

plot_nrc <- rbind(complaints_nrc[[1]], complaints_nrc[[2]])
plot_afinn <- rbind(complaints_afinn[[1]], complaints_afinn[[2]])
plot_bing <- rbind(complaints_bing[[1]], complaints_bing[[2]])

#comparing results for both buses and trains

ggplot(data = filter(plot_nrc, !is.na(sentiment))) +
  geom_histogram(aes(sentiment, fill = type), position = "dodge", stat = "count") +
  scale_x_discrete(guide = guide_axis(angle = 45)) +
  labs(title = "NRC Analysis of Late Trains and Buses comments")

ggplot(data = filter(plot_afinn, !is.na(value))) +
  geom_histogram(aes(value, fill = type), position = "dodge", stat = "count") +
  scale_x_discrete(guide = guide_axis(angle = 45)) +
  labs(title = "Afinn Analysis of Late Trains and Buses comments")

ggplot(data = filter(plot_bing, !is.na(sentiment))) +
  geom_histogram(aes(sentiment, fill = type), position = "dodge", stat = "count") +
  scale_x_discrete(guide = guide_axis(angle = 45)) +
  labs(title = "Bing Analysis of Late Trains and Buses comments")





