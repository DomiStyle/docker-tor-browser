#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# The baseimage regenerates /etc/passwd on every container start, hardcoding
# the 'app' user's shell to /sbin/nologin and its home directory to /dev/null.
# That is why a terminal opened from the desktop menu falls back to /bin/sh.
# Rewrite the last two fields (home and shell) of the 'app' entry. Matching on
# the fields rather than the whole line keeps this working if the user or group
# ID is overridden at runtime.
if ! sed-patch '/^app:/ s|:[^:]*:[^:]*$|:/app:/bin/bash|' /etc/passwd; then
    echo "WARNING: could not set the home directory and shell of user 'app'." >&2
fi

# /app is created by Docker and owned by root, so it is not writable by the
# user that a shell now starts in. Its contents are already owned by the app
# user.
chown "${USER_ID}:${GROUP_ID}" /app

# vim:ft=sh:ts=4:sw=4:et:sts=4
