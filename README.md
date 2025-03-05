# DevOps-SRE-Challenge-Series

Day 1 Challenge: Menu-Based System Health Check Script

Objective
The task is to create a menu-driven Bash script that performs essential system health checks, offering users the following options:
Check Disk Usage

Monitor Running Services

Assess Memory Usage

Evaluate CPU Usage

Send a Comprehensive Report via Email Every Four Hours

The script must include exception handling, debugging features, and be user-friendly with clear documentation for beginners.

Solution
Below is the complete Bash script that meets the requirements:

#!/bin/bash

# System Health Check Script
# This script provides a menu-driven interface for performing system health checks
# and sending a comprehensive report via email.

# Configuration
EMAIL="user@example.com"  # Change this to the desired email address

# Check if debug mode is enabled
DEBUG=false
if [ "$1" == "--debug" ]; then
    DEBUG=true
    shift
fi

# Function to check disk usage
check_disk_usage() {
    echo "=== Disk Usage ==="
    if ! command -v df &> /dev/null; then
        echo "Error: 'df' command not found."
        return 1
    fi
    df -h
    echo ""
}

# Function to check services status
check_services() {
    echo "=== Services Status ==="
    if ! command -v systemctl &> /dev/null; then
        echo "Error: 'systemctl' not found. This script requires a systemd-based system."
        return 1
    fi
    running=$(systemctl list-units --type=service --state=running --no-pager --no-legend | wc -l)
    failed=$(systemctl list-units --type=service --state=failed --no-pager --no-legend | wc -l)
    echo "Running services: $running"
    echo "Failed services: $failed"
    if [ $failed -gt 0 ]; then
        echo "Failed services list:"
        systemctl list-units --type=service --state=failed --no-pager --no-legend
    fi
    echo ""
}

# Function to check memory usage
check_memory_usage() {
    echo "=== Memory Usage ==="
    if ! command -v free &> /dev/null; then
        echo "Error: 'free' command not found."
        return 1
    fi
    free -h
    echo ""
}

# Function to check CPU usage
check_cpu_usage() {
    echo "=== CPU Usage ==="
    if ! command -v top &> /dev/null; then
        echo "Error: 'top' command not found."
        return 1
    fi
    if ! command -v bc &> /dev/null; then
        echo "Error: 'bc' command not found, required for CPU calculation."
        return 1
    fi
    idle=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print $1}')
    usage=$(echo "100 - $idle" | bc)
    echo "CPU Usage: $usage%"
    echo ""
}

# Function to send report
send_report() {
    if ! command -v mail &> /dev/null; then
        echo "Error: 'mail' command not found. Please install mailutils or configure email sending."
        return 1
    fi
    report=$(check_disk_usage)
    report+=$(check_services)
    report+=$(check_memory_usage)
    report+=$(check_cpu_usage)
    if echo "$report" | mail -s "System Health Report" "$EMAIL"; then
        echo "Report sent to $EMAIL."
    else
        echo "Error: Failed to send report."
    fi
}

# Check if running in non-interactive mode
if [ "$1" == "--send-report" ]; then
    if $DEBUG; then
        set -x
    fi
    send_report
    exit 0
fi

# Menu loop
while true; do
    echo "System Health Check Menu:"
    echo "1. Check Disk Usage"
    echo "2. Monitor Running Services"
    echo "3. Assess Memory Usage"
    echo "4. Evaluate CPU Usage"
    echo "5. Send Comprehensive Report via Email"
    echo "6. Exit"
    read -p "Select an option (1-6): " choice
    echo ""
    case $choice in
        1)
            check_disk_usage
            ;;
        2)
            check_services
            ;;
        3)
            check_memory_usage
            ;;
        4)
            check_cpu_usage
            ;;
        5)
            send_report
            ;;
        6)
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid option. Please select a number between 1 and 6."
            ;;
    esac
    echo "Press Enter to continue..."
    read
done

How to Use

Running the Script

Interactive Mode: Run the script without arguments to access the menu:

./health_check.sh

Non-Interactive Mode: Use the --send-report flag to send a report immediately:
bash

./health_check.sh --send-report

Debug Mode: Add the --debug flag for verbose output:
./health_check.sh --debug

Scheduling Reports
To send reports every four hours, set up a cron job:
Open the crontab editor

crontab -e

Add the following line to run the script every four hours

0 */4 * * * /path/to/health_check.sh --send-report

This schedules the script to run at the start of every fourth hour (eg: 12:00, 4:00, 8:00).

Configuration

Email Address: Edit the EMAIL variable at the top of the script to set the recipeint email address:

EMAIL="your_email@example.com"

Ensure the system has a mail server configured (e.g., mailutils installed and set up).

Features
System Health Checks
Check Disk Usage: Displays disk usage for all mounted filesystems in a human-readable format using df -h.

Monitor Running Services: Reports the number of running and failed services using systemctl, listing any failed services.

Assess Memory Usage: Shows memory and swap usage with free -h.

Evaluate CPU Usage: Calculates the CPU usage percentage by parsing top -bn1 output.

Comprehensive Report
Option 5 generates a report combining all health check outputs and sends it to the specified email address using the mail command.

Exception Handling
Each function checks for the availability of required commands (e.g., df, systemctl, free, top, bc, mail).

Errors are reported to the user with clear messages if a command is missing or fails.

Debugging Features
The --debug flag enables command tracing with set -x, allowing users to see the exact commands executed.

User-Friendly Design
Clear menu with numbered options.

Descriptive output with section headers (e.g., === Disk Usage ===).

Graceful handling of invalid inputs.

Prompt to press Enter after each action to keep the screen readable.

Documentation
Challenges Faced
Ambiguity in "Every Four Hours": The requirement to "send a report every four hours" as a menu option was unclear. I interpreted it as sending a report immediately when selected, with scheduling handled separately via cron.

Service Monitoring: Deciding which services to monitor was tricky. I settled on summarizing running and failed services for simplicity.

CPU Usage Calculation: Parsing top output required careful handling to extract the idle percentage accurately.

Email Sending: Ensuring email functionality depended on system configuration, which might not be set up on all systems.

Solutions Implemented
Dual-Mode Script: Added a --send-report flag for non-interactive report sending, allowing cron scheduling, while keeping the menu interactive.

Simplified Services Check: Used systemctl to count running and failed services, listing failures for detail.

Robust CPU Calculation: Used sed and bc to reliably compute CPU usage from top output.

Email Configuration Note: Hardcoded the email address with a comment to change it, assuming mail is configured, and added error checking.

Key Concepts Learned
Bash Scripting: Improved skills in functions, command output capture, and menu loops.

System Monitoring: Gained practical experience with tools like df, systemctl, free, and top.

Error Handling: Learned to check command availability and handle failures in Bash.

Cron Scheduling: Understood how to automate tasks using cron for periodic execution.

Submission Guidelines
GitHub Repository: Create a new repository named system-health-check and upload health_check.sh.

Documentation: Include a README.md with:
Script purpose and usage instructions.

Setup steps (e.g., installing dependencies, configuring email).

The challenges, solutions, and concepts documented above.

This script provides a practical tool for system monitoring, balancing functionality with beginner-friendly design, and serves as a foundation for further enhancements in system reliability engineering tasks.


