#!/bin/bash

# -------------------------
# $ trash-remove "*"
# > 2013-03-26 04:46:59 /home/emanon/test1.txt
# > 2013-03-26 04:46:59 /home/emanon/test2.txt
# > 2013-03-26 04:46:59 /home/emanon/test3.txt
# > 2013-03-26 04:46:59 /home/emanon/test4.txt
# > Delete these 4 files really? [y/n] y
# $ trash-remove "test3*" "test1*"
# > 2013-03-26 04:46:59 /home/emanon/test1.txt
# > 2013-03-26 04:46:59 /home/emanon/test3.txt
# > Delete these 2 files really? [y/n] y
# -------------------------

# step1
set -f;
_IFS="$IFS";IFS=$'\n';
trash=~/.local/share/Trash;
if [ ! -e $trash/files ] || [ ! -e $trash/info ];then
    IFS="$_IFS";
    unset trash _IFS;
    exit;
fi

# step2
declare stdout;
for a in $@;do
    info=(`find $trash/info -maxdepth 1 -name "$a.trashinfo";`);
    for i in ${info[@]};do
        f=$trash/files/`basename $i|sed -e 's/\.trashinfo$//';`;
        d=`sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1 \2/p' $i;`;
        p=`sed -n 's/Path=\(.*\)/\1/p' $i;`;
        declare s;
        if [ -d $f ];then s=/;fi
        if [ -L $f ];then s=@;fi
        stdout=(${stdout[@]} "$d '$p' '$s' '$f' '$i'");
        unset s;
    done
    unset info d p i f;
done
stdout=(`decode_utf8 "${stdout[*]}"|sort -u;`);

# step3
disp=(`echo -en "${stdout[*]}"|sed -e "s/^\(.*\)\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'$/\1 \2\3/g;"`);
num=${#disp[@]};
if [ $num -ne 0 ];then echo -e "${disp[*]}";fi
echo -n "Delete these $num files really? [y/n] ";
read ans;
if [ "$ans" != 'y' ] && [ "$ans" != 'yes' ];then
    IFS="$_IFS";
    unset _IFS trash stdout disp num ans;
    exit;
fi

# step4
rm=(-rf);
for l in ${stdout[@]};do
    f=`echo -en $l|sed -e "s/^\(.*\)\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'$/\4/g;"`;
    i=`echo -en $l|sed -e "s/^\(.*\)\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'$/\5/g;"`;
    if [ -L $f ] || [ -e $f ];then
        rm=(${rm[@]} $i $f);
    fi
done
unset l f i;
rm ${rm[@]};
IFS="$_IFS";
unset _IFS trash stdout disp num ans rm;

