#!/bin/sh
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
