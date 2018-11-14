library(tidyverse)
library(jsonlite)
library(magrittr)
library(lubridate)
library(bit64) # timestamps are 64 bit ints
library(anytime)
library(zoo)
library(ggthemes)

df <- file('annotation_1482644110969', open='r') %>%
  stream_in() %>%
  flatten()

# One timestamp in Unix ms, convert to human readable, adjust other to locale
df %<>%
  mutate(readingStartTime = anytime(as.integer64(annotationData.readingStartTime) / 1000),
         modificationDate = anytime(modificationDate))

# Plot of times opened a book per month?
# https://stackoverflow.com/questions/49208138/ggplot-geom-bar-group-by-month-and-show-count
df %>%
  mutate(rst_ym = as.yearmon(readingStartTime),
         md_ym = as.yearmon(readingStartTime)) %>%
  group_by(rst_ym) %>%
  summarise(cnt = n()) %>%
  ggplot() +
  geom_bar(aes(x = (rst_ym), y = cnt), stat="identity") +
  scale_x_yearmon( n = 12*3) +
  theme_solarized_2()

