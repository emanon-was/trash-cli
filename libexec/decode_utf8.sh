#!/bin/bash

# Usage
# -------------------------
# $ decode_utf8 %E3%83%86%E3%82%B9%E3%83%88
# > テスト
# -------------------------

IFS=$'\n'
for out in $@;do
    out=`echo -e $out | sed -e "s/%\([0-9a-fA-F][0-9a-fA-F]\)/\\\\\x\1/g"`;
    echo -e "$out";
done
unset out IFS;




