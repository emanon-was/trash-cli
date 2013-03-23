#!/bin/bash

# Usage
# -------------------------
# $ trash-put test1.txt test2.txt test3.txt test4.txt
# -------------------------

# values
_IFS="$IFS";IFS=$'\n';
trash=~/.local/share/Trash;
deldate=`date +"%Y-%m-%dT%T";`;
files=(`abspath $@;`);
# mkdir ~/.local/share/Trash
if [ ! -e $trash/files ];then mkdir -p $trash/files;fi
if [ ! -e $trash/info ] ;then mkdir -p $trash/info ;fi
# processing
for abs in ${files[@]};do
    # rename
    rname=`basename $abs;`;
    if [ -e $trash/files/$rname ] && [ -e $trash/info/$rname.trashinfo ];then
        if [ -f $abs ];then
            fname=`echo $rname|sed -e "s/\([^.]*\)\(.*\)/\1/";`;
            fext=`echo $rname|sed -e "s/\([^.]*\)\(.*\)/\2/";`;
            fnum=(`ls $trash/files|grep "^$fname\(\.[0-9]*\)\?$fext$";`);
            fnum=`expr ${#fnum[@]} + 1;`;
            if [ $fnum -gt 1 ];then
                rname=$fname.$fnum$fext;
            fi
            unset fname fext fnum;
        fi
        if [ -d $abs ];then
            fnum=(`ls $trash/files|grep "^$rname\(\.[0-9]*\)\?$";`);
            fnum=`expr ${#fnum[@]} + 1;`;
            if [ $fnum -gt 1 ];then
                rname=$rname.$fnum;
            fi
            unset fnum;
        fi
    fi
    # move file to Trash/files
    # and create trashinfo
    mv $abs $trash/files/$rname\
    && trashinfo=$trash/info/$rname.trashinfo\
    && echo "[Trash Info]"          >  $trashinfo\
    && echo "Path=$abs"              >> $trashinfo\
    && echo "DeletionDate=$deldate" >> $trashinfo;
done
IFS="$_IFS";
unset _IFS trash deldate files abs rname trashinfo;

