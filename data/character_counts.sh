#!/bin/bash

echo "count	author	title" > kindle_counts.tsv

for f in find /media/$USER/Kindle/documents/**/*.{azw3,mobi}; do
    wc -c "$f"  |
        sed "s/\(^[0-9]\+ \).\+\/Kindle\/documents/\1	AUTHORHERE/
            s/AUTHORHERE\/\(.\+\),\?\(.\+\)\?\//\2 \1	BOOKHERE\//
            s/BOOKHERE\/\(.\+\)-.\+/\1/" >> kindle_counts.tsv;
done

