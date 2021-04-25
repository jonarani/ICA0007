#!bin/bash
while IFS="" read -r p || [ -n "$p" ];
do
    if id "$1" &>/dev/null; then
        sudo usermod --expiredate "" "$p"
        printf "$p"' got disabled\n'
    else
        printf  'No user named '"$p"'\n'
    fi

done < naughty_list.txt
