#!/bin/bash
# @Function
# print arguments in human and debugging friendly style.
#
# @online-doc https://github.com/oldratlee/useful-scripts/blob/dev-2.x/docs/shell.md#-echo-args
# @author Jerry Lee (oldratlee at gmail dot com)

readonly ec=$'\033'      # escape char
readonly eend=$'\033[0m' # escape end

echoArg() {
    local index="$1" count="$2" value="$3"

    # if stdout is console, turn on color output.
    [ -t 1 ] &&
        echo "$index/$count: $ec[1;31m[$eend$ec[0;34;42m$value$eend$ec[1;31m]$eend" ||
        echo "$index/$count: [$value]"
}


echoArg 0 $# "$0"
idx=1
for a ; do
    echoArg $((idx++)) $# "$a"
done
