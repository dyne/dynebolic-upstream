#!/bin/sh
Xephyr -screen 1600x900 -resizeable +extension GLX -br -title "dyne:bolic desktop" -once -ac -name 'dyne:bolic' :69 &
XEPHPID="$!"
sleep 0.1
DISPLAY=:69 openbox-session
kill $XEPHPID
