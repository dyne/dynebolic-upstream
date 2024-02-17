#!/bin/bash
set -e
# ${Source} doesn't always show the source package name, ${source:Package} does.
# Multiple packages can have the same source, sort -u eliminates duplicates.
apt-get -q -y update
mkdir -p /usr/src/source-packages
chown -R _apt /usr/src/source-packages
pushd /usr/src/source-packages

dpkg-query -f '${source:Package}\n' -W | sort -u | while read p; do
	# excludes
    [ "$p" == "freesh-archive-keyring" ] && continue
    [ "$p" == "linux-libre" ] && continue
    [ "$p" == "linux-libre-6.1" ] && continue
    [ "$p" == "linux-libre-6.1-headers" ] && continue
    [ "$p" == "linux-libre-headers" ] && continue
    [ "$p" == "linux-upstream" ] && continue

    mkdir -p $p && chown -R _apt $p
    pushd $p

    # -qq very quiet, pushd provides cleaner progress.
    # -d download compressed sources only, do not extract.
    apt-get -qq -d source $p

    popd
done

popd
