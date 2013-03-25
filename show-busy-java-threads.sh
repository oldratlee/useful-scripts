#!/bin/bash
# @Function
# Find out the highest cpu consumed threads of java, and print the stack of these threads.
#
# @Usage
#   $ ./show-busy-java-threads.sh
#
# @author Jerry Lee

PROG=`basename $0`

redEcho() {
    if [ -c /dev/stdout ] ; then
        # if stdout is console, turn on color output.
        echo -e "\033[1;31m$@\033[0m"
    else
        echo "$@"
    fi
}

usage() {
    cat <<EOF
Usage: ${PROG} [OPTION]...
Find out the highest cpu consumed threads of java, and print the stack of these threads.
Example: ${PROG} -c 10

Options:
    -p, --pid       print thread stack from the specifed java process, default from all java process.
    -c, --count     set the thread count to show, default is 5
    -h, --help      display this help and exit
EOF
    exit $1
}

printStackOfThreads() {
    while read threadLine ; do
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
}

ARGS=`getopt -a -o c:p:h -l count:,pid:,help -- "$@"`
[ $? -ne 0 ] && usage 1
eval set -- "${ARGS}"

while true; do
    case "$1" in
    -c|--count)
        count="$2"
        shift 2
        ;;
    -p|--pid)
        pid="$2"
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
done
[ -z "${count}" ] && count=5

uuid=`date +%s`_${RANDOM}_$$

if [ -z ${pid} ] ; then 
    ps -Leo pid,lwp,user,comm,pcpu --no-headers | awk '$4=="java"{print $0}' |
    sort -k5 -r -n | head --lines "${count}" | printStackOfThreads
else
    ps -Leo pid,lwp,user,comm,pcpu --no-headers | awk '$1=="'${pid}'",$4=="java"{print $0}' |
    sort -k5 -r -n | head --lines "${count}" | printStackOfThreads
fi

rm /tmp/${uuid}_*
