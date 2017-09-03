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
Find file in the jar files under specified directory(recursive, include subdirectory).
Pattern is *extended* regex.

Example:
    ${PROG} -d 'log4j\.properties'
    ${PROG} -d libs 'log4j\.properties$'

Options:
    -d, --dir   the directory that find jar files, can specify multiply times
    -h, --help  display this help and exit
EOF
    exit $1
}

################################################################################
# parse options
################################################################################

args=()
dirs=()
while [ $# -gt 0 ]; do
    case "$1" in
    -d|--dir)
        dirs=("${dirs[@]}" "$2")
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
dirs=${dirs:-.}

[ "${#args[@]}" -eq 0 ] && { echo "No find file pattern!" ; usage 1; }
[ "${#args[@]}" -gt 1 ] && { echo "More than 1 file pattern!" ; usage 1; }
readonly pattern="${args[0]}"

################################################################################
# find logic
################################################################################

find "${dirs[@]}" -iname '*.jar' | while read jarFile; do
    jar tf "${jarFile}" | grep -E "$pattern" | while read file; do
        echo "${jarFile}"\!"${file}"
    done
done
