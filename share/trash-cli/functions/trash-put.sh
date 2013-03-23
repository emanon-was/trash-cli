# -------------------------
# $ trash-put test1.txt test2.txt test3.txt test4.txt
# -------------------------
trash-put ()
{
    # step1
    _IFS="$IFS";IFS=$'\n';
    trash=~/.local/share/Trash;
    date=`\date +"%Y-%m-%dT%T";`;
    files=`\abspath $@;`;

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
