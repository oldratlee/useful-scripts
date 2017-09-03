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
[ -c /dev/stdout ] && readonly is_console=true || readonly is_console=false

clear_line_if_is_console() {
    # How to delete line with echo?
    # https://unix.stackexchange.com/questions/26576
    #
    # terminal escapes: http://ascii-table.com/ansi-escape-sequences.php
    # In particular, to clear from the cursor position to the beginning of the line:
    # echo -e "\033[1K"
    # Or everything on the line, regardless of cursor position:
    # echo -e "\033[2K"
    $is_console && echo -n -e "\033[2K\\r"
}


readonly jar_files="$(find "${dirs[@]}" -iname '*.jar')"
readonly total_count="$(echo "$jar_files" | wc -l)"

counter=1
while read jar_file; do
    $is_console && echo -n "finding in jar($((counter++))/$total_count): $jar_file"

    jar tf "${jar_file}" | grep -E "$pattern" | while read file; do
        clear_line_if_is_console

        echo "${jar_file}"\!"${file}"
    done

    clear_line_if_is_console

done < <(echo "$jar_files")
