#/bin/bash

for STYLE in 0 1 2 3 4 5 6 7; do
    for FG in 30 31 32 33 34 35 36 37; do
        for BG in 40 41 42 43 44 45 46 47; do
            CTRL="\033[${STYLE};${FG};${BG}m"
            `which echo` -en "${CTRL}"
            `which echo` -n "${STYLE};${FG};${BG}"
            `which echo` -en "\033[0m"
        done
        echo
    done
    echo
done
`which echo` -e "\033[0m"