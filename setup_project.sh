#!/bin/bash
# Directory Architecture
echo "Students attendance tracker"

# promt the student to enter his name.
read -p "Enter your name" INPUT_SUFFIX

# If the student enters nothing , the script to stop.
if [ -z "$INPUT_SUFFIX" ]; then
	echo "Name required"
	exit 1
fi

# create the parent folder and subdirectories with the INPUT_SUFFIX
mkdir -p "attendance_tracker_${INPUT_SUFFIX}/Helpers"
mkdir -p "attendance_tracker_${INPUT_SUFFIX}/reports"

#creating  empty files inside the subdirectories
touch "attendance_tracker_${INPUT_SUFFIX}/attendance_checker.py"
touch "attendance_tracker_${INPUT_SUFFIX}/Helpers/config.jason"
touch "attendance_tracker_${INPUT_SUFFIX}/Helpers/assets.csv"
touch "attendance_tracker_${INPUT_SUFFIX}/reports/reports.log"

echo "directory structure created"
