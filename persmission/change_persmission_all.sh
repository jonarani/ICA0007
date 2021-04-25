#!bin/bash
mapfile -d $'\0' files < <(sudo find "$1" -print0)

for i in "${files[@]}"
do
    sudo chmod "$2" "$i" 
done
