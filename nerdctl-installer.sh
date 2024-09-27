#!/bin/bash
# Purpose: Install nerdctl in rootless mode with error handling
# Version: 1.0
# Created Date: $(date)
# Author: Your Name

# Exit the script if any command fails
set -e

# Function to print errors
error_exit() {
    echo "[ERROR] $1" 1>&2
    exit 1
}

# Ensure the script is run as a non-root user
if [[ $EUID -eq 0 ]]; then
   error_exit "This script must be run as a non-root user"
fi

# 1. Update package lists and install containerd
echo "[INFO] Updating packages and installing containerd"
sudo apt update || error_exit "Failed to update package lists"
sudo apt upgrade -y || error_exit "Failed to upgrade packages"
sudo apt install -y containerd || error_exit "Failed to install containerd"

# 2. Install necessary dependencies
echo "[INFO] Installing dbus-user-session, uidmap, and rootlesskit"
sudo apt install -y dbus-user-session uidmap rootlesskit || error_exit "Failed to install dependencies"

# 3. Check and configure dbus
echo "[INFO] Checking if dbus is active"
if ! systemctl --user is-active --quiet dbus; then
    echo "[INFO] Enabling and starting dbus service"
    systemctl --user enable --now dbus || error_exit "Failed to enable/start dbus"
fi

# 4. Check and configure subuid and subgid
echo "[INFO] Checking /etc/subuid and /etc/subgid for user $(whoami)"
if ! grep "^$(whoami)" /etc/subuid >/dev/null; then
    echo "Configuring subuid"
    echo "$(whoami):100000:65536" | sudo tee -a /etc/subuid || error_exit "Failed to configure /etc/subuid"
fi
if ! grep "^$(whoami)" /etc/subgid >/dev/null; then
    echo "Configuring subgid"
    echo "$(whoami):100000:65536" | sudo tee -a /etc/subgid || error_exit "Failed to configure /etc/subgid"
fi

# 5. Download and install nerdctl
NERDCTL_VERSION=$(curl -s https://api.github.com/repos/containerd/nerdctl/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
NERDCTL_ARCH="amd64"
NERDCTL_URL="https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-full-${NERDCTL_VERSION}-linux-${NERDCTL_ARCH}.tar.gz"
echo "[INFO] Downloading nerdctl version ${NERDCTL_VERSION}"
wget -q ${NERDCTL_URL} || error_exit "Failed to download nerdctl"

echo "[INFO] Extracting nerdctl to /usr/local"
sudo tar Cxzvvf /usr/local nerdctl-full-${NERDCTL_VERSION}-linux-${NERDCTL_ARCH}.tar.gz || error_exit "Failed to extract nerdctl"
rm nerdctl-full-${NERDCTL_VERSION}-linux-${NERDCTL_ARCH}.tar.gz || error_exit "Failed to remove downloaded file"

# 6. Create the sysctl configuration for unprivileged namespaces
echo "[INFO] Configuring kernel for unprivileged user namespaces"
SYSCTL_CONF="/etc/sysctl.d/99-rootless.conf"
if [[ ! -f $SYSCTL_CONF ]]; then
    echo "kernel.unprivileged_userns_clone=1" | sudo tee $SYSCTL_CONF || error_exit "Failed to create sysctl config"
    sudo sysctl --system || error_exit "Failed to apply sysctl settings"
fi

# 7. Install containerd for rootless setup
echo "[INFO] Setting up containerd in rootless mode"
containerd-rootless-setuptool.sh install || error_exit "Failed to set up rootless containerd"

# 8. Verify nerdctl installation
echo "[INFO] Verifying nerdctl installation"
nerdctl -v || error_exit "nerdctl command not found"

# 9. Test running in rootless mode
echo "[INFO] Running a containers nerdctl"
nerdctl ps
