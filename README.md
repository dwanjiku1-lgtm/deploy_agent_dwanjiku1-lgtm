# deploy_agent_dwanjiku1-lgtm
# summative repository
# Student Attendance Tracker — Project Factory
### By David Wanjiku

# A shell script that automatically builds a complete Student Attendance Tracker workspace on your computer. It creates all the folders, writes all the config files, lets you customize your settings, and even cleans up safely if something goes wrong.

---

## How to Run the Script

**Step 1 — Open Git Bash and navigate to your project folder:**
```bash
cd ~/deploy_agent_dwanjiku1-lgtm
```

**Step 2 — Make the script executable:**
```bash
chmod +x setup_project.sh
```

**Step 3 — Run it:**
```bash
./setup_project.sh
```

**Step 4 — Follow the prompts:**
- Type your project name when asked
- Choose whether to update the attendance thresholds
- Watch the health check confirm everything is set up correctly

---

## What the Script Does Step by Step

---

### Part 1 — Safety Net (The Trap)

```bash
cleanup_on_interrupt() {
    echo -e "\n\n[!] process stopped by user (SIGINT / Ctrl+C)."
    if [ -d "attendance_tracker_${INPUT_SUFFIX}" ]; then
        ARCHIVE_NAME="attendance_tracker_${INPUT_SUFFIX}_archive.tar.gz"
        echo "[*] packing up files and saving them to: $ARCHIVE_NAME"
        tar -czf "$ARCHIVE_NAME" "attendance_tracker_${INPUT_SUFFIX}" 2>/dev/null
        echo "[*] removing the incomplete folders.."
        rm -rf "attendance_tracker_${INPUT_SUFFIX}"
        echo "remove successful"
    fi
    exit 1
}

trap 'cleanup_on_interrupt' SIGINT
```

**What the code does**

# Think of this as a safety net. Before the script starts doing any work, it sets up a guard that watches for the user pressing **Ctrl+C**. If the user cancels at any point:

1. The guard catches the cancel signal
2. Checks if a project folder was already created
3. If yes — bundles everything inside it into a compressed backup file (.tar.gz)
4. Deletes the incomplete folder so no messy half-built files are left behind
5. Exits the script cleanly

The `trap` line is the actual guard registration — it tells bash "if Ctrl+C is pressed at any point, run the cleanup function instead of just stopping"

**Key commands used:**
- `tar -czf` → bundles and compresses the folder into one archive file
- `2>/dev/null` → silently throws away any error messages so the terminal stays clean
- `rm -rf` → force deletes the folder and everything inside it with no confirmation

---

### Part 2 — Directory Architecture

```bash
echo "Students attendance tracker"
read -p "Enter your name" INPUT_SUFFIX

if [ -z "$INPUT_SUFFIX" ]; then
    echo "Name required"
    exit 1
fi

mkdir -p "attendance_tracker_${INPUT_SUFFIX}/Helpers"
mkdir -p "attendance_tracker_${INPUT_SUFFIX}/reports"

touch "attendance_tracker_${INPUT_SUFFIX}/attendance_checker.py"
touch "attendance_tracker_${INPUT_SUFFIX}/Helpers/config.json"
touch "attendance_tracker_${INPUT_SUFFIX}/Helpers/assets.csv"
touch "attendance_tracker_${INPUT_SUFFIX}/reports/reports.log"

echo "directory structure created"
```

**What this  code does:**

# This section asks the user for a name and uses it to build the entire project folder structure automatically. Think of it like a construction crew that builds the house frame before anything else goes inside.

- `read -p` → pauses the script and waits for the user to type something
- `if [ -z "$INPUT_SUFFIX" ]` → checks if the user typed nothing. If empty, the script stops immediately
- `mkdir -p` → creates the folders. The -p flag means it creates parent folders too so you never get an error about a folder not existing yet
- `touch` → creates empty files in the right locations, ready to be filled with content

The result is this folder structure:
```
attendance_tracker_yourname/
├── attendance_checker.py
├── Helpers/
│   ├── config.json
│   └── assets.csv
└── reports/
    └── reports.log
```

---

### Part 3 — Writing the Config File

```bash
CONFIG_PATH="attendance_tracker_${INPUT_SUFFIX}/Helpers/config.json"
echo "[*] setting up default configuration"

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
```

**What this code does**

# This section writes the default settings into the config.json file automatically. Think of it like a script that pre-fills a form with default answers before handing it to you.

- `CONFIG_PATH=` → saves the full path to config.json in a variable so we do not have to type the long path every time
- `cat << 'EOF' > "$CONFIG_PATH"` → everything between the two EOF markers gets written directly into the config file. This is called a heredoc — like opening a mini text editor inside your script
- The JSON content sets:
  - `warning: 75` → students below 75% attendance get a warning
  - `failure: 50` → students below 50% attendance fail
  - `run_mode: live` → the app runs in live mode
  - `total_sessions: 15` → there are 15 classes in total

---

### Part 4 — Updating Attendance Thresholds

