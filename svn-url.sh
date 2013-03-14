#!/bin/bash
url=$(svn info | grep "^URL" | awk '{print $2}') 
if [ $url="svn: '.' is not a working copy" ]; then
  exit
fi
echo $url
if [ $(uname)="Darwin" ]; then
  echo -n $url | pbcopy
else
  echo -n $url | xsel -b 
fi
