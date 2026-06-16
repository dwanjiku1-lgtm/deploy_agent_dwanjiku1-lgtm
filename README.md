# Student Attendance Tracker — Project Factory
### By David Wanjiku (dwanjiku1-lgtm)

A shell script that automatically builds a complete Student Attendance Tracker workspace on your computer. It creates all the folders, writes all the files, lets you customize your settings, and even cleans up safely if something goes wrong.

---

## How to Run the Script

**Step 1 — Open Git Bash and navigate to your project folder:**
```bash
cd ~/deploy_agent_dwanjiku1-lgtm
```

**Step 2 — Make the script executable (only needed once):**
```bash
chmod +x setup_project.sh
```

**Step 3 — Run it:**
```bash
./setup_project.sh
```

**Step 4 — Follow the prompts on screen:**
- Type your name when asked
- Choose whether to update the attendance thresholds
- Watch the health check confirm everything is ready

---

## What the Script Does — Step by Step

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

**What this code does**

Before the script starts doing any real work, it sets up a safety net. Think of it like a security guard standing at the door of your script watching for any sign of trouble.

If you press Ctrl+C at any point while the script is running, the guard catches it and does the following automatically:

1. Checks if a project folder was already created on disk
2. If yes — bundles everything inside it into one compressed backup file
3. Deletes the incomplete folder so no messy half-built files are left behind
4. Exits the script cleanly

**Breaking down each command:**

- `cleanup_on_interrupt()` — this is a function, like a mini script inside the main script. It only runs when called
- `if [ -d "attendance_tracker_${INPUT_SUFFIX}" ]` — checks if the project folder exists. The `-d` means "is this a directory?"
- `ARCHIVE_NAME=` — creates a variable holding the name of the backup file, for example `attendance_tracker_david_archive.tar.gz`
- `tar -czf` — the actual command that bundles and compresses the folder into one file. The letters mean: **c** = create, **z** = compress with gzip, **f** = save to a file
- `2>/dev/null` — silently throws away any error messages. Think of `/dev/null` as a black hole that swallows anything sent to it
- `rm -rf` — force deletes the folder and everything inside it instantly with no confirmation asked
- `trap 'cleanup_on_interrupt' SIGINT` — this is the line that actually registers the safety net. It tells bash "if Ctrl+C is pressed at any point, run the cleanup function"

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

**What this code does**

This section asks the user for a name and uses it to build the entire project folder structure automatically. Think of it like a construction crew that builds the house frame before anything else goes inside.

**Breaking down each command:**

- `echo` — prints a message to the terminal so the user knows the script has started
- `read -p "Enter your name" INPUT_SUFFIX` — pauses the script and waits for the user to type something. Whatever is typed gets saved into the variable called `INPUT_SUFFIX`. So if you type `david` the folder will be called `attendance_tracker_david`
- `if [ -z "$INPUT_SUFFIX" ]` — checks if the user typed nothing and just pressed Enter. The `-z` means "is this empty?" If empty the script stops immediately with `exit 1`
- `mkdir -p` — creates the folders. The `-p` flag means create parent folders automatically so you never get an error about a folder not existing yet
- `touch` — creates empty files in the right locations, ready to be filled with content later

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

### Part 3 — Writing All the Files Automatically

This section writes the actual content into each file. Think of it like a robot that types everything into the right files for you so you never have to do it manually.

The technique used is called a **heredoc** — it works like this:
```bash
cat << 'EOF' > "destination_file"
everything written here goes into the file
EOF
```
Everything between the two `EOF` markers gets written directly into the file. Simple as that.

---

**3a — Writing config.json**

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

- `CONFIG_PATH=` — saves the full file path into a variable so we do not have to type it out every time
- The JSON content sets the default rules:
  - `warning: 75` — students below 75% attendance get a warning
  - `failure: 50` — students below 50% attendance fail the course
  - `run_mode: live` — the app will actually send alerts, not just pretend
  - `total_sessions: 15` — there are 15 classes in total

---

**3b — Writing assets.csv**

```bash
ASSETS_PATH="attendance_tracker_${INPUT_SUFFIX}/Helpers/assets.csv"
echo "injecting assets.csv into Helpers/"

cat << 'EOF' > "$ASSETS_PATH"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
```

This writes a CSV file containing four sample students with their email addresses and how many classes they attended and missed. The Python app reads this file to calculate each student's attendance percentage.

---

**3c — Writing attendance_checker.py**

```bash
SCRIPT_PATH="attendance_tracker_${INPUT_SUFFIX}/attendance_checker.py"
echo "injecting attendance checker into attendance_checker.py"

cat << 'EOF' > "$SCRIPT_PATH"
import csv
import json
...
EOF
```

This writes the entire Python application directly into the file. The Python script does the following when you run it:

1. Opens config.json and reads the threshold percentages
2. Archives the old reports.log if one already exists
3. Opens assets.csv and reads each student row
4. Calculates attendance percentage for each student using this simple formula: (classes attended divided by total sessions) multiplied by 100
5. If the percentage is below the failure threshold it writes an URGENT alert
6. If the percentage is below the warning threshold it writes a WARNING alert
7. Saves everything into reports.log

---

**3d — Writing reports.log**

