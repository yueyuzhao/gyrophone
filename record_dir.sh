#!/bin/sh

if [ $# -lt 2 ] 
then
	echo "Error: Specify directory with samples and output directory"
	exit 1
fi

SAMPLES_DIR=$1
OUTPUT_DIR=$2
FILES=$SAMPLES_DIR/*.wav

for f in $FILES
do
	echo Recording $f
	python run_gyromic.py -o $OUTPUT_DIR $f
done
