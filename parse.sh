#!/bin/bash

PROG=`basename $0`

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

blueEcho() {
    colorEcho 34 "$@"
}

echoCmdLineThenTimedRun() {
    echo ===============================================================================
    echo "run command below: "
    echo "$@"
    echo ===============================================================================
    local start=`date +%s`
    "$@"
    local exitCode=$?

    echo
    echo "Execute time: $((`date +%s` - $start))s"

    return $exitCode
}

# cut head whitespace, delete \r
cutHeadspaceAndCR() {
    [ $# -ne 1 ] && {
        redEcho "NOT 1 arguemnt when call cutHeadspaceAndCR: $@"
        return 1
    }
    echo "$1" | tr -d '\r' | sed -r 's/^\s*//'
}

checkEmptyOrComments() {
    [ $# -ne 1 ] && {
        redEcho "NOT 1 arguemnt when call checkEmptyOrComments: $@"
        return 1
    }
    echo "$1" | grep -Eq '^\s*#|^\s*$'
}

extractValue() {
    [ $# -ne 2 ] && {
        redEcho "NOT 2 arguemnts when call extractValue: $@"
        return 1
    }

    local settingFile=$1
    local key=$2
    grep "$key" -F "$settingFile" | tr -d '\r' | grep -vE '^\s*#' |
    awk -F= '{print $2}' | sed -r 's/^\s*//;s/\s*$//'
}

#################################################
# Parse Methods
#################################################

parseOpts() {
    local optsDescription="$1" # optsDescription LIKE a,a-long|b,b-long:|c,c-long+
    shift

    local OPTS_TUPLES=()
    echo "$optsDescription" | 
    # cut head and tail space
    sed -r 's/^\s+//;s/\s+$//' |
    awk -F '[\t ]*\\|[\t ]*' '{for(i=1; i<=NF; i++) print $i}' |
    while read optDesc ; do # optDesc LIKE b,b-long:
        local mode="${optDesc:(-1)}" # LIKE : or +
        case "$mode" in
        +|:)
            optDesc="${optDesc:0:(${#optDesc}-1)}" # LIKE b,b-long
            ;;
        *)
            mode="-"
            ;;
        esac
        echo "XXX mode=$mode optDesc=$optDesc"

        local optsLine=`echo "$optDesc" | awk -F '[\t ]*,[\t ]*' '{for(i=1; i<=NF; i++) print $i}'` # a\na-long

        [ $(echo "$optsLine" | wc -l) -gt 2 ] && {
            redEcho "Illegal option description($optDesc), more than 2 opt name!" 1>&2
            return 223
        }

        local optTuple=()
        echo "$optsLine" | while read opt ; do # opt LIKE a , a-long
            [ -z "$opt" ] && continue
            
            [ ${#opt} -eq 1 ] && {
                redEcho "$opt" | grep -E '^[a-zA-Z0-9]$' -q || {
                    echo "Illegal short option name($opt in $optDesc) in option description!" 1>&2
                    return 223
                }
            } || {
                echo "$opt" | grep -E '^[-a-zA-Z0-9]+$' -q || {
                    redEcho "Illegal long option name($opt in $optDesc) in option description!" 1>&2
                    return 223
                }
            }
            optTuple=(${optTuple[@]} opt)
        done

        echo "XXX $optDesc ${optTuple[@]}"
        [ ${#optTuple[@]} -gt 2 ] && {
            redEcho "more than 2 opt($optDesc) in option description!" 1>&2
            return 223
        }

        local optTupleNames=
        for o in "${optTuple[@]}"; do
            optTupleNames+="$o"
        done

        eval "optTupleNames=($mode ${optTuple[@]})"
        OPTS_TUPLES=("${OPTS_TUPLES[@]}", optTupleNames)
    done

    echo "${OPTS_TUPLES[@]}"
    for o in "${OPTS_TUPLES[@]}" ; do
        eval "echo \"[\${$o[@]}]\""
    done

    # local args=()

    # while true; do
    #     case "$1" in
    #     ---*)
    #         echo "Illegal option($1), more than 2 prefix -!" 1>&2
    #         return 221
    #     --)
    #         shift
    #         args=("${args[@]}" "$@")
    #         break
    #         ;;
    #     --*)
    #         local opt=${1#--}
    #         local value=$2
    #         shift 2
    #         ;;
    #     -*)
    #         local opt=${1#-}
    #         local value=$2
    #         shift 2
    #         ;;
    #     *)
    #         args=("${args[@]}" "$1")
    #         shift
    #         break
    #         ;;
    #     esac
    # done
}

#################################################
# Main Methods
#################################################

parseOpts "a,a-long|b,b-long:|c,c-long+" "$@"

# echo "a: "
# echo "$_OPT_a"
# echo "$_OPT_a_long"

# echo "b: "
# echo "$_OPT_b"
# echo "$_OPT_b"

# echo "c:"
# echo "$_OPT_c"
# echo "$_OPT_c_long"

# echo "${_ARGS_[@]}"
