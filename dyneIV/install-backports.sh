#!/bin/bash
# Copyright (C) 2025 Dyne.org Foundation
#
# Designed, written and maintained by Denis Roio <jaromil@dyne.org>
#
# This source code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This source code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  Please refer
# to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, see <https://www.gnu.org/licenses/>.

set -e

DEVUAN_REPO=http://packages.devuan.org/merged
DEVUAN_RELEASE=daedalus

# script to install only a few backports packages without bringing in
# all dependencies and recommended - this needs special handling and
# using apt flags is not enough

# START PACKAGE LIST
# END PACKAGE LIST

# Temporary backports repository configuration
BACKPORTS_REPO="deb ${DEVUAN_REPO} ${DEVUAN_RELEASE}-backports main contrib"
BACKPORTS_LIST="/etc/apt/sources.list.d/custom-backport.list"
BACKPORTS_PREFS="/etc/apt/preferences.d/custom-backports"

# Add Devuan backports repository
>&2 echo "Adding Devuan backports repository..."
echo "${BACKPORTS_REPO}" > "${BACKPORTS_LIST}"

# Update package lists
>&2 echo "Updating package lists..."
apt-get -qy update

rm -f ${BACKPORTS_PREFS}
touch ${BACKPORTS_PREFS}
for item in "${ITEMS[@]}" ; do
	echo "Package: $item" >> ${BACKPORTS_PREFS}
	echo "Pin: release n=${DEVUAN_RELEASE}-backports" >> ${BACKPORTS_PREFS}
	echo "Pin-Priority: 900" >> ${BACKPORTS_PREFS}
	printf "\n" >> ${BACKPORTS_PREFS}
done

# Install PipeWire packages from backports
>&2 echo "Installing backported packages..."
apt-get -qy --reinstall install -t ${DEVUAN_RELEASE}-backports "${ITEMS}"
apt-get -qy autoremove

# Clean up
>&2 echo "Cleaning up..."
rm -f "${BACKPORTS_LIST}"
apt-get -qy update  # Refresh package lists again

>&2 echo "Custom backports installation complete!"
