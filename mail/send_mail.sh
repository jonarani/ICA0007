#!bin/bash 
if [ -z "$1" ]
then 
    echo "Empty body. Not sending mail"
else
    echo "$1" | mail -s "Admin Notification" "$2"
fi
