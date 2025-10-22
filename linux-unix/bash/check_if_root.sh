#!/bin/bash
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

# Check if running as root

if [[ "$EUID" -ne 0 ]]; then
    echo "[Error] This script must be run as root. Use sudo."
    exit 1
else 
    echo "[Info] Running as root."
    exit 0
fi