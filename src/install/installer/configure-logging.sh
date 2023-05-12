#!/bin/sh

color()  { printf "\033[%sm${2}\033[0m\n" "${1}"; }
red()    { color "0;31" "$*" ; }
yellow() { color "0;33" "$*" ; }
green()  { color "0;32" "$*" ; }

log ()  { echo "$(basename "$0") [$1] $2" >&2 ; }
info()  { log " $(green INFO)"  "$*" ; }
cont()  { log "     "           "$*" ; }
warn()  { log " $(yellow WARN)" "$*" ; }
error() { log "$(red ERROR)"    "$*" ; }
fatal() { log "$(red FATAL)"    "$(red "$@")" ; }
