#!bin/bash
password=$(openssl rand -base64 10)
sudo yes "$password" | sudo passwd "$1"
sudo change -M 1 "$n"
sudo bash send_mail.sh "New Password: '$password' Expiring in 1 day!" TestingUserForLinux@gmail.com 
