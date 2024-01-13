#!/usr/bin/env bash
# @Function
# show all console text color themes.
#
# @online-doc https://github.com/oldratlee/useful-scripts/blob/dev-2.x/docs/shell.md#-console-text-color-themessh
# @author Jerry Lee (oldratlee at gmail dot com)
#
# NOTE about Bash Traps and Pitfalls:
#
# 1. DO NOT combine var declaration and assignment which value supplied by subshell in ONE line!
#    for example: readonly var1=$(echo value1)
#                 local var2=$(echo value1)
#
#    Because the combination make exit code of assignment to be always 0,
#      aka. the exit code of command in subshell is discarded.
#      tested on bash 3.2.57/4.2.46
#
#    solution is separation of var declaration and assignment:
#           var1=$(echo value1)
#           readonly var1
#           local var2
#           var2=$(echo value1)

colorEcho() {
  local combination=$1
  shift 1
  # if stdout is a terminal, turn on color output.
  #   '-t' check: is a terminal?
  #   check isatty in bash https://stackoverflow.com/questions/10022323
  if [ -t 1 ]; then
    printf '\e[%sm%s\e[0m\n' "$combination" "$*"
  else
    print '%s\n' "$*"
  fi
}

colorEchoWithoutNewLine() {
  local combination=$1
  shift 1

  if [ -t 1 ]; then
    printf '\e[%sm%s\e[0m' "$combination" "$*"
  else
    printf %s "$*"
  fi
}

# if source this script(use as lib), just export 2 helper functions, and do NOT print anything.
#
# if directly run this script, the length of array BASH_SOURCE is 1;
# if source this script, the length of array BASH_SOURCE is grater than 1.
((${#BASH_SOURCE[@]} == 1)) || return 0

for style in 0 1 2 3 4 5 6 7; do
  for fg in 30 31 32 33 34 35 36 37; do
    for bg in 40 41 42 43 44 45 46 47; do
      combination="${style};${fg};${bg}"
      colorEchoWithoutNewLine "$combination" "$combination"
      printf ' '
    done
    echo
  done
  echo
done

echo 'Code sample to print color text:'

printf %s '    echo -e "\e['
colorEchoWithoutNewLine '3;35;40' '1;36;41'
printf %s m
colorEchoWithoutNewLine '0;32;40' 'Sample Text'
printf '%s\n' '\e[0m"'

printf %s "    echo \$'\e["
colorEchoWithoutNewLine '3;35;40' '1;36;41'
printf %s "m'\""
colorEchoWithoutNewLine '0;32;40' 'Sample Text'
printf '%s\n' "\"$'\e[0m'"
printf '%s\n' "      # NOTE: $'foo' is the escape sequence syntax of bash, safer escape"

printf '%s\n' 'Output of above code:'
printf %s '    '
colorEcho '1;36;41' 'Sample Text'
echo
echo 'If you are going crazy to write text in escapes string like me,'
echo 'you can use colorEcho and colorEchoWithoutNewLine function in this script.'
echo
echo 'Code sample to print color text:'
echo '    colorEcho "1;36;41" "Sample Text"'
echo 'Output of above code:'
echo -n '    '
colorEcho '1;36;41' 'Sample Text'
