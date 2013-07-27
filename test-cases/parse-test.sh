#!/bin/bash

BASE=`dirname $0`

. $BASE/../parse.sh

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+" aa -a -b bb -c c.sh -a -b -c cc a1 a2 \; bb -d d.sh d1 d2 d3 \; cc -- dd ee
_opts_showOptDescInfoList
_opts_showOptValueInfoList

parseOpts "a,a-long|b,b-long:|c,c-long+|d,d-long+" aa -a -b bb -x -c c.sh -p pv -q qv \; bb -d -d d.sh d1 d2 d3 \; cc -- dd ee
_opts_showOptDescInfoList
_opts_showOptValueInfoList
