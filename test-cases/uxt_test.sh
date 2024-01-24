#!/usr/bin/env bash
set -eEuo pipefail

READLINK_CMD=readlink
if command -v greadlink &>/dev/null; then
  READLINK_CMD=greadlink
fi

BASE=$(dirname -- "$($READLINK_CMD -f -- "${BASH_SOURCE[0]}")")
cd "$BASE"

#################################################
# commons and test data
#################################################

readonly uxt="../bin/uxt"

#################################################
# test cases
#################################################

test_uxt_auto_detect() {
  assertEquals "2024-01-30 00:00:00 +0000" "$(TZ=0 "$uxt" 1706572800)"
  assertEquals "1900-01-30 00:00:00 +0000" "$(TZ=0 "$uxt" -- -2206483200)"

  assertEquals "1970-01-01 00:00:00 +0000" "$(TZ=0 "$uxt" 0)"
  assertEquals "1970-01-01 00:01:40 +0000" "$(TZ=0 "$uxt" -- 100)"
  assertEquals "1969-12-31 23:58:20 +0000" "$(TZ=0 "$uxt" -- -100)"

  # shellcheck disable=SC2016
  assertFalse 'should fail, 20 more than 19 digits' '"$uxt" 12345678901234567890'
}

test_uxt_unit_second() {
  assertEquals "2024-01-30 00:00:00 +0000" "$(TZ=0 "$uxt" -u s 1706572800)"
  assertEquals "1900-01-30 00:00:00 +0000" "$(TZ=0 "$uxt" -u s -- -2206483200)"

  assertEquals "1970-01-01 00:00:00 +0000" "$(TZ=0 "$uxt" -u s 0)"
  assertEquals "1970-01-01 00:01:40 +0000" "$(TZ=0 "$uxt" -u s -- 100)"
  assertEquals "1969-12-31 23:58:20 +0000" "$(TZ=0 "$uxt" -u s -- -100)"

  # shellcheck disable=SC2016
  assertFalse 'should fail, 20 more than 19 digits' '"$uxt" -u s 12345678901234567890'
}

test_uxt_unit_ms() {
  assertEquals "2024-01-30 00:00:00.000 +0000" "$(TZ=0 "$uxt" -u ms 1706572800000)"
  assertEquals "1900-01-30 00:00:00.000 +0000" "$(TZ=0 "$uxt" -u ms -- -2206483200000)"

  assertEquals "1970-01-01 00:00:00.000 +0000" "$(TZ=0 "$uxt" -u ms 0)"
  assertEquals "1970-01-01 00:01:40.000 +0000" "$(TZ=0 "$uxt" -u ms -- 100000)"
  assertEquals "1969-12-31 23:58:20.000 +0000" "$(TZ=0 "$uxt" -u ms -- -100000)"
}

#################################################
# Load and run shUnit2.
#################################################

source "$BASE/shunit2-lib/shunit2"
