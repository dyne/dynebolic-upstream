#!/bin/sh

# default pass is luther

# luther:luther
# ROOT_PASS='$y$j9T$07JXuzf/4me/gbFvyaam5/$6BjD46Fe5gVdzvvb5PKgHumZer3hepPN6rzWH3Pnj1A'
# LUTHER_PASS='$y$j9T$0OtPX2yRJMRFZfTrIlT62.$sXO3x8dCF6a4XS.fggk/aWvdjXQ.QcrQUd7btE6qf77'

# dyne:dyne
ROOT_PASS='$y$j9T$pp36aA25UALi.EwwWnqjt.$PfYqwrvIbAfuZ2UnA7E9Cclmx6zmy4xn95Xqw4QXp16'
USER_PASS='$y$j9T$YEJ35wRf/vcXlxn4mKjIg/$Zg2DKxQXwB86ya7Rx7pqNZ2f0mdAc9h4jBEnxq0SYZ6'
USER_NAME='dyne'

echo "Reset root password (dyne)"
echo "root:${ROOT_PASS}" | chpasswd -e
if ! grep luther /etc/passwd > /dev/null; then
echo "Setup user"
	useradd -m -u 1000 -p "${USER_PASS}" -s /bin/bash "${USER_NAME}"
fi
echo "Set dynebolic hostname"
echo "dynebolic" > /etc/hostname
#TODO: somehow this changes to ubuntu, is it live-boot?
