#!/bin/bash
# @Function
# Show total and every process's memory and cpu usage
#
# @Usage
#   $ ./show-cpu-and-memory.sh
#
# @author Bryant Hang
cur_date="`date +%Y%m%d`"

total_mem="`free -m | grep 'Mem'`"
total_cpu="`top -n 1 | grep 'Cpu'`"

echo '**********'$cur_date'**********'

echo 

echo $total_mem
echo $total_cpu

echo

for i in `ps -ef | grep -v "awk|$0" | awk '{print $2}'` 
do 
	# not pid
	if [[ $i == *[!0-9]* ]]; then
		continue
	fi

    mem=`cat /proc/$i/status 2> /dev/null | grep VmRSS | awk '{print $2" " $3}'` 
    cpu=`top -n 1 -b | awk '$1=='$i'{print $9}'` 

    echo 'pid: '$i', memory: '$mem', cpu:'$cpu'%'
done