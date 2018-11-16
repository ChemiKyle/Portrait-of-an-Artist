# Portrait of an Artist

Scrape quotes taken on a Kindle device into a SQLite database for display and analysis.

## Setup
### Get the quotes out of your Kindle
Quotes will be stored in a raw text file on your Kindle under `/documents/My Clippings.txt`  
A bash one liner is presented below; a more complicated script `multi_kindle_scrape.sh` is available for automatically managing quotes from multiple kindles.

```bash
cp /media/$USER/Kindle/documents/My\ Clippings.txt all_kindle_notes.txt
```

### Create a database
Parse quotes and create a database with `scrape_quotes.py`

From here you can use boilerplate scripts in `/data` for analysis, and set up an epaper device to display quotes (best used with cron), see `/rpi/display_quotes.py` for more information.

![epaper display](https://i.redd.it/2vr77kwwlt811.jpg "epaper display")

# TODO
Add support for ESP8266 to display quotes, Waveshare devices have support for these, but I need to figure out memory buffers to support the relatively large images.
