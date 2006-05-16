# Xdm initialization file
# this file lists all programs that are executed when starting X
# from an Xdm login (multiple user login and remote X manager)

source /lib/dyne/utils.sh
source /lib/dyne/wmaker.sh

# set the variable below if you want to switch the startup
# windowmanager in: wmaker | fluxbox
# this setting will affect only your user
# WINDOWMANAGER=fluxbox
# (for system-wide settings use dyne.cfg or kernel options)

dyne_startx

