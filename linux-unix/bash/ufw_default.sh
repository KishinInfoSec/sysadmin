#!/bin/bash
# ------------------------------------------------------------
#  DISCLAIMER & NOTICE
# ------------------------------------------------------------
# 2025 - Author: Alex Pack aka KishinInfosec
#
# This script is provided “as‑is” without any warranty of any kind,
# either expressed or implied.  The author makes no guarantees
# regarding its suitability for a particular purpose, its correctness,
# or its security.  Use it at your own risk.
#
# By using this script you agree to assume any and all responsibility for any
# damage, data loss, or legal consequences that may arise.
# 
set -euo pipefail
# Check if running as root

if [[ "$EUID" -ne 0 ]]; then
    echo "[Error] This script must be run as root. Use sudo."
    exit 1
fi
echo "[Info] Checking if ufw is already installed."
# Install ufw if not already present
if ! command -v ufw >/dev/null 2>&1; then 
    echo "[Info] Ufw is not currently installed, doing a system update before installation."
# Try to get package manager, do system update, and install ufw
    if command -v apt >/dev/null 2>&1; then
        apt update -qq
        apt upgrade -y
        apt install -y -qq ufw
    elif command -v dnf >/dev/null 2>&1; then
        dnf update -y
        dnf upgrade -y
        dnf install -y -q ufw
    elif command -v yum >/dev/null 2>&1; then
        yum update -y
        yum install -y -q ufw
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Syu --noconfirm
        pacman -S ufw --noconfirm
    # Copy above format and add other package managers here if you need.
    else
        echo "[Error] Unable to determine package manager,try installing manually." >&2
        exit 1
    fi
else
    echo "[Info] Ufw is already installed."
fi

# Reset any existing rules
ufw --force reset

# Set default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (default port 22 change if needed)
# Warning: By default this allows ipv4 and ipv6 at the firewall.
echo "[Info] Enabling SSH."
ufw allow ssh
# Enable the firewall
ufw --force enable
ufw --force reload
echo "Done."