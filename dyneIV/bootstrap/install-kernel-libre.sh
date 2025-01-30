#!/bin/bash

echo 'LANG="C"\nLANGUAGE="en_US:en"\nLC_ALL="C"\n' \
	 > /etc/default/locale

FREESH=freesh-archive-keyring_1.1_all.deb
DEBIAN_FRONTEND=noninteractive apt install -q -y /usr/src/${FREESH}

# fruity - hold up with rm -rf, we need better ways
#rm -f /usr/src/${FREESH}

# metapackages informations keep breaking on mirrors sides - fruity
DEBIAN_FRONTEND=noninteractive apt-get update -q -y

# fruity - i added the specification of the version for the kernel
# and I commented the removal of the sources because we'll need it
#rm -f /etc/apt/sources.list.d/freesh.sources

# Attempt to install the packages directly
#DEBIAN_FRONTEND=noninteractive apt-get install -y linux-libre-lts linux-libre-lts-headers

# Check if the installation was successful
if [ ! DEBIAN_FRONTEND=noninteractive apt-get install -y linux-libre-lts linux-libre-lts-headers  ]; then
    echo "Packages installed successfully."
    exit 0
else

	echo "FSFLA Freesh LTS kernel packages are broken at the moment. Initializing manual selection"
	# Search for packages containing "Linux-libre" in the description
	packages=$(apt-cache search "Linux-libre" | awk '{print $1}')

	# Convert the list of packages into a format suitable for dialog
	dialog_list=()
	for pkg in $packages; do
	    dialog_list+=("$pkg" "" off)
	done

	# Show the dialog interface for package selection
	selected_packages=$(dialog --stdout --checklist "Select kernel image and headers to install:" 20 60 10 "${dialog_list[@]}")

	# Check if the user selected any packages
	if [ -n "$selected_packages" ]; then
	    # Install the selected packages
	    DEBIAN_FRONTEND=noninteractive apt-get install -y $selected_packages
	else
	    echo "No packages selected."
	fi
fi
