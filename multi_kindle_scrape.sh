#!/bin/bash

# device_file="/media/${USER}/Kindle/documents/My\ Clippings.txt" # doesn't work due to space
kindle_num=1

# Checks each file for any local lines that are not on the kindle
# any difference at all will increment the kindle number
# e.g. if you delete a repeat quote on the kindle, a new file will be created
increment_file() {
    diffcheck="$(diff /media/${USER}/Kindle/documents/My\ Clippings.txt kindle_${kindle_num}_notes.txt)"
    # TODO: if the very first line is different, it is a different device
    # if others are different, it's a locally changed of the same device
    if [[ "$diffcheck" =~ ">" ]]
    then
        echo "Difference found with file $kindle_num"
        echo "$diffcheck"
        ((kindle_num++))
        increment_file
    else
        return 1
    fi
}

increment_file

cp /media/${USER}/Kindle/documents/My\ Clippings.txt kindle_${kindle_num}_notes.txt
echo "New quotes saved in kindle_${kindle_num}_notes.txt"

cat kindle_*_notes.txt > all_kindle_notes.txt
echo "Notes combined across $kindle_num devices"

