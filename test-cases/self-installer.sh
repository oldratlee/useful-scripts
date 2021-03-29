#!/bin/bash

if command -v svn &> /dev/null; then
	[ ! -d "/tmp/useful-scripts-$USER" ] &&
	svn checkout https://github.com/oldratlee/useful-scripts/branches/release-2.x "/tmp/useful-scripts-$USER"
fi

export PATH="$PATH:/tmp/useful-scripts-$USER/bin:/tmp/useful-scripts-$USER/legacy-bin"
