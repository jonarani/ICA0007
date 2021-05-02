#!/bin/bash
while IFS="" read -r p || [ -n "$p" ];
do
    if id "$p" &>/dev/null; then
        sudo usermod --expiredate '' "$p"
        printf "$p"' got enabled\n'
    else
        printf  'No user named '"$p"'\n'
    fi

done < "$1"
