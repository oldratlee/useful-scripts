#!/bin/bash
# @Function
# Show every process's memory and cpu usage
#
# @Usage
#   $ ./show-cpu-and-memory.sh
#
# @author Bryant Hang

for i in `ps -ef | egrep -v "awk|$0" | awk '/'$1'/{print $2}'` 
do 
    mem=`cat /proc/$i/status 2> /dev/null | grep VmRSS | awk '{print $2" " $3}'` 
    cpu=`top -n 1 -b | awk '$1=='$i'{print $9}'` 

    echo 'pid: '$i', memory: '$mem', cpu:'$cpu
done