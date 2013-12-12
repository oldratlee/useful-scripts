#!/bin/bash

[ $# -eq 0 ] && dirs=(.) || dirs=("$@")

for d in "${dirs[@]}" ; do
	[ ! -d ${d}/.svn ] && {
		echo "$d is not svn work dir!"
		continue
	}
	(
		cd "$d"
		trunk=`svn info | awk -F'/branches/|URL: ' '/^URL:/{print $2}'`/trunk
		svn sw "$trunk"
	)
done
