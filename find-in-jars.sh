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
    local out
    [ -n "$1" -a "$1" != 0 ] && out=/dev/stderr || out=/dev/stdout

    > $out cat <<EOF
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

[ "${#args[@]}" -eq 0 ] && { echo "No find file pattern!" 1>&2 ; usage 1; }
[ "${#args[@]}" -gt 1 ] && { echo "More than 1 file pattern!" 1>&2 ; usage 1; }
readonly pattern="${args[0]}"

################################################################################
# Check the existence of jar command!
################################################################################

if ! which jar &> /dev/null; then
    [ -z "$JAVA_HOME" ] && {
        echo "Error: jar not found on PATH!" 1>&2
        exit 1
    }
    ! [ -f "$JAVA_HOME/bin/jar" ] && {
        echo "Error: jar not found on PATH and \$JAVA_HOME/bin/jar($JAVA_HOME/bin/jar) file does NOT exists!" 1>&2
        exit 1
    }
    ! [ -x "$JAVA_HOME/bin/jar" ] && {
        echo "Error: jar not found on PATH and \$JAVA_HOME/bin/jar($JAVA_HOME/bin/jar) is NOT executalbe!" 1>&2
        exit 1
    }
    export PATH="$JAVA_HOME/bin:$PATH"
fi

################################################################################
# find logic
################################################################################

find "${dirs[@]}" -iname '*.jar' | while read jarFile; do
    jar tf "${jarFile}" | grep -E "$pattern" | while read file; do
        echo "${jarFile}"\!"${file}"
    done
done
