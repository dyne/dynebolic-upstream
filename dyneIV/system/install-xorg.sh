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

# fallback wm is openbox
mkdir -p /etc/X11
echo "exec openbox-session" > /etc/X11/xinitrc
# xdm logs into mate
cat <<EOF > /etc/X11/xsessionrc
pipewire &
pipewire-pulse &
wireplumber &

dbus-launch --exit-with-session mate-session
EOF
