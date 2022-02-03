#!/usr/bin/env bash

echo "Getting Server Info..."
export i="/tmp/info"
lsblk 						>  $i
free -m						>> $i
cat /etc/os-release | grep "VERSION="		>> $i
curl -s ipinfo.io 				>> $i
echo " "					>> $i
echo "NPM Version: $(npm -v)"			>> $i
echo "Node Version: $(node -v)"			>> $i
echo "Python Version: $(python --version)"	>> $i
systemctl list-units --type=service  		>> $i

echo "File saved in $i"
