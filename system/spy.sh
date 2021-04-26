#!/bin/bash

people=$(w -i | tail -n +3 | awk '{print $1,$3}')   # active users and their IPs
cpus=$(lscpu | grep "^CPU(s):" | awk '{print $2}')  # how many cpus does system have
me=$(whoami)                                        # who is running this script
total=$(free | awk '/Mem:/ { print $2 }')           # total RAM

for line in "${people}";
do
    user=$(echo ${line} | awk '{print $1}')
    ip=$(echo ${line} | awk '{print $2}')
    
    echo "User: ${user}"
    echo "IP: ${ip}"
    echo -n "CPU: "
    
    # https://unix.stackexchange.com/questions/120570/how-can-i-monitor-cpu-usage-by-user/120581
    # print other user's CPU usage in parallel but skip own one because
    # spawning many processes will increase our CPU usage significantly
    # 1st column - username, 2nd column - aggregated CPU ussage, 3rd column - normalized CPU usage
    if [[ "$me" == "$user" ]] ;
    then
        # ignores commands in top that are labeled "code" or "top"
        (top -b -n 1 -u "$user" | awk -v CPUS=$cpus -v code="code" -v top="top" 'NR>7  { 
                                                                                     if($12 != code && $12 != top ) 
                                                                                        sum += $9; 
                                                                                    } 
                                                                                    END { print sum, sum/CPUS; }') &
        # dont spawn too many processes in parallel
        sleep 0.05
    else
        (top -b -n 1 -u "$user" | awk -v CPUS=$cpus 'NR>7  { sum += $9; } END { print sum, sum/CPUS; }') &
        # dont spawn too many processes in parallel
        sleep 0.05
    fi
    wait

    echo -n "Memory usage: "
    # https://github.com/scaidermern/script-snippets/blob/master/showPerUserMem.sh
    ps hux -U $user | awk -v total=$total '{ sum += $6} END { printf "%.2f\n", sum / total * 100; }'

    echo
done