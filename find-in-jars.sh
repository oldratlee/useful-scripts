#!/bin/bash
# @Function
# Find file in the jar files under current directory
#
# @Usage
#   $ find-in-jars.sh log4j\\.xml
#   $ find-in-jars.sh 'log4j\.properties'
#   $ find-in-jars.sh 'log4j\.properties|log4j\.xml'
#
# @author Jerry Lee

[ -z "$1" ] && { echo No find file pattern! ; exit 1; }  

find -iname '*.jar' | while read jarFile
do
        jar tf ${jarFile} | egrep "$1" | while read file
        do
                echo "${jarFile}"\!"${file}"
        done
done
