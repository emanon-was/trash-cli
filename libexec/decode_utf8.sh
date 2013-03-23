#!/bin/bash

# Usage
# -------------------------
# $ decode_utf8 %E3%83%86%E3%82%B9%E3%83%88
# > テスト
# -------------------------

_IFS="$IFS";IFS=$'\n';
for stdout in $@;do
    echo -e "`echo -e $stdout|sed -e "s/%\([0-9a-fA-F][0-9a-fA-F]\)/\\\\\x\1/g";`";
done
IFS="$_IFS";
unset _IFS stdout;

