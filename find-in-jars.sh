#!/bin/bash
# @Function
# Find file in the jar files under current directory
#
# @Usage
#   $ find-in-jars.sh 'log4j\.properties'
#   $ find-in-jars.sh '^log4j(\.properties|\.xml)$'
#   $ find-in-jars.sh 'log4j\.properties$' -d /path/to/find/directory
#   $ find-in-jars.sh 'log4j\.properties' -d /path/to/find/directory1 -d /path/to/find/directory2
#
# @author Jerry Lee

readonly PROG=`basename $0`

usage() {
    local out
    [ -n "$1" -a "$1" != 0 ] && out=/dev/stderr || out=/dev/stdout

    > $out cat <<EOF
Usage: ${PROG} [OPTION]... PATTERN
Find file in the jar files under specified directory(recursive, include subdirectory).
The pattern default is *extended* regex.

Example:
    ${PROG} 'log4j\.properties'
    ${PROG} '^log4j(\.properties|\.xml)$' # search file log4j.properties/log4j.xml at zip root
    ${PROG} 'log4j\.properties$' -d /path/to/find/directory
    ${PROG} 'log4j\.properties' -d /path/to/find/dir1 -d /path/to/find/dir2

Options:
  -d, --dir              the directory that find jar files, default is current directory.
                         this option can specify multiply times to find in multiply directory.
  -E, --extended-regexp  PATTERN is an extended regular expression (*default*)
  -F, --fixed-strings    PATTERN is a set of newline-separated strings
  -G, --basic-regexp     PATTERN is a basic regular expression
  -P, --perl-regexp      PATTERN is a Perl regular expression
  -h, --help             display this help and exit
EOF

    exit $1
}

################################################################################
# parse options
################################################################################

args=()
dirs=()
regex_mode=-E
while [ $# -gt 0 ]; do
    case "$1" in
    -d|--dir)
        dirs=("${dirs[@]}" "$2")
        shift 2
        ;;
    -E|--extended-regexp)
        regex_mode=-E
        shift
        ;;
    -F|--fixed-strings)
        regex_mode=-F
        shift
        ;;
    -G|--basic-regexp)
        regex_mode=-G
        shift
        ;;
    -P|--perl-regexp)
        regex_mode=-P
        shift
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
# Check the existence of command for listing zip entry!
################################################################################

# `zipinfo -1`/`unzip -Z1` is ~25 times faster than `jar tf`, find zipinfo/unzip command first.
#
# How to list files in a zip without extra information in command line
# https://unix.stackexchange.com/a/128304/136953
if which zipinfo &> /dev/null; then
    readonly command_for_list_zip='zipinfo -1'
elif which unzip &> /dev/null; then
    readonly command_for_list_zip='unzip -Z1'
else
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

    readonly command_for_list_zip='jar tf'
fi

################################################################################
# find logic
################################################################################

[ -c /dev/stdout ] && readonly is_console=true || readonly is_console=false

# Getting console width using a bash script
# https://unix.stackexchange.com/questions/299067
$is_console && readonly columns=$(stty size | awk '{print $2}')

print_responsive_message() {
    $is_console || return

    local message="$*"
    # http://www.linuxforums.org/forum/red-hat-fedora-linux/142825-how-truncate-string-bash-script.html
    echo -n "${message:0:columns}"
}

clear_responsive_message() {
    $is_console || return

    # How to delete line with echo?
    # https://unix.stackexchange.com/questions/26576
    #
    # terminal escapes: http://ascii-table.com/ansi-escape-sequences.php
    # In particular, to clear from the cursor position to the beginning of the line:
    # echo -e "\033[1K"
    # Or everything on the line, regardless of cursor position:
    # echo -e "\033[2K"
    echo -n -e "\033[2K\\r"
}


readonly jar_files="$(find "${dirs[@]}" -iname '*.jar')"
readonly total_count="$(echo "$jar_files" | wc -l)"

counter=1
while read jar_file; do
    print_responsive_message "finding in jar($((counter++))/$total_count): $jar_file"

    $command_for_list_zip "${jar_file}" | grep $regex_mode "$pattern" | while read file; do
        clear_responsive_message

        echo "${jar_file}"\!"${file}"
    done

    clear_responsive_message

done < <(echo "$jar_files")
