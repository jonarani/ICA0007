#!/bin/bash
user=${1}

sudo useradd ${user}

unzip -d / "${user}.zip"