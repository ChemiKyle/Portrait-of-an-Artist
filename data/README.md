# Data storage and Analysis

SQL, JSON, or pickle files are stored here, as well as a couple of `R` scripts to analyze quotes and usage!

## Quote Analysis
`quote_analytics.R` is a (currently spaghetti code) script to be used with the quote database for a handful of analyses or to serve as a basis for writing your own.

## Usage Analysis
`usage_analytics.R` is a script to be used with a file that's stored on your kindle that will require some working up.  
The file will be located in `/media/$USER/Kindle/system/userannotlogsDir/` and titled `annotation_<Unix_Epoch_timestamp>`. 
It's not(?) accessible on Windows and seems to be a transient storage for Amazon's anlytics purposes. 
On my machine it's stamped with about the last time I connected it to the internet. 
If you keep your kindle connected to wifi, I suggest regularly pulling this file out to use for a better analysis.
Possibly of interest to pair with these data is the `calibre.metadata` file if you are a [Calibre](https://calibre-ebook.com/) user. 
Particularly for pairing `asin` with authors.

The file is in a quasi-`.jsonl` format and will need some working up. I used a regex in vim to ready the file for import into `R`; it's provided below for easy use.
```vim
:%s/^\(-?.*\)={\(.+}$\)/{"id":"\1",\2
```
A perl script is now also provided to perform the same regex and output a file title `parsed\_annotation.jsonl`. It takes your annotation file as an input on the command line.

