#!/bin/bash



FP="$1"
if [ "$FP" == "" ]; then
    FP=$(zenity --save --file-selection)
fi

if [ "$FP" != "" ]; then
    if [ 0 -eq 1 -a -f "$FP" ]; then
        printf 'File already exists quitting\n' 1>&2;
        exit -1;
    else
        maim -s "$FP" 2> /dev/null
    fi
fi
