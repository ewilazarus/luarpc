#!/bin/bash

# Exports paths
export LUA_PATH="$LUA_PATH;./.rocks/share/lua/5.3/?.lua;./?.lua"
export LUA_CPATH="$LUA_CPATH;./.rocks/lib/lua/5.3/?.so"


if [ $1 = "server" ]; then
    lua sample/server.lua
else
    if [ $1 = "client" ]; then
        lua -i sample/client.lua
    else
        echo "You must specify either 'server' or 'client'"
        exit 1
    fi
fi
