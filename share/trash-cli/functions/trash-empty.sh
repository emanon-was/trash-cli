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
trash-empty ()
{
    # step1
    _IFS="$IFS";IFS=$'\n';
    trash=~/.local/share/Trash;
    if [ ! -e $trash/files ] || [ ! -e $trash/info ];then
        IFS="$_IFS";
        unset trash _IFS;
        exit;
    fi
    declare -i ago;ago=$1;
    insert=`\date +"%Y-%m-%d %T" -d "$ago days ago";`;
    unset ago;

    # step2
    declare stdout;
    info=(`\ls -a $trash/info|\grep "\.trashinfo$"`);
    for i in ${info[@]};do
        f=$trash/files/`\echo -e $i|\sed -e 's/\.trashinfo$//';`;
        i=$trash/info/$i;
        d=`\sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1 \2/p' $i;`;
        p=`\sed -n 's/Path=\(.*\)/\1/p' $i;`;
        declare s;
        if [ -d $f ];then s=/;fi
        if [ -L $f ];then s=@;fi
        stdout=(${stdout[@]} "$d '$p' '$s' '$f' '$i'");
        unset s;
    done
    unset info d p i f;
    stdout=(${stdout[@]} "$insert");
    stdout=(`\decode_utf8 "${stdout[*]}";`);
    stdout=(`\echo -en "${stdout[*]}"|\sort|\grep "^$insert$" -B 10000|\sed "/^$/d;/^$insert$/d;"`);
    unset insert;

    # step3
    disp=(`\echo -en "${stdout[*]}"|\sed -e "s/^\(.*\)\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'$/\1 \2\3/g;"`);
    num=${#disp[@]};
    if [ $num -ne 0 ];then \echo -e "${disp[*]}";fi
    \echo -n "Delete these $num files really? [y/n] ";
    read ans;
    if [ "$ans" != 'y' ] && [ "$ans" != 'yes' ];then
        IFS="$_IFS";
        unset _IFS trash stdout disp num ans;
        exit;
    fi

    # step4
    rm=(-rf);
    for l in ${stdout[@]};do
        f=`\echo -en $l|\sed -e "s/^\(.*\)\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'$/\4/g;"`;
        i=`\echo -en $l|\sed -e "s/^\(.*\)\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'$/\5/g;"`;
        if [ -L $f ] || [ -e $f ];then
            rm=(${rm[@]} $i $f);
        fi
    done
    unset l f i;
    \rm ${rm[@]};
    IFS="$_IFS";
    unset _IFS trash stdout disp num ans rm;
}
