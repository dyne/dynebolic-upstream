#!/bin/sh
# Script to configure system locales non-interactively.
# Usage: ./configure-locale.sh [LOCALE]
# Default LOCALE is "C".

set -e  # Exit on error

# Set default locale if not provided
LOCALE=${1:-C}

# Configure /etc/default/locale
echo "Configuring /etc/default/locale with LANG=${LOCALE}..."
echo "LANG=\"${LOCALE}\"\nLANGUAGE=\"en_US\"\nLC_ALL=\"${LOCALE}\"\n" > /etc/default/locale

# Set debconf selections for locales
echo "Configuring debconf for locale ${LOCALE}..."
echo "locales locales/default_environment_locale select ${LOCALE}" | debconf-set-selections
echo "locales locales/locales_to_be_generated multiselect ${LOCALE} UTF-8" | debconf-set-selections

# Reconfigure locales non-interactively
echo "Reconfiguring locales..."
dpkg-reconfigure --frontend=noninteractive locales

# Update system locale
echo "Updating system locale to ${LOCALE}..."
update-locale LANG=${LOCALE}

# Generate and purge locales
echo "Generating and purging locales..."
locale-gen --purge ${LOCALE}

# Reconfigure locales again to ensure changes are applied
echo "Final reconfiguration of locales..."
dpkg-reconfigure --frontend=noninteractive locales

echo "Locale configuration complete. System is now using ${LOCALE}."
