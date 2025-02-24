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

echo "Acquire::Retries \"5\";" > /etc/apt/apt.conf.d/avoid-timeouts
echo 'DPkg::options { "--force-confdef"; };' >  /etc/apt/apt.conf.d/force-confdef
echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/recommends
echo 'APT::Install-Suggests "false";' > /etc/apt/apt.conf.d/suggests

# commented out by fruity for a more granular choice down the system and modules
#echo "deb http://deb.debian.org/debian bookworm-backports main" > ${ROOT}/etc/apt/sources.list.d/bookworm-backports.list
#cat << EOF > /etc/apt/preferences.d/99bookworm-backports
#Package: *
#Pin: release n=bookworm-backports
#Pin-Priority: 900
#EOF
