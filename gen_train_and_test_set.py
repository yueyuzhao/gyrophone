#!/usr/bin/env python

"Create train and test sets from a given directory of WAV files"

import os
import os.path
import shutil
import random
import sys
import fnmatch
import re

TRAIN_TEST_RATIO = 8
FILENAME_FILTER = '*.wav'

def main():
	if len(sys.argv) < 3:
		sys.exit('Usage: %s <input dir> <output dir> <filter>' % sys.argv[0])
	input_dir = sys.argv[1]
	output_dir = sys.argv[2]

	re_filter = fnmatch.translate(FILENAME_FILTER)

	files = [f for f in os.listdir(input_dir) if re.match(re_filter, f)]
	random.shuffle(files)
	N = len(files)
	train_set_size = TRAIN_TEST_RATIO * N / (TRAIN_TEST_RATIO + 1)
	train_set = set(files[:train_set_size])
	test_set = set(files[train_set_size:])

	# make sure we use all files
	assert( len(train_set) + len(test_set) == N )
	# make sure same file is not present in test and train sets
	assert( len(train_set.intersection(test_set)) == 0 )

	train_dir = os.path.join(output_dir, 'train')
	os.makedirs(train_dir)
	test_dir = os.path.join(output_dir, 'test')
	os.makedirs(test_dir)

	for filename in train_set:
		shutil.copyfile(os.path.join(input_dir, filename), os.path.join(train_dir, filename))

	for filename in test_set:
		shutil.copyfile(os.path.join(input_dir, filename), os.path.join(test_dir, filename))

if __name__ == '__main__':
	main()
