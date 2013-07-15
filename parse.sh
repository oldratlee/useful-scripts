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
    local arrayPlaceHolder="$arrayName[@]"
    local ret=( "${!arrayPlaceHolder}" )
    return ret
}

convertToVarName() {
    local from="$1"
    echo "$from" | sed 's/-/_/g'
}

#################################################
# Parse Methods
#################################################

findOptMode() {
    opt="$1"
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local ele0PlaceHolder="$idxName[0]"
        local mode="${!ele0PlaceHolder}"

        local arrayPlaceHolder="$idxName[@]"
        local optInfo=("${!arrayPlaceHolder}")

        for ((i = 1; i < ${#optInfo[@]}; i++)); do
            local arrayElePlaceHolder="$idxName[$i]"
            [ "$opt" = "${!arrayElePlaceHolder}" ] && {
                echo "$mode"
                return
            }
        done
    done

    echo ""
}

setOptBool() {
    setOptValue "$@"
}

setOptValue() {
    local opt="$1"
    local value="$2"

    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local arrayPlaceHolder="$idxName[@]"
        local optInfo=("${!arrayPlaceHolder}")
        
        for ((i = 1; i < ${#optInfo[@]}; i++)); do
            local arrayElePlaceHolder="$idxName[$i]"
            local optName="${!arrayElePlaceHolder}"
            [ "$opt" = "$optName" ] && {
                # set _OPT_VALUE
                for (( j = 1; j < ${#optInfo[@]}; j++)); do
                    local name=`convertToVarName "${optInfo[$j]}"`
                    local from='"$value"'
                    eval "_OPT_VALUE_$name=$from"
                done
                return
            }
        done
    done

    redEcho "NOT Found option $opt!"
    return 1
}

setOptArray() {
    local opt="$1"
    shift

    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local arrayPlaceHolder="$idxName[@]"
        local optInfo=("${!arrayPlaceHolder}")
        
        for ((i = 1; i < ${#optInfo[@]}; i++)); do
            local arrayElePlaceHolder="$idxName[$i]"
            local optName="${!arrayElePlaceHolder}"
            [ "$opt" = "$optName" ] && {
                # set _OPT_VALUE
                for (( j = 1; j < ${#optInfo[@]}; j++)); do
                    local name=`convertToVarName "${optInfo[$j]}"`
                    local from='"$@"'
                    eval "_OPT_VALUE_$name=($from)"
                done
                return
            }
        done
    done

    redEcho "NOT Fount option $opt!"
    return 1
}

showOptDescInfoList() {
    echo "===================================================="
    echo "show option desc info list:"
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}"; do
        local arrayPlaceHolder="$idxName[@]"
        echo "$idxName = ${!arrayPlaceHolder}"
    done
    echo "===================================================="
}

showOptValueInfoList() {
    echo "===================================================="
    echo "show option value info list:"
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}"; do
        local ele0PlaceHolder="$idxName[0]"
        local mode="${!ele0PlaceHolder}"

        local arrayPlaceHolder="$idxName[@]"
        local optInfo=("${!arrayPlaceHolder}")
        for ((i = 1; i < ${#optInfo[@]}; i++)); do
            local arrayElePlaceHolder="$idxName[$i]"
            local optName="${!arrayElePlaceHolder}"
            local optValueVarName="_OPT_VALUE_`convertToVarName "$optName"`"

            case "$mode" in
            -)
                echo "$optValueVarName=${!optValueVarName}"
                ;;
            :)
                echo "$optValueVarName=${!optValueVarName}"
                ;;
            +)
                local arrPlaceHolder="$optValueVarName[@]"
                echo "$optValueVarName=(${!arrPlaceHolder})"
                ;;
            esac
        done
    done
    echo "_OPT_ARGS=(${_OPT_ARGS[@]})"
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
    blueEcho "XXX optDescLines=$optDescLines"
    
    while read optDesc ; do # optDesc LIKE b,b-long:
        [ -z "$optDesc" ] && continue

        local mode="${optDesc:(-1)}" # LIKE : or +
        case "$mode" in
        +|:|-)
            optDesc="${optDesc:0:(${#optDesc}-1)}" # LIKE b,b-long
            ;;
        *)
            mode="-"
            ;;
        esac
        blueEcho "XXX splite mode and optDesc: mode=$mode optDesc=$optDesc"

        local optLines=`echo "$optDesc" | awk -F '[\t ]*,[\t ]*' '{for(i=1; i<=NF; i++) print $i}'` # a\na-long

        [ $(echo "$optLines" | wc -l) -gt 2 ] && {
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
        done < <(echo "$optLines")
        blueEcho "XXX find out optTuple: optDesc=$optDesc optTuple=(${optTuple[@]})"

        [ ${#optTuple[@]} -gt 2 ] && {
            redEcho "more than 2 opt($optDesc) in option description!" 1>&2
            return 223
        }

        local optInfo=
        local evalOpts=
        for o in "${optTuple[@]}"; do
            optInfo+="_`convertToVarName "$o"`"
            evalOpts+=" $o"
        done
        blueEcho "XXX optInfo=$optInfo"

        eval "$optInfo=($mode $evalOpts)"
        blueEcho "XXX eval $optInfo=($mode $evalOpts)"

        local arrayPlaceHolder="$optInfo[@]"
        blueEcho "XXX optInfo Array $optInfo = (${!arrayPlaceHolder})"

        _OPT_INFO_LIST_INDEX=("${_OPT_INFO_LIST_INDEX[@]}" "$optInfo")
        blueEcho "XXX _OPT_INFO_LIST_INDEX=(${_OPT_INFO_LIST_INDEX[@]})"
    done < <(echo "$optDescLines")

    showOptDescInfoList

    redEcho "YYY start parse!"

    local args=()
    while true; do
        [ $# -eq 0 ] && break

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
        -*)
            local opt=`echo "$1" | sed -r 's/^--?//'`
            local mode=`findOptMode "$opt"`
            redEcho "mode of $1 = $mode"
            case "$mode" in
            -)
                setOptBool "$opt" "true"
                shift
                ;;
            :)
                setOptValue "$opt" "$2"
                shift 2
                ;;
            +)
                shift
                local valueArray=()
                local foundComma=""
                for value in "$@" ; do
                    [ ";" = "$value" ] && {
                        foundComma=true
                        break
                    } || valueArray=("${valueArray[@]}" "$value")
                done
                [ "$foundComma" ] || {
                    redEcho "value of option $opt no end comma, value = ${valueArray[@]}"
                    return 228
                }
                redEcho shift "$((${#valueArray[@]} + 2))"
                shift "$((${#valueArray[@]} + 1))"
                redEcho setOptArray "$opt" "${valueArray[@]}"
                setOptArray "$opt" "${valueArray[@]}"
                ;;
            *)
                redEcho "Undefined option $opt!"
                return 225
                ;;
            esac
            ;;
        *)
            redEcho "========= $1"
            args=("${args[@]}" "$1")
            shift
            ;;
        esac
        _OPT_ARGS=("$args")
    done
}

#################################################
# Main Methods
#################################################

parseOpts "a,a-long|b,b-long:|c,c-long+" "$@"
showOptValueInfoList

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
