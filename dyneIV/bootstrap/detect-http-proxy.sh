#!/bin/bash

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

# TODO: allow customization, insert here your apt-cache-ng IP on LAN
try_proxies=()

if [ -z "${APT_PROXY_OVERRIDE}" ]; then
	try_proxies+=('localhost:3142') # try loopback first (running apt-cacher-ng locally)
	#
	# find apt proxies on lan advertised over mdns (apt-cacher-ng publishes automatically)
	# TODO: tidy pipe chain, include IPv6, etc.
	if $(command -v avahi-browse 1>/dev/null) ; then
		mdns_proxies=$(avahi-browse -trp _apt_proxy._tcp | grep -E "^=;" \
			| grep IPv4 | cut -f8,9 -d';' | tr ';' ':')
		for proxy in "${mdns_proxies}"; do
			try_proxies+=("${proxy}")
		done
	fi
else
	try_proxies+="${APT_PROXY_OVERRIDE}"
fi

print_msg() {
    # \x0d clears the line so [Working] is hidden
    [ "$show_proxy_messages" = 1 ] && printf '\x0d%s\n' "$1" >&2
}

for proxy in "${try_proxies[@]}"; do
    # if the host machine / proxy is reachable...
    if nc -z ${proxy/:/ }; then
        proxy=http://$proxy
        print_msg "Proxy that will be used: $proxy"
        echo "$proxy"
        exit
    fi
done
print_msg "No proxy will be used"

# Workaround for Launchpad bug 654393 so it works with Debian Squeeze (<0.8.11)
echo DIRECT
