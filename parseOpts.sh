#!/bin/bash
# @Function
#   parse options lib, support multiple values for one option.
#
# @Usage
#   source this script to your script file, then use func parseOpts.
#   parseOpts func useage sample:
#   $ parseOpts "a,a-long|b,b-long:|c,c-long+" -a -b bv -c c.sh -p pv -q qv arg1 \; aa bb cc
#       then below globle var is set:
#           _OPT_VALUE_a = true
#           _OPT_VALUE_a_long = true
#           _OPT_VALUE_b = bv
#           _OPT_VALUE_b_long = bv
#           _OPT_VALUE_c = (c.sh -p pv -q qv arg1) # Array type
#           _OPT_VALUE_c_long = (c.sh -p pv -q qv arg1) # Array type
#           _OPT_ARGS = (aa bb cc) # Array type
#
# @author Jerry Lee

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
    [ $# -ne 1 ] && {
        _opts_redEcho "NOT 1 arguemnts when call _opts_convertToVarName: $@"
        return 1
    }
    echo "$1" | sed 's/-/_/g'
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

    local opt="$1" # like a, a-long
    local idxName
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        local -a idxNameArray=("${!idxNameArrayPlaceHolder}")

        local mode="${idxNameArray[0]}"

        local optName
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

    local opt="$1" # like a, a-long
    local value="$2"

    local idxName
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        local -a idxNameArray=("${!idxNameArrayPlaceHolder}")

        local optName
        for optName in "${idxNameArray[@]:1:${#idxNameArray[@]}}"; do # index from 1, skip mode
            [ "$opt" = "$optName" ] && {
                local optName2
                for optName2 in "${idxNameArray[@]:1:${#idxNameArray[@]}}"; do
                    local optValueVarName="_OPT_VALUE_`_opts_convertToVarName "${optName2}"`"
                    local from='"$value"'
                    eval "$optValueVarName=$from" # set global var!
                done
                return
            }
        done
    done

    _opts_redEcho "NOT Found option $opt!"
    return 1
}

_opts_setOptArray() {
    local opt="$1" # like a, a-long
    shift

    local idxName
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}" ; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        local -a idxNameArray=("${!idxNameArrayPlaceHolder}")
        
        local optName
        for optName in "${idxNameArray[@]:1:${#idxNameArray[@]}}"; do # index from 1, skip mode
            [ "$opt" = "$optName" ] && {
                # set _OPT_VALUE
                local optName2
                for optName2 in "${idxNameArray[@]:1:${#idxNameArray[@]}}"; do
                    local optValueVarName="_OPT_VALUE_`_opts_convertToVarName "${optName2}"`"
                    local from='"$@"'
                    eval "$optValueVarName=($from)" # set global var!
                done
                return
            }
        done
    done

    _opts_redEcho "NOT Found option $opt!"
    return 1
}

_opts_cleanOptValueInfoList() {
    local idxName
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}"; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        local -a idxNameArray=("${!idxNameArrayPlaceHolder}")

        eval "unset $idxName"

        local optName
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

    _OPT_INFO_LIST_INDEX=() # set global var!
    
    local optDescLines=`echo "$optsDescription" | 
        # cut head and tail space
        sed -r 's/^\s+//;s/\s+$//' |
        awk -F '[\t ]*\\\\|[\t ]*' '{for(i=1; i<=NF; i++) print $i}'`
    
    local optDesc
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

        local optLines=`echo "$optDesc" | awk -F '[\t ]*,[\t ]*' '{for(i=1; i<=NF; i++) print $i}'` # LIKE "a\na-long"

        [ $(echo "$optLines" | wc -l) -gt 2 ] && {
            _opts_redEcho "Illegal option description($optDesc), more than 2 opt name!" 1>&2
            _opts_cleanOptValueInfoList
            return 220
        }

        local -a optTuple=()
        local opt
        while read opt ; do # opt LIKE a , a-long
            [ -z "$opt" ] && continue
            
            [ ${#opt} -eq 1 ] && {
                echo "$opt" | grep -E '^[a-zA-Z0-9]$' -q || {
                    _opts_redEcho "Illegal short option name($opt in $optDesc) in option description!" 1>&2
                    _opts_cleanOptValueInfoList
                    return 221
                }
            } || {
                echo "$opt" | grep -E '^[-a-zA-Z0-9]+$' -q || {
                    _opts_redEcho "Illegal long option name($opt in $optDesc) in option description!" 1>&2
                    _opts_cleanOptValueInfoList
                    return 222
                }
            }
            optTuple=("${optTuple[@]}" "$opt")
        done < <(echo "$optLines")

        [ ${#optTuple[@]} -gt 2 ] && {
            _opts_redEcho "more than 2 opt(${optTuple[@]}) in option description($optDesc)!" 1>&2
            _opts_cleanOptValueInfoList
            return 223
        }

        local idxName=
        local evalOpts=
        local o
        for o in "${optTuple[@]}"; do
            idxName="${idxName}_opts_index_name_`_opts_convertToVarName "$o"`"
            evalOpts="${evalOpts} $o"
        done

        eval "$idxName=($mode $evalOpts)"
        _OPT_INFO_LIST_INDEX=("${_OPT_INFO_LIST_INDEX[@]}" "$idxName")
    done < <(echo "$optDescLines")

    local -a args=()
    while true; do
        [ $# -eq 0 ] && break

        case "$1" in
        ---*)
            _opts_redEcho "Illegal option($1), more than 2 prefix '-'!" 1>&2
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
                    _opts_redEcho "Option $opt has NO value!" 1>&2
                    _opts_cleanOptValueInfoList
                    return 231
                } 
                _opts_setOptValue "$optName" "$2"
                shift 2
                ;;
            +)
                shift
                local -a valueArray=()
                local foundComma=""

                local value
                for value in "$@" ; do
                    [ ";" = "$value" ] && {
                        foundComma=true
                        break
                    } || valueArray=("${valueArray[@]}" "$value")
                done
                [ "$foundComma" ] || {
                    _opts_redEcho "value of option $opt no end comma, value = ${valueArray[@]}" 1>&2
                    _opts_cleanOptValueInfoList
                    return 231
                }
                shift "$((${#valueArray[@]} + 1))"
                _opts_setOptArray "$optName" "${valueArray[@]}"
                ;;
            *)
                _opts_redEcho "Undefined option $opt!" 1>&2
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
    _OPT_ARGS=("${args[@]}") # set global var!
}

#####################################################################
# Show parsed Option Info Methods
#####################################################################

_opts_showOptDescInfoList() {
    echo "==============================================================================="
    echo "show option desc info list:"
    local idxName
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}"; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        echo "$idxName = (${!idxNameArrayPlaceHolder})"
    done
    echo "==============================================================================="
}

_opts_showOptValueInfoList() {
    echo "==============================================================================="
    echo "show option value info list:"
    local idxName
    for idxName in "${_OPT_INFO_LIST_INDEX[@]}"; do
        local idxNameArrayPlaceHolder="$idxName[@]"
        local -a idxNameArray=("${!idxNameArrayPlaceHolder}")

        local mode=${idxNameArray[0]}

        local optName
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
