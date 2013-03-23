#!/bin/bash

# Usage
# -------------------------
# $ trash-restore
# >   1 2013-03-11 08:37:49 /home/emanon/test1.txt
# >   2 2013-03-12 08:37:49 /home/emanon/test2.txt
# >   3 2013-03-15 08:37:49 /home/emanon/test3.txt
# >   4 2013-03-21 08:37:49 /home/emanon/test4.txt
# > What file to restore [1..4]: 1 3
# -------------------------

# values
_IFS="$IFS";IFS=$'\n';
trash=~/.local/share/Trash;
if [ ! -e $trash/files ] || [ ! -e $trash/info ];then
    IFS="$_IFS";unset trash _IFS;exit;
fi
info=(`ls -a $trash/info|grep "\.trashinfo$"`);
if [ ${#info[@]} -eq 0 ];then
    IFS="$_IFS";unset trash _IFS info;exit;
fi

# create prototype
declare stdout;
for i in ${info[@]};do
    f=$trash/files/`echo -e $i|sed -e 's/\.trashinfo$//';`;
    i=$trash/info/$i;
    deldate=`sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1 \2/p' $i;`;
    p=`sed -n 's/Path=\(.*\)/\1/p' $i;`;
    stdout=(${stdout[@]} "$deldate '$f' '$p'");
done
unset deldate p i f;
stdout=(`decode_utf8 "${stdout[*]}";`);
stdout=(`echo -e "${stdout[*]}"|sort|awk '{printf("%3s %s\n",NR,$0)}';`);

# message
echo -e "${stdout[*]}" | sed -e "s/'\(.*\)' '\(.*\)'/\2/;s/'//g;";
echo -en "What file to restore [1..${#info[@]}]: ";
read ans;ans=(`echo $ans|sed -e 's/[^0-9]/\n/g;s/^$//g';`);

# processing
for a in ${ans[@]};do
    f=`echo -e "${stdout[*]}"|sed -n "s/^\ *$a\ \+.*\('.*'\)\ \+\('.*'\)/\1 \2/p"`;
    tf=`echo -e $f|sed -e "s/'\(.*\)'\ \+'\(.*\)'/\1/;s/ /\ /";`;
    rf=`echo -e $f|sed -e "s/'\(.*\)'\ \+'\(.*\)'/\2/;s/ /\ /";`;
    if [ -e $rf ];then
        dname=`dirname $rf;`;
        rname=`basename $rf;`;
        if [ -f $rf ];then
            fname=`echo $rname|sed -e "s/\([^.]*\)\(.*\)/\1/";`;
            fext=`echo $rname|sed -e "s/\([^.]*\)\(.*\)/\2/";`;
            fnum=(`ls -a $dname|grep "^$fname\(\.[0-9]*\)\?$fext$";`);
            fnum=`expr ${#fnum[@]} + 1;`;
            if [ $fnum -gt 1 ];then
                rname=$fname.$fnum$fext;
            fi
            unset fname fext fnum;
        fi
        if [ -d $rf ];then
            fnum=(`ls -a $dname|grep "^$rname\(\.[0-9]*\)\?$";`);
            fnum=`expr ${#fnum[*]} + 1;`;
            if [ $fnum -gt 1 ];then
                rname=$rname.$fnum;
            fi
            unset fnum;
        fi
        rf=$dname/$rname;
        unset rname dname;
    fi
    mv $tf $rf && rm $trash/info/`basename $tf;`.trashinfo;
done
IFS="$_IFS";
unset _IFS trash stdout info a f tf rf;

