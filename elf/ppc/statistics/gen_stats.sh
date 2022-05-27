#!/bin/sh

echo "rizin -qq -A $1 2> $1.err | sort -g | uniq -c | sort -g -r > $2"

rizin -qq -A "$1" 2> "$1.err" | sort -g | uniq -c | sort -g -r > "$2"

./print_stats.py "$2"
