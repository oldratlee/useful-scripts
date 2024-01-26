#!/usr/bin/env bash
# unit test lib

#################################################
# commons functions
#################################################

__ut_colorEcho() {
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
  __ut_colorEcho 31 "$@"
}

greenEcho() {
  __ut_colorEcho 32 "$@"
}

yellowEcho() {
  __ut_colorEcho 33 "$@"
}

blueEcho() {
  __ut_colorEcho 34 "$@"
}

fail() {
  redEcho "TEST FAIL: $*"
  exit 1
}

die() {
  redEcho "Error: $*" >&2
  exit 1
}

#################################################
# assertion functions
#################################################

assertArrayEquals() {
  (($# == 2 || $# == 3)) || die "assertArrayEquals must 2 or 3 arguments!"
  local failMsg=""
  (($# == 3)) && {
    failMsg=$1
    shift
  }

  local a1PlaceHolder="$1[@]"
  local a2PlaceHolder="$2[@]"
  local a1=("${!a1PlaceHolder}")
  local a2=("${!a2PlaceHolder}")

  ((${#a1[@]} == ${#a2[@]})) || fail "assertArrayEquals array length [${#a1[@]}] != [${#a2[@]}]${failMsg:+: $failMsg}"

  local i
  for ((i = 0; i < ${#a1[@]}; i++)); do
    [ "${a1[$i]}" = "${a2[$i]}" ] || fail "assertArrayEquals fail element $i: [${a1[$i]}] != [${a2[$i]}]${failMsg:+: $failMsg}"
  done
}

assertEquals() {
  (($# == 2 || $# == 3)) || die "assertEqual must 2 or 3 arguments!"
  local failMsg=""
  (($# == 3)) && {
    failMsg=$1
    shift
  }
  [ "$1" == "$2" ] || fail "assertEqual fail [$1] != [$2]${failMsg:+: $failMsg}"
}

readonly __ut_exclude_vars_builtin='^BASH_|^_=|^COLUMNS=|LINES='
readonly __ut_exclude_vars_ut_functions='^FUNCNAME=|^test_'

assertAllVarsSame() {
  local test_afterVars
  test_afterVars=$(declare)

  diff \
    <(echo "$test_beforeVars" | grep -Ev "$__ut_exclude_vars_builtin") \
    <(echo "$test_afterVars" | grep -Ev "$__ut_exclude_vars_builtin|$__ut_exclude_vars_ut_functions") ||
    fail "assertAllVarsSame: Unexpected extra global vars!"
}

assertAllVarsExcludeOptVarsSame() {
  local test_afterVars
  test_afterVars=$(declare)

  diff \
    <(echo "$test_beforeVars" | grep -Ev "$__ut_exclude_vars_builtin") \
    <(echo "$test_afterVars" | grep -Ev "$__ut_exclude_vars_builtin|$__ut_exclude_vars_ut_functions"'|^_OPT_|^_opts_index_name_') ||
    fail "assertAllVarsExcludeOptVarsSame: Unexpected extra global vars!"
}

test_beforeVars=$(declare)
