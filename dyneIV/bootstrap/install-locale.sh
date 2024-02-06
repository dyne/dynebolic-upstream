#!/bin/sh
#DEBIAN_FRONTEND=noninteractive apt-get -q -y install locales-all util-linux-locales
# echo \
# 	 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\nLC_ALL="en_US.UTF-8"\n' \
# 	 > /etc/default/locale
# echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections
# echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections
#rm -f "/etc/locale.gen"
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
