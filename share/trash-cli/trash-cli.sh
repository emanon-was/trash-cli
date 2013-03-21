abspath ()
{
    _IFS="$IFS";IFS=$'\n';
    for arg in $@;do
        # file
        if [ -f $arg ];then
            f=`\basename $arg;`;
            p=`\dirname $arg;`;
            p=`\cd $p;\pwd;`;
            abs=$p/$f;
            \echo $abs;
        fi
        # directory
        if [ -d $arg ];then
            abs=`\cd $arg;\pwd;`;
            \echo $abs;
        fi
    done
    IFS=$_IFS;
    unset arg f p abs _IFS;
}

decode_utf8 ()
{
    _IFS="$IFS";IFS=$'\n';
    for out in $@;do
        out=`\echo $out|\sed -e "s/%\([0-9a-fA-F][0-9a-fA-F]\)/\\\\\x\1/g";`;
        \echo $out;
    done
    IFS=$_IFS;
    unset out _IFS;
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
    out=(`\echo -e "\`trash-list\`\n$insert"|\sort|\grep "^$insert$" -B 10000|\sed "/^$/d;/^$insert$/d;"`);
    num=${#out[*]};
    if [ $num -ne 0 ];then echo -e "${out[*]}";fi
    \echo -n "Delete these $num files really? [y/n] ";
    \read ans;

    # delete
    if [ "$ans" = 'y' ] || [ "$ans" = 'yes' ];then
        info=(`\ls $trash/info|\grep "\.trashinfo$";`);
        rm=(-rf);
        for i in ${info[*]};do
            file=`\echo $i|\sed -e "s/\.trashinfo//";`;
            i=$trash/info/$i;
            file=$trash/files/$file;
            if [ -e $file ];then
                t=`\sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1\2/;s/-//g;s/\://gp' $i;`;
                if [ $deldate -gt $t ];then
                    rm=(${rm[@]} $i $file);
                fi
            fi
        done
        \rm ${rm[@]};
    fi
    IFS=$_IFS;
    unset _IFS trash ago insert deldate ans info i file t rm;
}

trash-list ()
{
    # values
    _IFS="$IFS";IFS=$'\n';
    trash=~/.local/share/Trash;
    if [ ! -e $trash/files ] || [ ! -e $trash/info ];then
        return 1;
    fi
    info=(`\ls $trash/info|\grep "\.trashinfo$"`);
    if [ ${#info[*]} -eq 0 ];then
        return 0;
    fi
    declare -a out;
    for i in ${info[*]};do
        i=$trash/info/$i;
        out=(${out[*]} "`\sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1 \2/p' $i` `\sed -n 's/Path=\(.*\)/\1/p' $i`");
    done
    \decode_utf8 ${out[*]} | \sort $@;
    IFS=$_IFS;
    unset _IFS trash out info;
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
    for fp in ${files[*]};do
        # rename
        rname=`\basename $fp;`;
        if [ -e $trash/files/$rname ] && [ -e $trash/info/$rname.trashinfo ];then
            if [ -f $fp ];then
                fname=`\echo $rname|\sed -e "s/\([^.]*\)\(.*\)/\1/";`;
                fext=`\echo $rname|\sed -e "s/\([^.]*\)\(.*\)/\2/";`;
                fnum=(`\ls $trash/files|\grep "^$fname\(\.[0-9]*\)\?$fext$";`);
                fnum=`\expr ${#fnum[*]} + 1;`;
                if [ $fnum -gt 1 ];then
                    rname=$fname.$fnum$fext;
                fi
                unset fname fext fnum;
            fi
            if [ -d $fp ];then
                fnum=(`\ls $trash/files|\grep "^$rname\(\.[0-9]*\)\?$";`);
                fnum=`\expr ${#fnum[*]} + 1;`;
                if [ $fnum -gt 1 ];then
                    rname=$rname.$fnum;
                fi
                unset fnum;
            fi
        fi
        # move file to Trash/files
        # and create trashinfo
        \mv $fp $trash/files/$rname\
        && trashinfo=$trash/info/$rname.trashinfo\
        && \echo "[Trash Info]"          >  $trashinfo\
        && \echo "Path=$fp"              >> $trashinfo\
        && \echo "DeletionDate=$deldate" >> $trashinfo;
    done
    IFS=$_IFS;
    unset _IFS trash deldate files fp rname trashinfo;
}

trash-restore ()
{
    # values
    _IFS="$IFS";IFS=$'\n';
    trash=~/.local/share/Trash;
    if [ ! -e $trash/files ] || [ ! -e $trash/info ];then
        return 1;
    fi
    info=(`\ls $trash/info|\grep "\.trashinfo$"`);
    if [ ${#info[*]} -eq 0 ];then
        return 0;
    fi

    # create prototype
    declare out;
    for i in ${info[*]};do
        f="$trash/files/`\echo $i|\sed -e 's/\.trashinfo$//';`";
        i=$trash/info/$i;
        deldate=`\sed -n 's/DeletionDate=\(.*\)T\(.*\)/\1 \2/p' $i;`;
        rp=`\sed -n 's/Path=\(.*\)/\1/p' $i;`;
        out=(${out[*]} "$deldate '$f' '$rp'");
    done
    unset deldate rp i f;
    out=(`\decode_utf8 ${out[*]};`);
    out=(`\echo -e "${out[*]}"|\sort|\awk '{printf("%3s %s\n",NR,$0)}';`);

    # message
    \echo -e "${out[*]}" | \sed -e "s/'\(.*\)' '\(.*\)'/\2/;s/'//g;";
    \echo -en "What file to restore [1..${#info[*]}]: ";
    \read ans;ans=(`\echo $ans|\sed -e 's/[^0-9]/\n/g;s/^$//g';`);

    # processing
    for a in ${ans[@]};do
        f=`\echo -e "${out[*]}"|\sed -n "s/^ *$a *[^ ]* *[^ ]* *\(.*\)/\1/p";`;
        tf=`\echo -e $f|\sed -e "s/'\(.*\)' '\(.*\)'/\1/";`;
        rf=`\echo -e $f|\sed -e "s/'\(.*\)' '\(.*\)'/\2/";`;
        if [ -e $rf ];then
            dname=`\dirname $rf;`;
            rname=`\basename $rf;`;
            if [ -f $rf ];then
                fname=`\echo $rname|\sed -e "s/\([^.]*\)\(.*\)/\1/";`;
                fext=`\echo $rname|\sed -e "s/\([^.]*\)\(.*\)/\2/";`;
                fnum=(`\ls $dname|\grep "^$fname\(\.[0-9]*\)\?$fext$";`);
                fnum=`\expr ${#fnum[*]} + 1;`;
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
            rf="$dname/$rname";
            unset rname dname;
        fi
        \mv $tf $rf && \rm $trash/info/`\basename $tf;`.trashinfo;
    done
    IFS=$_IFS;
    unset _IFS trash out info a f tf rf;
}

