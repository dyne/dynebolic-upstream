#!/usr/bin/env bash

SOURCE="https://github.com/jaromil/dotfiles"
TARBALL="$SOURCE/tarball/master"
TARGET="$HOME/.dotfiles"
TAR_CMD="tar -xzv -C "$TARGET" --strip-components=1 --exclude='{.gitignore}'"

is_executable() {
  type "$1" > /dev/null 2>&1
}

if is_executable "git"; then
  CMD="git clone -q $SOURCE $TARGET"
elif is_executable "curl"; then
  CMD="curl -#Ls $TARBALL | $TAR_CMD"
elif is_executable "wget"; then
  CMD="wget -q --no-check-certificate -O - $TARBALL | $TAR_CMD"
fi

if [ -z "$CMD" ]; then
  echo "No git, curl or wget available. Aborting."
else
  echo "Installing dotfiles..."
  mkdir -p "$TARGET"
  eval "$CMD"
  echo "Installation succesful in ~/.dotfiles"
  echo "to activate: cd ~/.dotfiles && make setup"
  echo "type 'make' inside the dir for a list of commands."
fi

