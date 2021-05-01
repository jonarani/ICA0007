#!/bin/bash

# crontab task that reads resource usage of predefined users 
# (/home/student/Documents/ICA0007/system/users) 
# and writes to another file if over limits

timestamp() {
  date +'%d/%m/%Y %H:%M:%S'
}

cpuLimit=${1}
memLimit=${2}

if [[ -z "$cpuLimit" || -z "$memLimit" ]] ;
then
    echo "wrong arguments"
    exit
fi

cpus=$(lscpu | grep "^CPU(s):" | awk '{print $2}')  # how many cpus does system have
total=$(free | awk '/Mem:/ { print $2 }')           # total RAM

input_path="/home/jonathan/Documents/ShellScripts/ICA0007/system/users"   # "/home/student/Documents/ICA0007/system/users"
output_path="/home/jonathan/Documents/ShellScripts/ICA0007/system/output" # "/home/student/Documents/ICA0007/system/output"

people=$(cat ${input_path})                         # users to check on

while IFS= read -r user; do 

    # check from ps aux if user has proccesses running
    psUser=$(ps aux | tail -n +2 | awk '{print $1}' | grep "${user}")

    if [[ -z "$psUser" ]];
    then
        #echo "Not active user: ${user}" 
        continue
    fi

    # https://unix.stackexchange.com/questions/120570/how-can-i-monitor-cpu-usage-by-user/120581
    # 1st column - aggregated CPU ussage, 2nd column - normalized CPU usage
    timestamp >> $output_path
    echo "${user}" >> $output_path

    (top -b -n 1 -u "$user" \
        | awk -v CPUS=$cpus -v cpuLimit=$cpuLimit -v user=$user \
            'NR>7 {  
                sum += $9; 
            } 
            END {
                normalized = sum/CPUS 
                if (normalized >= cpuLimit)
                    print sum, normalized;
            }') >> $output_path

    # https://github.com/scaidermern/script-snippets/blob/master/showPerUserMem.sh
    (ps hux -U $user \
        | awk -v total=$total -v memLimit=$memLimit \
            '{ sum += $6} 
            END {
                mem = sum / total * 100
                if (mem >= memLimit)
                    print mem;
            }') >> $output_path

    echo >> $output_path
    
    sleep 0.05  # dont spawn too many processes in parallel
    wait
done <<< "$people"
