#!/bin/bash
# @Function
# switch svn work directory to trunk.
#
# @Usage
#   $ ./swtrunk.sh [<svn work dir>...]
#
# @author Jerry Lee

[ $# -eq 0 ] && dirs=(.) || dirs=("$@")

for d in "${dirs[@]}" ; do
	[ ! -d ${d}/.svn ] && {
		echo "$d is not svn work dir!"
		continue
	}
	(
		cd "$d"
		branches=`svn info | grep '^URL' | awk '{print $2}'`
		trunk=`echo $branches | awk -F'/branches/' '{print $1}'`/trunk
		svn sw "$trunk"
		echo "svn work dir $d switch from ${branches} to ${trunk} !"
	)
done
