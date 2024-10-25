import praw
import csv
import time
import logging

# Setup logging to monitor the script's operation
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def main():
    # Time tracking
    start_time = time.time()
    
    # Initialize Reddit instance
    reddit = praw.Reddit(
        client_id='xxxxxxxxxxxxxx',
        client_secret='xxxxxxxxxxxxx',
        user_agent='script:StockSentiment:1.0 (by u/xxxxxxxxxxx)',
        username='xxxxxxxx',
        password='xxxxxxxx'
    )

    # Subreddits to scrape
    subreddits_list = ['Ask_Politics', 'Conservative', 'Liberal', 'ModeratePolitics', 'PoliticalDiscussion', 'Politics']
    num_posts = 500  

    # File setup
    csv_file_path = '/Users/joaofilipe/Documents/3AnoUni/BusinessAnalytics/csvtextoreddit.csv'
    with open(csv_file_path, 'w', newline='') as csvfile:
        fieldnames = ['subreddit', 'title', 'post']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        # Collect post data from multiple subreddits
        for subreddit_name in subreddits_list:
            subreddit = reddit.subreddit(subreddit_name)
            try:
                for submission in subreddit.hot(limit=num_posts):
                    title = submission.title
                    writer.writerow({
                        'subreddit': subreddit_name,
                        'title': title.replace('\n', ' ').replace('\r', ' ').replace(',', ' ')
                    })
            except Exception as e:
                logging.error(f"Error processing posts from {subreddit_name}: {str(e)}")

    # Timing and wrap-up
    end_time = time.time()
    elapsed_time = end_time - start_time
    logging.info(f"Data successfully written to {csv_file_path}")
    logging.info(f"Elapsed time: {elapsed_time} seconds")

if __name__ == "__main__":
    main()