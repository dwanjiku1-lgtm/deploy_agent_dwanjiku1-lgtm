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

# ======================================================================================
# Adjusting attendance settings
# ======================================================================================
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



# ==================================================================================
# System Integrity & Health check
# ==================================================================================
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
