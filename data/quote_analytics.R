library(dplyr)
library(ggplot2)
library(lubridate)
library(ggthemes)
library(sentimentr)
library(RSQLite)

# Linux
setwd("/home/kyle/projects/Portrait-of-an-Artist/data/")
#Windows
setwd("kyle_analytics/Portrait-of-an-Artist/data/")
con <- dbConnect(RSQLite::SQLite(), dbname='quotes.db')
df <- dbGetQuery(conn=con, statement = ("SELECT * FROM quotes;"))
dbDisconnect(con)

df_sent <- df %>%
  rowwise() %>%
  mutate(sentiment = sum(sentiment(get_sentences(as.character(quote)))[,4]))

df <- df_sent

#write.table(df, file = 'quote_and_sentiment.tsv', sep='\t')

#df <- read.table("quote_and_sentiment.tsv", sep = '\t', header = TRUE)
df <- df %>% mutate(num_characters = nchar(as.character(quote)),
                    timestamp = as.POSIXct(timestamp, format='%A, %B %d, %Y %r'))

qplot(df$sentiment[abs(df$sentiment) > 0.5], bins = 20)

ggplot(df, aes(x = hour(timestamp), y = author)) +
  geom_bin2d() +
  ggthemes::theme_solarized_2()
# Hour and sentiment perfect for ANOVA

auth_cmp <- df %>%
  group_by(author, book) %>%
  summarise(mean_sent = mean(sentiment)) %>%
  filter(length(unique(book)) >= 2)

ggplot(auth_cmp, aes(y = mean_sent, x = reorder(book, mean_sent), color=reorder(author, mean_sent))) +
  geom_hline(yintercept = mean(auth_cmp$mean_sent), color = 'red') +
  geom_segment(aes(y = mean_sent, x = reorder(book, mean_sent),
               yend = mean(auth_cmp$mean_sent), xend = book)) +
  geom_point() +
  coord_flip() +
  labs(x = 'Book', y='Mean sentiment score') +
  theme(legend.position = 'bottom')


p <- ggplot(df, aes(x = timestamp, y = reorder(author, timestamp), color = sentiment)) +
  geom_point() +
  theme_solarized_2() +
  scale_color_gradient2(midpoint = 0, low='dodgerblue4', mid='grey', high='orange')

p +
  geom_vline(xintercept = as.POSIXct('Aug 21, 2017 12:06am', format='%b %d, %Y %I:%M%p'),
             color='darkred') +
  geom_vline(xintercept = as.POSIXct('Apr 21, 2018 13:00:00', format="%b %d, %Y %X"),
             color = 'forestgreen')


gg_add_timelines <- function(p, datelist, col_list) {
  add_date <- function(datestr, colr) {
    return(geom_vline(xintercept = as.POSIXct(datestr, format='%m/%d/%y'), color=colr))
  }
  i = 1
  for (date in datelist) {
    p <- p + add_date(as.character(date), col_list[i])
    i = i + 1
  }
  print(p)
}

datelist <- c('06/01/16', '07/27/17', '12/15/17', '05/07/18', # moving/jobs
              '08/21/17', '04/21/18')

gg_add_timelines(, datelist, col_list = c('forestgreen', 'blue', 'orange', 'darkred',
                                           'darkmagenta', 'darkmagenta'))

p <- ggplot(df, aes(x=timestamp, fill=cut(sentiment, 9)
                    )) +
  geom_histogram(bins=200) +
#  geom_point() +
#  geom_point(pch = 21, color='grey') +
  theme_solarized_2() +
#  scale_color_gradient2(midpoint = 0, low='dodgerblue4', mid='grey', high='orange')
  scale_fill_brewer(type='div', palette = 'PuOr', direction = -1)
p


ggplot(df %>% filter(num_characters < 6000), aes(x = num_characters, fill = author)) +
  geom_bar(stat=df$author)

gg_sentiment_violin <- ggplot(df,
                           aes(x = author, y = sentiment, fill = author)) +
  geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)) +
  theme_solarized_2() +
  theme(axis.text.x = element_text(angle=45)) +
  labs(title = "",
       x = "Author",
       y = "Sentiments") +
  guides(fill = FALSE)
gg_sentiment_violin

ggplot(df, aes(x=hour(timestamp), y=author)) +
  geom_bin2d()

library(plotly)
pl_segment_violin <- df %>%
  plot_ly(y=~sentiment, x = ~author, split = ~book, color = ~book,
          type='violin')
pl_segment_violin
pl_segment_violin %>%
  add_trace(x = ~author, y = ~sentiment, split = ~book, fill = ~book, type='scatter',
            text=~quote)

df %>%
  plot_ly(x = ~timestamp, y=~author, text = ~book, color=~sentiment,
          type='scatter')

df %>%
  plot_ly(x = ~lubridate::wday(timestamp), y = ~hour(timestamp),
          type='scatter')

plot_ly(na.omit(df[order(df$sentiment),]),
        y = ~sentiment,
        color = ~author, text = paste(df$author, df$book, df$quote, sep="<br>"),
        type = 'scatter')
