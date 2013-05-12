#!/bin/bash
# @Function
# copy the svn remote url of current svn directory.
#
# @Usage
#   $ ./svn-url.sh
#
# @author ivanzhangwb

PROG=`basename $0`

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

ARGS=`getopt -a -o h -l help -- "$@"`
[ $? -ne 0 ] && usage 1
eval set -- "${ARGS}"

while true; do
    case "$1" in
    -h|--help)
        usage
        ;;
    --)
        shift
        break
        ;;
    esac
done

[ $# -gt 1 ]  && { echo At most 1 local directory is need! ; usage 1; }

dir="${1}"
dir=${dir:-.}

url=$(svn info "${dir}" | awk '/^URL: /{print $2}') 
if [ -z "${url}" ]; then
    echo "Fail to get svn url!"  1>&2
    exit 1
fi

name=$(uname | tr A-Z a-z)

case "${name}" in 
darwin*)
    echo -n "${url}" | pbcopy ;;
cygwin*)
    echo -n "${url}" | clip ;;
*)
    echo -n "${url}" | xsel -b ;;
esac 

[ $? == 0 ] && echo "${url} copied!" || exit 2
