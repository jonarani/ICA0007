#!/bin/bash
timestamp() {
  date +'%d/%m/%Y_%H:%M:%S'
}
timestamp >> ssh_established_con.txt
sudo netstat -tnpa | grep 'ESTABLISHED.*sshd' >> ssh_established_con.txt
