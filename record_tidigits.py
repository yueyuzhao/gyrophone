#!/usr/bin/env python

from optparse import OptionParser 
import run_gyromic
import os, os.path

WAV_EXT = '.WAV'

def process(input_dir, output_dir, dry):
	for root, dirs, files in os.walk(input_dir):
		print 'Processing', root
		dest_dir = os.path.join(output_dir, *root.split(input_dir)[1:])
		print 'Creating', dest_dir
		if not dry:
			if not os.path.exists(dest_dir):
				os.makedirs(dest_dir)
		wavfiles = [f for f in files if os.path.splitext(f)[1] == WAV_EXT]
		single_digit = [f for f in wavfiles if len(os.path.splitext(f)[0]) == 2]
		for f in single_digit:
			print 'Recording', f	
			if not dry:
				run_gyromic.play_and_record(os.path.join(root, f),
																		False,
																		dest_dir)

def main():
	parser = OptionParser("Usage: %prog [--dry] <input directory> <output_directory>")
	parser.add_option('--dry', action="store_true", dest="dry", default=False, 
										help="Dry run (don't record)")
	(options, args) = parser.parse_args()
	if len(args) < 2:
		parser.error('Not enough arguments. Specify input and output directories.')
	
	input_dir = args[0]
	output_dir = args[1]
	process(input_dir, output_dir, options.dry)

if __name__ == '__main__':
	main()
