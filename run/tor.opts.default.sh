#!/usr/bin/env bash

# PulseAudio process file location
PA_PID="$HOME/.config/pulse/`hostname`-runtime/pid"

# VNC port exposed
EXTERNAL_PORT_VNC=5801

# PulseAudio port exposed
EXTERNAL_PORT_PULASE_AUDIO=4000

# Width of display
DISPLAY_WIDTH=1426

# Height of display
DISPLAY_HEIGHT=897

# Local folder to map inside VM, appears as /app/host
SHARED_LOCAL_FOLDER="host"

# Docker Image
DOCKER_IMAGE_TAG="davidnewcomb/tor-browser"

# PulseAudio needs the IP of your host to connect
# Darwin
#HOST_IP=$(ifconfig | grep broadcast | awk '{print $2}')
# Linux
#HOST_IP=$(hostname -I | awk '{print $1}')
