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

# --- Gather total system memory ---
TOTAL_RAM_KB=$(grep -Po 'MemTotal:\s*\K\d+' /proc/meminfo)
if [[ -z "$TOTAL_RAM_KB" ]]; then
    echo "ERROR: Could not determine total RAM."
    exit 1
fi

# --- Calculate parameters (in KiB) ---
MEM_LIMIT_KB=$((TOTAL_RAM_KB * 75 / 100))   # 75% of RAM
ZRAM_LOGICAL_SIZE_KB=$((MEM_LIMIT_KB * 4))  # 4× memory limit

echo "Total RAM:           ${TOTAL_RAM_KB} KiB"
echo "ZRAM mem_limit:      ${MEM_LIMIT_KB} KiB (≈75% of RAM)"
echo "ZRAM logical size:   ${ZRAM_LOGICAL_SIZE_KB} KiB (4× limit)"

# --- Configure /dev/zram0 ---
echo ">>> Configuring /dev/zram0..."
zramctl /dev/zram0 --algorithm lz4 --size "${ZRAM_LOGICAL_SIZE_KB}KiB" || { echo "ERROR: Failed to configure ZRAM"; exit 1; }

# --- Set memory limit if supported ---
if [[ -f /sys/block/zram0/mem_limit ]]; then
    echo "${MEM_LIMIT_KB}K" > /sys/block/zram0/mem_limit || {
        echo "WARNING: Could not set mem_limit (kernel may not support it)."
    }
fi

# --- Format as swap and enable ---
mkswap -U clear /dev/zram0 || { echo "ERROR: Failed to format ZRAM device."; exit 1; }
swapon --discard --priority 100 /dev/zram0 || { echo "ERROR: Failed to enable ZRAM swap."; exit 1; }

# --- Set system swappiness ---
sysctl -w vm.swappiness=200 || { echo "ERROR: Failed to set swappiness."; exit 1; }

# --- Temporary VM tuning: disable page clustering ---
if [[ -f /proc/sys/vm/page-cluster ]]; then
    echo 0 | tee /proc/sys/vm/page-cluster >/dev/null || {
        echo "WARNING: Could not set vm.page-cluster"
    }
fi

echo "ZRAM setup complete for this session."
echo "Verify with: sudo swapon --show"
echo "Verify swappiness with: cat /proc/sys/vm/swappiness"
echo "--- IMPORTANT: These changes are temporary and will be lost on reboot. ---"
