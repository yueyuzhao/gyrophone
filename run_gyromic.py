#!/usr/bin/env python

# Requires pyadb
# can be installed with
# > easy_install pyadb

import pyadb
from time import sleep
import os
import datetime

ADB_PATH = '~/Documents/Sookasa/adt-bundle-mac-x86_64/sdk/platform-tools/adb'
APP_NAME = 'seclab.GyroMic'
ACTIVITY_NAME = '%s.GyroMic' % APP_NAME
APP_PATH = 'App/bin/GyroMic-debug.apk'

LOCAL_PLAYBACK_WAV_FILE = 'samples/chirp-120-160hz.wav'
RECORDED_SAMPLES_FILE = '/sdcard/gyro_samples.txt'
LOCAL_FILENAME = 'chirp-120-160hz'
RESULTS_PARENT_DIR= 'gyro_results/Nexus4/'
RUN_APP_COMMAND = 'am start -W -n %s/%s' % (APP_NAME, ACTIVITY_NAME)
CLOSE_APP_COMMAND = 'am broadcast -a %s.intent.action.SHUTDOWN' % (APP_NAME)

def reinstall_app(adb, app_name, keepdata):
		print 'Uninstalling previously installed app...'
		print adb.uninstall(app_name, keepdata)
		print 'Installing new app version...'
		print adb.install(pkgapp=APP_PATH)

def play(audio_file):
	import subprocess
	return_code = subprocess.call(["afplay", audio_file])

def main():
	adb = pyadb.ADB(ADB_PATH)
	devices = adb.get_devices()[1]
	print 'Available devices:', devices
	
	for device in devices:
		print 'Recording frequency response for device %s' % device
		adb.set_target_device(device)

		parent_dir = RESULTS_PARENT_DIR + device
		if not os.path.exists(parent_dir):
			os.mkdir(parent_dir)

		# Uninstall previously installed package and install new one
		reinstall_app(adb, APP_NAME, keepdata= True)

		# Run app
		print 'Running app (%s)' % RUN_APP_COMMAND
		print adb.shell_command(RUN_APP_COMMAND)

	print 'Waiting...'
	sleep(2)

	play(LOCAL_PLAYBACK_WAV_FILE)
	sleep(1)

	for device in devices:
		adb.set_target_device(device)
		print 'Closing app (%s)' % CLOSE_APP_COMMAND
		print adb.shell_command(CLOSE_APP_COMMAND)
	
	for device in devices:
		adb.set_target_device(device)
		# Download recorded file
		print 'Downloading samples file...'
		adb.get_remote_file(RECORDED_SAMPLES_FILE, 
				RESULTS_PARENT_DIR + '%s/%s' % (device, LOCAL_FILENAME))

if __name__ == '__main__':
	main()
