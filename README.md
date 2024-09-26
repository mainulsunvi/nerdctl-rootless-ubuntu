# Nerdctl Rootless Installation Script for Ubuntu

This script automates the process of installing `nerdctl` in **rootless mode** on a Linux system. `nerdctl` is a Docker-compatible CLI for containerd, and rootless mode allows unprivileged users to run containers without requiring root permissions.

## Features

- Automatically detects the latest version of `nerdctl`.
- Installs required dependencies such as `containerd`, `dbus-user-session`, `uidmap`, and `rootlesskit`.
- Configures necessary files such as `/etc/subuid`, `/etc/subgid`, and `/etc/sysctl.d/99-rootless.conf`.
- Sets up `containerd` in rootless mode.
- Works on both `amd64` and `arm64` architectures.

## Prerequisites

- A Linux system (Ubuntu `22.4` lts).
- Do not use `Sudo` when executing the script
- Access to the internet to download necessary packages and `nerdctl`.

## Script Overview

### What the Script Does

1. **Fetches the latest `nerdctl` version** from the official GitHub releases.
2. **Installs system dependencies**, such as:
   - `containerd`
   - `dbus-user-session`
   - `uidmap`
   - `rootlesskit`
3. **Configures user namespaces** by setting up `/etc/subuid` and `/etc/subgid` for the current user.
4. **Configures sysctl** to allow unprivileged user namespaces.
5. **Downloads and installs `nerdctl`**.
6. **Sets up containerd in rootless mode**, enabling the user to run containers without root privileges.

## Usage

1. **Clone or download the script** to your system.

   ```bash
   git clone https://github.com/your-repo/nerdctl-rootless-installer.git
   cd nerdctl-rootless-ubuntu

2. **Make the script executable:**

    ```bash
    chmod 755 nerdctl.sh
    ```

    The script will prompt for ``sudo`` access to install dependencies and modify system files. It will also check and configure necessary files like ``/etc/subuid``, ``/etc/subgid``, and ``sysctl`` settings.

2. **Run the script:**

    ```bash
    ./nerdctl.sh
    ```
2. **Verify the installation:**

    After the installation is complete, you can verify the installation of ``nerdctl`` by running:

    ```bash
    nerdctl --version
    ```
    To confirm that ``containerd`` is running in rootless mode, run:

    ```bash
    nerdctl run hello-world
    ```
## Usage
To uninstall ``nerdctl`` and its associated files:

1. **Remove the nerdctl binary:**
    ```bash
    sudo rm -rf /usr/local/bin/nerdctl*
    ```
1. **Remove the rootless configuration:**
    ```bash
    sudo rm /etc/sysctl.d/99-rootless.conf
    sudo sysctl --system
    ```
3. **Remove the nerdctl binary:**
    ```bash
    sudo apt remove containerd dbus-user-session uidmap rootlesskit -y
    ```

