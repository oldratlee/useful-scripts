#########################################################################
# File Name: shell_process.sh
# Author: 遇见王斌
# mail: meetbill@163.com
# Created Time: 2016-02-08 12:04:59
#########################################################################
#!/bin/bash
x=''
NUM=3
function ProcessBar()
{
	x=##########$x
	printf "test:[%-${NUM}0s]\r" $x
	sleep 0.1
}

ProcessBar
ProcessBar
ProcessBar
echo

