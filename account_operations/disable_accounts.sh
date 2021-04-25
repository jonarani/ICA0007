#!bin/bash
while IFS="" read -r p || [ -n "$p" ];
do
    if id "$p" &>/dev/null; then
        sudo usermod --expiredate 1 "$p"
        printf "$p"' got disabled\n'
    else
        printf  'No user named '"$p"'\n'
    fi

done < "$1"
