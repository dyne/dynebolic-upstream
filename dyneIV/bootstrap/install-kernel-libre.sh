#!/bin/bash

# Start of kernel installation
echo "============================================="
echo "WARNING: Start of kernel installation"
echo "============================================="

# Set locale to avoid localization issues
echo 'LANG="C"\nLANGUAGE="en_US:en"\nLC_ALL="C"\n' > /etc/default/locale

# Define the URLs to download
URLS=(
    "https://files.dyne.org/dynebolic/development/kernel/linux-image-6.13.3-gnu_6.13.3-gnu-3_amd64.deb"
    "https://files.dyne.org/dynebolic/development/kernel/linux-headers-6.13.3-gnu_6.13.3-gnu-3_amd64.deb"
    "https://files.dyne.org/dynebolic/development/kernel/linux-libc-dev_6.13.3-gnu-3_amd64.deb"
)

# Download the files to /usr/src
echo "Downloading kernel files..."
for url in "${URLS[@]}"; do
    if ! wget -q -P /usr/src "$url"; then
        echo "ERROR: Failed to download $url. Aborting installation."
        exit 1
    fi
done

# Install the Freesh repository keyring (if needed)
FREESH=freesh-archive-keyring_1.1_all.deb
if [[ -f /usr/src/${FREESH} ]]; then
    DEBIAN_FRONTEND=noninteractive apt install -q -y /usr/src/${FREESH}
fi

# Update the package list
DEBIAN_FRONTEND=noninteractive apt-get update -q -y

# Install initramfs-tools to ensure initrd generation
DEBIAN_FRONTEND=noninteractive apt-get install -y initramfs-tools initramfs-tools-core zstd

# Install the downloaded .deb packages
echo "Installing downloaded .deb packages..."
for deb_file in /usr/src/*.deb; do
    if ! DEBIAN_FRONTEND=noninteractive dpkg -i "$deb_file"; then
        echo "ERROR: Failed to install $deb_file. Attempting to fix dependencies..."
        DEBIAN_FRONTEND=noninteractive apt-get install -f -y
    fi
done

# Verify that the packages were installed successfully
if dpkg -l | grep -q "linux-image"; then
    echo "Kernel packages installed successfully."
    # Generate initrd for the installed kernel
    update-initramfs -c -k $(uname -r)
else
    echo "ERROR: Failed to install kernel packages. Please check /usr/src and try again."
    exit 1
fi

# Cleanup: Delete downloaded files
echo "Cleaning up downloaded files..."
rm -f /usr/src/*.deb

# Ending of kernel installation
echo "============================================="
echo "WARNING: Ending of kernel installation"
echo "============================================="
