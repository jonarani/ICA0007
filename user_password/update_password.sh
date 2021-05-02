#!bin/bash
password=$(openssl rand -base64 10)
sudo yes "$password" | sudo passwd "$1"
sudo chage -M 1 "$1"
sudo bash send_mail.sh "New Password: '$password' Expiring in 1 day!" TestingUserForLinux@gmail.com 
