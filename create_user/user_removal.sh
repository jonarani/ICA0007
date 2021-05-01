#!/bin/bash
user=${1}
zip -r "${user}" /home/${user}/
sudo mv "${user}.zip" /home/
sudo deluser --remove-home ${user}