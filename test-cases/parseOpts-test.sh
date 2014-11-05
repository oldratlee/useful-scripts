#!/bin/bash

BASE=`dirname $0`

. $BASE/../parseOpts.sh


#################################################
# Utils Methods
#################################################

colorEcho() {
    local color=$1
    shift
    if [ -c /dev/stdout ] ; then
        # if stdout is console, turn on color output.
        echo -ne "\033[1;${color}m"
        echo -n "$@"
        echo -e "\033[0m"
    else
        echo "$@"
    fi
}

redEcho() {
    colorEcho 31 "$@"
}

greenEcho() {
    colorEcho 32 "$@"
}

yellowEcho() {
    colorEcho 33 "$@"
}

blueEcho() {
    colorEcho 34 "$@"
}

arrayEquals() {
    local a1PlaceHolder="$1[@]"
    local a2PlaceHolder="$2[@]"
    local a1=("${!a1PlaceHolder}")
    local a2=("${!a2PlaceHolder}")

    [ ${#a1[@]} -eq ${#a2[@]} ] || return 1

    local i
    for((i=0; i<${#a1[@]}; i++)); do
        [ "${a1[$i]}" = "${a2[$i]}" ] || return 1
    done
}

compareAllVars() {
    local test_afterVars=`declare`
    diff <(echo "$test_beforeVars" | grep -v '^BASH_\|^_=') <(echo "$test_afterVars" | grep -v '^BASH_\|^_=\|^FUNCNAME=\|^test_')
}

compareAllVarsExcludeOptVars() {
    local test_afterVars=`declare`
    diff <(echo "$test_beforeVars" | grep -v '^BASH_\|^_=') <(echo "$test_afterVars" | grep -v '^BASH_\|^_=\|^FUNCNAME=\|^test_\|^_OPT_\|^_opts_index_name_')
}

fail() {
    redEcho "TEST FAIL: $@"
    exit 1
}

#################################################
# Test
#################################################

test_beforeVars=`declare`

# ========================================
blueEcho "Test case: success parse"
# ========================================

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+" aa -a -b bb -c c.sh -p pv -q qv cc \; bb --d-long d.sh -x xv d1 d2 d3 \; cc dd ee
test_exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $test_exitCode -eq 0 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 4 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[ $_OPT_VALUE_a = "true" ] && [ $_OPT_VALUE_a_long  = "true" ] || fail "Wrong option value of a!"
[ $_OPT_VALUE_b = "bb" ] && [ $_OPT_VALUE_b_long = "bb" ] || fail "Wrong option value of b!"
test_cArray=(c.sh -p pv -q qv cc)
arrayEquals test_cArray _OPT_VALUE_c && arrayEquals test_cArray _OPT_VALUE_c_long || fail "Wrong option value of c!"
test_dArray=(d.sh -x xv d1 d2 d3 ) 
arrayEquals test_dArray _OPT_VALUE_d && arrayEquals test_dArray _OPT_VALUE_d_long || fail "Wrong option value of d!"
test_argArray=(aa bb cc dd ee)
arrayEquals test_argArray _OPT_ARGS || fail "Wrong args!"

compareAllVarsExcludeOptVars || fail "Unpected extra glable vars!"
_opts_cleanOptValueInfoList
compareAllVars || fail "Unpected extra glable vars!"

# ========================================
blueEcho "Test case: success parse with -- "
# ========================================

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+" aa -a -b bb -c c.sh -p pv -q qv cc \; bb -- --d-long d.sh -x xv d1 d2 d3 \; cc dd ee
test_exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $test_exitCode -eq 0 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 4 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[ $_OPT_VALUE_a = "true" ] && [ $_OPT_VALUE_a_long  = "true" ] || fail "Wrong option value of a!"
[ $_OPT_VALUE_b = "bb" ] && [ $_OPT_VALUE_b_long = "bb" ] || fail "Wrong option value of b!"
test_cArray=(c.sh -p pv -q qv cc)
arrayEquals test_cArray _OPT_VALUE_c && arrayEquals test_cArray _OPT_VALUE_c_long || fail "Wrong option value of c!"
[ "$_OPT_VALUE_d" = "" ] && [ "$_OPT_VALUE_d_long" = "" ] || fail "Wrong option value of d!"
test_argArray=(aa bb --d-long d.sh -x xv d1 d2 d3 \; cc dd ee)
arrayEquals test_argArray _OPT_ARGS || fail "Wrong args!"

compareAllVarsExcludeOptVars || fail "Unpected extra glable vars!"
_opts_cleanOptValueInfoList
compareAllVars || fail "Unpected extra glable vars!"


# ========================================
blueEcho "Test case: illegal option x"
# ========================================

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+" aa -a -b bb -x -c c.sh -p pv -q qv cc \; bb --d-long d.sh -x xv d1 d2 d3 \; cc -- dd ee
test_exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $test_exitCode -eq 232 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 0 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[ "$_OPT_VALUE_a" = "" ] && [ "$_OPT_VALUE_a_long"  = "" ] || fail "Wrong option value of a!"
[ "$_OPT_VALUE_b" = "" ] && [ "$_OPT_VALUE_b_long" = "" ] || fail "Wrong option value of b!"
[ "$_OPT_VALUE_c" = "" ] && [ "$_OPT_VALUE_c_long" = "" ] || fail "Wrong option value of c!"
[ "$_OPT_VALUE_d" = "" ] && [ "$_OPT_VALUE_d_long" = "" ] || fail "Wrong option value of d!"
[ "$_OPT_ARGS" = "" ] || fail "Wrong args!"



# ========================================
blueEcho "Test case: empty options"
# ========================================

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+"
test_exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $test_exitCode -eq 0 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 4 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[ "$_OPT_VALUE_a" = "" ] && [ "$_OPT_VALUE_a_long"  = "" ] || fail "Wrong option value of a!"
[ "$_OPT_VALUE_b" = "" ] && [ "$_OPT_VALUE_b_long" = "" ] || fail "Wrong option value of b!"
[ "$_OPT_VALUE_c" = "" ] && [ "$_OPT_VALUE_c_long" = "" ] || fail "Wrong option value of c!"
[ "$_OPT_VALUE_d" = "" ] && [ "$_OPT_VALUE_d_long" = "" ] || fail "Wrong option value of d!"
[ "$_OPT_ARGS" = "" ] || fail "Wrong args!"



# ========================================
blueEcho "Test case: illegal option name"
# ========================================

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+|#,z-long" aa -a -b bb -x -c c.sh -p pv -q qv cc \; bb -d d.sh -x xv d1 d2 d3 \; cc -- dd ee
test_exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $test_exitCode -eq 221 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 0 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[ "$_OPT_VALUE_a" = "" ] && [ "$_OPT_VALUE_a_long"  = "" ] || fail "Wrong option value of a!"
[ "$_OPT_VALUE_b" = "" ] && [ "$_OPT_VALUE_b_long" = "" ] || fail "Wrong option value of b!"
[ "$_OPT_VALUE_c" = "" ] && [ "$_OPT_VALUE_c_long" = "" ] || fail "Wrong option value of c!"
[ "$_OPT_VALUE_d" = "" ] && [ "$_OPT_VALUE_d_long" = "" ] || fail "Wrong option value of d!"
[ "$_OPT_ARGS" = "" ] || fail "Wrong args!"


parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+|z,z-#long" aa -a -b bb -x -c c.sh -p pv -q qv cc \; bb -d d.sh -x xv d1 d2 d3 \; cc -- dd ee
test_exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $test_exitCode -eq 222 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 0 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[ "$_OPT_VALUE_a" = "" ] && [ "$_OPT_VALUE_a_long"  = "" ] || fail "Wrong option value of a!"
[ "$_OPT_VALUE_b" = "" ] && [ "$_OPT_VALUE_b_long" = "" ] || fail "Wrong option value of b!"
[ "$_OPT_VALUE_c" = "" ] && [ "$_OPT_VALUE_c_long" = "" ] || fail "Wrong option value of c!"
[ "$_OPT_VALUE_d" = "" ] && [ "$_OPT_VALUE_d_long" = "" ] || fail "Wrong option value of d!"
[ "$_OPT_ARGS" = "" ] || fail "Wrong args!"

compareAllVars || fail "Unpected extra glable vars!"

greenEcho "TEST SUCCESS!!!"