```bash
LOG_PATH="attendance_tracker_${INPUT_SUFFIX}/reports/reports.log"
echo "injecting reports.log into reports/"

cat << 'EOF' > "$LOG_PATH"
--- Attendance Report Run: 2026-02-06 18:10:01 ---
[2026-02-06 18:10:01] ALERT SENT TO bob@example.com: URGENT: Bob Smith...
EOF
```

This writes a sample report into reports.log so the file is not empty when the project is first created. When you actually run the Python app later it will overwrite this with a fresh real report.

---

### Part 4 — Adjusting Attendance Settings

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

**What this code does**

This section gives you a chance to change the default pass and fail percentages before the app runs. Think of it like a settings screen where you customize things to match your school's rules.

**Breaking down each command:**

- `read -p "Do you want to update..."` — asks yes or no and saves the answer
- `=~ ^[Yy]$` — only accepts lowercase `y` or uppercase `Y` as a yes. Anything else like `yes` or `yeah` is treated as no
- `WARN_VAL=${WARN_VAL:-75}` — if you just pressed Enter without typing a number it automatically falls back to 75. The `:-75` part means "use 75 if the variable is empty"
- `sed -i` — opens the config.json file and finds the old number and replaces it with your new number directly inside the file without creating any temporary copy. This is called stream editing
- The `||` between the two sed commands means "if the first attempt fails, try this second version instead." This exists because Windows and Mac handle quotes slightly differently

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
        echo "config.json file exists but the content is corrupt"
        HEALTH_STATUS="FAILED"
    fi
else
    echo "[-] Integrity Check FAILED: config.json file was not generated."
    HEALTH_STATUS="FAILED"
fi
```

**What this code does**

This section is like a final inspection before handing over the keys. It checks that everything was built correctly and nothing is missing. It runs two separate checks:

**Check 1 — Folder Structure:**
- `-d` — checks if a directory exists on disk
- `&&` — both folders must exist for this check to pass. If either one is missing it fails
- `HEALTH_STATUS="FAILED"` — this is like raising a red flag. The variable starts as PASSED and only changes to FAILED when something goes wrong

**Check 2 — Config File Content:**
- `-f` — checks if a file exists on disk
- `grep -q` — silently searches inside the file for a specific word without printing anything to the terminal. It just returns true or false
- It searches for both `"thresholds"` and `"run_mode"` inside config.json to confirm the content was written correctly
- If the file exists but those words are missing inside it, the content check fails

---

### Part 6 — Python3 Environment Validation

```bash
if python3 --version &>/dev/null; then
    PY_VERSION=$(python3 --version 2>&1)
    echo "[+] Python3 is installed: $PY_VERSION"
else
    echo "[!] Warning: python3 was not found on this system."
    echo "    Install it before running attendance_checker.py"
fi
```

**What this code does**

This checks if Python3 is installed on your computer because without it the attendance_checker.py file cannot run.

- `python3 --version &>/dev/null` — quietly runs the python3 version command. If python3 exists it returns true, if not it returns false. The `&>/dev/null` makes sure nothing prints to the terminal at this stage
- `PY_VERSION=$(python3 --version 2>&1)` — if python3 is found this captures the version text like `Python 3.11.2` and saves it into a variable
- If python3 is missing a warning is printed telling the user to install it before trying to run the Python app

---

### Part 7 — Final Result

```bash
echo "----------------------------------------"
if [ "$HEALTH_STATUS" == "PASSED" ]; then
    echo "=== SYSTEM HEALTH STATUS: [ PASSED ] =="
    echo "[+] Deployment environment is 100% healthy and operational"
else
    echo "=== SYSTEM HEALTH STATUS: [ CRITICAL FAILURE ] ==="
    echo "[-] Environment build failed. please evaluate the script errors."
    exit 1
fi
```

**What this code does**

This is the final verdict. After all the checks are done the script looks at the HEALTH_STATUS variable like checking a scoreboard:

- If it still says PASSED — everything went perfectly, print a success message and finish
- If it says FAILED — something went wrong somewhere, print an error message and exit with code 1 which tells the system the script did not complete successfully

---

## How to Trigger the Archive Feature (Testing the Trap)

The archive feature fires automatically when you press Ctrl+C during the script.

**Step 1 — Run the script:**
```bash
./setup_project.sh
```

**Step 2 — Type your name when asked:**
```
Enter your name: david
```

**Step 3 — Press Ctrl+C immediately**

You will see this in the terminal:
```
[!] process stopped by user (SIGINT / Ctrl+C).
[*] packing up files and saving them to: attendance_tracker_david_archive.tar.gz
[*] removing the incomplete folders..
remove successful
```

**Step 4 — Confirm it worked:**
```bash
ls
```
You should see the archive file created and the incomplete folder gone:
```
attendance_tracker_david_archive.tar.gz   ✔ backup saved
```

**Step 5 — Peek inside the archive without extracting:**
```bash
tar -tzf attendance_tracker_david_archive.tar.gz
```

**Step 6 — Extract and recover everything:**
```bash
tar -xzf attendance_tracker_david_archive.tar.gz
```

---

## Project Folder Structure After Running

```
deploy_agent_dwanjiku1-lgtm/
├── setup_project.sh
├── README.md
└── attendance_tracker_yourname/
    ├── attendance_checker.py
    ├── Helpers/
    │   ├── config.json
    │   └── assets.csv
    └── reports/
        └── reports.log
```

---


