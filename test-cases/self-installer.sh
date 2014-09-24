#!/bin/bash

if which svn &> /dev/null; then
	svn checkout https://github.com/oldratlee/useful-shells/trunk "/tmp/useful-shells-$USER"
fi
export PATH="$PATH:/tmp/useful-shells-$USER"
