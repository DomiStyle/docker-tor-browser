#!/usr/bin/env bash

# VNC port exposed
EXTERNAL_PORT_VNC=5801

# Width of display
DISPLAY_WIDTH=1426

# Height of display
DISPLAY_HEIGHT=897

# Local folder to map inside VM, appears as /app/host
SHARED_LOCAL_FOLDER="$PWD/host"

# Shared memory size
SHARED_MEMORY_SIZE=2g

# Docker Image
DOCKER_IMAGE_TAG="domistyle/tor-browser"

########
# Using PulseAudio needs the IP of your host to connect and a place for the pid file

# PulseAudio port exposed
EXTERNAL_PORT_PULSEAUDIO=4713

# Define HOST_IP in tor.opt.sh, you will need something like the following:
# Darwin
#HOST_IP=$(ifconfig | grep broadcast | awk '{print $2}')
# Linux
#HOST_IP=$(hostname -I | awk '{print $1}')

# PulseAudio process file location, may be different on other platforms
PA_PID="$HOME/.config/pulse/`hostname`-runtime/pid"

