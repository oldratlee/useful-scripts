#!/bin/bash

if which svn &> /dev/null; then
	[ ! -d "/tmp/useful-scripts-$USER" ] &&
	svn checkout https://github.com/oldratlee/useful-scripts/trunk "/tmp/useful-scripts-$USER"
fi

export PATH="$PATH:/tmp/useful-scripts-$USER"
