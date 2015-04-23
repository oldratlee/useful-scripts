#!/bin/bash
# @Function
# Show total and every process's memory and cpu usage
#
# @Usage
#   $ ./show-cpu-and-memory.sh
#
# @author Bryant Hang

readonly cur_date="`date +%Y%m%d`"

readonly total_mem="`free -m | grep 'Mem'`"
readonly total_cpu="`top -n 1 | grep 'Cpu'`"

echo '**********'$cur_date'**********'
echo
echo "total memory: $total_mem total cpu: $total_cpu"
echo

for pid in `ps -ef | awk 'NR > 0 {print $2}'` ; do
    mem=`cat /proc/$pid/status 2> /dev/null | grep VmRSS | awk '{print $2 $3}'`
    cpu=`top -n 1 -b | awk -v "pid=${pid}" '$1==pid {print $9}'`

    echo "pid: $pid, memory: $mem, cpu:$cpu%"
done
