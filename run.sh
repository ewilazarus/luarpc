#!/bin/bash

export LUA_PATH="$LUA_PATH;./.rocks/share/lua/5.3/?.lua;./src/?.lua"
export LUA_CPATH="$LUA_CPATH;./.rocks/lib/lua/5.3/?.so"

lua tests/$1.lua
