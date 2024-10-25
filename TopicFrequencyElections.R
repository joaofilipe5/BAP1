# Load necessary libraries
library(tidytext)
library(tidyr)
library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(readr)
library(ggplot2)
library(dplyr)
library(stringr)

# Load the dataset (use readr's read_csv to handle the delimiter issues and only select relevant columns)
data <- read_csv("/Users/joaofilipe/Documents/3AnoUni/BusinessAnalytics/csvtextoreddit.csv", 
                 quote = "\"", col_select = c("subreddit", "title"))

# Define custom stopwords
custom_stopwords <- c("trump", "donald", "biden", "kamala", "harris")

# Add columns for text classification based on key individuals
data <- data %>%
  mutate(
    contains_trump = grepl("trump|donald|dt", title, ignore.case = TRUE),
    contains_kamala = grepl("kamala|harris|kh", title, ignore.case = TRUE),
    both = contains_trump & contains_kamala,
    none = !contains_trump & !contains_kamala
  )

# Define topic-specific keyword lists
topics <- list(
  Saúde = c("healthcare", "medicare", "medicaid", "insurance", "hospital", "doctor", "nurse",
                 "surgery", "treatment", "clinic", "patient", "pharmacy", "medical", "health insurance"),
  Média = c("media", "news", "journalist", "report", "broadcast", "press", "publication",
            "newspaper", "magazine", "blogger", "podcast", "vlog", "anchor", "correspondent"),
  Direitos = c("rights", "human rights", "freedom", "equality", "justice", "discrimination",
                   "liberty", "civil rights", "legal rights", "right to life", "freedom","speech",
                   "gender equality", "racial equality", "LGBT"),
  Immigração = c("immigration", "immigrant", "deportation", "border", "refugee", "asylum",
                  "migrant", "visa", "citizenship", "naturalization", "undocumented", "green card"),
  Economia = c("economy", "economic", "inflation", "tax", "budget", "finance", "fiscal",
                "GDP", "unemployment", "market", "trade", "investment", "stocks", "recession",
                "monetary policy", "federal reserve"),
  Militar = c("military", "army", "navy", "air", "force", "marines", "defense", "armed forces",
               "veteran", "war", "conflict", "security", "troops", "operation", "strategy",
               "national security")
)

# Function to generate DTMs for Trump and Kamala mentions within each topic
generate_topic_dtm <- function(data, topic_name, keywords) {
  pattern <- paste(keywords, collapse = "|")
  filtered_data <- data %>% filter(str_detect(tolower(title), pattern))
  
  # Create corpus and tokens correctly
  dtm_trump <- filtered_data %>%
    filter(contains_trump & !contains_kamala) %>%
    corpus(text_field = "title") %>%
    tokens(remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE) %>%
    tokens_tolower() %>%
    tokens_remove(stopwords("en")) %>%
    tokens_remove(custom_stopwords) %>%
    dfm()
  
  dtm_kamala <- filtered_data %>%
    filter(contains_kamala & !contains_trump) %>%
    corpus(text_field = "title") %>%
    tokens(remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE) %>%
    tokens_tolower() %>%
    tokens_remove(stopwords("en")) %>%
    tokens_remove(custom_stopwords) %>%
    dfm()
  
  list(dtm_trump, dtm_kamala)
}

# Create DTMs for each topic
topic_dtms <- lapply(names(topics), function(topic) generate_topic_dtm(data, topic, topics[[topic]]))

# Combine data for plotting: total number of mentions per topic by individual
topic_summary <- lapply(seq_along(topic_dtms), function(i) {
  topic <- names(topics)[i]
  
  dtm_trump <- topic_dtms[[i]][[1]]
  dtm_kamala <- topic_dtms[[i]][[2]]
  
  data.frame(
    topic = topic,
    trump_mentions = sum(colSums(dtm_trump)),
    kamala_mentions = sum(colSums(dtm_kamala))
  )
}) %>% 
  bind_rows()

# Reshape data to long format for easier plotting
topic_summary_long <- topic_summary %>%
  pivot_longer(cols = c(trump_mentions, kamala_mentions), 
               names_to = "individual", 
               values_to = "mentions") %>%
  mutate(individual = ifelse(individual == "trump_mentions", "Trump", "Kamala"))

# Plot: Bar chart comparing mentions by topic with red and blue colors
ggplot(topic_summary_long, aes(x = topic, y = mentions, fill = individual)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Trump" = "red", "Kamala" = "blue")) +
  labs(
    title = "Menção de Tópicos: Trump vs. Kamala",
    x = "Tópico",
    y = "Número de menções",
    fill = "Indivíduo"
  ) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

