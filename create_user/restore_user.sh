#!/bin/bash
user=${1}

sudo useradd ${user}

sudo unzip -d / "../../../../../${user}.zip"