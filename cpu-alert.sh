#!/bin/bash

THRESHOLD=80  # CPU usage limit
EMAIL=b0900075@gmail.com  # Replace with your actual email
LOG_FILE="/var/log/cpu_monitor.log"  # Log file for troubleshooting

# Get the highest CPU usage percentage (ignoring the first line)
HIGH_CPU_PROCESS=$(ps -eo pid,comm,%cpu --sort=-%cpu | awk 'NR==2 {print $3}')

# Ensure we got a valid number
if [[ -z "$HIGH_CPU_PROCESS" ]]; then
    echo "$(date):Error: Could not retrieve CPU usage data." | tee -a "$LOG_FILE"
    exit 1
fi

# Check if CPU usage is above the threshold
if (( $(echo "$HIGH_CPU_PROCESS > $THRESHOLD" | bc -l) )); then
    MESSAGE="Alert: A process is consuming more than $THRESHOLD% CPU! Usage: $HIGH_CPU_PROCESS%"
else
    MESSAGE="System is stable. No process is exceeding $THRESHOLD% CPU."
fi

# Send email and log the message
echo "$MESSAGE" | mail -s "CPU Usage Alert" "$EMAIL" && echo "$(date): $MESSAGE" >> "$LOG_FILE"
