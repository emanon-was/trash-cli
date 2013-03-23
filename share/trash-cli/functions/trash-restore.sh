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
        exit;
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
        \echo -e "${stdout[*]}"| \sed -e "s/^\(.*\)\ \+'\(.*\)'\ \+'\(.*\)'\ \+'\(.*\)'\ \+'\(.*\)'$/\1 \2\3/;";
        \echo -en "What file to restore [1..${#stdout[@]}]: ";
        read ans;ans=(`\echo $ans|\sed -e 's/[^0-9]/\n/g;s/^$//g';`);
    fi

    # step4
    for a in ${ans[@]};do
        f=`\echo -e "${stdout[*]}"|\sed -n "/^\ *$a\ /p"`;
        tf=`\echo -e $f|\sed -e "s/^\(.*\)\ \+'\(.*\)'\ \+'\(.*\)'\ \+'\(.*\)'\ \+'\(.*\)'$/\4/;";`;
        if=`\echo -e $f|\sed -e "s/^\(.*\)\ \+'\(.*\)'\ \+'\(.*\)'\ \+'\(.*\)'\ \+'\(.*\)'$/\5/;";`;
        rf=`\echo -e $f|\sed -e "s/^\(.*\)\ \+'\(.*\)'\ \+'\(.*\)'\ \+'\(.*\)'\ \+'\(.*\)'$/\2/;";`;
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
