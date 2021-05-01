#!/bin/bash

# example run: ./create_user.sh 2013-07-30 test2 pub_test james@gmail.com grp1 grp2 grp3

# Check expiration date: chage <user> 

expired=${1}
username=${2}
pubkey=${3}
email=${4}
groups=${@:5}

if [ -z "$expired" ]
then
    echo "Expired field was empty"
    exit 1
fi

if [ -z "$username" ]
then
    echo "Username field was empty"
    exit 1
fi

if [ -z "$pubkey" ]
then
    echo "Pubkey field was empty"
    exit 1
fi

if [ -z "$email" ]
then
    echo "Email field was empty"
    exit 1
fi

if [ -z "$groups" ]
then
    echo "Groups field was empty"
    exit 1
fi

sudo useradd -e ${expired} ${username}

groups=$(echo ${groups} | sed 's/ /,/g')

password=$(openssl rand -base64 10)

sudo yes ${password} | sudo passwd ${username}

sudo usermod -a -G ${groups} ${username}

sudo mkdir /home/${username}
sudo mkdir /home/${username}/.ssh
sudo touch /home/${username}/.ssh/authorized_keys
sudo chmod 777 /home/${username}/.ssh/authorized_keys
sudo cat ${pubkey} >> /home/${username}/.ssh/authorized_keys

email="TestingUserForLinux@gmail.com"
sudo bash ../mail/send_mail.sh "Hello, this is your password: ${password} and expires in $expired" ${email}