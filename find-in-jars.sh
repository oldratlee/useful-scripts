#!/bin/bash
# @Function
# Find file in the jar files under current directory
#
# @Usage
#   $ find-in-jars.sh log4j\\.xml
#   $ find-in-jars.sh 'log4j\.properties'
#   $ find-in-jars.sh 'log4j\.properties|log4j\.xml'
#
# @author Jerry Lee

readonly PROG=`basename $0`

usage() {
    cat <<EOF
Usage: ${PROG} [OPTION]... PATTERN
Find file in the jar files under specified directory(recursive, include subdirectory)
Example: ${PROG} -d libs 'log4j\.properties$'

Options:
    -d, --dir       the directory that find jar files
    -h, --help      display this help and exit
EOF
    exit $1
}

################################################################################
# parse options
################################################################################

args=()
while [ $# -gt 0 ]; do
    case "$1" in
    -d|--dir)
        [ -n "${dir}" ] && { echo "more than a jar directory option!"; usage 1;}
        dir="$2"
        shift 2
        ;;
    -h|--help)
        usage
        ;;
    *)
        args=("${args[@]}" "$1")
        shift
        ;;
    esac
done
dir=${dir:-.}

[ "${#args[@]}" -eq 0 ] && { echo "No find file pattern!" ; usage 1; }
[ "${#args[@]}" -gt 1 ] && { echo "More than 1 file pattern!" ; usage 1; }
readonly pattern="${args[0]}"

################################################################################
# find logic
################################################################################

find "${dir}" -iname '*.jar' | while read jarFile; do
    jar tf "${jarFile}" | egrep "$pattern" | while read file; do
        echo "${jarFile}"\!"${file}"
    done
done
