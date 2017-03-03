#!/bin/bash
# @Function
# show count of tcp connection stat.
#
# @Usage
#   $ ./tcp-connection-state-counter.sh
#
# @author Jerry Lee
# on mac osx , netstat need to using -p tcp to get only tcp output.
netstat -tna `[ ! -z $(uname|grep Darwin) ] && echo "-ptcp"` | awk 'NR > 2 {
    s[$NF]++
}

END {
    for(v in s) {
        printf "%-12s%s\n", v, s[v]
    }
}' | sort -nr -k2,2
