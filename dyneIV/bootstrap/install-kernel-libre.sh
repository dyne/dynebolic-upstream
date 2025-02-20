#!/bin/bash

echo 'LANG="C"\nLANGUAGE="en_US:en"\nLC_ALL="C"\n' > /etc/default/locale

FREESH=freesh-archive-keyring_1.1_all.deb
DEBIAN_FRONTEND=noninteractive apt install -q -y /usr/src/${FREESH}

DEBIAN_FRONTEND=noninteractive apt-get update -q -y

# Install initramfs-tools to ensure initrd generation
DEBIAN_FRONTEND=noninteractive apt-get install -y initramfs-tools initramfs-tools-core live-boot-initramfs-tools zstd

# Attempt to install the packages directly
if DEBIAN_FRONTEND=noninteractive apt-get install -y linux-libre-lts linux-libre-lts-headers; then
    echo "Packages installed successfully."
    # Generate initrd for the installed kernel
    update-initramfs -c -k $(uname -r)
else
    echo "FSFLA Freesh LTS kernel packages are broken at the moment. Initializing manual selection"

    # Search for packages containing "Linux-libre" in the description
    packages=$(apt-cache search "Linux-libre" | awk '{print $1}')

    # Sort packages by version number in progressive order
    sorted_packages=$(echo "$packages" | sort -V)

    # Convert the sorted list of packages into a format suitable for dialog
    dialog_list=()
    for pkg in $sorted_packages; do
        dialog_list+=("$pkg" "" off)
    done

    # Show the dialog interface for package selection
    selected_packages=$(dialog --stdout --checklist "Select kernel image and headers to install (sorted by version):" 20 60 10 "${dialog_list[@]}")

    # Check if the user selected any packages
    if [ -n "$selected_packages" ]; then
        # Install the selected packages
        DEBIAN_FRONTEND=noninteractive apt-get install -y $selected_packages
        # Generate initrd for the installed kernel
        update-initramfs -c -k $(uname -r)
    else
        echo "No packages selected."
    fi
fi
