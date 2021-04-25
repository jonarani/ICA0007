#!/bin/bash

# example run: ./script1.sh -u test2 -k pub_test -e james@gmail.com -g grp1 grp2 grp3

show_help()
{
    echo "-u <username> -k <abs_path_to_pub_file> -g <gr1 gr2 gr3>"
}

while :; do
    case $1 in
        -h|-\?|--help)
            show_help
            exit
            ;;
        -u|--username)
            username=${2}
            shift
            ;;
        -e|--email)
            email=${2}
            shift
            ;;
        -k|--pubkey)
            pubkey=${2}
            shift
            ;;
        -g|--groups)
            groups="${@:2}"
            shift
            ;;
        --)
            shift
            break
            ;;
        -?*)
            echo "WARN: Unknown option: $1"
            ;;
        *)
            break
    esac
    shift
done

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

groups=$(echo ${groups} | sed 's/ /,/g')

password=$(openssl rand -base64 10)

sudo yes ${password} | sudo passwd ${username}

sudo usermod -a -G ${groups} ${username}

sudo mkdir /home/${username}/.ssh
sudo touch /home/${username}/.ssh/authorized_keys
sudo chmod 777 /home/${username}/.ssh/authorized_keys
sudo cat ${pubkey} >> /home/${username}/.ssh/authorized_keys

sudo ../mail/send_mail.sh "Hello, this is your password: ${password}" ${email}