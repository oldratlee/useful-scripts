#!/bin/bash
# @Function
# Find out the highest cpu consumed threads of java, and print the stack of these threads.
#
# @Usage
#   $ ./show-busy-java-threads
#
# @online-doc https://github.com/oldratlee/useful-scripts/blob/master/docs/java.md#beer-show-busy-java-threads
# @author Jerry Lee (oldratlee at gmail dot com)
# @author superhj1987 (superhj1987 at 126 dot com)

readonly PROG="`basename $0`"
readonly -a COMMAND_LINE=("$0" "$@")
# Get current user name via whoami command
#   See https://www.lifewire.com/current-linux-user-whoami-command-3867579
# Because if run command by `sudo -u`, env var $USER is not rewritten/correct, just inherited from outside!
readonly USER="`whoami`"

################################################################################
# util funtions
################################################################################

# NOTE: $'foo' is the escape sequence syntax of bash
readonly ec=$'\033' # escape char
readonly eend=$'\033[0m' # escape end

colorPrint() {
    local color=$1
    shift

    # if stdout is console, turn on color output.
    [ -t 1 ] && echo "$ec[1;${color}m$@$eend" || echo "$@"

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
    [ -n "$append_file" ] && echo "$@" >> "$append_file"
}

fatal() {
    redPrint "$@" 1>&2
    exit 1
}

usage() {
    [ -n "$1" -a "$1" != 0 ] && local out=/dev/stderr || local out=/dev/stdout

    > $out cat <<EOF
Usage: ${PROG} [OPTION]... [delay [count]]
Find out the highest cpu consumed threads of java, and print the stack of these threads.

Example:
  ${PROG}       # show busy java threads info
  ${PROG} 1     # update every 1 second, (stop by eg: CTRL+C)
  ${PROG} 3 10  # update every 3 seconds, update 10 times

Options:
  -p, --pid <java pid>      find out the highest cpu consumed threads from the specifed java process,
                            default from all java process.
  -c, --count <num>         set the thread count to show, default is 5
  -a, --append-file <file>  specify the file to append output as log
  -s, --jstack-path <path>  specify the path of jstack command
  -F, --force               set jstack to force a thread dump
                            use when jstack <pid> does not respond (process is hung)
  -m, --mix-native-frames   set jstack to print both java and native frames (mixed mode)
  -l, --lock-info           set jstack with long listing. Prints additional information about locks
  -h, --help                display this help and exit
  delay                     the delay between updates in seconds
  count                     the number of updates
                            delay/count arguments imitates the style of vmstat command
EOF

    exit $1
}

################################################################################
# Check os support
################################################################################

uname | grep '^Linux' -q || fatal "Error: $PROG only support Linux, not support `uname` yet!"

################################################################################
# parse options
################################################################################

readonly ARGS=`getopt -n "$PROG" -a -o p:c:a:s:Fmlh -l count:,pid:,append-file:,jstack-path:,force,mix-native-frames,lock-info,help -- "$@"`
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
    -s|--jstack-path)
        jstack_path="$2"
        shift 2
        ;;
    -F|--force)
        force=-F
        shift 1
        ;;
    -m|--mix-native-frames)
        mix_native_frames=-m
        shift 1
        ;;
    -l|--lock-info)
        more_lock_info=-l
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

update_delay=${1:-0}
[ -z "$1" ] && update_count=1 || update_count=${2:-0}
[ $update_count -lt 0 ] && update_count=0

################################################################################
# check the existence of jstack command
################################################################################

if [ -n "$jstack_path" ]; then
    [ -f "$jstack_path" ] || fatal "Error: $jstack_path is NOT found!"
    [ -x "$jstack_path" ] || fatal "Error: $jstack_path is NOT executalbe!"
elif which jstack &> /dev/null; then
    jstack_path="`which jstack`"
