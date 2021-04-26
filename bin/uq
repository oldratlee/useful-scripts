#!/bin/bash
# @Function
# Filter lines from INPUT (or standard input), writing to OUTPUT (or standard output).
# same as `uniq` command in core utils,
# but detect repeated lines that are not adjacent, no sorting required.
#
# @Usage
#   uq [OPTION]... [INPUT [OUTPUT]]
#
# @online-doc https://github.com/oldratlee/useful-scripts/blob/dev-2.x/docs/shell.md#-uq
# @author Zava Xu (zava.kid at gmail dot com)
# @author Jerry Lee (oldratlee at gmail dot com)# NOTE about Bash Traps and Pitfalls:
#
# NOTE about Bash Traps and Pitfalls:
#
# 1. DO NOT combine var declaration and assignment which value supplied by subshell!
#    for example: readonly var1=$(echo value1)
#                 local var1=$(echo value1)
#
#    declaration make exit code of assignment to be always 0,
#      aka. the exit code of command in subshell is discarded.
#      tested on bash 3.2.57/4.2.46
set -eEuo pipefail

# NOTE: DO NOT declare var PROG as readonly, because its value is supplied by subshell.
PROG="$(basename "$0")"
readonly PROG_VERSION='2.5.0-dev'

################################################################################
# util functions
################################################################################

# NOTE: $'foo' is the escape sequence syntax of bash
readonly ec=$'\033'      # escape char
readonly eend=$'\033[0m' # escape end
readonly nl=$'\n'        # new line

redEcho() {
    [ -t 1 ] && echo "${ec}[1;31m$*$eend" || echo "$*"
}

yellowEcho() {
    [ -t 1 ] && echo "${ec}[1;33m$*$eend" || echo "$*"
}

die() {
    redEcho "Error: $*" 1>&2
    exit 1
}

convertHumanReadableSizeToSize() {
    local human_readable_size="$1"

    [[ "$human_readable_size" =~ ^([0-9][0-9]*)([kmg]?)$ ]] || return 1

    local size="${BASH_REMATCH[1]}" unit="${BASH_REMATCH[2]}"
    case "$unit" in
    g)
        ((size *= 1024 * 1024 * 1024))
        ;;
    m)
        ((size *= 1024 * 1024))
        ;;
    k)
        ((size *= 1024))
        ;;
    esac

    echo "$size"
}

