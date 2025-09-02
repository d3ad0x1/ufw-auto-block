#!/bin/bash
# ufw-auto-block.sh
# Automatic IP/subnet blocking based on UFW logs with unblock option

LOG_FILE="/var/log/ufw.log"
BLOCK_LOG="/var/log/ufw-blocked.log"
THRESHOLD=5          # Number of attempts in a time window before blocking
TIME_WINDOW=10       # Time window in minutes for log analysis

# -----------------------
# Root privileges check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo)!" 
   exit 1
fi

# -----------------------
# Logging function (avoids duplicates)
log_block() {
    local addr="$1"
    local type="$2"
    if ! grep -q "$addr" "$BLOCK_LOG" 2>/dev/null; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') | $type | $addr" >> "$BLOCK_LOG"
    fi
}

# -----------------------
# Function to unblock all IPs/subnets from the block log
ufw_unblock_all() {
    if [ ! -f "$BLOCK_LOG" ]; then
        echo "Block log not found!"
        exit 1
    fi
    while read -r line; do
        addr=$(echo $line | awk -F'|' '{print $3}' | xargs)
        if sudo ufw status | grep -q "$addr"; then
            sudo ufw delete deny from $addr
            echo "Unblocked $addr"
        fi
    done < "$BLOCK_LOG"
    echo "All IPs and subnets from the log have been unblocked."
    > "$BLOCK_LOG"
}

# -----------------------
# If called with 'unblock', perform unblock and exit
if [ "$1" == "unblock" ]; then
    ufw_unblock_all
    exit 0
fi

# -----------------------
# Start time for log filtering
TIME_START=$(date --date="$TIME_WINDOW minutes ago" "+%b %e %H:%M:%S")

# Extract sources from UFW logs
SOURCES=$(awk -v start="$TIME_START" '$0 > start {print $0}' $LOG_FILE \
          | grep "UFW BLOCK" \
          | awk '{for(i=1;i<=NF;i++){if ($i ~ /^SRC=/){print substr($i,5)}}}' \
          | sort)

IPS4=$(echo "$SOURCES" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
IPS6=$(echo "$SOURCES" | grep -Eo '([0-9a-fA-F:]+:+[0-9a-fA-F:]*)')

# -----------------------
# IPv4 processing
if [ -n "$IPS4" ]; then
    for ip in $(echo "$IPS4" | uniq -c | awk -v threshold=$THRESHOLD '$1 >= threshold {print $2}'); do
        if ! sudo ufw status | grep -q "$ip"; then
            sudo ufw deny from $ip
            log_block "$ip" "IPv4 IP"
            echo "[Blocked IPv4] $ip"
        fi
        subnet=$(echo $ip | awk -F. '{print $1"."$2"."$3".0/24"}')
        if ! sudo ufw status | grep -q "$subnet"; then
            sudo ufw deny from $subnet
            log_block "$subnet" "IPv4 Subnet /24"
            echo "[Blocked IPv4 Subnet] $subnet"
        fi
    done
fi

# -----------------------
# IPv6 processing
if [ -n "$IPS6" ]; then
    for ip in $(echo "$IPS6" | uniq -c | awk -v threshold=$THRESHOLD '$1 >= threshold {print $2}'); do
        if ! sudo ufw status | grep -q "$ip"; then
            sudo ufw deny from $ip
            log_block "$ip" "IPv6 IP"
            echo "[Blocked IPv6] $ip"
        fi
        subnet=$(echo $ip | awk -F: '{print $1":"$2":"$3":"$4"::/64"}')
        if ! sudo ufw status | grep -q "$subnet"; then
            sudo ufw deny from $subnet
            log_block "$subnet" "IPv6 Subnet /64"
            echo "[Blocked IPv6 Subnet] $subnet"
        fi
    done
fi

echo "Auto-block completed. All new blocks have been added to $BLOCK_LOG"
