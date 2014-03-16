#!/bin/bash

redEcho() {
    if [ -c /dev/stdout ] ; then
        # if stdout is console, turn on color output.
        echo -ne "\033[1;31m"
        echo -n "$@"
        echo -ne "\033[0m"
    else
        echo -n "$@"
    fi
}

echoArg() {
    local index=$1
    local count=$2
    local value=$3

    echo -n "$index/$count: "
    redEcho "["
    echo -n "$value"
    redEcho "]"
    echo
}


echoArg 0 $# "$0"
idx=1
for a ; do
    echoArg $((idx++)) $# "$a"
done
