#!/bin/bash
for n in "${@}"
do
    sudo chage -M 60 "$n"
done
