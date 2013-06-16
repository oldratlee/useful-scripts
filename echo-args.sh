#!/bin/bash

echo "(0/$#): [$0]"
idx=1
for a ; do
    echo "($idx/$#): [$a]"
    idx=$((idx + 1))
done
