#!bin/bash

# crontab task to check all user's passwords

mapfile -t names < <( getent passwd {1000..6000} | awk -F: '{ print $1}' )
for n in "${names[@]}"
do
    sudo chage -M 60 "$n"
done