else
    [ -z "$JAVA_HOME" ] && fatal "Error: jstack not found on PATH and No JAVA_HOME setting! Use -s option set jstack path manually."
    [ -f "$JAVA_HOME/bin/jstack" ] || fatal "Error: jstack not found on PATH and \$JAVA_HOME/bin/jstack($JAVA_HOME/bin/jstack) file does NOT exists! Use -s option set jstack path manually."
    [ -x "$JAVA_HOME/bin/jstack" ] || fatal "Error: jstack not found on PATH and \$JAVA_HOME/bin/jstack($JAVA_HOME/bin/jstack) is NOT executalbe! Use -s option set jstack path manually."
    jstack_path="$JAVA_HOME/bin/jstack"
fi

################################################################################
# biz logic
################################################################################

readonly uuid=`date +%s`_${RANDOM}_$$

cleanupWhenExit() {
    rm /tmp/${uuid}_* &> /dev/null
}
trap "cleanupWhenExit" EXIT

printStackOfThreads() {
    local line
    local counter=0
    while IFS=" " read -a line ; do
        local pid=${line[0]}
        local threadId=${line[1]}
        local threadId0x="0x`printf %x ${threadId}`"
        local pcpu=${line[3]}
        local user=${line[4]}

        ((counter++))
        local jstackFile=/tmp/${uuid}_${pid}
        [ -f "${jstackFile}" ] || {
            if [ "${user}" == "${USER}" ]; then
                # run without sudo, when java process user is current user
                "$jstack_path" ${force} $mix_native_frames $more_lock_info ${pid} > ${jstackFile}
            elif [ $UID == 0 ]; then
                # if java process user is not current user, must run jstack with sudo
                sudo -u "${user}" "$jstack_path" ${force} $mix_native_frames $more_lock_info ${pid} > ${jstackFile}
            else
                # current user is not root user, so can not run with sudo; print error message and rerun suggestion
                redPrint "[$counter] Fail to jstack busy(${pcpu}%) thread(${threadId}/${threadId0x}) stack of java process(${pid}) under user(${user})."
                redPrint "User of java process($user) is not current user($USER), need sudo to rerun:"
                yellowPrint "    sudo ${COMMAND_LINE[@]}"
                normalPrint
                continue
            fi || {
                redPrint "[$counter] Fail to jstack busy(${pcpu}%) thread(${threadId}/${threadId0x}) stack of java process(${pid}) under user(${user})."
                normalPrint
                rm ${jstackFile}
                continue
            }
        }

        bluePrint "[$counter] Busy(${pcpu}%) thread(${threadId}/${threadId0x}) stack of java process(${pid}) under user(${user}):"

        if [ -n "$mix_native_frames" ]; then
            local sed_script="/--------------- $threadId ---------------/,/^---------------/ {
                /--------------- $threadId ---------------/b # skip first seperator line
                /^---------------/s/.*// # replace sencond seperator line to empty line
                p
            }"
        elif [ -n "$force" ]; then
            local sed_script="/^Thread ${threadId}:/,/^$/p"
        else
            local sed_script="/nid=${threadId0x} /,/^$/p"
        fi
        sed "$sed_script" -n ${jstackFile} | tee ${append_file:+-a "$append_file"}
    done
}

headInfo() {
    echo ================================================================================
    echo "$(date "+%Y-%m-%d %H:%M:%S.%N") [$((i+1))/$update_count]: ${COMMAND_LINE[@]}"
    echo ================================================================================
    echo
}

# if update_count <= 0, infinite loop till user interupted (eg: CTRL+C)
for ((i = 0; update_count <= 0 || i < update_count; ++i)); do
    [ "$i" -gt 0 ] && sleep "$update_delay"

    [ -n "$append_file" ] && headInfo >> "$append_file"
    [ "$update_count" -ne 1 ] && headInfo

    # use wide output(unlimited width), avoid trunk user column to username_fo+ or $uid alike
    ps -wwLeo pid,lwp,comm,pcpu,user --no-headers | {
        [ -z "${pid}" ] &&
        awk '$3=="java"{print $0}' ||
        awk -v "pid=${pid}" '$1==pid,$3=="java"{print $0}'
    } | sort -k4,4 -r -n | head -n "${count}" | printStackOfThreads
done
