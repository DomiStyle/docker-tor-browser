#!/usr/bin/env bash
#
# Starts Pulse Audio server:
#    listening on default port (4713)
#    allowing anonymous connections

DEBUG="-v"
DEBUG=""

echo "Starting Pulse Audio"
pulseaudio $DEBUG --load="module-native-protocol-tcp auth-anonymous=1" --exit-idle-time=-1 --use-pid-file=1

