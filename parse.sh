#!/bin/bash

#####################################################################
# Utils Methods
#####################################################################

_opts_colorEcho() {
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

_opts_redEcho() {
    _opts_colorEcho 31 "$@"
}

_opts_convertToVarName() {
    local from="$1"
    echo "$from" | sed 's/-/_/g'
}

#####################################################################
# Parse Methods
#
# Use Globle Variable: 
# * _OPT_INFO_LIST_INDEX : Option info, data structure.
#                          _OPT_INFO_LIST_INDEX ->* _a_a_long -> option value.
# * _OPT_VALUE_* : value of option. is Array type for + mode option
# * _OPT_ARGS : option arguments
#####################################################################

_opts_findOptMode() {
    [ $# -ne 1 ] && {
        _opts_redEcho "NOT 1 arguemnts when call _opts_findOptMode: $@"
        return 1
    }

    local opt="$1"
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        local idxNameArray=("${!idxNameArrayPlaceHolder}")

        local mode="${idxNameArray[0]}"

        for optName in "${idxNameArray[@]:1:${#idxNameArray[@]}}"; do # index from 1, skip mode
            [ "$opt" = "${optName}" ] && {
                echo "$mode"
                return
            }
        done
    done

    echo ""
}

_opts_setOptBool() {
    [ $# -ne 2 ] && {
        _opts_redEcho "NOT 2 arguemnts when call _opts_setOptBool: $@"
        return 1
    }

    _opts_setOptValue "$@"
}

_opts_setOptValue() {
    [ $# -ne 2 ] && {
        _opts_redEcho "NOT 2 arguemnts when call _opts_setOptValue: $@"
        return 1
    }

    local opt="$1"
    local value="$2"

    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        local idxNameArray=("${!idxNameArrayPlaceHolder}")

        for optName in "${idxNameArray[@]:1:${#idxNameArray[@]}}"; do # index from 1, skip mode
            [ "$opt" = "$optName" ] && {
                # set _OPT_VALUE
                for optName2 in "${idxNameArray[@]:1:${#idxNameArray[@]}}"; do
                    local optValueVarName="_OPT_VALUE_`_opts_convertToVarName "${optName2}"`"
                    local from='"$value"'
                    eval "$optValueVarName=$from"
                done
                return
            }
        done
    done

    _opts_redEcho "NOT Found option $opt!"
    return 1
}

_opts_setOptArray() {
    local opt="$1"
    shift

    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        local idxNameArray=("${!idxNameArrayPlaceHolder}")
        
        for optName in "${idxNameArray[@]:1:${#idxNameArray[@]}}"; do # index from 1, skip mode
            [ "$opt" = "$optName" ] && {
                # set _OPT_VALUE
                for optName2 in "${idxNameArray[@]:1:${#idxNameArray[@]}}"; do
                    local optValueVarName="_OPT_VALUE_`_opts_convertToVarName "${optName2}"`"
                    local from='"$@"'
                    eval "$optValueVarName=($from)"
                done
                return
            }
        done
    done

    _opts_redEcho "NOT Found option $opt!"
    return 1
}

_opts_cleanOptValueInfoList() {
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}"; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        local idxNameArray=("${!idxNameArrayPlaceHolder}")

        for optName in "${idxNameArray[@]:1:${#idxNameArray[@]}}"; do # index from 1, skip mode
            local optValueVarName="_OPT_VALUE_`_opts_convertToVarName "$optName"`"
            eval "unset $optValueVarName"
        done
    done

    unset _OPT_INFO_LIST_INDEX
    unset _OPT_ARGS
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
            _opts_redEcho "Illegal option description($optDesc), more than 2 opt name!" 1>&2
            _opts_cleanOptValueInfoList
            return 220
        }

        local optTuple=()
        while read opt ; do # opt LIKE a , a-long
            [ -z "$opt" ] && continue
            
            [ ${#opt} -eq 1 ] && {
                _opts_redEcho "$opt" | grep -E '^[a-zA-Z0-9]$' -q || {
                    echo "Illegal short option name($opt in $optDesc) in option description!" 1>&2
                    _opts_cleanOptValueInfoList
                    return 221
                }
            } || {
                echo "$opt" | grep -E '^[-a-zA-Z0-9]+$' -q || {
                    _opts_redEcho "Illegal long option name($opt in $optDesc) in option description!" 1>&2
                    _opts_cleanOptValueInfoList
                    return 221
                }
            }
            optTuple=("${optTuple[@]}" "$opt")
        done < <(echo "$optLines")

        [ ${#optTuple[@]} -gt 2 ] && {
            _opts_redEcho "more than 2 opt($optDesc) in option description!" 1>&2
            _opts_cleanOptValueInfoList
            return 222
        }

        local idxName=
        local evalOpts=
        for o in "${optTuple[@]}"; do
            idxName+="_`_opts_convertToVarName "$o"`"
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
            _opts_cleanOptValueInfoList
            return 230
            ;;
        --)
            shift
            args=("${args[@]}" "$@")
            break
            ;;
        -*) # short & long option(-a, -a-long), use same read-in logic.
            local opt="$1"
            local optName=`echo "$1" | sed -r 's/^--?//'`
            local mode=`_opts_findOptMode "$optName"`
            case "$mode" in
            -)
                _opts_setOptBool "$optName" "true"
                shift
                ;;
            :)
                [ $# -lt 2 ] && {
                    echo "Option $opt has NO value!" 1>&2
                    _opts_cleanOptValueInfoList
                    return 231
                } 
                _opts_setOptValue "$optName" "$2"
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
                    _opts_cleanOptValueInfoList
                    return 231
                }
                shift "$((${#valueArray[@]} + 1))"
                _opts_setOptArray "$optName" "${valueArray[@]}"
                ;;
            *)
                echo "Undefined option $opt!" 1>&2
                _opts_cleanOptValueInfoList
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

#####################################################################
# Show parsed Option Info Methods
#####################################################################

_opts_showOptDescInfoList() {
    echo "==============================================================================="
    echo "show option desc info list:"
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}"; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        echo "$idxName = (${!idxNameArrayPlaceHolder})"
    done
    echo "==============================================================================="
}

_opts_showOptValueInfoList() {
    echo "==============================================================================="
    echo "show option value info list:"
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}"; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        local idxNameArray=("${!idxNameArrayPlaceHolder}")

        local mode=${idxNameArray[0]}

        for optName in "${idxNameArray[@]:1:${#idxNameArray[@]}}"; do # index from 1, skip mode
            local optValueVarName="_OPT_VALUE_`_opts_convertToVarName "$optName"`" 
            case "$mode" in
            -)
                echo "$optValueVarName=${!optValueVarName}"
                ;;
            :)
                echo "$optValueVarName=${!optValueVarName}"
                ;;
            +)
                local optArrayValueArrayPlaceHolder="$optValueVarName[@]"
                echo "$optValueVarName=(${!optArrayValueArrayPlaceHolder})"
                ;;
            esac
        done
    done
    echo "_OPT_ARGS=(${_OPT_ARGS[@]})"
    echo "==============================================================================="
}
