# -------------------------
# $ abspath .
# > /home/emanon
# -------------------------
abspath ()
{
    _IFS="$IFS";IFS=$'\n';
    for arg in $@;do
        if [ -f $arg ];then
            b=`\basename $arg;`;
            d=`\dirname $arg;`;d=`\cd $d;\pwd;`;
            \echo -e $d/$b;
        fi
        if [ -d $arg ];then
            \echo -e `\cd $arg;\pwd;`;
        fi
    done
    unset arg b d;
    IFS="$_IFS";
    unset _IFS;
}
# -------------------------
# $ decode_utf8 %E3%83%86%E3%82%B9%E3%83%88
# > テスト
# -------------------------
decode_utf8 ()
{
    _IFS="$IFS";IFS=$'\n';
    for stdout in $@;do
        stdout=`\echo -e $stdout|\sed -e "s/%\([0-9a-fA-F][0-9a-fA-F]\)/\\\\\x\1/g";`;
        \echo -e $stdout;
    done
    IFS="$_IFS";
    unset _IFS stdout;
}
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
        return 1;
    fi
    declare -i ago;ago=$1;
    declare insert;
    if date --version > /dev/null 2>&1;then
        insert=`\date +"%Y-%m-%d %T" -d "$ago days ago";`;
    else
        insert=`\date -v-"$ago"d +"%Y-%m-%d %T";`;
    fi
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
        return 0;
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
trash-list ()
{
    # step1
    _IFS="$IFS";IFS=$'\n';
    trash=~/.local/share/Trash;
    if [ ! -e $trash/files ] || [ ! -e $trash/info ];then
        IFS="$_IFS";
        unset _IFS trash;
        return 1;
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
}
# -------------------------
# $ trash-put test1.txt test2.txt test3.txt test4.txt
# -------------------------
trash-put ()
{
    # step1
    _IFS="$IFS";IFS=$'\n';
    trash=~/.local/share/Trash;
    date=`\date +"%Y-%m-%dT%T";`;
    files=(`\abspath $@;`);

    # step2
    if [ ! -d $trash/files ];then \mkdir -p $trash/files;fi
    if [ ! -d $trash/info ] ;then \mkdir -p $trash/info ;fi

    # step3
    for f in ${files[@]};do
        bname=`\basename $f;`;
        if [ -e $trash/files/$bname ] && [ -e $trash/info/$bname.trashinfo ];then
            if [ -f $f ];then
                fname=`\echo -en $bname|\sed -e "s/\([^.]*\)\(.*\)/\1/";`;
                fext=`\echo -en $bname|\sed -e "s/\([^.]*\)\(.*\)/\2/";`;
                fnum=(`\ls -a $trash/files|\grep "^$fname\(\.[0-9]*\)\?$fext$";`);
                fnum=`\expr ${#fnum[@]} + 1;`;
                if [ $fnum -gt 1 ];then bname=$fname.$fnum$fext;fi
                unset fname fext fnum;
            fi
            if [ -d $f ];then
                fnum=(`\ls -a $trash/files|\grep "^$bname\(\.[0-9]*\)\?$";`);
                fnum=`\expr ${#fnum[@]} + 1;`;
                if [ $fnum -gt 1 ];then bname=$bname.$fnum;fi
                unset fnum;
            fi
        fi
        \mv $f $trash/files/$bname\
    && trashinfo=$trash/info/$bname.trashinfo\
    && \echo "[Trash Info]"       >  $trashinfo\
    && \echo "Path=$f"            >> $trashinfo\
    && \echo "DeletionDate=$date" >> $trashinfo;
    done
    unset f trashinfo;
    IFS="$_IFS";
    unset _IFS trash date files bname;
}
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
trash-remove ()
{
    # step1
    set -f;
    _IFS="$IFS";IFS=$'\n';
    trash=~/.local/share/Trash;
    if [ ! -e $trash/files ] || [ ! -e $trash/info ];then
        IFS="$_IFS";
        unset trash _IFS;
        return 1;
    fi

    # step2
    declare stdout;
    for a in $@;do
        info=(`\find $trash/info -maxdepth 1 -name "$a.trashinfo";`);
        for i in ${info[@]};do
            f=$trash/files/`\basename $i|\sed -e 's/\.trashinfo$//';`;
            d=`\sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1 \2/p' $i;`;
            p=`\sed -n 's/Path=\(.*\)/\1/p' $i;`;
            declare s;
            if [ -d $f ];then s=/;fi
            if [ -L $f ];then s=@;fi
            stdout=(${stdout[@]} "$d '$p' '$s' '$f' '$i'");
            unset s;
        done
        unset info d p i f;
    done
    stdout=(`\decode_utf8 "${stdout[*]}"|\sort -u;`);

    # step3
    disp=(`\echo -en "${stdout[*]}"|\sed -e "s/^\(.*\)\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'$/\1 \2\3/g;"`);
    num=${#disp[@]};
    if [ $num -ne 0 ];then \echo -e "${disp[*]}";fi
    \echo -n "Delete these $num files really? [y/n] ";
    read ans;
    if [ "$ans" != 'y' ] && [ "$ans" != 'yes' ];then
        IFS="$_IFS";
        unset _IFS trash stdout disp num ans;
        return 0;
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
# -------------------------
# $ trash-restore
# >   1 2013-03-11 08:37:49 /home/emanon/test1.txt
# >   2 2013-03-12 08:37:49 /home/emanon/test2.txt
# >   3 2013-03-15 08:37:49 /home/emanon/test3.txt
# >   4 2013-03-21 08:37:49 /home/emanon/test4.txt
# > What file to restore [1..4]: 1 3
# -------------------------
trash-restore ()
{
    # step1
    _IFS="$IFS";IFS=$'\n';
    trash=~/.local/share/Trash;
    if [ ! -e $trash/files ] || [ ! -e $trash/info ];then
        IFS="$_IFS";
        unset _IFS trash;
        return 1;
    fi

    # step2
    declare stdout;
    info=(`\ls -a $trash/info|\grep "\.trashinfo$"`);
    for i in ${info[@]};do
        f=$trash/files/`\echo -e $i|\sed -e 's/\.trashinfo$//';`;
        i=$trash/info/$i;
        p=`\sed -n 's/Path=\(.*\)/\1/p' $i;`;
        d=`\sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1 \2/p' $i;`;
        declare s;
        if [ -d $f ];then s=/;fi
        if [ -L $f ];then s=@;fi
        stdout=(${stdout[@]} "$d '$p' '$s' '$f' '$i'");
        unset s;
    done
    unset d p f i info;
    stdout=(`\decode_utf8 "${stdout[*]}";`);
    stdout=(`\echo -en "${stdout[*]}"|\sort|\awk '{printf("%3s %s\n",NR,$0)}';`);

    # step3
    if [ ${#stdout[@]} -ne 0 ];then
        \echo -e "${stdout[*]}"| \sed -e "s/^\(.*\)\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'$/\1 \2\3/;";
        \echo -en "What file to restore [1..${#stdout[@]}]: ";
        read ans;ans=(`\echo $ans|\sed -e 's/[^0-9]/\n/g;s/^$//g';`);
    fi

    # step4
    for a in ${ans[@]};do
        f=`\echo -e "${stdout[*]}"|\sed -n "/^\ *$a\ /p"`;
        tf=`\echo -e $f|\sed -e "s/^\(.*\)\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'$/\4/;";`;
        if=`\echo -e $f|\sed -e "s/^\(.*\)\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'$/\5/;";`;
        rf=`\echo -e $f|\sed -e "s/^\(.*\)\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'\  *'\(.*\)'$/\2/;";`;
        if [ -e $rf ];then
            dname=`\dirname $rf;`;
            bname=`\basename $rf;`;
            if [ -f $rf ];then
                fname=`\echo $bname|\sed -e "s/\([^.]*\)\(.*\)/\1/";`;
                fext=`\echo $bname|\sed -e "s/\([^.]*\)\(.*\)/\2/";`;
                fnum=(`\ls -a $dname|\grep "^$fname\(\.[0-9]*\)\?$fext$";`);
                fnum=`\expr ${#fnum[@]} + 1;`;
                if [ $fnum -gt 1 ];then bname=$fname.$fnum$fext;fi
                unset fname fext fnum;
            fi
            if [ -d $rf ];then
                fnum=(`\ls -a $dname|\grep "^$bname\(\.[0-9]*\)\?$";`);
                fnum=`\expr ${#fnum[*]} + 1;`;
                if [ $fnum -gt 1 ];then bname=$bname.$fnum;fi
                unset fnum;
            fi
            rf=$dname/$bname;
            unset bname dname;
        fi
        \mv $tf $rf && \rm $if;
    done
    unset ans a f tf if rf;
    IFS="$_IFS";
    unset _IFS trash stdout;
}
