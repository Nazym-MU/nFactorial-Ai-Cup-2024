# nFactorial-Ai-Cup-2024


# VoiceLetter

Voiceletter is an iOS application that allows users to fetch the latest news using a query and display a summarized version of the news in a table view. Each query results in a summary of the news articles retrieved from Bing, summarized using OpenAI's language model. The summarized news is displayed in the app's table view with the query as the title.


## Features

- Fetches the latest news based on user queries.
- Summarizes the news using OpenAI's language model.
- Displays the summarized news in a table view with the query as the title.
- Automatically updates the table view with new summaries.
- Supports playback of audio even when the app is backgrounded.

## Usage

The app provides a simple interface where users can enter queries. These queries fetch data using the Bing API, and responses are converted to audio and played back to the user. Users can interact with the app both in the foreground and while it is backgrounded thanks to the background audio capabilities.


## Structure

- **ChatbotViewController.swift:** Handles the user interface for entering queries, fetching news, and displaying summaries in a table view.
- **APIManager.swift:** Contains methods to fetch news from Bing, summarize news using OpenAI, and manage API requests.
- **AudioTableViewCell.swift:** Custom table view cell class, adapted for potential future use.


## Demo

Project Link: https://github.com/Nazym-MU/nFactorial-Ai-Cup-2024/
YouTube Demo: https://youtu.be/3HhCQ3LU__4?si=cUcalfsVU4D1DUiO



## Typeform to submit:
https://docs.google.com/forms/d/e/1FAIpQLSfjnACTWf5xYKInMllmhy5Bchc-DnOXw6vEXsHmXI4XFPwZXw/viewform?usp=sf_link

## DEADLINE: 26/05/2024 10:00
