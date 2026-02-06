#!/usr/bin/env bash
#
# lima-list.sh - Simple, colorful output for limactl list
#
# Usage: ./scripts/lima-list.sh

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

# Icons
readonly RUNNING_ICON="●"
readonly STOPPED_ICON="○"

# Print header
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${CYAN}Lima VMs${RESET}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# Parse limactl list output
limactl list | tail -n +2 | while read -r line; do
    # Parse columns using awk
    name=$(echo "$line" | awk '{print $1}')
    status=$(echo "$line" | awk '{print $2}')
    ssh=$(echo "$line" | awk '{print $3}')
    cpus=$(echo "$line" | awk '{print $4}')
    memory=$(echo "$line" | awk '{print $5}')
    disk=$(echo "$line" | awk '{print $6}')

    # Skip if no name (empty line)
    [[ -z "$name" ]] && continue

    # Format status with color
    if [[ "$status" == "Running" ]]; then
        status_display="${GREEN}${RUNNING_ICON} Running${RESET}"
    else
        status_display="${RED}${STOPPED_ICON} Stopped${RESET}"
    fi

    # Format SSH
    if [[ "$ssh" == "127.0.0.1:0" ]]; then
        ssh_color="${RED}"
        ssh_text="-"
    else
        ssh_color="${GREEN}"
        ssh_text="$ssh"
    fi

    # Print formatted line with proper escaping
    printf "%b%-20s%b %b\n" "${BOLD}" "${name}" "${RESET}" "${status_display}"
    printf "  %bSSH:%b    %b%-30s%b %bCPUs:%b %s\n" "${CYAN}" "${RESET}" "${ssh_color}" "${ssh_text}" "${RESET}" "${CYAN}" "${RESET}" "$cpus"
    printf "  %bMemory:%b %-20s %bDisk:%b %s\n" "${CYAN}" "${RESET}" "$memory" "${CYAN}" "${RESET}" "$disk"
    echo ""
done

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════${RESET}"

# Print summary
total=$(limactl list | tail -n +2 | wc -l | xargs)
running=$(limactl list | tail -n +2 | grep -c "Running" || echo "0")
stopped=$(limactl list | tail -n +2 | grep -c "Stopped" || echo "0")

echo -e "${BOLD}Total:${RESET} $total VMs  |  ${GREEN}${RUNNING_ICON} Running:${RESET} $running  |  ${RED}${STOPPED_ICON} Stopped:${RESET} $stopped"
echo ""
