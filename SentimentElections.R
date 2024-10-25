# Load libraries
library(tidytext)
library(tidyr)
library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(readr)
library(ggplot2)
library(dplyr)

# Load the dataset
data <- read_csv("/Users/joaofilipe/Documents/3AnoUni/BusinessAnalytics/csvtextoreddit.csv")

# Add four new columns for text classification
data <- data %>%
  mutate(
    contains_trump = grepl("trump|donald|dt", title, ignore.case = TRUE),
    contains_kamala = grepl("kamala|harris|kh", title, ignore.case = TRUE),
    both = contains_trump & contains_kamala,
    none = !contains_trump & !contains_kamala
  )

# Separate the data into four groups based on the newly created columns
data_trump <- data %>%
  filter(contains_trump & !both)
data_kamala <- data %>%
  filter(contains_kamala & !both)
data_both <- data %>%
  filter(both)
data_none <- data %>%
  filter(none)

# Define custom stopwords (only remove clear names, not political terms)
custom_stopwords <- c("trump", "donald", "biden", "kamala", "harris")

# Preprocess the text and create DTMs (adding unigrams for sentiment analysis)
dtm_trump <- corpus(data_trump, text_field = 'title') |>
  tokens(remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en")) |>
  tokens_remove(custom_stopwords) |>
  dfm()

dtm_kamala <- corpus(data_kamala, text_field = 'title') |>
  tokens(remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en")) |>
  tokens_remove(custom_stopwords) |>
  dfm()

dtm_both <- corpus(data_both, text_field = 'title') |>
  tokens(remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en")) |>
  tokens_remove(custom_stopwords) |>
  dfm()

dtm_none <- corpus(data_none, text_field = 'title') |>
  tokens(remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en")) |>
  tokens_remove(custom_stopwords) |>
  dfm()

# Convert DTM to data frame for sentiment analysis
convert_dtm_to_df <- function(dtm) {
  # Convert DFM to a tidy data frame using tidytext's tidy() function
  tidy_dtm <- tidy(dtm)  # Converts DFM to tidy format (document-term)
  
  # Filter out rows where count is zero and keep only words with counts
  tidy_dtm_long <- tidy_dtm %>%
    filter(count > 0)
  
  return(tidy_dtm_long)
}

# Apply the conversion to each category's DTM
trump_words <- convert_dtm_to_df(dtm_trump)
kamala_words <- convert_dtm_to_df(dtm_kamala)
both_words <- convert_dtm_to_df(dtm_both)
none_words <- convert_dtm_to_df(dtm_none)

sentiment_lexicon <- get_sentiments("bing")
sentiment_lexicon <- sentiment_lexicon %>%
  mutate(sentiment = ifelse(sentiment == "negative", "Negativo", "Positivo"))

# Function to perform sentiment analysis and plot donut chart
perform_sentiment_analysis <- function(word_df, title) {
  sentiment_analysis <- word_df %>%
    inner_join(sentiment_lexicon, by = c("term" = "word")) %>%
    count(sentiment) %>%
    mutate(percentage = n / sum(n) * 100) %>%
    ungroup()
  
  # Create a donut chart for sentiment distribution
  ggplot(sentiment_analysis, aes(x = "", y = percentage, fill = sentiment)) +
    geom_bar(stat = "identity", width = 1, color = "white") +
    coord_polar("y", start = 0) +
    geom_text(aes(label = paste0(round(percentage, 1), "%")), position = position_stack(vjust = 0.5)) +
    scale_fill_manual(values = c("Positivo" = "#00ba38", "Negativo" = "#f8766d")) +
    theme_void() +
    labs(title = title) +
    theme(legend.position = "bottom")
}

# Perform sentiment analysis and plot donut chart for each category
perform_sentiment_analysis(trump_words, "Análise de Sentimento - Categoria Trump")
perform_sentiment_analysis(kamala_words, "Análise de Sentimento - Categoria Kamala Harris")
perform_sentiment_analysis(both_words, "Análise de Sentimento - Categoria Trump e Kamala Harris")
perform_sentiment_analysis(none_words, "Análise de Sentimento - Categoria Nem Trump nem Kamala Harris")

