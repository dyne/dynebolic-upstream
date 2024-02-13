#!/bin/bash
#
APT_PROXY="$(${PWD}/detect-http-proxy.sh)"

if ! [ "${APT_PROXY}" = "DIRECT" ]; then \
	echo "--aptopt='Acquire::http { Proxy \"${APT_PROXY}\"; }'"
fi
