#!/bin/bash

# TODO: allow customization, insert here your apt-cache-ng IP on LAN
try_proxies=()
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
