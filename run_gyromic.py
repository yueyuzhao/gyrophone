#!/usr/bin/env python

# Requires pyadb
# can be installed with
# > easy_install pyadb

import pyadb
import sys
from time import sleep
import os
import os.path
import datetime
from optparse import OptionParser

ADB_PATH = '~/Documents/Sookasa/adt-bundle-mac-x86_64/sdk/platform-tools/adb'
APP_NAME = 'seclab.GyroMic'
ACTIVITY_NAME = '%s.GyroMic' % APP_NAME
APP_PATH = 'App/bin/GyroMic-debug.apk'
SLEEP_TIME = 0
LOCAL_EXT = '.gyr'

RECORDED_SAMPLES_FILE = '/sdcard/gyro_samples.txt'
RESULTS_PARENT_DIR= 'gyro_results/Nexus/'
# RESULTS_PARENT_DIR= 'gyro_results/SCPD-Room/'
RUN_APP_COMMAND = 'am start -W -n %s/%s' % (APP_NAME, ACTIVITY_NAME)
CLOSE_APP_COMMAND = 'am broadcast -a %s.intent.action.SHUTDOWN' % (APP_NAME)

def reinstall_app(adb, app_name, keepdata):
	"Reinstall an application with option of keeping the data"
	print 'Uninstalling previously installed app...'
	print adb.uninstall(app_name, keepdata)
	print 'Installing new app version...'
	print adb.install(pkgapp=APP_PATH)

def play(audio_file):
	"Playback audio file using afplay command line utility"
	import subprocess
	print 'Playing file', audio_file
	return_code = subprocess.call(["afplay", audio_file])

def get_local_filename(playback_filename):
	return os.path.basename(os.path.splitext(playback_filename)[0]) + LOCAL_EXT

def play_and_record(playback_filename, reinstall, results_parent_dir):
	"Do all the stuff"

	# Run one time to make sure we don't get the success message next time
	os.system(ADB_PATH + ' devices')

	adb = pyadb.ADB(ADB_PATH)
	devices = adb.get_devices()[1]
	print 'Available devices:', devices
	
	for device in devices:
		print 'Recording frequency response for device %s' % device
		adb.set_target_device(device)

		parent_dir = os.path.join(results_parent_dir, device)
		print 'Parent dir is', parent_dir
		if not os.path.exists(parent_dir):
			os.mkdir(parent_dir)

		# Uninstall previously installed package and install new one
		if reinstall:
			reinstall_app(adb, APP_NAME, keepdata= True)

		# Run app
		print 'Running app (%s)' % RUN_APP_COMMAND
		print adb.shell_command(RUN_APP_COMMAND)

	print 'Waiting...'
	sleep(SLEEP_TIME)
	play(playback_filename)
	sleep(SLEEP_TIME)

	# Close app and stop recording on all devices
	for device in devices:
		adb.set_target_device(device)
		print 'Closing app (%s)' % CLOSE_APP_COMMAND
		print adb.shell_command(CLOSE_APP_COMMAND)

	# Download recorded file
	for device in devices:
		adb.set_target_device(device)
		local_filename = os.path.join(results_parent_dir, device, get_local_filename(playback_filename))
		print 'Downloading samples file to %s' % local_filename
		adb.get_remote_file(RECORDED_SAMPLES_FILE, local_filename)


def main():
	parser = OptionParser("""Usage: %prog [--reinstall] <wav_file>
	-r --reinstall	: Reinstalls the GyroMic application on connected devices
	-o --output	: Results output directory""")
	parser.add_option("-r", "--reinstall", dest="reinstall",	
		help="Reinstall application on devices")
	parser.add_option("-o", "--output", dest="results_parent_dir",
		help="Results output directory", default=RESULTS_PARENT_DIR)
	(options, args) = parser.parse_args()

	if len(args) < 1:
		parser.error('Not enough arguments. Specify audio file.')

	playback_filename = args[0]
	play_and_record(playback_filename, options.reinstall, options.results_parent_dir)


if __name__ == '__main__':
	main()
