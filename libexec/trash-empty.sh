#!/bin/bash

# Usage
# -------------------------
# $ trash-list
# > 2013-03-11 08:37:49 /home/emanon/test1.txt
# > 2013-03-12 08:37:49 /home/emanon/test2.txt
# > 2013-03-15 08:37:49 /home/emanon/test3.txt
# > 2013-03-21 08:37:49 /home/emanon/test4.txt
# $ trash-empty 7
# > 2013-03-11 08:37:49 /home/emanon/test1.txt
# > 2013-03-12 08:37:49 /home/emanon/test2.txt
# > Delete these 2 files really? [y/n] y
# -------------------------

# values
_IFS="$IFS";IFS=$'\n';
trash=~/.local/share/Trash;
declare -i ago;ago=$1;
insert=`date +"%Y-%m-%d %T" -d "$ago days ago";`;
deldate=`date +"%Y%m%d%H%M%S" -d "$ago days ago";`;

# message
stdout="`trash-list`\n$insert"
stdout=(`echo -en "${stdout[*]}"|sort|grep "^$insert$" -B 10000 | \sed "/^$/d;/^$insert$/d;"`);
num=${#stdout[@]};
if [ $num -ne 0 ];then echo -e "${stdout[*]}";fi
echo -n "Delete these $num files really? [y/n] ";
read ans;

# delete
if [ "$ans" = 'y' ] || [ "$ans" = 'yes' ];then
    info=(`ls $trash/info|grep "\.trashinfo$";`);
    rm=(-rf);
    for i in ${info[@]};do
        f=$trash/files/`echo -e $i|sed -e 's/\.trashinfo$//';`;
        i=$trash/info/$i;
        if [ -e $f ];then
            t=`sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1\2/;s/-//g;s/\://gp' $i;`;
            if [ $deldate -gt $t ];then
                rm=(${rm[@]} $i $f);
            fi
        fi
    done
    rm ${rm[@]};
fi
IFS="$_IFS";
unset _IFS trash ago insert deldate ans info i f t rm;

