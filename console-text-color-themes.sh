#!/bin/bash
# @Function
# show all console text color themes.

colorEcho() {
    local combination="$1"
    shift 1
    [ -c /dev/stdout ] && {
        echo -e -n "\033[${combination}m"
        echo -e -n "$@"
        echo -e "\033[0m"
    } || echo "$@"
}

colorEchoWithoutNewLine() {
    local combination="$1"
    shift 1
    [ -c /dev/stdout ] && {
        echo -e -n "\033[${combination}m"
        echo -e -n "$@"
        echo -e -n "\033[0m"
    } || echo -n "$@"
}

for style in 0 1 2 3 4 5 6 7; do
    for fg in 30 31 32 33 34 35 36 37; do
        for bg in 40 41 42 43 44 45 46 47; do
            combination="${style};${fg};${bg}"
            colorEchoWithoutNewLine "$combination" "$combination"
            echo -n " "
        done
        echo
    done
    echo
done

echo "Code sample to print color text:"
echo -n '    echo -e "\033['
colorEchoWithoutNewLine "3;35;40" "1;36;41"
echo -n "m"
colorEchoWithoutNewLine "0;32;40" "Sample Text"
echo "\033[0m\""
echo "Output of above code:"
echo -e "    \033[1;36;41mSample Text\033[0m"
echo
echo "If you are going crazy to write text in escapes string like me,"
echo "you can use colorEcho and colorEchoWithoutNewLine function in this script."
echo
echo "Code sample to print color text:"
echo '    colorEcho "1;36;41" "Sample Text"'
echo "Output of above code:"
echo -n "    "
colorEcho "1;36;41" "Sample Text"
