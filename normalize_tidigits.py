#!/usr/bin/env python

from optparse import OptionParser 
import run_gyromic
import os, os.path

WAV_EXT = '.WAV'
NORMALIZE = '../utils/normalize/src/normalize'

def process(input_dir, dry):
	for root, dirs, files in os.walk(input_dir):
		print 'Processing', root
		if not dry:
			os.system(NORMALIZE + ' -b ' + os.path.join(root, '*'))

def main():
	parser = OptionParser("Usage: %prog [--dry] <input directory> <output_directory>")
	parser.add_option('--dry', action="store_true", dest="dry", default=False, 
										help="Dry run (don't record)")
	(options, args) = parser.parse_args()
	if len(args) < 1:
		parser.error('Not enough arguments. Specify input and output directories.')

	input_dir = args[0]
	process(input_dir, options.dry)

if __name__ == '__main__':
	main()
