#!/bin/bash
# @Function
# show count of tcp connection stat.
#
# @Usage
#   $ ./tcp-connection-state-counter.sh
#
# @author Jerry Lee

netstat -tn | awk 'NR > 2 {
    s[$NF]++ 
}

END {
    for(v in s) {
        print v "\t" s[v]
    }
}' | sort -nr -k2,2
