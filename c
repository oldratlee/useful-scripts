#!/bin/bash
# @Function
# Run command and put output to system clipper.
#
# @Usage
#   $ c echo "hello world!"
#   $ echo "hello world!" | c
#
# @online-doc https://github.com/oldratlee/useful-scripts/blob/master/docs/shell.md#beer-c
# @author Jerry Lee (oldratlee at gmail dot com)

set -e
set -o pipefail

readonly PROG="`basename "$0"`"

usage() {
    [ -n "$1" -a "$1" != 0 ] && local out=/dev/stderr || local out=/dev/stdout

    [ $# -gt 1 ] && { echo "$2"; echo; } > $out

    > $out cat <<EOF
Usage: ${PROG} [OPTION]... [command [command_args ...]]
Run command and put output to system clipper.
If no command is specified, read from stdin(pipe).

Example:
  ${PROG} echo "hello world!"
  ${PROG} grep -i 'hello world' menu.h main.c
  set | ${PROG}
  ${PROG} -q < ~/.ssh/id_rsa.pub

Options:
  -k, --keep-eol  do not trim new line at end of file
  -q, --quiet     suppress all normal output, default is false
  -h, --help      display this help and exit
EOF

    exit $1
}

################################################################################
# parse options
################################################################################

quiet=false
eol=-n
while [ $# -gt 0 ]; do
    case "$1" in
    -k|--keep-eol)
        eol=
        shift
        ;;
    -q|--quiet)
        quiet=true
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
        # if not option, treat all follow args as command
        args=("${args[@]}" "$@")
        break
        ;;
    esac
done

################################################################################
# biz logic
################################################################################

copy() {
    case "`uname`" in
    Darwin*)
        pbcopy ;;
    CYGWIN*|MINGW*)
        clip ;;
    *)
        xsel -b ;;
    esac
}

teeAndCopy() {
    $quiet && local out=/dev/null || local out=/dev/stdout
    tee >(
        content="$(cat)"
        echo $eol "$content" | copy
    ) > $out
}

[ ${#args[@]} -eq 0 ] && teeAndCopy ||
                "${args[@]}" | teeAndCopy
