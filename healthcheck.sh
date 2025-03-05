#!/bin/bash

# System Health Check Script
# This script provides a menu-driven interface for performing system health checks
# and sending a comprehensive report via email.

# Configuration
EMAIL="user@localhost.localdomain.com"  # Change this to the desired email address

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
