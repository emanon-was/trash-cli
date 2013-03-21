#!/bin/bash

# Usage
# -------------------------
# $ trash-put test1.txt test2.txt test3.txt test4.txt
# -------------------------

# values
IFS=$'\n';
trash=~/.local/share/Trash;
deldate=`date +"%Y-%m-%dT%T"`;
files=(`abspath $@`);

# mkdir ~/.local/share/Trash
if [ -e $trash/files ];then mkdir -p $trash/files;fi
if [ -e $trash/info ] ;then mkdir -p $trash/info ;fi

# processing
for fp in ${files[*]};do
    # rename
    rname=`basename $fp`;
    if [ -e $trash/files/$rname ] && [ -e $trash/info/$rname.trashinfo ];then
        if [ -f $fp ];then
            declare -i fnum;
            fname=`echo $rname|sed -e "s/\([^.]*\)\(.*\)/\1/"`;
            fext=`echo $rname|sed -e "s/\([^.]*\)\(.*\)/\2/"`;
            fnum=`ls $trash/files | grep "^$fname\(\.[0-9]*\)\?$fext$"|wc -l`+1;
            if [ $fnum -gt 1 ];then
                rname=$fname.$fnum$fext;
            fi
            unset fname fext fnum;
        fi
        if [ -d $fp ];then
            declare -i fnum;
            fnum=`ls $trash/files | grep "^$rname\(\.[0-9]*\)\?$"|wc -l`+1;
            if [ $fnum -gt 1 ];then
                rname=$rname.$fnum;
            fi
            unset fnum;
        fi
    fi
    # move file to Trash/files
    # and create trashinfo
    mv $fp $trash/files/$rname\
    && trashinfo=$trash/info/$rname.trashinfo\
    && echo "[Trash Info]"          >  $trashinfo\
    && echo "Path=$fp"              >> $trashinfo\
    && echo "DeletionDate=$deldate" >> $trashinfo;
done
unset IFS trash deldate files fp rname trashinfo;
