library(dplyr)
library(ggplot2)
library(ggthemes)
library(sentimentr)
library(RSQLite)

# Linux
setwd("/home/kyle/projects/Portrait-of-an-Artist/data/")
#Windows
setwd("kyle_analytics/Portrait-of-an-Artist/data/")
con <- dbConnect(RSQLite::SQLite(), dbname='quotes.db')
df <- dbGetQuery(conn=con, statement = ("SELECT * FROM quotes;"))


df <- df %>%
  rowwise() %>%
  mutate(sentiment = sum(sentiment(get_sentences(as.character(quote)))[,4]))

#write.table(df, file = 'quote_and_sentiment.tsv', sep='\t')

#df <- read.table("quote_and_sentiment.tsv", sep = '\t', header = TRUE)
df <- df %>% mutate(num_characters = nchar(as.character(quote)))

qplot(df$sentiment[abs(df$sentiment) > 0.5], bins = 20)

ggplot(df, aes(x = num_characters, y = abs(sentiment))) +
  geom_smooth()

ggplot(df %>% filter(num_characters < 6000), aes(x = num_characters, fill = author)) +
  geom_bar(stat=df$author)

df$author <- factor
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

library(plotly)
pl_segment_violin <- df %>%
  plot_ly(y=~sentiment, x = ~author, split = ~book, color = ~book,
          type='violin')
pl_segment_violin %>%
  add_trace(x = ~author, y = ~sentiment, split = ~book, fill = ~book, type='scatter',
            text=~quote)

plot_ly(na.omit(df[order(df$sentiment),]),
        y = ~sentiment,
        color = ~author, text = paste(df$author, df$book, df$quote, sep="<br>"),
        type = 'scatter')
