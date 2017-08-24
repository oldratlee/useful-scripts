#!/bin/bash
# @Function
# show count of tcp connection stat.
#
# @Usage
#   $ ./tcp-connection-state-counter.sh
#
# @author Jerry Lee

# On MacOS, netstat need to using -p tcp to get only tcp output.
[ -n "$(uname | grep Darwin)" ] && option_for_mac="-ptcp"

netstat -tna $option_for_mac | awk 'NR > 2 {
    s[$NF]++
}

END {
    for(v in s) {
        printf "%-12s%s\n", v, s[v]
    }
}' | sort -nr -k2,2
