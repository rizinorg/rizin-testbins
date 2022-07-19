#!/bin/bash
if [[ "$1" == "-h" || "$2" == "--help" ]]; then
    echo "$0 <bin> <log-file>"
    exit
fi

if [[ $# -ne 2 ]]; then
    echo "$0 <bin> <log-file>"
    exit
fi

echo "rizin -qq -A $1 2> $1.err | sort -g | uniq -c | sort -g -r > $2"
rizin -qq -A "$1" 2> "$1.err" | sort -g | uniq -c | sort -g -r > "$2"
./print_stats.py "$2"
