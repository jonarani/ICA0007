#!bin/bash
array=()
mapfile -d $'\0' files < <(sudo find "$1" -perm "$2" -print0)

for i in "${files[@]}"
do
    sudo chmod "$3" "$i" 
done
