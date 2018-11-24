library(tidyverse)
library(jsonlite)
library(magrittr)
library(lubridate)
library(bit64) # timestamps are 64 bit ints
library(anytime)
library(zoo)
library(ggthemes)
library(plotly)

annot_file = 'parsed_annotation.jsonl'

df <- file(annot_file, open='r') %>%
  stream_in() %>%
  flatten()
closeAllConnections()

# One timestamp in Unix ms, convert to human readable, adjust other to locale
df %<>%
  mutate(readingStartTime = anytime(as.integer64(annotationData.readingStartTime) / 1000), annotationData.readingStartTime = NULL,
         modificationDate = anytime(modificationDate),
         sinceStart = modificationDate - readingStartTime) %>%
    group_by(contentReference.guid) %>%
    mutate(bookProgress = position.pos / max(position.pos), # dangerously assumes each book is completely read
           bookStarted = min(readingStartTime, na.rm = T),
           title = sub("^(.+):.+$", "\\1", gsub("_+", " ", contentReference.guid), perl = T))


# In 2 years of not connnecting to wifi, the device is ahead by ~ 4h45m
# Clocked at 4.748562 hours on 11/15
# Better clocked at ~ 4.87 hours on 11/16
t_delta <- make_difftime(hour = 4.87)

# ~ 0.0172 minutes added per minute on 11/15
difftime(max(df$modificationDate), min(df$modificationDate), units="hours")

df$modificationDate <- df$modificationDate - t_delta

# scrape in character counts, combine with df
ccdf <- read.table('kindle_counts.tsv', sep = '\t', header=T)

df %<>%
    merge(ccdf %>% mutate(title = substr(title, 1, 31)),
          by = "title",
          all.x=T) %>%
    mutate(bookProgress = position.pos/book_count)

# Optional manipulation pipeline to add significant date ranges
df %<>% mutate(sig_date = dplyr::case_when(
  modificationDate <= as.Date("2017-08-11") ~ "Range 1",
  modificationDate >= as.Date("2017-08-12") & modificationDate < as.Date("2017-12-15") ~ "Range 2",
  modificationDate >= as.Date("2017-12-15") & modificationDate <= as.Date("2018-05-07") ~ "Range 3",
  modificationDate > as.Date("2018-05-07") ~ "Range 4",
  T ~ "error"
)
)


# TODO: table of ASIN to book title, right join w/ db to get authors
# Possibly query calibre metadata?

# Plot of times opened a book per month(?)
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

# Plot actions by weekday
df %>%
  group_by(wday(modificationDate)) %>%
  mutate(mod_count = n()) %>%
  ggplot(aes(x = wday(modificationDate, label = T), y = mod_count, fill = wday(modificationDate))) +
  geom_bar(stat = "identity", position="dodge") +
  labs(title = "Recorded actions by Weekday",
       x = "Weekday",
       y = "Total Actions")

# leftover debug
df_alter <- df %>%
  filter(modificationDate > as.Date("2018-11-10")) %>%
  mutate(H = hour(modificationDate), weekday = wday(modificationDate, label = T)) %>%
  filter(weekday != "Sun" & weekday != "Sat") %>%
  group_by(H) %>%
  mutate(mod_count = n()) %>%
  ungroup() %>%
  select(modificationDate, H, title, mod_count, weekday) %>%
  dplyr::arrange(H)

# Plot actions by hour of day
# Credit for AM/PM formatting: https://stackoverflow.com/questions/18510271/convert-24h-to-am-pm-format?rq=1
df %>%
  mutate(H = hour(modificationDate)) %>%
  group_by(sig_date, H) %>%
  mutate(mod_count = n()) %>%
  ungroup() %>% group_by(sig_date) %>%
  mutate(mod_count = mod_count / max(mod_count)) %>%
  ggplot(aes(x = H, y = mod_count, fill = sig_date)) +
  geom_bar(stat = "identity", position="dodge") +
  theme_solarized_2() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
  scale_x_continuous(limits=c(0,24),
                     breaks=0:12*2,
                     labels=c(paste(0:5*2,"AM"),
                              "12 PM",
                              paste(7:11*2-12,"PM"), 
                              "0 am")) +
    labs(title = "Scaled Reading Actions by Hour", x = "Hour", y = "Action Count")

# Playing around trying to understand how readingStartTime is determined
# Seems to only mark the beginning of an indepent session until the screen is turned off
df %>%
  ggplot() +
  geom_point(aes(x = readingStartTime, y = sinceStart))

# Reading progress over time by book
p <- df %>%
  filter(!grepl("CR!", title)) %>% # get rid of non-book entires
  ggplot() +
  geom_point(aes(x = position.pos, y = modificationDate, color = title)) +
  theme_solarized_2() +
  theme(legend.position = "bottom") +
  labs(title = "Book Progress Over Time", x = "Characters Read", y = "Date")

p
# Interactive version of above plot
ggplotly(p)

# Same as above plot but scaled to characters(?) read
df %>%
    filter(!grepl("CR!", title)) %>% # get rid of non-book entires
    ggplot() +
    geom_point(aes(x = bookProgress, y = modificationDate, color = title)) +
    theme_solarized_2() +
    theme(legend.position = "bottom") +
    labs(title = "Book Progress Over Time", x = "Portion of Book Read", y = "Date")


# Non-converted interactive version of above plot where I also play with sinceStart
df %>%
  filter(!grepl("CR!", title)) %>% # get rid of non-book entires
    plot_ly(x = ~bookProgress, y = ~modificationDate, color = ~title,
            type="scatter",
            hoverinfo="text",
            text = ~paste('Book: ', title,
                          '<br/>TDelta: ', bookProgress))

# Help see books I didn't get very far in (x ~= y)
df %>%
  group_by(title) %>%
  mutate(lastRead = max(modificationDate)) %>%
  ggplot() +
  geom_point(aes(x = bookStarted, y = lastRead, color = title))

# Comparisons of authors
df %>%
    mutate(ym  = as.yearmon(modificationDate)) %>%
    group_by(author) %>%
    mutate(mod_count = n()) %>%
    ggplot() +
    geom_bar(aes(x = ym, y = mod_count, fill = author), stat="identity") +
    scale_x_yearmon(n = 12*3)
