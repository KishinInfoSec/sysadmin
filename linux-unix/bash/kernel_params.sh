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
# See my notes at the end for the README.sysctl used for making this script
set -euo pipefail

# Check if running as root

if [[ "$EUID" -ne 0 ]]; then
    echo "[Error] This script must be run as root. Use sudo."
    exit 1
fi
# Kernel hardening, set restrict ptrace, hide kernel pointers, disable core dumps, etc.
# Enabled MITM network protections.
cat << EOF >> /etc/sysctl.conf
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
kernel.core_uses_pid = 1
kernel.sysrq = 0
kernel.unprivileged_bpf_disabled = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
EOF
sysctl --system
echo "Kernel parameters applied."

### File for reference /etc/sysctl.d/README.sysctl ###
# cat README.sysctl
#Kernel system variables configuration files
#
#Files found under the /etc/sysctl.d directory that end with .conf are
#parsed within sysctl(8) at boot time.  If you want to set kernel variables
#you can either edit /etc/sysctl.conf or make a new file.

#The filename isn't important, but don't make it a package name as it may clash
#with something the package builder needs later. It must end with .conf though.

#My personal preference would be for local system settings to go into
#/etc/sysctl.d/local.conf but as long as you follow the rules for the names
#of the file, anything will work. See sysctl.conf(8) man page for details
#of the format.

#After making any changes, please run "service procps force-reload" (or, from
#a Debian package maintainer script "deb-systemd-invoke restart procps.service").