# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License

# here set the language settings and keyboard mapping
# simple parser for settings and list of available languages
# all with my beloved AWK

init_language() {

  if ! [ -r /etc/LANGUAGE ]; then
    lang=`get_config language`
    if ! [ $lang ]; then lang=english; fi

    keyb=`get_config keyboard`
    if ! [ $keyb ]; then keyb=English; fi

    language=`cat /usr/share/dyne/locale.alias \
              | awk -v lang=$lang '/^#/       { next }
                                   lang ~ $1 { print $1 }'`

    lc_all=`cat /usr/share/dyne/locale.alias \
            | awk -v lang=$lang '/^#/       { next }
                                 lang ~ $1 { print $2 }' | cut -d. -f1`


    keyboard=`cat /usr/share/dyne/keyboard.lst \
              | awk -v keyb=$keyb '/^#/      { next }
                                   $0 ~ keyb { print $1 }'`

    # quick crop on strings with preceeding/trailing spaces
    language=`echo ${(f)language}`
    lc_all=`echo ${(f)lc_all}`
    keyboard=`echo ${(f)keyboard}`

    cat <<EOF > /etc/LANGUAGE
# dyne:bolic language configuration file
# generated at boot from dyne.cfg settings
export LC_ALL="$lc_all"
export LANG="$language"
export KEYB="$keyboard"
EOF
  fi    

} 

