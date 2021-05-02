#!/bin/bash
while IFS="" read -r p || [ -n "$p" ];
do
    echo "$p" | grep -Po "\b(\d|\.)+:[0-9]*(?= .*ssh)" > ip_to_check.temp
    while IFS="" read -r ip || [ -n "$ip" ];
    do
        if  grep -Fxq "$ip" trusted_ip.txt
        then
            echo "$ip trusted"
            printf "\n"
        else
            echo "$ip not trusted"
            echo "Killing connection"
	    echo "$p" | grep -Po "[0-9]{5}[\/]sshd" | grep -Po "[0-9]{5}"
	   # kill "$uid"
            printf "\n"
        fi
    done < ip_to_check.temp
done < ssh_established_con.txt
rm -rf ip_to_check.temp
