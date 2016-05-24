#!/bin/bash
# @Function
# Run command and put output to system clipper.
#
# @Usage
#   $ ./c echo "hello world!"
#   $ echo "hello world!" | c
#
# @author Jerry Lee
copy() {
    case "`uname`" in
    Darwin*)
        pbcopy ;;
    CYGWIN*)
        clip ;;
    MINGW*)
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
