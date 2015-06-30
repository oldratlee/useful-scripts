#!/bin/bash
# @Function
# Run command and put output to system clipper.
#
# @Usage
#   $ ./c echo "hello world!"
#   $ echo "hello world!" | c
#
# @author Jerry Lee

readonly PROG=`basename $0`

copy() {
    local name=$(uname | tr A-Z a-z)

    case "${name}" in
    darwin*)
        pbcopy ;;
    cygwin*)
        clip ;;
    mingw*)
        clip ;;
    *)
        xsel -b ;;
    esac
}

teeAndCopy() {
    tee >(content="$(cat)"; echo -n "$content" | copy)
}

if [ $# -eq 0 ]; then
    teeAndCopy
else
    "$@" | teeAndCopy
fi
