#!/bin/bash

# -------------------------
# $ trash-list
# > 2013-03-11 08:37:49 /home/emanon/test1.txt
# > 2013-03-12 08:37:49 /home/emanon/test2.txt
# > 2013-03-15 08:37:49 /home/emanon/test3.txt
# > 2013-03-21 08:37:49 /home/emanon/test4.txt
# $ trash-list -r (sort command options)
# > 2013-03-21 08:37:49 /home/emanon/test4.txt
# > 2013-03-15 08:37:49 /home/emanon/test3.txt
# > 2013-03-12 08:37:49 /home/emanon/test2.txt
# > 2013-03-11 08:37:49 /home/emanon/test1.txt
# -------------------------

# step1
_IFS="$IFS";IFS=$'\n';
trash=~/.local/share/Trash;
if [ ! -e $trash/files ] || [ ! -e $trash/info ];then
    IFS="$_IFS";
    unset _IFS trash;
    exit 1;
fi

# step2
declare stdout;
info=(`\ls -a $trash/info|\grep "\.trashinfo$"`);
for i in ${info[@]};do
    f=$trash/files/`\echo -e $i|\sed -e 's/\.trashinfo$//';`;
    i=$trash/info/$i;
    d=`\sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1 \2/p' $i`
    p=`\sed -n 's/Path=\(.*\)/\1/p' $i`
    declare s;
    if [ -d $f ];then s=/;fi
    if [ -L $f ];then s=@;fi
    stdout=(${stdout[@]} "$d $p$s");
    unset s;
done
unset info i d p;

# step3
\decode_utf8 "${stdout[*]}" | \sort $@;
IFS="$_IFS";
unset _IFS trash stdout;
