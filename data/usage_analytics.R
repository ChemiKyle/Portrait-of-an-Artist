library(tidyverse)
library(jsonlite)
library(magrittr)
library(lubridate)
library(bit64) # timestamps are 64 bit ints
library(anytime)
library(zoo)
library(ggthemes)
library(plotly)


df <- file('annotation_1482644110969', open='r') %>%
  stream_in() %>%
  flatten()

# One timestamp in Unix ms, convert to human readable, adjust other to locale
df %<>%
  mutate(readingStartTime = anytime(as.integer64(annotationData.readingStartTime) / 1000), annotationData.readingStartTime = NULL,
         modificationDate = anytime(modificationDate),
         time_delta = modificationDate - readingStartTime) %>%
    group_by(contentReference.guid) %>%
    mutate(bookProgress = position.pos / max(position.pos)) # dangerously assumes each book is completely read

# TODO: table of ASIN to book title, sql w/ db to get authors

# Plot of times opened a book per month?
# Viz credit: https://stackoverflow.com/questions/49208138/ggplot-geom-bar-group-by-month-and-show-count
df %>%
  mutate(rst_ym = as.yearmon(readingStartTime),
         md_ym = as.yearmon(readingStartTime)) %>%
  group_by(rst_ym) %>%
  summarise(cnt = n()) %>%
  ggplot() +
  geom_bar(aes(x = (rst_ym), y = cnt), stat="identity") +
  scale_x_yearmon( n = 12*3) +
  theme_solarized_2()

# Playing around trying to understand how readingStartTime is determined
# Seems to only mark the beginning of an indepent session until the screen is turned off
df %>%
  ggplot() +
  geom_point(aes(x = readingStartTime, y = time_delta))

# Reading progress over time by book
p <- df %>%
  filter(!grepl("CR!", contentReference.guid)) %>% # get rid of non-book entires
  ggplot() +
  geom_line(aes(x = position.pos, y = modificationDate, color = contentReference.guid)) +
  theme_solarized_2() +
  theme(legend.position = "bottom") +
  labs(title = "Book Progress Over Time", x = "Characters Read", y = "Date")

# Interactive version of above plot
ggplotly(p)

# Same as above plot but scaled to characters(?) read
df %>%
    filter(!grepl("CR!", contentReference.guid)) %>% # get rid of non-book entires
    ggplot() +
    geom_line(aes(x = bookProgress, y = modificationDate, color = contentReference.guid)) +
    theme_solarized_2() +
    theme(legend.position = "bottom") +
    labs(title = "Book Progress Over Time", x = "Portion of Book Read", y = "Date")


# Non-converted interactive version of above plot
df %>%
  filter(!grepl("CR!", contentReference.guid)) %>% # get rid of non-book entires
    plot_ly(x = ~position.pos, y = ~modificationDate, color = ~contentReference.guid,
            type="scatter",
            hoverinfo="text",
            text = ~paste('Book: ', contentReference.guid,
                          '<br/>TDelta: ', time_delta))

df %>%
    filter(time_delta > 5)
