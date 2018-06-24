#!/bin/bash
# @Function
# copy the svn remote url of current svn directory.
#
# @Usage
#   $ ./cp-svn-url.sh
#   $ ./cp-svn-url.sh /path/to/svn/work/dir
#
# @online-doc https://github.com/oldratlee/useful-scripts/blob/master/docs/vcs.md#-cp-svn-urlsh
# @author ivanzhangwb (ivanzhangwb at gmail dot com)

readonly PROG=`basename $0`

usage() {
    cat <<EOF
Usage: ${PROG} [DIR]
Copy the svn remote url of local svn directory
DIR is local svn directory, default is current directory.

Example:
    ${PROG}
    ${PROG} /path/to/svn/work/dir

Options:
    -h, --help      display this help and exit
EOF
    exit $1
}

for a; do
    [ -h = "$a" -o  --help = "$1" ] && usage
done

[ $# -gt 1 ]  && { echo At most 1 local directory is need! ; usage 1; }

readonly dir="${1:-.}"

readonly url="$(svn info "${dir}" | awk '/^URL: /{print $2}')"
if [ -z "${url}" ]; then
    echo "Fail to get svn url!"  1>&2
    exit 1
fi

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

echo -n "${url}" | copy && echo "${url} copied!"
