#!/bin/bash
# @Function
# Open file in file explorer.
#
# @Usage
#   $ ./xpf [file [file ...] ]
#
# @online-doc https://github.com/oldratlee/useful-scripts/blob/master/docs/shell.md#-xpl-and-xpf
# @author Jerry Lee (oldratlee at gmail dot com)

PROG=`basename $0`

usage() {
    [ -n "$1" -a "$1" != 0 ] && local out=/dev/stderr || local out=/dev/stdout

    [ $# -gt 1 ] && { echo "$2"; echo; } > $out

    cat <<EOF
Usage: ${PROG} [OPTION] [FILE]...
Open file in file explorer.
Example: ${PROG} file.txt

Options:
    -s, --selected  select the file or dir
    -h, --help      display this help and exit
EOF
    exit $1
}

# if program name is xpf, set option selected!
[ "xpf" == "${PROG}" ] && selected=true

declare -a args=()
while [ $# -gt 0 ]; do
    case "$1" in
    -s|--selected)
        selected=true
        shift
        ;;
    -h|--help)
        usage
        ;;
    --)
        shift
        args=("${args[@]}" "$@")
        break
        ;;
    -*)
        usage 2 "${PROG}: unrecognized option '$1'"
        ;;
    *)
        args=("${args[@]}" "$1")
        shift
        ;;
    esac
done

[ "${#args[@]}"  == 0 ] && files=( "." ) || files=( "${args[@]}" )
for file in "${files[@]}" ; do
    [ ! -e "$file" ] && { echo "$file not exsited!"; continue; }

    case "$(uname)" in
    Darwin*)
        [ -f "${file}" ] && selected=true
        open ${selected:+-R} "$file"
        ;;
    CYGWIN*)
        [ -f "${file}" ] && selected=true
        explorer ${selected:+/select,} "$(cygpath -w "${file}")"
        ;;
    *)
        if [ -d "${file}" ] ; then
            nautilus "$(dirname "${file}")"
        else
            if [ -z "${selected}" ] ; then
                nautilus "$(dirname "${file}")"
            else
                nautilus "${file}"
            fi
        fi
        ;;
    esac
    echo "$file opened${selected:+ with selection}!"
done
