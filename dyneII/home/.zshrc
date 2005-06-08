#
# zsh configuration file of dyne:bolic GNU/Linux
# by jaromil http://rastasoft.org
# based on the Ggeneric .zshrc file for zsh 2.7
#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases, functions, options, key bindings, etc.
#

#source /etc/zshenv


# Where to look for autoloaded function definitions
#fpath=(~/.zfunc)
# Autoload all shell functions from all directories
# in $fpath that have the executable bit on
# (the executable bit is not necessary, but gives
# you an easy way to stop the autoloading of a
# particular shell function).
#for dirname in $fpath
#do
#  autoload $dirname/*(.x:t)
#done


# Some environment variables
export MAIL=/home/INBOX
export MAILDIR=$MAIL

HISTSIZE=500
HISTFILESIZE=0
DIRSTACKSIZE=20

export TZ=Europe/Rome

# we have a home
cd
