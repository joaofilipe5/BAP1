README for Sentiment and Topic Analysis on 2024 US Elections

Project Overview

This project focuses on sentiment analysis and topic analysis of online discussions regarding the 2024 US presidential election. The data is gathered from political subreddits and is analyzed to determine public opinion about the candidates, Donald Trump and Kamala Harris, across various key topics relevant to the election.

The project leverages Python and R scripts to perform data collection, analysis, and visualization. The analysis includes sentiment categorization, identification of dominant topics, and graphical representation of the results.

Key Features:

	•	Sentiment Analysis: Using the tidytext library in R, the project classifies words as positive or negative based on predefined lexicons (using get_sentiments('bing')). This helps assess how the public feels about each candidate.
	•	Topic Analysis: The project categorizes mentions into 6 major topics: Healthcare, Media, Human Rights, Immigration, Economics, and Military.
	•	Visualization: The project provides pie charts to show sentiment distribution and bar charts to display the mentions of candidates across various topics.
	•	Bias Detection: The project also evaluates the overall bias in the subreddits towards negative or positive sentiments.

Technologies:

	•	Python: Used for data collection (e.g., scraping Reddit discussions) and basic preprocessing.
	•	R: Used for sentiment analysis, topic modeling, and visualization using libraries such as tidytext, ggplot2, and dplyr.
