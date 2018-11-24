#!/bin/bash

echo "book_count	author	title" > kindle_counts.tsv

for f in find /media/$USER/Kindle/documents/**/*.{azw3,mobi}; do
    wc -c "$f"  |
        sed "s/\(^[0-9]\+ \).\+\/Kindle\/documents/\1	AUTHORHERE/
            s/AUTHORHERE\/\(.\+\)\//\1	BOOKHERE\//
            s/BOOKHERE\/\(.\+\) -.\+$/\1/
            s/	\([^	]\+\), The/	The \1/
            s/'//" >> kindle_counts.tsv;
done

