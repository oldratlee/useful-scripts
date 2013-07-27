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

yellowEcho() {
    colorEcho 33 "$@"
}

blueEcho() {
    colorEcho 34 "$@"
}

echoCmdLineThenTimedRun() {
    echo "==============================================================================="
    echo "run command below: "
    echo "$@"
    echo "==============================================================================="
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

convertToVarName() {
    local from="$1"
    echo "$from" | sed 's/-/_/g'
}

#################################################
# Parse Methods
#
# Use Globle Variable: 
# * _OPT_INFO_LIST_INDEX : Option info, data structure.
#                          _OPT_INFO_LIST_INDEX ->* _a_a_long -> option value.
# * _OPT_VALUE_* : value of option. is Array type for + mode option
# * _OPT_ARGS : option arguments
#################################################

findOptMode() {
    [ $# -ne 1 ] && {
        redEcho "NOT 1 arguemnts when call findOptMode: $@"
        return 1
    }

    local opt="$1"
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local ele0PlaceHolder="$idxName[0]"
        local mode="${!ele0PlaceHolder}"

        local idxNameArrayPlaceHolder="$idxName[@]"
        local idxNameArray=("${!idxNameArrayPlaceHolder}")

        for ((i = 1; i < ${#idxNameArray[@]}; i++)); do
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
    [ $# -ne 2 ] && {
        redEcho "NOT 2 arguemnts when call setOptValue: $@"
        return 1
    }

    local opt="$1"
    local value="$2"

    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        local idxNameArray=("${!idxNameArrayPlaceHolder}")
        
        for ((i = 1; i < ${#idxNameArray[@]}; i++)); do
            local arrayElePlaceHolder="$idxName[$i]"
            local optName="${!arrayElePlaceHolder}"
            [ "$opt" = "$optName" ] && {
                # set _OPT_VALUE
                for (( j = 1; j < ${#idxNameArray[@]}; j++)); do
                    local name=`convertToVarName "${idxNameArray[$j]}"`
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
    [ $# -ne 2 ] && {
        redEcho "NOT 2 arguemnts when call setOptArray: $@"
        return 1
    }

    local opt="$1"
    shift

    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        local idxNameArray=("${!idxNameArrayPlaceHolder}")
        
        for ((i = 1; i < ${#idxNameArray[@]}; i++)); do
            local arrayElePlaceHolder="$idxName[$i]"
            local optName="${!arrayElePlaceHolder}"
            [ "$opt" = "$optName" ] && {
                # set _OPT_VALUE
                for (( j = 1; j < ${#idxNameArray[@]}; j++)); do
                    local name=`convertToVarName "${idxNameArray[$j]}"`
                    local from='"$@"'
                    eval "_OPT_VALUE_$name=($from)"
                done
                return
            }
        done
    done

    redEcho "NOT Found option $opt!"
    return 1
}

showOptDescInfoList() {
    echo "==============================================================================="
    echo "show option desc info list:"
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}"; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        echo "$idxName = ${!idxNameArrayPlaceHolder}"
    done
    echo "==============================================================================="
}

showOptValueInfoList() {
    echo "==============================================================================="
    echo "show option value info list:"
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}"; do
        local ele0PlaceHolder="$idxName[0]"
        local mode="${!ele0PlaceHolder}"

        local idxNameArrayPlaceHolder="$idxName[@]"
        local idxNameArray=("${!idxNameArrayPlaceHolder}")

        for ((i = 1; i < ${#idxNameArray[@]}; i++)); do # index from 1, skip mode
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
                local OptInfoArrayPlaceHolder="$optValueVarName[@]"
                echo "$optValueVarName=(${!OptInfoArrayPlaceHolder})"
                ;;
            esac
        done
    done
    echo "_OPT_ARGS=(${_OPT_ARGS[@]})"
    echo "==============================================================================="
}

cleanOptValueInfoList() {
    unset _OPT_INFO_LIST_INDEX
}

parseOpts() {
    local optsDescription="$1" # optsDescription LIKE a,a-long|b,b-long:|c,c-long+
    shift

    _OPT_INFO_LIST_INDEX=() # Global var
    
    local optDescLines=`echo "$optsDescription" | 
        # cut head and tail space
        sed -r 's/^\s+//;s/\s+$//' |
        awk -F '[\t ]*\\\\|[\t ]*' '{for(i=1; i<=NF; i++) print $i}'`
    
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

        local optLines=`echo "$optDesc" | awk -F '[\t ]*,[\t ]*' '{for(i=1; i<=NF; i++) print $i}'` # a\na-long

        [ $(echo "$optLines" | wc -l) -gt 2 ] && {
            redEcho "Illegal option description($optDesc), more than 2 opt name!" 1>&2
            cleanOptValueInfoList
            return 220
        }

        local optTuple=()
        while read opt ; do # opt LIKE a , a-long
            [ -z "$opt" ] && continue
            
            [ ${#opt} -eq 1 ] && {
                redEcho "$opt" | grep -E '^[a-zA-Z0-9]$' -q || {
                    echo "Illegal short option name($opt in $optDesc) in option description!" 1>&2
                    cleanOptValueInfoList
                    return 221
                }
            } || {
                echo "$opt" | grep -E '^[-a-zA-Z0-9]+$' -q || {
                    redEcho "Illegal long option name($opt in $optDesc) in option description!" 1>&2
                    cleanOptValueInfoList
                    return 221
                }
            }
            optTuple=("${optTuple[@]}" "$opt")
        done < <(echo "$optLines")

        [ ${#optTuple[@]} -gt 2 ] && {
            redEcho "more than 2 opt($optDesc) in option description!" 1>&2
            cleanOptValueInfoList
            return 222
        }

        local idxName=
        local evalOpts=
        for o in "${optTuple[@]}"; do
            idxName+="_`convertToVarName "$o"`"
            evalOpts+=" $o"
        done

        eval "$idxName=($mode $evalOpts)"

        local idxNameArrayPlaceHolder="$idxName[@]"

        _OPT_INFO_LIST_INDEX=("${_OPT_INFO_LIST_INDEX[@]}" "$idxName")
    done < <(echo "$optDescLines")

    local args=()
    while true; do
        [ $# -eq 0 ] && break

        case "$1" in
        ---*)
            echo "Illegal option($1), more than 2 prefix -!" 1>&2
            cleanOptValueInfoList
            return 230
            ;;
        --)
            shift
            args=("${args[@]}" "$@")
            break
            ;;
        -*) # short & long option(-a, -a-long), use same read-in logic.
            local opt=`echo "$1" | sed -r 's/^--?//'`
            local mode=`findOptMode "$opt"`
            case "$mode" in
            -)
                setOptBool "$opt" "true"
                shift
                ;;
            :)
                [ $# -lt 2 ] && {
                    echo "Option $opt has NO value!" 1>&2
                    cleanOptValueInfoList
                    return 231
                } 
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
                    echo "value of option $opt no end comma, value = ${valueArray[@]}" 1>&2
                    cleanOptValueInfoList
                    return 231
                }
                shift "$((${#valueArray[@]} + 1))"
                setOptArray "$opt" "${valueArray[@]}"
                ;;
            *)
                echo "Undefined option $opt!" 1>&2
                cleanOptValueInfoList
                return 232
                ;;
            esac
            ;;
        *)
            args=("${args[@]}" "$1")
            shift
            ;;
        esac
    done
    _OPT_ARGS=("${args[@]}")
}

#################################################
# Main Methods
#################################################

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+" aa -a -b bb -c c.sh -a -b -c cc a1 a2 \; bb -d d.sh d1 d2 d3 \; cc -- dd ee
showOptDescInfoList
showOptValueInfoList

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+" aa -a -b bb -x -c c.sh -p pv -q qv \; bb -d -d d.sh d1 d2 d3 \; cc -- dd ee
showOptDescInfoList
showOptValueInfoList