```bash
read -p "Do you want to update the default attendance? (y/N): " UPDATE_CHOICE

if [[ "$UPDATE_CHOICE" =~ ^[Yy]$ ]]; then
    read -p "Enter Warning Threshold (Default 75): " WARN_VAL
    read -p "Enter Failure Threshold (Default 50): " FAIL_VAL

    WARN_VAL=${WARN_VAL:-75}
    FAIL_VAL=${FAIL_VAL:-50}

    sed -i "s/'warning': *[0-9]*/'warning': $WARN_VAL/g" "$CONFIG_PATH" 2>/dev/null || \
    sed -i 's/"warning": *[0-9]*/"warning": '$WARN_VAL'/g' "$CONFIG_PATH"

    sed -i "s/'failure': *[0-9]*/'failure': $FAIL_VAL/g" "$CONFIG_PATH" 2>/dev/null || \
    sed -i 's/"failure": *[0-9]*/"failure": '$FAIL_VAL'/g' "$CONFIG_PATH"

    echo "[+] configuration values updated successfully!"
fi
```

**What the code does**

# This section gives the user a chance to change the default passing and failing percentages. Think of it like a settings screen where you can customize things before the app launches.

- `read -p` → asks the user yes or no
- `=~ ^[Yy]$` → only accepts y or Y as a yes answer. Anything else is treated as no
- `WARN_VAL=${WARN_VAL:-75}` → if the user just pressed Enter without typing a number, it automatically falls back to 75. The :-75 part means "use 75 if empty"
- `sed -i` → opens the config.json file, finds the old number and replaces it with the new one the user typed, directly inside the file
- The `||` between the two sed commands means "if the first attempt fails, try the second version"

---

### Part 5 — Health Check

```bash
HEALTH_STATUS="PASSED"

if [ -d "attendance_tracker_${INPUT_SUFFIX}/Helpers" ] && [ -d "attendance_tracker_${INPUT_SUFFIX}/reports" ]; then
    echo "[+] Structural check: Required workspace folder verified"
else
    echo "[-] Structural Check FAILED: workspace folder missing or broken."
    HEALTH_STATUS="FAILED"
fi

if [ -f "$CONFIG_PATH" ]; then
    if grep -q '"thresholds"' "$CONFIG_PATH" && grep -q '"run_mode"' "$CONFIG_PATH"; then
        echo "config.json is set and verified"
    else
        echo "config.json file exists but the content is broken"
        HEALTH_STATUS="FAILED"
    fi
else
    echo "[-] Integrity Check FAILED: config.json file was not generated."
    HEALTH_STATUS="FAILED"
fi
```

**What this code does**

# This section is like a final inspection before handing over the keys. It double checks that everything was built correctly and nothing is missing. It runs two checks:

**Check 1 — Folder Structure:**
- `-d` → checks if a directory exists on disk
- `&&` → both folders must exist for this to pass
- If either Helpers/ or reports/ is missing it raises a red flag

**Check 2 — Config File Content:**
- `-f` → checks if the config.json file exists
- `grep -q` → silently searches inside the file for specific words without printing anything
- It looks for both "thresholds" and "run_mode" inside the file
- If the file exists but those words are missing it means something went wrong when writing the file

The `HEALTH_STATUS` variable works like a scoreboard — it starts as PASSED and gets changed to FAILED the moment any check goes wrong.

---

### Part 6 — Final Result

```bash
if [ "$HEALTH_STATUS" == "PASSED" ]; then
    echo "=== SYSTEM HEALTH STATUS: [ PASSED ] =="
    echo "[+] Deployment environment is 100% healthy and operational"
else
    echo "=== SYSTEM HEALTH STATUS: [ CRITICAL FAILURE ] ==="
    echo "[-] Environment build failed. please evaluate the script errors."
    exit 1
fi
```

**What this  code does**

# This is the final verdict. After all the checks are done the script looks at the HEALTH_STATUS scoreboard:

- If it still says PASSED → everything went well, print a success message and finish
- If it says FAILED → something went wrong, print an error message and exit with code 1 which signals to the system that the script did not complete successfully

---

## How to Trigger the Archive Feature

The archive feature activates automatically when you press **Ctrl+C** during the script.

**To test it:**
```bash
./setup_project.sh
```
Type your project name when asked, then immediately press **Ctrl+C**

You will see:
```
[!] process stopped by user (SIGINT / Ctrl+C).
[*] packing up files and saving them to: attendance_tracker_test_archive.tar.gz
[*] removing the incomplete folders..
remove successful
```

**To confirm it worked:**
```bash
ls
```
You should see the archive file and the incomplete folder gone:
```
attendance_tracker_test_archive.tar.gz
```

**To peek inside the archive without extracting:**
```bash
tar -tzf attendance_tracker_test_archive.tar.gz
```

**To extract and recover the files:**
```bash
tar -xzf attendance_tracker_test_archive.tar.gz
```

---

## Project Folder Structure After Running

```
deploy_agent_dwanjiku1-lgtm/
├── setup_project.sh
├── attendance_tracker_yourname/
│   ├── attendance_checker.py
│   ├── Helpers/
│   │   ├── config.json
│   │   └── assets.csv
│   └── reports/
│       └── reports.log
└── README.md
```

---
