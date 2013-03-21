#!/bin/bash

# Usage
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

# values
_IFS="$IFS";IFS=$'\n';
trash=~/.local/share/Trash;
if [ ! -e $trash/files ] || [ ! -e $trash/info ];then
    exit 1;
fi
info=(`\ls $trash/info|\grep "\.trashinfo$"`);
if [ ${#info[*]} -eq 0 ];then
    exit 0;
fi
declare -a out;
for i in ${info[*]};do
    i=$trash/info/$i;
    out=(${out[*]} "`\sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1 \2/p' $i` `\sed -n 's/Path=\(.*\)/\1/p' $i`");
done
\decode_utf8 ${out[*]} | \sort $@;
IFS=$_IFS;
unset _IFS trash out info;

