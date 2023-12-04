#!/bin/sh

SIZE="$(du -sk ROOT | cut -f 1)"
tar c ROOT | pv -p -s "${SIZE}k" \
	| tar2sqfs -r ROOT -x -f -q -c zstd dynebolic.squash
