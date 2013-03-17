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

usage() {
    cat <<EOF
Usage: $0 [OPTION]... PATTERN
Find file in the jar files under specified directory(recursive, include subdirectory)
Example: $0 -d libs 'log4j\.properties$'

Options:
    -d, --dir       the directory that find jar files
    -h, --help      display this help and exit
EOF
    exit $1
}

ARGS=`getopt -a -o d:h -l dir:,help -- "$@"`
[ $? -ne 0 ] && usage 1
eval set -- "${ARGS}"

while true; do
    case "$1" in
    -d|--dir)
        dir="$2"
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
    shift
done


[ -z ${dir} ] && dir=.

find ${dir} -iname '*.jar' | while read jarFile
do
        jar tf ${jarFile} | egrep "$1" | while read file
        do
                echo "${jarFile}"\!"${file}"
        done
done
