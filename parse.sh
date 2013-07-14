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

indirectReferredArray() {
    redEcho "$1"
    local arrayName="$1"
    local arrayNamePlaceHolder="$arrayName[@]"
    local ret=( "${!arrayNamePlaceHolder}" )
    return ret
}

#################################################
# Parse Methods
#################################################

setOptBool() {
    return
}

setOptValue() {
    return
}

setOptArray() {
    return
}

showOptDescInfoList() {
    echo "===================================================="
    echo "show option desc info list:"
    for idx in "${_OPT_INFO_LIST_INDEX[@]}"; do
        local arrayPlaceHolder="$idx[@]"
        echo "$idx = ${!arrayPlaceHolder}"
    done
    echo "===================================================="
}

parseOpts() {
    local optsDescription="$1" # optsDescription LIKE a,a-long|b,b-long:|c,c-long+
    shift

    _OPT_INFO_LIST_INDEX=()
    
    local optDescLines=`echo "$optsDescription" | 
        # cut head and tail space
        sed -r 's/^\s+//;s/\s+$//' |
        awk -F '[\t ]*\\\\|[\t ]*' '{for(i=1; i<=NF; i++) print $i}'`
    blueEcho "xxx optDescLines=$optDescLines"
    
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
        blueEcho "XXX splite mode: mode=$mode optDesc=$optDesc"

        local optsLine=`echo "$optDesc" | awk -F '[\t ]*,[\t ]*' '{for(i=1; i<=NF; i++) print $i}'` # a\na-long

        [ $(echo "$optsLine" | wc -l) -gt 2 ] && {
            redEcho "Illegal option description($optDesc), more than 2 opt name!" 1>&2
            return 223
        }

        local optTuple=()
        while read opt ; do # opt LIKE a , a-long
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
            optTuple=("${optTuple[@]}" "$opt")
            blueEcho "optTuple: ${optTuple[@]}"
        done < <(echo "$optsLine")

        blueEcho "XXX find out optTuple: optDesc=$optDesc optTuple=${optTuple[@]}"
        [ ${#optTuple[@]} -gt 2 ] && {
            redEcho "more than 2 opt($optDesc) in option description!" 1>&2
            return 223
        }

        local optTupleNames=
        local evalOpts=
        for o in "${optTuple[@]}"; do
            optTupleNames+=_`echo "$o" | sed 's/-/_/g'`
            evalOpts+=" $o"
        done
        blueEcho "XXX optTupleNames=$optTupleNames"

        eval "$optTupleNames=($mode $evalOpts)"
        blueEcho "XXX eval $optTupleNames=($mode $evalOpts)"

        local arrayNamePlaceHolder="$optTupleNames[@]"
        blueEcho "XXX optTupleNames Array=$optTupleNames ! ${!arrayNamePlaceHolder} "

        _OPT_INFO_LIST_INDEX=("${_OPT_INFO_LIST_INDEX[@]}" "$optTupleNames")
        blueEcho "XXX _OPT_INFO_LIST_INDEX=${_OPT_INFO_LIST_INDEX[@]}"
    done < <(echo "$optDescLines")

    showOptDescInfoList

    local args=()

    while true; do
        case "$1" in
        ---*)
            echo "Illegal option($1), more than 2 prefix -!" 1>&2
            return 221
            ;;
        --)
            shift
            args=("${args[@]}" "$@")
            break
            ;;
        --*)
            local opt=${1#--}
            local mode=`findOptMode "$opt"`
            redEcho "mode of $1 = $mode"
            case "$mode" in
            :)
                setOptValue "$opt" "$2"
                shift 2
                ;;
            +)
                setOptArray "$opt"
                ;;
            -)
                setOptBool "$opt"
                ;;
            *)
                redEcho "Undefined option $opt!"
                return 225
                ;;
            esac
            ;;
        -*)
            local opt=${1#-}
            local mode=`findOptMode "$opt"`
            redEcho "mode of $1 = $mode"
            case "$mode" in
            :)
                setOptValue "$opt" "$2"
                shift 2
                ;;
            +)
                setOptArray "$opt"
                ;;
            -)
                setOptBool "$opt"
                ;;
            *)
                redEcho "Undefined option $opt!"
                return 225
                ;;
            esac
            ;;
        *)
            args=("${args[@]}" "$1")
            shift
            ;;
        esac
    done
}

findOptMode() {
    opt="$1"
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local ele0PlaceHolder="$idxName[0]"

        local arrayPlaceHolder="$idxName[@]"
        local tmpArray=( "${!arrayPlaceHolder}" )
        
        for (( i = 1; i < ${#tmpArray[@]}; i++)); do
            local arrayElePlaceHolder="$idxName[$i]"
            [ "$opt" = "${!arrayElePlaceHolder}" ] && {
                echo "${!ele0PlaceHolder}"
            }
        done
    done

    echo ""
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
