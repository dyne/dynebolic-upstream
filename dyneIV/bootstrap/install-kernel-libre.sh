#!/bin/bash

# Start of kernel installation
echo "============================================="
echo "WARNING: Start of kernel installation"
echo "============================================="

# Set locale to avoid localization issues
echo 'LANG="C"\nLANGUAGE="en_US:en"\nLC_ALL="C"\n' > /etc/default/locale

# Install the Freesh repository keyring
FREESH=freesh-archive-keyring_1.1_all.deb
DEBIAN_FRONTEND=noninteractive apt install -q -y /usr/src/${FREESH}

# Update the package list
DEBIAN_FRONTEND=noninteractive apt-get update -q -y

# Install initramfs-tools to ensure initrd generation
DEBIAN_FRONTEND=noninteractive apt-get install -y initramfs-tools initramfs-tools-core zstd

# Attempt to install the linux-libre-lts and linux-libre-lts-headers packages from the repository
if DEBIAN_FRONTEND=noninteractive apt-get install -y linux-libre-lts linux-libre-lts-headers; then
    echo "Packages installed successfully from the repository."
    # Generate initrd for the installed kernel
    update-initramfs -c -k $(uname -r)
else
    # Warning message for fallback to local installation
    echo "WARNING: The linux-libre-lts and linux-libre-lts-headers packages from the repository are not available or broken."
    echo "Falling back to installing from local .deb packages in /usr/src."

    # Check if the /usr/src directory contains the necessary .deb files
    if ls /usr/src/linux-*.deb >/dev/null 2>&1; then
        # List the .deb and .asc files in /usr/src
        echo "The following .deb and .asc files are available in /usr/src:"
        ls -l /usr/src/linux-*.deb /usr/src/*.asc

        # Prompt for manual verification of the .asc signature
        echo "Please manually verify the .asc signature files before proceeding."

        # Install dependencies required for the local .deb packages
        echo "Installing dependencies for the local .deb packages..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential libc6-dev

        # Install the .deb packages from /usr/src
        echo "Installing local .deb packages from /usr/src..."
        for deb_file in /usr/src/linux-*.deb ; do
            if ! DEBIAN_FRONTEND=noninteractive dpkg -i "$deb_file"; then
                echo "ERROR: Failed to install $deb_file. Attempting to fix dependencies..."
                DEBIAN_FRONTEND=noninteractive apt-get install -f -y
            fi
        done

        # Verify that the packages were installed successfully
        if dpkg -l | grep -q "linux-image"; then
            echo "Local .deb packages installed successfully."
            # Generate initrd for the installed kernel
            update-initramfs -c -k $(uname -r)
        else
            echo "ERROR: Failed to install local .deb packages. Please check /usr/src and try again."
            exit 1
        fi
    else
        echo "ERROR: The required .deb packages are not found in /usr/src."
        exit 1
    fi
fi

# Ending of kernel installation
echo "============================================="
echo "WARNING: Ending of kernel installation"
echo "============================================="
