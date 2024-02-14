#!/bin/sh

echo \
	 'LANG="C"\nLANGUAGE="en_US"\nLC_ALL="C"\n' \
	 > /etc/default/locale
echo "locales locales/default_environment_locale select C" | debconf-set-selections
echo "locales locales/locales_to_be_generated multiselect C UTF-8" | debconf-set-selections

dpkg-reconfigure --frontend=noninteractive locales

>&2 echo "update-locale"
#update-locale LANG=en_US.UTF-8
update-locale LANG=C

>&2 echo "locale-gen"
#locale-gen --purge en_US.UTF-8
locale-gen --purge C
# sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
>&2 echo "dpkg-reconfigure"
dpkg-reconfigure --frontend=noninteractive locales
