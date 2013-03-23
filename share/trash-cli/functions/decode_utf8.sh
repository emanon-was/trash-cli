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
