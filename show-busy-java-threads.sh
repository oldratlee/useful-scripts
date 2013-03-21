#!/bin/bash
# @Function
# Find the High cpu consume thread of java, and print the stack of these threads.
#
# @Usage
#   $ ./show-busy-java-threads.sh
#
# @author Jerry Lee

PROG=`basename $0`

redEcho() {
    if [ -p /dev/stdout ] ; then
        # if stdout is pipeline, shutdown color output.
        echo "$@"
    else
        echo -e "\033[1;31m$@\033[0m"
    fi
}

usage() {
    cat <<EOF
Usage: ${PROG} [OPTION]...
Find the High cpu consume thread of java, and print the stack of these threads.
Example: ${PROG} -c 10

Options:
    -c, --count     set the thread count to show, default is 5
    -h, --help      display this help and exit
EOF
    exit $1
}

ARGS=`getopt -a -o c:h -l count:,help -- "$@"`
[ $? -ne 0 ] && usage 1
eval set -- "${ARGS}"

while true; do
    case "$1" in
    -c|--count)
        count="$2"
        shift 2
        ;;
    -h|--help)
        usage
        ;;
    --)
        shift
        break
        ;;
    esac
    shift
done
[ -z "${count}" ] && count=5

uuid=`date +%s`_${RANDOM}_$$

ps -Leo pid,lwp,user,comm,pcpu --no-headers | awk '$4=="java"{print $0}' |
sort -k5 -r -n | head --lines "${count}" | while read threadLine ; do
        pid=`echo ${threadLine} | awk '{print $1}'`
        threadId=`echo ${threadLine} | awk '{print $2}'`
        threadId0x=`printf %x ${threadId}`
        user=`echo ${threadLine} | awk '{print $3}'`
        pcpu=`echo ${threadLine} | awk '{print $5}'`
        
        jstackFile=/tmp/${uuid}_${pid}
        
        [ ! -f "${jstackFile}" ] && {
            jstack ${pid} > ${jstackFile} || {
                redEcho "Fail to jstack java process ${pid}"
                rm ${jstackFile}
                continue
            }
        }
        
        redEcho "The stack of busy(${pcpu}%) thread(${threadId}/0x${threadId0x}) of java process(${pid}) of user(${user}):"
        sed "/nid=0x${threadId0x}/,/^$/p" -n ${jstackFile}
done

rm /tmp/${uuid}_*
