#!/usr/local/bin/awk -f

function printResult(for_lines) {
    for (idx = 0; idx < length(for_lines); idx++) {
        line=for_lines[idx]
        count=line_count_array[storeLine(line)]

        #printf "DEBUG 1: %7s %s, index: %s\n", count, line, idx

        if (uq_opt_only_unique) {
            if (count == 1) printLine(count, line)
        } else {
            #printf "DEBUG 2: %7s %s uq_opt_only_repeated: %s\n", count, line, uq_opt_only_repeated

            if (uq_opt_only_repeated && count <= 1) {
                continue
            }

            if (uq_opt_repeated_method == "prepend" || uq_opt_repeated_method == "separate" && outputted) {
                if (!compareLine(line, outputted)) print ""
            }

            printLine(count, line)
            outputted=line
        }
    }
}

function printLine(count, line) {
    if (uq_opt_count) {
        printf "%7s %s%s", count, line, ORS
    } else {
        print line
    }
}

function storeLine(line) {
    if (uq_opt_ignore_case) {
        return tolower(line)
    } else {
        return line
    }
}

function compareLine(line1, line2) {
    return storeLine(line1) == storeLine(line2)
}


BEGIN {
    if (uq_opt_zero_terminated) {
        RS = "\0"
        ORS = "\0"
    }
}


{
    # use index to keep lines order
    lines[line_index++] = $0

    store_line=storeLine($0)
    # line_count_array: line content -> count
    if (++line_count_array[store_line] == 1) {
        # use index to keep lines order
        deduplicated_lines[deduplicated_line_index++] = store_line
    }
}


END {
    if (uq_opt_all_repeated) printResult(lines)
    else printResult(deduplicated_lines)
}
