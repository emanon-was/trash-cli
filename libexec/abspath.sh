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
        f=`\basename $arg;`;
        p=`\dirname $arg;`;
        p=`\cd $p;\pwd;`;
        abs=$p/$f;
        \echo $abs;
    fi
    # directory
    if [ -d $arg ];then
        abs=`\cd $arg;\pwd;`;
        \echo $abs;
    fi
done
IFS=$_IFS;
unset arg f p abs _IFS;

