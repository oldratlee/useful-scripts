#!/bin/bash
set -eEuo pipefail

READLINK_CMD=readlink
if command -v greadlink &> /dev/null; then
    READLINK_CMD=greadlink
fi

cd "$(dirname "$($READLINK_CMD -f "${BASH_SOURCE[0]}")")"

################################################################################
# constants
################################################################################

# NOTE: $'foo' is the escape sequence syntax of bash
readonly ec=$'\033'      # escape char
readonly eend=$'\033[0m' # escape end
readonly nl=$'\n'        # new line

################################################################################
# common util functions
################################################################################

colorEcho() {
    local color=$1
    shift

    # if stdout is the console, turn on color output.
    [ -t 1 ] && echo "${ec}[1;${color}m$*${eend}" || echo "$*"
}

redEcho() {
    colorEcho 31 "$@"
}

yellowEcho() {
    colorEcho 33 "$@"
}

blueEcho() {
    colorEcho 36 "$@"
}

logAndRun() {
    local simple_mode=false
    [ "$1" == "-s" ] && {
        simple_mode=true
        shift
    }

    if $simple_mode; then
        echo "Run under work directory $PWD : $*"
        "$@"
    else
        blueEcho "Run under work directory $PWD :$nl$*"
        time "$@"
    fi
}

################################################################################
# run *_test.sh unit test cases
################################################################################

for test_case in *_test.sh; do
    logAndRun ./"$test_case"
done
