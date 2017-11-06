#!/bin/bash
# @Function
# Open file in file explorer.
#
# @Usage
#   $ ./xpf file
#
# @online-doc https://github.com/oldratlee/useful-scripts/blob/master/docs/shell.md#beer-xpl-and-xpf
# @author Jerry Lee (oldratlee at gmail dot com)

PROG=`basename $0`

usage() {
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

ARGS=`getopt -a -o sh -l selected,help -- "$@"`
[ $? -ne 0 ] && usage 1
eval set -- "${ARGS}"

while true; do
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
        break
        ;;
    esac
done

[ $# == 0 ] && files=( "." ) || files=( "$@" )
for file in "${files[@]}" ; do
    [ ! -e $file ] && { echo "$file not exsited!"; continue; }

    case "`uname`" in
    Darwin*)
        [ -f "${file}" ] && selected=true
        open ${selected:+-R} ${file}
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
    echo "$file opened!"
done
