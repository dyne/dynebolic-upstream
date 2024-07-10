#!/bin/bash

# libpulse.mainloop-glib cannot be removed or X won't start
# but debian says "it's unused" and auto wipes it, so we pin it
# fruity, 10 July 2024
apt-mark hold libpulse-mainloop-glib0


# missing asound conf to use pipewire
# fruity, 10 July 2024
cat < EOF > /etc/asoundrc
pcm.!default pipewire
ctl.!default pipewire
EOF


#############
# LIBREOFFICE
#[ -r "/usr/local/bin/libreoffice24.2" ] && {
#	>&2 echo "-- Libreoffice found already installed."
#	exit 0
#}

#wget https://files.dyne.org/dynebolic/development/LibreOffice_24.2.1_Linux_x86-64_deb.tar.gz
#tar xf LibreOffice_24.2.1_Linux_x86-64_deb.tar.gz \
#&& cd LibreOffice_24.2.1.2_Linux_x86-64_deb/DEBS \
#&& dpkg -i *.deb

#rm -rf LibreOffice*



