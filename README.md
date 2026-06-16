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

# The video to explain how the codes work
https://drive.google.com/file/d/1VmfCVID01tn-tRlUjOhbk6kdjMKuxEzB/view?usp=drive_link
