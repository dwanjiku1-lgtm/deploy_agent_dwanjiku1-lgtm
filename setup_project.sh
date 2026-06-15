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
touch "attendance_tracker_${INPUT_SUFFIX}/Helpers/config.json"
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

ASSETS_PATH="attendance_tracker_${INPUT_SUFFIX}/Helpers/assets.csv"
echo "injecting assets.csv into Helpers/"
cat << 'EOF' > "$ASSETS_PATH"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

SCRIPT_PATH="attendance_tracker_${INPUT_SUFFIX}/attendance_checker.py"
echo "injecting attendance cheker into attendance_checker.py/"
cat << 'EOF' > "$SCRIPT_PATH"
import csv
import json
import os
from datetime import datetime
def run_attendance_check():
# 1. Load Config
with open('Helpers/config.json', 'r') as f:
config = json.load(f)
# 2. Archive old reports.log if it exists
if os.path.exists('reports/reports.log'):
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
os.rename('reports/reports.log',
f'reports/reports_{timestamp}.log.archive')
# 3. Process Data
with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log',
'w') as log:
reader = csv.DictReader(f)
total_sessions = config['total_sessions']
log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
for row in reader:
name = row['Names']
email = row['Email']
attended = int(row['Attendance Count'])
# Simple Math: (Attended / Total) * 100
attendance_pct = (attended / total_sessions) * 100
message = ""
if attendance_pct < config['thresholds']['failure']:
message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}
%. You will fail this class."
elif attendance_pct < config['thresholds']['warning']:
message = f"WARNING: {name}, your attendance is
{attendance_pct:.1f}%. Please be careful."
if message:
if config['run_mode'] == "live":
log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}
\n")
print(f"Logged alert for {name}")
else:
print(f"[DRY RUN] Email to {email}: {message}")
if __name__ == "__main__":
run_attendance_check()
EOF

LOG_PATH="attendance_tracker_${INPUT_SUFFIX}/reports/reports.log"
echo "injecting reports.lo into reports/"
cat << 'EOF' > "$LOG_PATH"
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

# Adjusting attendance settings


echo "..................................."
read -p "Do you want to update the default attendance ? (y/N): " UPDATE_CHOICE

# Evaluate preference safely using  expressions
if [[ "$UPDATE_CHOICE" =~ ^[Yy]$ ]]; then
	read -p "Enter Warning Threshold (Default 75): " WARN_VAL
	read -p "Enter Failure Threshold (Default 50): " FAIL_VAL

	# if nothing is typed stick  with the original 75% and 50% default
	WARN_VAL=${WARN_VAL:-75}
	FAIL_VAL=${FAIL_VAL:-50}

	echo "[*] Modifying configuration on_the_fly via sed.."
	sed -i "s/'warning': *[0-9]*/'warning': $WARN_VAL/g" "$CONFIG_PATH" 2>/dev/null || sed -i 's/"warning": *[0-9]*/"warning": '$WARN_VAL'/g' "$CONFIG_PATH"
	sed -i "s/'failure': *[0-9]*/'failure': $FAIL_VAL/g" "$CONFIG_PATH" 2>/dev/null || sed -i 's/"failure": *[0-9]*/"failure": '$FAIL_VAL'/g' "$CONFIG_PATH"
	echo "[+] configuration values updated successfully!"

fi




# System Integrity & Health check

echo "......................................"
echo "[*] Launching system architecture Health check"

HEALTH_STATUS="PASSED"

if [ -d "attendance_tracker_${INPUT_SUFFIX}/Helpers" ] && [ -d "attendance_tracker_${INPUT_SUFFIX}/reports" ]; then
	echo "[+] Structural check: Required workspace folder verified"
else
	echo "[-] Structural Check FAILED: workspace folder missing or broken."
	HEALTH_STATUS="FAILED"
fi

# file verification scan
if [ -f "$CONFIG_PATH" ]; then
	# confirmation of vital configuration parameter if they exist
	if grep -q '"thresholds"' "$CONFIG_PATH" && grep -q '"run_mode"' "$CONFIG_PATH"; then

		echo "config.json is set  and verified"
	else
		echo "config.json file  exist but the content is corrupt"
		HEALTH_STATUS="FAILED"
	fi
else
	echo "[-] Integrity Check FAILED: config.json file was not generated."
	HEALTH_STATUS="FAILED"
fi

# final deployment verdict evaluation
echo "----------------------------------------"
if [ "$HEALTH_STATUS" == "PASSED" ]; then
	echo "=== SYSTEM HEALTH STATUS: [ PASSED ] =="
	echo "[+] Deployment environment is 100% healthy and operational"
else
	echo "=== SYSTEM HEALTH STATUS: [ CRITICAL FAILURE ] ==="
	echo "[-] Environment build failed. please evaluate the script errors."
	exit 1
fi

#environment validation
# Check if python3 is installed on the system
if python3 --version &>/dev/null; then
    PY_VERSION=$(python3 --version 2>&1)
    echo "[+] Python3 is installed: $PY_VERSION"
else
    echo "[!] Warning: python3 was not found on this system."
    echo "    Install it before running attendance_checker.py"
fi

