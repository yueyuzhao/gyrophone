#!/usr/bin/python

# Downsample TIDIGITS

import os.path
import wave

OUTPUT_FS = 200; # Hz
INPUT_DIR = '../TIDIGITS-Downsampled'

WAV_EXT = '.wav'

def process(arg, dirname, names):
	print 'Processing directory', dirname
	wav_files = filter(lambda x: os.path.splitext(x)[1].lower() == WAV_EXT, names)
	for f in wav_files:
		filename = os.path.join(dirname, f)
		print 'Processing', filename
		wav_obj = wave.open(filename, 'rb')
		original_fs = wav_obj.getframerate()
		frames_num = wav_obj.getnframes()
		samp_width = wav_obj.getsampwidth()
		params = wav_obj.getparams()
		wav_data = wav_obj.readframes(frames_num)
		wav_obj.close()
		N = original_fs / OUTPUT_FS # downsampling factor
		downsampled_data = ''
		for i in xrange(frames_num/N):
			pos = i*N*samp_width
			downsampled_data += wav_data[pos:pos + samp_width]
		wav_obj = wave.open(filename, 'wb')
		wav_obj.setparams(params)
		wav_obj.setframerate(OUTPUT_FS)
		wav_obj.writeframes(downsampled_data)
		wav_obj.close()

def main():
	print 'Downsampling TIDIGITS'
	os.path.walk(INPUT_DIR, process, None)

if __name__ == '__main__':
	main()