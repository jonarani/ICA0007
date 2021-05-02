<<<<<<< HEAD
#!bin/bash

# crontab task to check all user's passwords

=======
#!/bin/bash
>>>>>>> e6925dc2fe2e43321134d20d1865f1bafede98a1
mapfile -t names < <( getent passwd {1000..6000} | awk -F: '{ print $1}' )
for n in "${names[@]}"
do
    sudo chage -M 60 "$n"
done
