#!/bin/bash

GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE='\033[1;34m'
NC='\033[0m'

echo -e "${GREEN}New Files${NC}"

NEW_FILES=`git status | grep 'new file:' | awk '{print $3}'`
if [ "$NEW_FILES" == "" ]; then echo "None"; fi
for f in $NEW_FILES; do
    echo -e "Ready to add new file: ${GREEN}$f${NC}"
    echo "any other input value to abort!"
    read  input
    if [ "$input" == "" ]; then
        git add "$f"
    else
        echo "new file: $f not being added!"
    fi
done

echo -e "${BLUE}Modifies Files${NC}"
MOD_FILES=`git status | grep 'modified:' | awk '{print $2}'`
if [ "$MOD_FILES" == "" ]; then echo "None"; fi
for f in $MOD_FILES; do
    echo -e "Ready to add modified ${BLUE}$f${NC}"
    echo "any other input value to abort!"
    read  input
    if [ "$input" == "" ]; then
        git add "$f"
    else
        echo "modified file: $f not being added!"
    fi
done

echo -e "${RED}Deleted Files${NC}"
DEL_FILES=`git status | grep 'deleted:' | awk '{print $2}'`
if [ "$DEL_FILES" == "" ]; then echo "None"; fi
for f in $DEL_FILES; do
    echo -e "Ready to delete(cache) file ${RED}$f${NC}"
    echo "any other input value to abort!"
    read  input
    if [ "$input" == "" ]; then
        git rm --cache "$f"
    else
        echo "modified file: $f not being added!"
    fi
done

echo "All Done"
