#!/bin/bash
# @Function
# monitor host:network io memory cpu 
#
# @Usage
#   $ ./monitor-host.sh
#
# @author Bryant Hang

DELAY=10
COUNT=60

LOG_PATH='monitor_logs'

if ! [ -d $LOG_PATH ]; then
        mkdir -p $LOG_PATH
fi

cur_date="`date +%Y%m%d`"

top_log_path=$LOG_PATH'/top_'$cur_date'.log'
memory_log_path=$LOG_PATH'/memory_'$cur_date'.log'
cpu_log_path=$LOG_PATH'/cpu_'$cur_date'.log'
io_log_path=$LOG_PATH'/io_'$cur_date'.log'
network_log_path=$LOG_PATH'/network_'$cur_date'.log'

# total performance check
top -b -d $DELAY -n $COUNT >> $top_log_path 2>&1 &

# memory check
vmstat $DELAY $COUNT >> $memory_log_path 2>&1 &

# cpu check
sar -u $DELAY $COUNT >> $cpu_log_path 2>&1 &

# IO check
iostat $DELAY $COUNT >> $io_log_path 2>&1 &

# network check
sar -n DEV $DELAY $COUNT >> $network_log_path 2>&1 &
