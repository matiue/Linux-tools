#!/bin/bash

# --- Quick Temporary ZRAM Setup ---

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root. Please use 'sudo $0'."
    exit 1
fi

echo "Setting up temporary ZRAM swap..."

# Load the zram kernel module
modprobe zram || { echo "ERROR: Failed to load zram module."; exit 1; }

# Calculate total RAM in KiB and use it as ZRAM size
# Note: This sets ZRAM size to 100% of your RAM. You might prefer 50% for typical use.
TOTAL_RAM_KB=$(grep -Po 'MemTotal:\s*\K\d+' /proc/meminfo)
if [[ -z "$TOTAL_RAM_KB" ]]; then
    echo "ERROR: Could not determine total RAM. Exiting."
    exit 1
fi

# Configure and activate ZRAM
zramctl /dev/zram0 --algorithm zstd --size "${TOTAL_RAM_KB}KiB" || { echo "ERROR: Failed to configure ZRAM device."; exit 1; }
mkswap -U clear /dev/zram0 || { echo "ERROR: Failed to format ZRAM device."; exit 1; }
swapon --discard --priority 100 /dev/zram0 || { echo "ERROR: Failed to enable ZRAM swap."; exit 1; }

# Set system swappiness
sysctl -w vm.swappiness=200 || { echo "ERROR: Failed to set swappiness."; exit 1; }

echo "ZRAM setup complete for this session."
echo "Verify with: sudo swapon --show"
echo "Verify swappiness with: cat /proc/sys/vm/swappiness"
echo "--- IMPORTANT: These changes are temporary and will be lost on reboot. ---"
