#!/bin/bash
#

# https://stackoverflow.com/a/4774063/1700121
DTB_HOME="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

. $DTB_HOME/run/tor.opts.default.sh
if [ -f $DTB_HOME/run/tor.opts.sh ]
then
	. $DTB_HOME/run/tor.opts.sh
fi

echo "Building '$DOCKER_IMAGE_TAG'"
docker build -t "$DOCKER_IMAGE_TAG" .

