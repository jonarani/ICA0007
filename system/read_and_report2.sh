#!/bin/bash

# crontab task that reads from the output file and 
# if too many warnings for one user then message it sent to sysadmin

allowed_warnings=${1}

if [[ -z "$allowed_warnings" ]] ;
then
    allowed_warnings=20
fi

input_path="/home/jonathan/Documents/ShellScripts/ICA0007/system/users"                 # "/home/student/Documents/ICA0007/system/users"
output_path="/home/jonathan/Documents/ShellScripts/ICA0007/system/output"               # "/home/student/Documents/ICA0007/system/output""
mail_script_path="/home/jonathan/Documents/ShellScripts/ICA0007/mail/send_mail.sh"      # "/home/student/Documents/ICA0007/mail/send_mail.sh"
email="TestingUserForLinux@gmail.com" # TODO: could be as an input

people=$(cat ${input_path})

while IFS= read -r user; do
    warnings=$(grep "${user}" "${output_path}" | wc -l)

    if [[ ${warnings} > ${allowed_warnings} ]];
    then
        echo ${user}
        echo ${warnings}
        echo "Over limit"
        sudo bash $mail_script_path "Warning: ${user} is using a lot of resources!" ${email} # TODO: test sending
    fi
done <<< "$people"