#!/bin/bash

# Usage
# -------------------------
# $ abspath .
# > /home/emanon
# -------------------------

_IFS="$IFS";IFS=$'\n';
for arg in $@;do
    # file
    if [ -f $arg ];then
        f=`basename $arg;`;
        p=`dirname $arg;`;p=`cd $p;pwd;`;
        echo -e $p/$f;
    fi
    # directory
    if [ -d $arg ];then
        echo -e `cd $arg;pwd;`;
    fi
done
IFS="$_IFS";
unset _IFS arg f p;
