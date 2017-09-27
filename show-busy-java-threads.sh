#!/bin/bash
# @Function
# Find out the highest cpu consumed threads of java, and print the stack of these threads.
#
# @Usage
#   $ ./show-busy-java-threads.sh
#
# @author Jerry Lee

readonly PROG=`basename $0`
readonly -a COMMAND_LINE=("$0" "$@")

usage() {
    local out
    [ -n "$1" -a "$1" != 0 ] && out=/dev/stderr || out=/dev/stdout

    > $out cat <<EOF
Usage: ${PROG} [OPTION]...
Find out the highest cpu consumed threads of java, and print the stack of these threads.
Example: ${PROG} -c 10

Options:
  -p, --pid <java pid>      find out the highest cpu consumed threads from the specifed java process,
                            default from all java process.
  -c, --count <num>         set the thread count to show, default is 5
  -a, --append-file <file>  specify the file to append output as log
  -t, --repeat-times <num>  specify the show times, default just show 1 time
  -i, --interval <secs>     seconds to wait between updates, default 3 seconds
  -s, --jstack-path <path>  specify the path of jstack command
  -F, --force               set jstack to force a thread dump(use jstack -F option)
  -h, --help                display this help and exit
EOF

    exit $1
}

readonly ARGS=`getopt -n "$PROG" -a -o p:c:a:t:i:s:Fh -l count:,pid:,append-file:,repeat-times:,interval:,jstack-path:,force,help -- "$@"`
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
    -a|--append-file)
        append_file="$2"
        shift 2
        ;;
    -t|--repeat-times)
        repeat_times="$2"
        shift 2
        ;;
    -i|--interval)
        interval="$2"
        shift 2
        ;;
    -s|--jstack-path)
        jstack_path="$2"
        shift 2
        ;;
    -F|--force)
        force=-F
        shift 1
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
count=${count:-5}
repeat_times=${repeat_times:-1}
interval=${interval:-3}

colorPrint() {
    local color=$1
    shift
    if [ -c /dev/stdout ] ; then
        # if stdout is console, turn on color output.
        echo -ne "\033[1;${color}m"
        echo -n "$@"
        echo -e "\033[0m"
    else
        echo "$@"
    fi

    [ -n "$append_file" ] && echo "$@" >> "$append_file"
}

redPrint() {
    colorPrint 31 "$@"
}

greenPrint() {
    colorPrint 32 "$@"
}

yellowPrint() {
    colorPrint 33 "$@"
}

bluePrint() {
    colorPrint 36 "$@"
}

normalPrint() {
    echo "$@"

    [ -z "$append_file" ] && echo "$@" >> "$append_file"
}

if [ -n "$jstack_path" ]; then
    ! [ -x "$jstack_path" ] && {
        redPrint "Error: $jstack_path is NOT executalbe!" 1>&2
        exit 1
    }
# Check the existence of jstack command!
elif ! which jstack &> /dev/null; then
    [ -z "$JAVA_HOME" ] && {
        redPrint "Error: jstack not found on PATH!" 1>&2
        exit 1
    }
    ! [ -f "$JAVA_HOME/bin/jstack" ] && {
        redPrint "Error: jstack not found on PATH and \$JAVA_HOME/bin/jstack($JAVA_HOME/bin/jstack) file does NOT exists!" 1>&2
        exit 1
    }
    ! [ -x "$JAVA_HOME/bin/jstack" ] && {
        redPrint "Error: jstack not found on PATH and \$JAVA_HOME/bin/jstack($JAVA_HOME/bin/jstack) is NOT executalbe!" 1>&2
        exit 1
    }
    export PATH="$JAVA_HOME/bin:$PATH"
    jstack_path="`which jstack`"
fi

readonly uuid=`date +%s`_${RANDOM}_$$

cleanupWhenExit() {
    rm /tmp/${uuid}_* &> /dev/null
}
trap "cleanupWhenExit" EXIT

printStackOfThreads() {
    local line
    local counter=1
    while IFS=" " read -a line ; do
        local pid=${line[0]}
        local threadId=${line[1]}
        local threadId0x="0x`printf %x ${threadId}`"
        local user=${line[2]}
        local pcpu=${line[4]}

        local jstackFile=/tmp/${uuid}_${pid}
        [ ! -f "${jstackFile}" ] && {
            {
                if [ "${user}" == "${USER}" ]; then
                    "$jstack_path" ${force} ${pid} > ${jstackFile}
                elif [ $UID == 0 ]; then
                    sudo -u "${user}" "$jstack_path" ${force} ${pid} > ${jstackFile}
                else
                    redPrint "[$((counter++))] Fail to jstack Busy(${pcpu}%) thread(${threadId}/${threadId0x}) stack of java process(${pid}) under user(${user})."
                    redPrint "User of java process($user) is not current user($USER), need sudo to run again:"
                    yellowPrint "    sudo ${COMMAND_LINE[@]}"
                    normalPrint
                    continue
                fi
            } || {
                redPrint "[$((counter++))] Fail to jstack Busy(${pcpu}%) thread(${threadId}/${threadId0x}) stack of java process(${pid}) under user(${user})."
                normalPrint
                rm ${jstackFile}
                continue
            }
        }

        bluePrint "[$((counter++))] Busy(${pcpu}%) thread(${threadId}/${threadId0x}) stack of java process(${pid}) under user(${user}):"
        sed "/nid=${threadId0x} /,/^$/p" -n ${jstackFile} | tee ${append_file+-a "$append_file"}
    done
}


head_info() {
    echo ================================================================================
    echo "$(date "+%Y-%m-%d %H:%M:%S.%N"): ${COMMAND_LINE[@]}"
    echo ================================================================================
    echo
}

for((i = 0; i < repeat_times; ++i)); do
    [ "$i" -gt 0 ] && sleep "$interval"

    [ -n "$append_file" ] && head_info >> "$append_file"
    [ "$repeat_times" -gt 1 ] && head_info

    ps -Leo pid,lwp,user,comm,pcpu --no-headers | {
        [ -z "${pid}" ] &&
        awk '$4=="java"{print $0}' ||
        awk -v "pid=${pid}" '$1==pid,$4=="java"{print $0}'
    } | sort -k5 -r -n | head --lines "${count}" | printStackOfThreads
done
