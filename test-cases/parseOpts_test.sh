#!/bin/bash

BASE="$(dirname "${BASH_SOURCE[0]}")"

source "$BASE/../lib/parseOpts.sh"

source "$BASE/my_unit_test_lib.sh"

#################################################
# Test
#################################################

# ========================================
blueEcho "Test case: success parse"
# ========================================

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+" aa -a -b bb -c c.sh -p pv -q qv cc \; bb --d-long d.sh -x xv d1 d2 d3 \; cc dd ee
test_exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $test_exitCode -eq 0 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 4 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"

[[ $_OPT_VALUE_a == "true" && $_OPT_VALUE_a_long == "true" ]] || fail "Wrong option value of a!"
[[ $_OPT_VALUE_b == "bb" && $_OPT_VALUE_b_long == "bb" ]] || fail "Wrong option value of b!"

test_cArray=(c.sh -p pv -q qv cc)
assertArrayEquals "Wrong option value of c!" test_cArray _OPT_VALUE_c
assertArrayEquals "Wrong option value of c!" test_cArray _OPT_VALUE_c_long

test_dArray=(d.sh -x xv d1 d2 d3)
assertArrayEquals "Wrong option value of d!" test_dArray _OPT_VALUE_d
assertArrayEquals "Wrong option value of d!" test_dArray _OPT_VALUE_d_long

test_argArray=(aa bb cc dd ee)
assertArrayEquals "Wrong args!" test_argArray _OPT_ARGS

assertAllVarsExcludeOptVarsSame

_opts_cleanOptValueInfoList
assertAllVarsSame

# ========================================
blueEcho "Test case: success parse with -- "
# ========================================

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+" aa -a -b bb -c c.sh -p pv -q qv cc \; bb -- --d-long d.sh -x xv d1 d2 d3 \; cc dd ee
test_exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $test_exitCode -eq 0 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 4 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"

[[ $_OPT_VALUE_a == "true" && $_OPT_VALUE_a_long == "true" ]] || fail "Wrong option value of a!"
[[ $_OPT_VALUE_b == "bb" && $_OPT_VALUE_b_long == "bb" ]] || fail "Wrong option value of b!"

test_cArray=(c.sh -p pv -q qv cc)
assertArrayEquals "Wrong option value of c!" test_cArray _OPT_VALUE_c
assertArrayEquals "Wrong option value of c!" test_cArray _OPT_VALUE_c_long

[[ "$_OPT_VALUE_d" == "" && "$_OPT_VALUE_d_long" == "" ]] || fail "Wrong option value of d!"

test_argArray=(aa bb --d-long d.sh -x xv d1 d2 d3 \; cc dd ee)
assertArrayEquals "Wrong args!" test_argArray _OPT_ARGS

assertAllVarsExcludeOptVarsSame

_opts_cleanOptValueInfoList
assertAllVarsSame

# ========================================
blueEcho "Test case: illegal option x"
# ========================================

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+" aa -a -b bb -x -c c.sh -p pv -q qv cc \; bb --d-long d.sh -x xv d1 d2 d3 \; cc -- dd ee
test_exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $test_exitCode -eq 232 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 0 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[[ "$_OPT_VALUE_a" == "" && "$_OPT_VALUE_a_long" == "" ]] || fail "Wrong option value of a!"
[[ "$_OPT_VALUE_b" == "" && "$_OPT_VALUE_b_long" == "" ]] || fail "Wrong option value of b!"
[[ "$_OPT_VALUE_c" == "" && "$_OPT_VALUE_c_long" == "" ]] || fail "Wrong option value of c!"
[[ "$_OPT_VALUE_d" == "" && "$_OPT_VALUE_d_long" == "" ]] || fail "Wrong option value of d!"
[ "$_OPT_ARGS" == "" ] || fail "Wrong args!"

# ========================================
blueEcho "Test case: empty options"
# ========================================

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+"
test_exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $test_exitCode -eq 0 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 4 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[[ "$_OPT_VALUE_a" == "" && "$_OPT_VALUE_a_long" == "" ]] || fail "Wrong option value of a!"
[[ "$_OPT_VALUE_b" == "" && "$_OPT_VALUE_b_long" == "" ]] || fail "Wrong option value of b!"
[[ "$_OPT_VALUE_c" == "" && "$_OPT_VALUE_c_long" == "" ]] || fail "Wrong option value of c!"
[[ "$_OPT_VALUE_d" == "" && "$_OPT_VALUE_d_long" == "" ]] || fail "Wrong option value of d!"
[ "$_OPT_ARGS" == "" ] || fail "Wrong args!"

# ========================================
blueEcho "Test case: illegal option name"
# ========================================

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+|#,z-long" aa -a -b bb -x -c c.sh -p pv -q qv cc \; bb -d d.sh -x xv d1 d2 d3 \; cc -- dd ee
test_exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $test_exitCode -eq 221 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 0 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[[ "$_OPT_VALUE_a" == "" && "$_OPT_VALUE_a_long" == "" ]] || fail "Wrong option value of a!"
[[ "$_OPT_VALUE_b" == "" && "$_OPT_VALUE_b_long" == "" ]] || fail "Wrong option value of b!"
[[ "$_OPT_VALUE_c" == "" && "$_OPT_VALUE_c_long" == "" ]] || fail "Wrong option value of c!"
[[ "$_OPT_VALUE_d" == "" && "$_OPT_VALUE_d_long" == "" ]] || fail "Wrong option value of d!"
[ "$_OPT_ARGS" == "" ] || fail "Wrong args!"

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+|z,z-#long" aa -a -b bb -x -c c.sh -p pv -q qv cc \; bb -d d.sh -x xv d1 d2 d3 \; cc -- dd ee
test_exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $test_exitCode -eq 222 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 0 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[[ "$_OPT_VALUE_a" == "" && "$_OPT_VALUE_a_long" == "" ]] || fail "Wrong option value of a!"
[[ "$_OPT_VALUE_b" == "" && "$_OPT_VALUE_b_long" == "" ]] || fail "Wrong option value of b!"
[[ "$_OPT_VALUE_c" == "" && "$_OPT_VALUE_c_long" == "" ]] || fail "Wrong option value of c!"
[[ "$_OPT_VALUE_d" == "" && "$_OPT_VALUE_d_long" == "" ]] || fail "Wrong option value of d!"
[ "$_OPT_ARGS" == "" ] || fail "Wrong args!"

assertAllVarsSame

greenEcho "TEST SUCCESS!!!"
