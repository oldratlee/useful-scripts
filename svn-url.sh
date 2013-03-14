#!/bin/bash
# @Function
# copy the svn remote url of current svn directory.
#
# @Usage
#   $ ./svn-url.sh
#
# @author ivanzhangwb

url=$(svn info | grep "^URL: " | awk '{print $2}') 
if [ -z "${url}" ]; then
    echo "Fail to get svn url!"  1>&2
    exit 1
fi

name=$(uname | tr A-Z a-z)

case "${name}" in 
darwin*)
    echo -n ${url} | pbcopy ;;
cygwin*)
    echo -n ${url} | clip ;;
*)
    echo -n ${url} | xsel -b ;;
esac 

[ $? == 0 ] && echo ${url} copied!
