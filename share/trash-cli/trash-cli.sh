abspath ()
{
    _IFS="$IFS";IFS=$'\n';
    for arg in $@;do
        # file
        if [ -f $arg ];then
            f=`\basename $arg;`;
            p=`\dirname $arg;`;p=`\cd $p;\pwd;`;
            \echo -e $p/$f;
        fi
        # directory
        if [ -d $arg ];then
            \echo -e `\cd $arg;\pwd;`;
        fi
    done
    IFS="$_IFS";
    unset _IFS arg f p;
}

decode_utf8 ()
{
    _IFS="$IFS";IFS=$'\n';
    for stdout in $@;do
        \echo -e "`\echo -e $stdout | \sed -e "s/%\([0-9a-fA-F][0-9a-fA-F]\)/\\\\\x\1/g";`";
    done
    IFS="$_IFS";
    unset _IFS stdout;
}

trash-empty ()
{
    # values
    _IFS="$IFS";IFS=$'\n';
    trash=~/.local/share/Trash;
    declare -i ago;ago=$1;
    insert=`\date +"%Y-%m-%d %T" -d "$ago days ago";`;
    deldate=`\date +"%Y%m%d%H%M%S" -d "$ago days ago";`;

    # message
    stdout="`trash-list`\n$insert"
    stdout=(`\echo -en "${stdout[*]}" | \sort | \grep "^$insert$" -B 10000 | \sed "/^$/d;/^$insert$/d;"`);
    num=${#stdout[@]};
    if [ $num -ne 0 ];then echo -e "${stdout[*]}";fi
    \echo -n "Delete these $num files really? [y/n] ";
    \read ans;

    # delete
    if [ "$ans" = 'y' ] || [ "$ans" = 'yes' ];then
        info=(`\ls $trash/info | \grep "\.trashinfo$";`);
        rm=(-rf);
        for i in ${info[@]};do
            f=$trash/files/`\echo -e $i | \sed -e 's/\.trashinfo$//';`;
            i=$trash/info/$i;
            if [ -e $f ];then
                t=`\sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1\2/;s/-//g;s/\://gp' $i;`;
                if [ $deldate -gt $t ];then
                    rm=(${rm[@]} $i $f);
                fi
            fi
        done
        \rm ${rm[@]};
    fi
    IFS="$_IFS";
    unset _IFS trash ago insert deldate ans info i f t rm;
}

trash-list ()
{
    # values
    _IFS="$IFS";IFS=$'\n';
    trash=~/.local/share/Trash;
    if [ ! -e $trash/files ] || [ ! -e $trash/info ];then
        IFS=$_IFS;unset _IFS trash;return;
    fi
    info=(`\ls $trash/info | \grep "\.trashinfo$"`);
    if [ ${#info[@]} -eq 0 ];then
        IFS=$_IFS;unset _IFS trash info;return;
    fi
    declare -a stdout;
    for i in ${info[@]};do
        i=$trash/info/$i;
        stdout=(${stdout[@]} "`\sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1 \2/p' $i` `\sed -n 's/Path=\(.*\)/\1/p' $i`");
    done
    \decode_utf8 "${stdout[*]}" | \sort $@;
    IFS="$_IFS";
    unset _IFS trash stdout info;
}

trash-put ()
{
    # values
    _IFS="$IFS";IFS=$'\n';
    trash=~/.local/share/Trash;
    deldate=`\date +"%Y-%m-%dT%T";`;
    files=(`\abspath $@;`);
    # mkdir ~/.local/share/Trash
    if [ ! -e $trash/files ];then mkdir -p $trash/files;fi
    if [ ! -e $trash/info ] ;then mkdir -p $trash/info ;fi
    # processing
    for abs in ${files[@]};do
        # rename
        rname=`\basename $abs;`;
        if [ -e $trash/files/$rname ] && [ -e $trash/info/$rname.trashinfo ];then
            if [ -f $abs ];then
                fname=`\echo $rname|\sed -e "s/\([^.]*\)\(.*\)/\1/";`;
                fext=`\echo $rname|\sed -e "s/\([^.]*\)\(.*\)/\2/";`;
                fnum=(`\ls $trash/files|\grep "^$fname\(\.[0-9]*\)\?$fext$";`);
                fnum=`\expr ${#fnum[@]} + 1;`;
                if [ $fnum -gt 1 ];then
                    rname=$fname.$fnum$fext;
                fi
                unset fname fext fnum;
            fi
            if [ -d $abs ];then
                fnum=(`\ls $trash/files|\grep "^$rname\(\.[0-9]*\)\?$";`);
                fnum=`\expr ${#fnum[@]} + 1;`;
                if [ $fnum -gt 1 ];then
                    rname=$rname.$fnum;
                fi
                unset fnum;
            fi
        fi
        # move file to Trash/files
        # and create trashinfo
        \mv $abs $trash/files/$rname\
        && trashinfo=$trash/info/$rname.trashinfo\
        && \echo "[Trash Info]"          >  $trashinfo\
        && \echo "Path=$abs"              >> $trashinfo\
        && \echo "DeletionDate=$deldate" >> $trashinfo;
    done
    IFS="$_IFS";
    unset _IFS trash deldate files abs rname trashinfo;
}

trash-restore ()
{
    # values
    _IFS="$IFS";IFS=$'\n';
    trash=~/.local/share/Trash;
    if [ ! -e $trash/files ] || [ ! -e $trash/info ];then
        IFS="$_IFS";unset trash _IFS;return;
    fi
    info=(`\ls $trash/info | \grep "\.trashinfo$"`);
    if [ ${#info[@]} -eq 0 ];then
        IFS="$_IFS";unset trash _IFS info;return;
    fi

    # create prototype
    declare stdout;
    for i in ${info[@]};do
        f=$trash/files/`\echo -e $i|\sed -e 's/\.trashinfo$//';`;
        i=$trash/info/$i;
        deldate=`\sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1 \2/p' $i;`;
        p=`\sed -n 's/Path=\(.*\)/\1/p' $i;`;
        stdout=(${stdout[@]} "$deldate '$f' '$p'");
    done
    unset deldate p i f;
    stdout=(`\decode_utf8 "${stdout[*]}";`);
    stdout=(`\echo -e "${stdout[*]}"| \sort | \awk '{printf("%3s %s\n",NR,$0)}';`);

    # message
    \echo -e "${stdout[*]}" | \sed -e "s/'\(.*\)' '\(.*\)'/\2/;s/'//g;";
    \echo -en "What file to restore [1..${#info[@]}]: ";
    \read ans;ans=(`\echo $ans|\sed -e 's/[^0-9]/\n/g;s/^$//g';`);

    # processing
    for a in ${ans[@]};do
        f=`\echo -e "${stdout[*]}"|\sed -n "s/^\ *$a\ \+.*\('.*'\)\ \+\('.*'\)/\1 \2/p"`;
        tf=`\echo -e $f|\sed -e "s/'\(.*\)'\ \+'\(.*\)'/\1/;s/ /\ /";`;
        rf=`\echo -e $f|\sed -e "s/'\(.*\)'\ \+'\(.*\)'/\2/;s/ /\ /";`;
        if [ -e $rf ];then
            dname=`\dirname $rf;`;
            rname=`\basename $rf;`;
            if [ -f $rf ];then
                fname=`\echo $rname|\sed -e "s/\([^.]*\)\(.*\)/\1/";`;
                fext=`\echo $rname|\sed -e "s/\([^.]*\)\(.*\)/\2/";`;
                fnum=(`\ls $dname|\grep "^$fname\(\.[0-9]*\)\?$fext$";`);
                fnum=`\expr ${#fnum[@]} + 1;`;
                if [ $fnum -gt 1 ];then
                    rname=$fname.$fnum$fext;
                fi
                unset fname fext fnum;
            fi
            if [ -d $rf ];then
                fnum=(`\ls $dname|\grep "^$rname\(\.[0-9]*\)\?$";`);
                fnum=`\expr ${#fnum[*]} + 1;`;
                if [ $fnum -gt 1 ];then
                    rname=$rname.$fnum;
                fi
                unset fnum;
            fi
            rf=$dname/$rname;
            unset rname dname;
        fi
        \mv $tf $rf && \rm $trash/info/`\basename $tf;`.trashinfo;
    done
    IFS="$_IFS";
    unset _IFS trash stdout info a f tf rf;
}

