abspath ()
{
    #
    # Return the absolute path
    #
    IFS=$'\n';
    for arg in $@;do
        # file
        if [ -f $arg ];then
            f=`basename $arg;`;
            p=`dirname $arg;`;
            p=`cd $p;pwd;`;
            abs=$p/$f;
            echo $abs;
        fi
        # directory
        if [ -d $arg ];then
            abs=`cd $arg;pwd`;
            echo $abs;
        fi
    done
    unset arg f p abs IFS;
}

decode_utf8 ()
{
    #
    # Decode to UTF-8 (Use 'echo -e')
    #
    IFS=$'\n'
    for out in $@;do
        out=`echo -e $out | sed -e "s/%\([ 0-9a-fA-F][ 0-9a-fA-F]\)/\\\\\x\1/g"`;
        echo -e "$out";
    done
    unset out IFS;
}

trash-put ()
{
    #
    # Move files to Trash and Create a trashinfo
    #
    # values
    IFS=$'\n';
    trash=~/.local/share/Trash;
    deldate=`date +"%Y-%m-%dT%T"`;
    files=(`abspath $@`);
    # mkdir ~/.local/share/Trash
    if [ -e $trash/files ];then mkdir -p $trash/files;fi
    if [ -e $trash/info ] ;then mkdir -p $trash/info ;fi
    # processing
    for fp in ${files[*]};do
        # rename
        rname=`basename $fp`;
        if [ -e $trash/files/$rname ] && [ -e $trash/info/$rname.trashinfo ];then
            if [ -f $fp ];then
                declare -i fnum;
                fname=`echo $rname|sed -e "s/\([^.]*\)\(.*\)/\1/"`;
                fext=`echo $rname|sed -e "s/\([^.]*\)\(.*\)/\2/"`;
                fnum=`find $trash/files -regex ".*\/$fname\(\.[0-9]*\)?$fext"|wc -l`+1;
                if [ $fnum -gt 1 ];then
                    rname=$fname.$fnum$fext;
                fi
                unset fname fext fnum;
            fi
            if [ -d $fp ];then
                declare -i fnum;
                fnum=`find $trash/files -regex ".*\/$rname\(\.[0-9]*\)?"|wc -l`+1;
                if [ $fnum -gt 1 ];then
                    rname=$rname.$fnum;
                fi
                unset fnum;
            fi
        fi
        # move file to Trash/files
        # and create trashinfo
        mv $fp $trash/files/$rname\
        && trashinfo=$trash/info/$rname.trashinfo\
        && echo "[Trash Info]"          >  $trashinfo\
        && echo "Path=$fp"              >> $trashinfo\
        && echo "DeletionDate=$deldate" >> $trashinfo;
    done
    unset IFS trash deldate files fp rname trashinfo;
}

trash-list ()
{
    #
    # All arguments are passed to the sort command to be executed at the end.
    #
    # values
    IFS=$'\n';
    trash=~/.local/share/Trash;
    if [ -e $trash/files ] && [ -e $trash/info ];then
        info=(`find $trash/info -name '*.trashinfo'`);
        if [ ${#info[*]} -ne 0 ];then
            out="`cat ${info[*]} | grep -v '\[Trash Info\]'\
                | sed  -e '/Path=/{;N;s/Path=\(.*\)\nDeletionDate=\(.*\)T\(.*\)/\2 \3 \1/g;}'`";
            decode_utf8 $out | sort $@;
        fi
    fi
    unset IFS trash out info;
}

trash-empty ()
{
    # values
    IFS=$'\n';
    trash=~/.local/share/Trash;
    declare -i ago;ago=$1;
    insert=`date +"%Y-%m-%d %T" -d "$ago days ago"`;
    deldate=`date +"%Y%m%d%H%M%S" -d "$ago days ago"`;

    # message
    echo -ne "`trash-list`\n$insert"\
    | sort | grep "^$insert$" -B 10000 | grep -v "^$insert$" | sed '/^$/d';
    echo -n "Delete these files really? [y/n] ";
    read ans;

    # delete
    if [ "$ans" = 'y' ] || [ "$ans" = 'yes' ];then
        info=(`find $trash/info -name '*.trashinfo'`);
        rm=(-rf);
        for i in ${info[*]};do
            file=`basename $i|sed -e "s/[.]trashinfo//"`;
            file=$trash/files/$file;
            if [ -e $file ];then
                t=`sed -n "/DeletionDate=.*/p" $i | sed -e "s/DeletionDate=//;s/-//g;s/T//g;s/\://g;"`;
                if [ $deldate -gt $t ];then
                    rm=(${rm[*]} $i $file);
                fi
            fi
        done
        rm ${rm[*]};
    fi
    unset IFS trash ago insert deldate ans info i file t rm;
}
