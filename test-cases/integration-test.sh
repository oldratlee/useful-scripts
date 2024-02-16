#!/usr/bin/env bash
set -eEuo pipefail

realpath() {
  [ -e "$1" ] && command realpath -- "$1"
}

cd "$(dirname -- "$(realpath "${BASH_SOURCE[0]}")")"

################################################################################
# common util functions
################################################################################

colorEcho() {
  local color=$1
  shift
  # if stdout is a terminal, turn on color output.
  #   '-t' check: is a terminal?
  #   check isatty in bash https://stackoverflow.com/questions/10022323
  if [[ -t 1 || "${GITHUB_ACTIONS:-}" = true ]]; then
    printf '\e[1;%sm%s\e[0m\n' "$color" "$*"
  else
    printf '%s\n' "$*"
  fi
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
    # NOTE: $'foo' is the escape sequence syntax of bash
    local nl=$'\n' # new line
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
