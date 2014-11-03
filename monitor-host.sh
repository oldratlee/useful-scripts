#!/bin/bash
# @Function
# monitor host:network io memory cpu 
#
# @Usage
#   $ 0 * * * * ./monitor-host.sh
#
# @author Bryant Hang

DELAY=10
COUNT=60

LOG_PATH='monitor_path'

if ! [ -d $monitor_log_path ]; then
        mkdir -p $monitor_log_path
fi

cur_date="`date +%Y%m%d`"

top_log_path=$LOG_PATH'/top_'$cur_date'.log'
memory_log_path=$LOG_PATH'/memory_'$cur_date'.log'
cpu_log_path=$LOG_PATH'/cpu_'$cur_date'.log'
io_log_path=$LOG_PATH'/io_'$cur_date'.log'
network_log_path=$LOG_PATH'/network_'$cur_date'.log'

# total performance check
top -b -d $delay -n $count > top_log_path 2>&1 &

# memory check
vmstat $delay $count > memory_log_path 2>&1 &

# cpu check
sar -u $delay $count > cpu_log_path 2>&1 &

# IO check
iostat $delay $count > io_log_path 2>&1 &

# network check
sar -n DEV $delay $count > network_log_path 2>&1 &