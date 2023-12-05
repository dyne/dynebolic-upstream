#!/bin/bash

# TODO: allow customization, insert here your apt-cache-ng IP on LAN
try_proxies=(
	192.168.1.2:3142
)

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
