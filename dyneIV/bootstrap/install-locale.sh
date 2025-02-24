#!/bin/sh

# Copyright (C) 2023-2024 Dyne.org Foundation
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

# Script to generate and install all locales and keyboard layouts non-interactively.

set -e  # Exit on error

# Generate and install all locales
echo "Generating and installing all locales..."
# Uncomment all locales in /etc/locale.gen
sed -i 's/^# \(.*\)/\1/' /etc/locale.gen

# Generate locales
locale-gen

# Reconfigure locales non-interactively
echo "Reconfiguring locales..."
dpkg-reconfigure --frontend=noninteractive locales

# Configure all keyboard layouts
echo "Configuring all keyboard layouts..."

# Get a list of all available keyboard layouts
KEYBOARD_LAYOUTS=$(localectl list-x11-keymap-layouts)

# Set each keyboard layout
for layout in $KEYBOARD_LAYOUTS; do
    echo "Setting keyboard layout: $layout"
    setxkbmap $layout
done

# Reconfigure keyboard settings
echo "Reconfiguring keyboard settings..."
dpkg-reconfigure --frontend=noninteractive keyboard-configuration

echo "Locale and keyboard configuration complete. All locales and keyboard layouts have been installed and configured."
