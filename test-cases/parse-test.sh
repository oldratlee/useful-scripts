#!/bin/bash

BASE=`dirname $0`

. $BASE/../parse.sh


#################################################
# Utils Methods
#################################################

colorEcho() {
    color=$1
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

	for((i=0; i<${#a1[@]}; i++)); do
		[ "${a1[$i]}" = "${a2[$i]}" ] || return 1
	done
}

fail() {
	redEcho "$@"
	exit 1
}

#################################################
# Test
#################################################


blueEcho "Test case: success parse"

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+" aa -a -b bb -c c.sh -p pv -q qv cc \; bb -d d.sh -x xv d1 d2 d3 \; cc -- dd ee
exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $exitCode -eq 0 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 4 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[ $_OPT_VALUE_a = "true" ] && [ $_OPT_VALUE_a_long  = "true" ] || fail "Wrong option value of a!"
[ $_OPT_VALUE_b = "bb" ] && [ $_OPT_VALUE_b_long = "bb" ] || fail "Wrong option value of b!"
cArray=(c.sh -p pv -q qv cc)
arrayEquals cArray _OPT_VALUE_c && arrayEquals cArray _OPT_VALUE_c_long || fail "Wrong option value of c!"
dArray=(d.sh -x xv d1 d2 d3 ) 
arrayEquals dArray _OPT_VALUE_d && arrayEquals dArray _OPT_VALUE_d_long || fail "Wrong option value of d!"
argArray=(aa bb cc dd ee)
arrayEquals argArray _OPT_ARGS || fail "Wrong args!"



blueEcho "Test case: illegal option x"

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+" aa -a -b bb -x -c c.sh -p pv -q qv cc \; bb -d d.sh -x xv d1 d2 d3 \; cc -- dd ee
exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $exitCode -eq 232 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 0 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[ "$_OPT_VALUE_a" = "" ] && [ "$_OPT_VALUE_a_long"  = "" ] || fail "Wrong option value of a!"
[ "$_OPT_VALUE_b" = "" ] && [ "$_OPT_VALUE_b_long" = "" ] || fail "Wrong option value of b!"
[ "$_OPT_VALUE_c" = "" ] && [ "$_OPT_VALUE_c_long" = "" ] || fail "Wrong option value of c!"
[ "$_OPT_VALUE_d" = "" ] && [ "$_OPT_VALUE_d_long" = "" ] || fail "Wrong option value of d!"
[ "$_OPT_ARGS" = "" ] || fail "Wrong args!"



blueEcho "Test case: empty options"

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+"
exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $exitCode -eq 0 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 0 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[ "$_OPT_VALUE_a" = "" ] && [ "$_OPT_VALUE_a_long"  = "" ] || fail "Wrong option value of a!"
[ "$_OPT_VALUE_b" = "" ] && [ "$_OPT_VALUE_b_long" = "" ] || fail "Wrong option value of b!"
[ "$_OPT_VALUE_c" = "" ] && [ "$_OPT_VALUE_c_long" = "" ] || fail "Wrong option value of c!"
[ "$_OPT_VALUE_d" = "" ] && [ "$_OPT_VALUE_d_long" = "" ] || fail "Wrong option value of d!"
[ "$_OPT_ARGS" = "" ] || fail "Wrong args!"



blueEcho "Test case: illegal option name"

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+|-#,-z-long" aa -a -b bb -x -c c.sh -p pv -q qv cc \; bb -d d.sh -x xv d1 d2 d3 \; cc -- dd ee
exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $exitCode -eq 221 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 0 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[ "$_OPT_VALUE_a" = "" ] && [ "$_OPT_VALUE_a_long"  = "" ] || fail "Wrong option value of a!"
[ "$_OPT_VALUE_b" = "" ] && [ "$_OPT_VALUE_b_long" = "" ] || fail "Wrong option value of b!"
[ "$_OPT_VALUE_c" = "" ] && [ "$_OPT_VALUE_c_long" = "" ] || fail "Wrong option value of c!"
[ "$_OPT_VALUE_d" = "" ] && [ "$_OPT_VALUE_d_long" = "" ] || fail "Wrong option value of d!"
[ "$_OPT_ARGS" = "" ] || fail "Wrong args!"


parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+|-z,-z-#long" aa -a -b bb -x -c c.sh -p pv -q qv cc \; bb -d d.sh -x xv d1 d2 d3 \; cc -- dd ee
exitCode=$?
_opts_showOptDescInfoList
_opts_showOptValueInfoList

[ $exitCode -eq 222 ] || fail "Wrong exit code!"
[ ${#_OPT_INFO_LIST_INDEX[@]} -eq 0 ] || fail "Wrong _OPT_INFO_LIST_INDEX!"
[ "$_OPT_VALUE_a" = "" ] && [ "$_OPT_VALUE_a_long"  = "" ] || fail "Wrong option value of a!"
[ "$_OPT_VALUE_b" = "" ] && [ "$_OPT_VALUE_b_long" = "" ] || fail "Wrong option value of b!"
[ "$_OPT_VALUE_c" = "" ] && [ "$_OPT_VALUE_c_long" = "" ] || fail "Wrong option value of c!"
[ "$_OPT_VALUE_d" = "" ] && [ "$_OPT_VALUE_d_long" = "" ] || fail "Wrong option value of d!"
[ "$_OPT_ARGS" = "" ] || fail "Wrong args!"
