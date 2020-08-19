#!/bin/sh

export SERVER_PORT=$PORT
set -e

# Check if incomming command contains flags.
if [ "${1#-}" != "$1" ]; then
    set -- static-web-server "$@"
fi

exec "$@"