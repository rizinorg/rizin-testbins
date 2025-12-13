#!/bin/bash

usage() {
	echo "usage: unpack_bundle.sh <file.xe>"
	echo "unpacks xe files using rizin"
}

FILENAME=$(basename -- "$1")
EXTENSION="${FILENAME##*.}"

if [[ -z "$1" ]] || [[ "$EXTENSION" != "xe" ]]; then
	usage
	exit 1
fi

OFFSETS=$(rizin -qc '/mq' "$1")

OFFSET_START=""
for OFFSET in $OFFSETS; do
	OFFSET_END=$(rz-ax "$OFFSET")
	if [ ! -z "$OFFSET_START" ]; then
		SIZE=$(rz-ax -d "$OFFSET_END-$OFFSET_START")
		echo "Unpacking ($OFFSET_START $OFFSET_END)"
		dd "bs=$OFFSET_START" "count=$SIZE" skip=1 "if=$1" "of=$FILENAME.$OFFSET_START"
	fi
	OFFSET_START="$OFFSET_END"
done

if [ ! -z "$OFFSET_START" ]; then
	echo "Unpacking ($OFFSET_START eof)"
	dd "bs=$OFFSET_START" skip=1 "if=$1" "of=$FILENAME.$OFFSET_START"
fi
