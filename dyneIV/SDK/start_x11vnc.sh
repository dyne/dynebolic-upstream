#!/bin/sh

x11vnc -display :0 -passwd $1 -ncache 10 -shared -forever

