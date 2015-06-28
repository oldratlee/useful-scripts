#!/bin/bash
# @Function
# copy the svn remote url of current svn directory.
#
# @Usage
#   $ ./cp-svn-url.sh
#   $ ./cp-svn-url.sh /path/to/svn/work/dir
#
# @author ivanzhangwb
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

for a in "$@"; do
    [ -h = "$a" -o  --help = "$1" ] && usage
done

[ $# -gt 1 ]  && { echo At most 1 local directory is need! ; usage 1; }

readonly dir="${1:-.}"

readonly url=$(svn info "${dir}" | awk '/^URL: /{print $2}') 
if [ -z "${url}" ]; then
    echo "Fail to get svn url!"  1>&2
    exit 1
fi

copy() {
    local name=$(uname | tr A-Z a-z)

    case "${name}" in
    darwin*)
        pbcopy ;;
    cygwin*)
        clip ;;
    mingw*)
        clip ;;
    *)
        xsel -b ;;
    esac
}

echo -n "${url}" | copy && echo "${url} copied!"
