#!/bin/sh

echo "Configuring Tor browser"

cd /browser-cfg
if [ -f "mozilla.cfg" ]
then
	echo "Copying browser config"
	cp autoconfig.js /app/Browser/defaults/pref/autoconfig.js
	cp mozilla.cfg /app/Browser/mozilla.cfg
fi

echo "Starting Tor browser"

cd /app
./Browser/start-tor-browser

echo "Tor browser exited"
