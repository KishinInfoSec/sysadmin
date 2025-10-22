#!/bin/bash

# Check if running as root

if [[ "$EUID" -ne 0 ]]; then
    echo "[Error] This script must be run as root. Use sudo."
    exit 1
else 
    echo "[Info] Running as root."
    exit 0
fi