usage() {
    local -r exit_code="${1:-0}"
    (($# > 0)) && shift
    # shellcheck disable=SC2015
    [ "$exit_code" != 0 ] && local -r out=/dev/stderr || local -r out=/dev/stdout

    (($# > 0)) && redEcho "$*$nl" >$out

    cat >$out <<EOF
Usage: ${PROG} [OPTION]... [INPUT [OUTPUT]]
Filter lines from INPUT (or standard input), writing to OUTPUT (or standard output).
Same as \`uniq\` command in core utils,
but detect repeated lines that are not adjacent, no sorting required.

Example:
  # only one file, output to stdout
  uq in.txt
  # more than 1 file, last file argument is output file
  uq in.txt out.txt
  # when use - as output file, output to stdout
  uq in1.txt in2.txt -

Options:
  -c, --count           prefix lines by the number of occurrences
  -d, --repeated        only print duplicate lines, one for each group
  -D                    print all duplicate lines
                        combined with -c/-d option usually
  --all-repeated[=METHOD]  like -D, but allow separating groups
                           with an empty line;
                           METHOD={none(default),prepend,separate}
  -u, --unique          Only output unique lines
                          that are not repeated in the input
  -i, --ignore-case     ignore differences in case when comparing
  -z, --zero-terminated line delimiter is NUL, not newline
  -XM, --max-input      max input size(count by char), support k,m,g postfix
                          default is 256m
                          avoid consuming large memory unexpectedly
  -h, --help            display this help and exit
  -V, --version         display version information and exit
EOF

    exit "$exit_code"
}

progVersion() {
    echo "$PROG $PROG_VERSION"
    exit
}

################################################################################
# parse options
################################################################################

uq_opt_count=0
uq_opt_only_repeated=0
uq_opt_all_repeated=0
uq_opt_repeated_method=none
uq_opt_only_unique=0
uq_opt_ignore_case=0
uq_opt_zero_terminated=0
uq_max_input_human_readable_size=256m
declare -a argv=()

while (($# > 0)); do
    case "$1" in
    -c | --count)
        uq_opt_count=1
        shift
        ;;
    -d | --repeated)
        uq_opt_only_repeated=1
        shift
        ;;
    -D)
        uq_opt_all_repeated=1
        shift
        ;;
    --all-repeated=*)
        uq_opt_all_repeated=1

        uq_opt_repeated_method=$(echo "$1" | awk -F= '{print $2}')
        [[ $uq_opt_repeated_method == 'none' || $uq_opt_repeated_method == 'prepend' || $uq_opt_repeated_method == 'separate' ]] ||
            usage 1 "$PROG: invalid argument ‘${uq_opt_repeated_method}’ for ‘--all-repeated’${nl}Valid arguments are:$nl  - ‘none’$nl  - ‘prepend’$nl  - ‘separate’"

        shift
        ;;
    -u | --unique)
        uq_opt_only_unique=1
        shift
        ;;
    -i | --ignore-case)
        uq_opt_ignore_case=1
        shift
        ;;
    -z | --zero-terminated)
        uq_opt_zero_terminated=1
        shift
        ;;
    -XM | --max-input)
        uq_max_input_human_readable_size="$2"
        shift 2
        ;;
    -h | --help)
        usage
        ;;
    -V | --version)
        progVersion
        ;;
    --)
        shift
        argv=("${argv[@]}" "$@")
        break
        ;;
    -)
        argv=(${argv[@]:+"${argv[@]}"} "$1")
        shift
        ;;
    -*)
        usage 2 "${PROG}: unrecognized option '$1'"
        ;;
    *)
        argv=(${argv[@]:+"${argv[@]}"} "$1")
        shift
        ;;
    esac
done

[[ $uq_opt_only_repeated == 1 && $uq_opt_only_unique == 1 ]] &&
    usage 2 "printing duplicated lines(-d, --repeated) and unique lines(-u, --unique) is meaningless"
[[ $uq_opt_all_repeated == 1 && $uq_opt_only_unique == 1 ]] &&
    usage 2 "printing all duplicate lines(-D, --all-repeated) and unique lines(-u, --unique) is meaningless"

[[ $uq_opt_all_repeated == 1 && $uq_opt_repeated_method == none && ($uq_opt_count == 0 && $uq_opt_only_repeated == 0) ]] &&
    yellowEcho "[$PROG] WARN: -D/--all-repeated=none option without -c/-d option, just cat input simply!" >&2

# NOTE: DO NOT declare var uq_max_input_size as readonly, because its value is supplied by subshell.
uq_max_input_size="$(convertHumanReadableSizeToSize "$uq_max_input_human_readable_size")" ||
    usage 2 "[$PROG] ERROR: illegal value of option -XM/--max-input: $uq_max_input_human_readable_size"

readonly argc=${#argv[@]}

if ((argc == 0)); then
    input_files=()
    output_file=/dev/stdout
elif ((argc == 1)); then
    input_files=("${argv[0]}")
    output_file=/dev/stdout
else
    input_files=("${argv[@]:0:argc-1}")
    output_file=${argv[argc - 1]}
    if [ "$output_file" == - ]; then
        output_file=/dev/stdout
    fi
fi

# Check input file
for f in ${input_files[@]:+"${input_files[@]}"}; do
    # - is stdin, ok
    [ "$f" == - ] && continue

    [ -e "$f" ] || die "input file $f does not exist!"
    [ ! -d "$f" ] || die "input file $f exists, but is a directory!"
    [ -f "$f" ] || die "input file $f exists, but is not a file!"
    [ -r "$f" ] || die "input file $f exists, but is not readable!"
done

################################################################################
# biz logic
################################################################################

# uq awk script
#
# edit in a separated file(eg: uq.awk) then copy here,
# maybe more convenient(like good syntax highlight)

# shellcheck disable=SC2016
readonly uq_awk_script='

function printResult(for_lines) {
    for (idx = 0; idx < length(for_lines); idx++) {
        line = for_lines[idx]
        count = line_count_array[caseAwareLine(line)]
        #printf "DEBUG: %s %s, index: %s, uq_opt_only_repeated: %s\n", count, line, idx, uq_opt_only_repeated

        if (uq_opt_only_unique) {
            if (count == 1) printLine(count, line)
        } else {
            if (uq_opt_only_repeated && count <= 1) continue

            if (uq_opt_repeated_method == "prepend" || uq_opt_repeated_method == "separate" && previous_output) {
                if (line != previous_output) print ""
            }

            printLine(count, line)
            previous_output = line
        }
    }
}

function printLine(count, line) {
    if (uq_opt_count) printf "%7s %s%s", count, line, ORS
    else print line
}

function caseAwareLine(line) {
    if (IGNORECASE) return tolower(line)
    else return line
}

BEGIN {
    if (uq_opt_zero_terminated) ORS = RS = "\0"
}

{
    total_input_size += length + 1
    if (total_input_size > uq_max_input_size) {
        printf "[%s] ERROR: input size exceed max input size %s!\nuse option -XM/--max-input specify a REASONABLE larger value.\n",
            uq_PROG, uq_max_input_human_readable_size > "/dev/stderr"
        exit(1)
    }

    # use index to keep lines order
    original_lines[line_index++] = $0

    case_aware_line = caseAwareLine($0)
    # line_count_array: line content -> count
    if (++line_count_array[case_aware_line] == 1) {
        # use index to keep lines order
        deduplicated_lines[deduplicated_line_index++] = case_aware_line
    }
}

END {
    if (uq_opt_all_repeated) printResult(original_lines)
    else printResult(deduplicated_lines)
}

'

awk \
    -v "uq_opt_count=$uq_opt_count" \
    -v "uq_opt_only_repeated=$uq_opt_only_repeated" \
    -v "uq_opt_all_repeated=$uq_opt_all_repeated" \
    -v "uq_opt_repeated_method=$uq_opt_repeated_method" \
    -v "uq_opt_only_unique=$uq_opt_only_unique" \
    -v "IGNORECASE=$uq_opt_ignore_case" \
    -v "uq_opt_zero_terminated=$uq_opt_zero_terminated" \
    -v "uq_max_input_human_readable_size=$uq_max_input_human_readable_size" \
    -v "uq_max_input_size=$uq_max_input_size" \
    -v "uq_PROG=$PROG" \
    -f <(printf "%s" "$uq_awk_script") \
    -- ${input_files[@]:+"${input_files[@]}"} \
    >"$output_file"
