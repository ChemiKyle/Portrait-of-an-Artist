# Portrait of an Artist

Scrape quotes taken on a Kindle device into a SQLite database for display and analysis.

## Setup
Parse quotes and create a database with `scrape_quotes.py` (edit the file name on line 6)

From here you can use boilerplate scripts in `/data` for analysis, and set up an epaper device to display quotes (best used with cron, see `/data/display_quotes.py` for more information.

# TODO
Add support for ESP8266 to display quotes, Waveshare devices have support for these, but I need to figure out memory buffers to support the relatively large images.
