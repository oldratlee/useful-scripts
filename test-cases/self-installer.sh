#!/bin/bash
echo 'this is test edit'
echo 'this is test edit#2'
if which svn &> /dev/null; then
	[ ! -d "/tmp/useful-scripts-$USER" ] &&
	svn checkout https://github.com/oldratlee/useful-scripts/trunk "/tmp/useful-scripts-$USER"
fi

export PATH="$PATH:/tmp/useful-scripts-$USER"

