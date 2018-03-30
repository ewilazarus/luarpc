#!/bin/bash

# Exports paths
export LUA_PATH="$LUA_PATH;./.rocks/share/lua/5.3/?.lua;./?.lua"
export LUA_CPATH="$LUA_CPATH;./.rocks/lib/lua/5.3/?.so"

if [ $# -eq 0 ]; then
    find tests -type f -exec lua {} \;
    exit 0
fi

INPUT="tests/${1}"
STRIPPED_INPUT=${INPUT%.*}

if [ -d "${STRIPPED_INPUT}" ]; then
    find $STRIPPED_INPUT -type f -exec lua {} \;
    exit 0
fi

MAYBE_FILE="${STRIPPED_INPUT}.lua"
if [ -f "${MAYBE_FILE}" ]; then
    lua $MAYBE_FILE
    exit 0
fi

echo "You must choose tests under the tests directory"
exit 1

