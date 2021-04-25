#!bin/bash
while IFS="" read -r p || [ -n "$p" ];
do
    if id "$p" &>/dev/null; then
        sudo passwd -l "$p"
        printf "$p"' password got locked\n'
    else
        printf  'No user named '"$p"'\n'
    fi

done < "$1"