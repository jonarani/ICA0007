#!/bin/bash

cpuCrit=${1}
memCrit=${2}
onlyIps=${3}

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
total=$(free | awk '/Mem:/ { print $2 }')           # total RAM

while IFS= read -r line; do
    user=$(echo "${line}" | awk '{print $1}')
    ip=$(echo "${line}" | awk '{print $2}')
    
    # if not IP pattern (for example if it is tmux(31632).%1 then continue)
    if [[ "$onlyIps" && !($ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$) ]]; then
        continue
    fi

    echo "User: ${user}"
    echo "Connected from: ${ip}"
    echo -n "CPU: "
    
    # https://unix.stackexchange.com/questions/120570/how-can-i-monitor-cpu-usage-by-user/120581
    # 1st column - aggregated CPU ussage, 2nd column - normalized CPU usage
    (top -b -n 1 -u "$user" \
        | awk -v CPUS=$cpus -v cpuCrit=$cpuCrit \
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
        | awk -v total=$total -v memCrit=$memCrit \
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