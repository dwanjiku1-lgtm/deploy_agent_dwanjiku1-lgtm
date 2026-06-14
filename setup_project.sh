#!/bin/bash
# Process Management (Trap)

cleanup_on_interrupt() {
	echo -e "\n\n[!] process stoped by user (SIGINT / Ctrl+C)."
	# look for target folder if it exist or not before executing backup
	if [ -d "attendance_tracker_${INPUT_SUFFIX}" ]; then
	       ARCHIVE_NAME="attendance_tracker_${INPUT_SUFFIX}_archive.tar.gz"
	       echo " [*] packing up files and saving them to:$ARCHIVE_NAME"


	       # packaging files and compressing, and takes errors into the linux black hole
	       tar -czf "$ARCHIVE_NAME" "attendance_tracker_${INPUT_SUFFIX}" 2>/dev/null

	       # Remove the incomplete folders 
	       echo "[*] removing the incomplete folders.."
	       rm -rf "attendance_tracker_${INPUT_SUFFIX}"
	       echo "remove successful"
	fi

	exit 1
}	

 # if the user press ctrl+c , run the cleanup_on_interrupt function
 trap 'cleanup_on_interrupt' SIGINT

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

# Automated file injection

CONFIG_PATH="attendance_tracker_${INPUT_SUFFIX}/Helpers/config.json"
echo "[*] setting up default configuration"
# JSON structure with correct indentation
cat << 'EOF' > "$CONFIG_PATH"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF



