#!/bin/sh

# Copyright (C) 2023-2024 Dyne.org Foundation
#
# Designed, written and maintained by Denis Roio <jaromil@dyne.org>
#
# This source code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This source code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  Please refer
# to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, see <https://www.gnu.org/licenses/>.

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
