#!/bin/bash

cpuCrit=${1}
memCrit=${2}

if [ -z "$cpuCrit" ]
then
    cpuCrit=90
fi

if [ -z "$memCrit" ]
then
    memCrit=50
fi

people=$(w -i | tail -n +3 | awk '{print $1,$3}')   # active users and their IPs
cpus=$(lscpu | grep "^CPU(s):" | awk '{print $2}')  # how many cpus does system have
me=$(whoami)                                        # who is running this script
total=$(free | awk '/Mem:/ { print $2 }')           # total RAM

while IFS= read -r line; do
    user=$(echo "${line}" | awk '{print $1}')
    ip=$(echo "${line}" | awk '{print $2}')
    
    # if not IP pattern (for example if it is tmux(31632).%1 then continue)
    if [[ !($ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$) ]]; then
        continue
    fi

    echo "User: ${user}"
    echo "IP: ${ip}"
    echo -n "CPU: "
    
    # https://unix.stackexchange.com/questions/120570/how-can-i-monitor-cpu-usage-by-user/120581
    # print other user's CPU usage in parallel but skip own one because
    # spawning many processes will increase our CPU usage significantly
    # 1st column - username, 2nd column - aggregated CPU ussage, 3rd column - normalized CPU usage
    # ignores commands in top that are labeled "code" or "top"
    (top -b -n 1 -u "$user" \
        | awk -v CPUS=$cpus -v code="code" -v top="top" \
            -v cpuCrit=$cpuCrit \
            'NR>7 {  
                sum += $9; 
            } 
            END {
                normalized = sum/CPUS 
                if (normalized >= cpuCrit)
                    print "\033[1;31m" sum, normalized "\033[0m"; 
                else
                    print sum, normalized; 
            }') &
    sleep 0.05  # dont spawn too many processes in parallel
    wait

    echo -n "Memory usage: "
    # https://github.com/scaidermern/script-snippets/blob/master/showPerUserMem.sh
    ps hux -U $user \
        | awk -v total=$total -v memCrit=$memCrit\
            '{ sum += $6} 
            END {
                mem = sum / total * 100
                if (mem >= memCrit)
                    print "\033[1;31m" mem "\033[0m"
                else
                    printf "%.2f\n", mem; 
            }'

    echo
done <<< "$people"