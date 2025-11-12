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

# Calculate memory limit (75% of total RAM)
MEM_LIMIT_BYTES=$((TOTAL_RAM_KB * 1024 * 75 / 100))

# Calculate ZRAM logical size (4× memory limit)
ZRAM_LOGICAL_SIZE_KB=$((MEM_LIMIT_BYTES / 1024 * 4))


echo "Total RAM: $TOTAL_RAM_KB KiB"
echo "Memory limit for ZRAM: $MEM_LIMIT_BYTES bytes (75% of RAM)"
echo "ZRAM logical size: $ZRAM_LOGICAL_SIZE_KB KiB (4× mem limit)"

# Configure and activate ZRAM
zramctl /dev/zram0 --algorithm lz4 --size "${ZRAM_LOGICAL_SIZE_KB}KiB" || { echo "ERROR: Failed to configure ZRAM device."; exit 1; }


# Set memory limit
if [[ -f /sys/block/zram0/mem_limit ]]; then
    echo "$MEM_LIMIT_BYTES" > /sys/block/zram0/mem_limit || { echo "ERROR: Failed to set mem_limit."; exit 1; }
fi


# Format as swap and enable
mkswap -U clear /dev/zram0 || { echo "ERROR: Failed to format ZRAM device."; exit 1; }
swapon --discard --priority 100 /dev/zram0 || { echo "ERROR: Failed to enable ZRAM swap."; exit 1; }

# Set system swappiness
sysctl -w vm.swappiness=200 || { echo "ERROR: Failed to set swappiness."; exit 1; }

echo "ZRAM setup complete for this session."
echo "Verify with: sudo swapon --show"
echo "Verify swappiness with: cat /proc/sys/vm/swappiness"
echo "--- IMPORTANT: These changes are temporary and will be lost on reboot. ---"
