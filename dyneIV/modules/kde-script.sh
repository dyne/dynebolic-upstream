

# libpulse.mainloop-glib cannot be removed or X won't start
# but debian says "it's unused" and auto wipes it, so we pin it
# fruity, 10 July 2024
apt-mark hold libpulse-mainloop-glib0

rm /etc/xdg/autostart/org.kde.discover.notifier.desktop

# flatpak is activated by dyne-install on user request (requires storage and awareness)
# HOME=/home/dyne setuidgid dyne \
#	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

