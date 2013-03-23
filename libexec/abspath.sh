#!/bin/bash

# -------------------------
# $ abspath .
# > /home/emanon
# -------------------------

_IFS="$IFS";IFS=$'\n';
for arg in $@;do
    if [ -f $arg ];then
        b=`basename $arg;`;
        d=`dirname $arg;`;d=`cd $d;pwd;`;
        echo -e $d/$b;
    fi
    if [ -d $arg ];then
        echo -e `cd $arg;pwd;`;
    fi
done
unset arg b d;
IFS="$_IFS";
unset _IFS;
