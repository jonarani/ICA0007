#!bin/bash
mapfile -d $'\0' files < <(sudo find "$1" -type f -mtime "$2" -name '*'"$3";)

printf "Delete files:\n $files"
read delete
if [ $delete = "yes" ]
then
    for i in "${files[@]}"
    do
        sudo rm -rf "$1"
    done
else
    echo Files will not be deleted
fi
