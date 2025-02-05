# Linux Forensic Artifact Collector
Introduction:-
The Linux Forensic Artifact Collector is an automated Bash script designed to gather crucial forensic artifacts from a Linux system, whether it's a workstation or server. This tool assists security analysts, incident responders, and DFIR professionals in efficiently collecting system logs, network activity, running processes, browser artifacts, and file activity details.

#NOTE: 
The script is built to run with sudo/root privileges and ensures that key forensic evidence is preserved in a structured format. The collected data is then compressed and stored in the Downloads directory for further analysis.

#Working Model:-
1️⃣ System Identification
The script first determines whether the system is a workstation (GUI-based) or a server (headless).
This helps in adjusting the type of artifacts collected based on the environment.

2️⃣ Key Forensic Artifacts Collected
System Information: Kernel details, OS version, release information.
User Authentication Logs: Logs from /var/log/auth.log, /var/log/secure, and currently logged-in users.
Running Processes & Services: Lists active processes and system services.
Crontab & Scheduled Tasks: Captures user cron jobs and scheduled tasks.
Network Activity: Open ports, active network connections, and firewall rules.
File System & Configuration Changes: Captures recent modifications in system configuration files.
Shell History: Collects command history from .bash_history for user and root.
System Errors & Logs: Extracts errors and warning messages from system logs.
Browser Artifacts: Collects browsing history and settings from Firefox, Chrome, and Chromium.
File Activity Monitoring: Uses inotifywait to track file creation, modification, and deletion in real-time.

3️⃣ Ensuring Required Tools are Available
The script checks for inotifywait, a necessary tool for monitoring file activity.
If it is not installed, the script automatically installs it without user interaction.

4️⃣ Data Storage & Compression
All collected artifacts are saved in a timestamped directory within Downloads.
The script then compresses the directory into a tar.gz file for easy retrieval.

5️⃣ Output Location
The final compressed archive is stored in:
~/Linux-Artifacts_<TIMESTAMP>.tar.gz
This ensures that the forensic data remains intact and easily accessible.


#Usage
Run the script with sudo privileges:
sudo ./forensic_collector.sh
Upon execution, the script will:

Detect the system type.
Collect relevant forensic artifacts.
Validate the presence of inotifywait and install it if missing.
Monitor file activities for forensic investigation.
Compress and store the data securely.


Why Use This Tool?
✔ Automates forensic collection for incident response.
✔ Minimal user interaction required.
✔ Stores data in a structured format for easy analysis.
✔ Works on both Workstations & Servers.
✔ Captures critical evidence before it is lost.
