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

if [ $(uname)="Darwin" ]; then
  echo -n ${url} | pbcopy
else
  echo -n ${url} | xsel -b 
fi

echo ${url} copied!
