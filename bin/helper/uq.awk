#!/usr/local/bin/awk -f

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
    if (uq_opt_zero_terminated) {
        RS = "\0"
        ORS = "\0"
    }
}

{
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
