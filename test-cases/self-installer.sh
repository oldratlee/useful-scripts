#!/bin/bash

if which svn &> /dev/null; then
	[ ! -d "/tmp/useful-shells-$USER" ] &&
	svn checkout https://github.com/oldratlee/useful-shells/trunk "/tmp/useful-shells-$USER"
fi

export PATH="$PATH:/tmp/useful-shells-$USER"
