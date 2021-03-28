#!/bin/bash
set -eEuo pipefail

READLINK_CMD=readlink
if command -v greadlink &>/dev/null; then
    READLINK_CMD=greadlink
fi

BASE="$(dirname "$($READLINK_CMD -f "${BASH_SOURCE[0]}")")"
cd "$BASE"

#################################################
# commons and test data
#################################################

readonly uq="../bin/uq"
readonly nl=$'\n' # new line

test_input=$(cat uq_test_input)

#################################################
# test cases
#################################################

test_uq_simple() {
    assertEquals "c${nl}v${nl}a${nl}u" \
        "$(echo "$test_input" | "$uq")"
    assertEquals "c${nl}v${nl}a${nl}u" \
        "$("$uq" uq_test_input)"

    assertEquals "c${nl}a" \
        "$(echo "$test_input" | "$uq" -d)"
    assertEquals "c${nl}a" \
        "$("$uq" -d uq_test_input)"

    assertEquals "v${nl}u" "$(echo "$test_input" | "$uq" -u)"
    assertEquals "v${nl}u" "$("$uq" -u uq_test_input)"
}

readonly test_output_uq_count='      4 c
      1 v
      2 a
      1 u'

readonly test_output_uq_D_count='      4 c
      4 c
      1 v
      2 a
      2 a
      4 c
      4 c
      1 u'

test_uq_count() {
    assertEquals "$test_output_uq_count" "$(echo "$test_input" | "$uq" -c)"
    assertEquals "$test_output_uq_count" "$("$uq" -c uq_test_input)"

    assertEquals "$test_output_uq_D_count" "$(echo "$test_input" | "$uq" -D -c)"
    assertEquals "$test_output_uq_D_count" "$("$uq" -D -c uq_test_input)"
}

test_uq_only_D_option__same_as_cat() {
    assertEquals "$test_input" "$(echo "$test_input" | "$uq" -D)"
    assertEquals "$test_input" "$("$uq" -D uq_test_input)"
}

test_multi_input_files__output_file() {
    local output_file="$SHUNIT_TMPDIR/uq_output_file_${$}_${RANDOM}_${RANDOM}"
    "$uq" uq_test_input uq_test_another_input "$output_file"
    assertEquals "c${nl}v${nl}a${nl}u${nl}m${nl}x" \
        "$(cat "$output_file")"

    local output_file="$SHUNIT_TMPDIR/uq_output_file_${$}_${RANDOM}_${RANDOM}"
    "$uq" -d uq_test_input uq_test_another_input "$output_file"
    assertEquals "c${nl}a${nl}m" \
        "$(cat "$output_file")"

    local output_file="$SHUNIT_TMPDIR/uq_output_file_${$}_${RANDOM}_${RANDOM}"
    "$uq" -u uq_test_input uq_test_another_input "$output_file"
    assertEquals "v${nl}u${nl}x" \
        "$(cat "$output_file")"
}

test_multi_input_files__output_stdout() {
    assertEquals "c${nl}v${nl}a${nl}u${nl}m${nl}x" "$("$uq" uq_test_input uq_test_another_input -)"

    assertEquals "c${nl}a${nl}m" "$("$uq" -d uq_test_input uq_test_another_input -)"

    assertEquals "v${nl}u${nl}x" "$("$uq" -u uq_test_input uq_test_another_input -)"
}

test_ignore_case() {
    local input="a${nl}b${nl}A"

    assertEquals "a${nl}b${nl}A" "$(echo "$input" | "$uq")"
    assertEquals "a${nl}b" "$(echo "$input" | "$uq" -i)"
}

test_ignore_case__count() {
    local input="a${nl}b${nl}A"

    assertEquals "      1 a${nl}      1 b${nl}      1 A" \
        "$(echo "$input" | "$uq" -c)"

    assertEquals "      2 a${nl}      1 b" \
        "$(echo "$input" | "$uq" -i -c)"

    assertEquals "      2 a${nl}      1 b${nl}      2 A" \
        "$(echo "$input" | "$uq" -i -D -c)"
}

test_max_input_check() {
    # shellcheck disable=SC2016
    assertTrue 'echo 123 | "$uq"'
    # shellcheck disable=SC2016
    assertTrue 'echo 123 | "$uq" -XM 4'
    # shellcheck disable=SC2016
    assertTrue 'echo 123 | "$uq" -XM 1k'
    # shellcheck disable=SC2016
    assertTrue 'echo 123 | "$uq" --max-input 1042k'
    # shellcheck disable=SC2016
    assertTrue 'echo 123 | "$uq" --max-input 1m'
    # shellcheck disable=SC2016
    assertTrue 'echo 123 | "$uq" --max-input 10420g'
    # shellcheck disable=SC2016
    assertTrue '"$uq" uq_test_input'
    # shellcheck disable=SC2016
    assertTrue '"$uq" uq_test_input -XM 42m'
    # shellcheck disable=SC2016
    assertTrue '"$uq" uq_test_input --max-input 1024000g'
    # shellcheck disable=SC2016
    assertTrue '"$uq" uq_test_input --max-input 1234567890g'

    # shellcheck disable=SC2016
    assertFalse 'should fail by -XM' 'echo -e 123 | "$uq" -XM 1'
    # shellcheck disable=SC2016
    assertFalse 'should fail by -XM' 'echo -e 123 | "$uq" -XM 3'
    # shellcheck disable=SC2016
    assertFalse 'should fail by --max-input' 'echo -e 123 | "$uq" --max-input 2'
    # shellcheck disable=SC2016
    assertFalse 'should fail by --max-input' '"$uq" --max-input 2 uq_test_input'

    # shellcheck disable=SC2016
    assertFalse 'should fail, number overflow!' '"$uq" uq_test_input --max-input 12345678901g'
}

#################################################
# Load and run shUnit2.
#################################################

source "$BASE/shunit2-lib/shunit2"
