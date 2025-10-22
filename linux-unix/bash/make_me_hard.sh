#!/bin/bash/
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

# I wrote this "script" with auto complete enabled, not a very pretty example.
Ciphers='chacha20-poly1305@openssh.com,aes128-gcm@openssh.com,aes256-gcm@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr'
KexAlgorithms='curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256'
Macs='hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com'

HostKeys=("HostKey /etc/ssh/ssh_host_ed25519_key" "HostKey /etc/ssh/ssh_host_rsa_key" "HostKey /etc/ssh/ssh_host_ecdsa_key")

sshd_config="/etc/ssh/sshd_config"

# Check if running as root

if [[ $EUID -ne 0 ]]; then
    echo "[Error] This script must be run as root. Use sudo."
    exit 1
else
# Do System Update and Upgrade
    echo "=== Performing System Update and Upgrade ==="

    echo "[Info] Always keep the system updated with the latest security patches."
    apt update -y
    apt full-upgrade -y
    apt autoremove -y
    echo "System updated."
fi

# Check if sshd is installed
echo "=== Checking for SSH Server Installation ==="
if ! command -v sshd &>/dev/null; then
    echo "[Error] sshd is not installed"
    exit 1
else
    echo "[Info] sshd is installed"
# Get the version of OpenSSH Server
    echo "[Info] Checking OpenSSH Server version..."
    sshd_version=$(sshd -V 2>&1 | grep OpenSSH | awk '{print $1}' | cut -d '_' -f 2 | sed 's/,//g')
    sshd_version_major=$(echo "${sshd_version}" | cut -d '.' -f 1)
    sshd_version_minor=$(echo "${sshd_version}" | cut -d '.' -f 2)
    echo "[Info] OpenSSH Server version: ${sshd_version}"

# Start and enable SSH service
    echo "=== Enabling and Starting SSH Service ==="
    systemctl enable ssh
    systemctl start ssh


# Install essential security tools
    echo "=== Installing Essential Security Tools ==="
    apt install -y ufw
# Enable and configure UFW
    echo "Configuring UFW Defaults to allow SSH and outgoing traffic, deny incoming traffic"
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw enable -y
    echo "[Info] Security tools installed and configured."
    echo "Make sure to add an SSH key to the server for secure access."
fi

# Check if the sshd_config file exists
echo "Checking for sshd_config file and backing it up if exists..."

if [[ -f "${sshd_config}" ]]; then
    backup_file "${sshd_config}"
fi
# Set KexAlgorithms
echo "=== Configuring SSH Strong Ciphers and Algorithms ==="
if grep -q "^KexAlgorithms" /etc/ssh/sshd_config; then
        sed -i -e "s/^KexAlgorithms.*/KexAlgorithms ${KexAlgorithms}/g" /etc/ssh/sshd_config
        echo "[Info] KexAlgorithms set to ${KexAlgorithms}"
    else
        echo "KexAlgorithms ${KexAlgorithms}" &gt;&gt;/etc/ssh/sshd_config
        echo "[Info] Added KexAlgorithms: ${KexAlgorithms}"
fi

# Set Ciphers
if grep -q "^Ciphers" /etc/ssh/sshd_config; then
        sed -i -e "s/^Ciphers.*/Ciphers ${Ciphers}/g" /etc/ssh/sshd_config
        echo "[Info] Ciphers set to ${Ciphers}"
    else
        echo "Ciphers ${Ciphers}" &gt;&gt;/etc/ssh/sshd_config
        echo "[Info] Added Ciphers: ${Ciphers}"
fi

# Set MACs
if grep -q "^MACs" /etc/ssh/sshd_config; then
        sed -i -e "s/^MACs.*/MACs ${Macs}/g" /etc/ssh/sshd_config
        echo "[Info] MACs set to ${Macs}"
    else
        echo "MACs ${Macs}" &gt;&gt;/etc/ssh/sshd_config
        echo "[Info] Added MACs: ${Macs}"
fi

# Remove old HostKey entries
if grep -q "^HostKey" /etc/ssh/sshd_config; then
        sed -i '/^HostKey/d' /etc/ssh/sshd_config
        echo "[Info] Removed old HostKey entries"
fi

# Add new HostKey entries
for HostKey in "${HostKeys[@]}"; do
        # Display the HostKey after the last /
        _displayName=${HostKey##*/}
    if grep -q "^${HostKey}" /etc/ssh/sshd_config; then
            echo "[Info] HostKey ${_displayName} already exists"
        else
            echo "${HostKey}" &gt;&gt;/etc/ssh/sshd_config
            echo "[Info] Added HostKey ${HostKey} to /etc/ssh/sshd_config"
    fi
done
# Restart SSH service to apply changes
echo "=== Restarting SSH Service to Apply Changes ==="
systemctl daemon-reload
systemctl restart ssh.socket
echo "[Info] SSH service restarted successfully with new configurations."