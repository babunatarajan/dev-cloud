#!/usr/bin/env bash

echo 'This does an OS pre-reqs and upgrade so the first time it may run for 15 minutes or more, this is normal.'
echo 'Cockpit will be installed to manage/ssh the Server via Browser'
echo "curl ifconfig.io/ip"
echo -n "Enter the Sub Domain (Make sure its pointing to this server : "
read NEW_DOMAIN

sudo apt update -yq
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -yq
sudo DEBIAN_FRONTEND=noninteractive apt dist-upgrade -yq
sudo apt install build-essential -yq
sudo DEBIAN_FRONTEND=noninteractive apt install openssh-client -yq
sudo apt install unzip git zsh htop expect wget curl pkg-config net-tools software-properties-common -yq
#needed for nanomsg and lz4
sudo DEBIAN_FRONTEND=noninteractive apt --reinstall install libc6 libc6-dev -yq
sudo apt install cmake -yq
sudo apt install nanomsg-utils -yq
sudo apt install ninja-build
sudo apt install fio -yq
sudo apt install net-tools -qq
sudo apt-get install gcc g++ make -qq

DEBIAN_FRONTEND=noninteractive sudo apt install gyp -yq


#sudo ln -s /etc/netplan // /etc/netplan http://github.com/cockpit-project/cockpit/issues/8477#issuecomment-708037727
sudo apt -y install aptitude
sudo echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

sudo systemctl disable console-setup // fixes service
sudo DEBIAN_FRONTEND=noninteractive apt install tuned tuned-utils tuned-utils-systemtap -yq
sudo DEBIAN_FRONTEND=noninteractive apt install chrony -yq
sudo apt autoremove -yq
sudo chronyc -a makestep
sudo chronyc tracking
sudo DEBIAN_FRONTEND=noninteractive apt install cockpit -yq
echo 'You may want to reboot for new Linux to kick in. Also you may need to edit the file in /etc/netplan for cockpit based updates (renderer: NetworkManager)'
echo 'Following are recommended to fix the issue'
echo 'sudo systemctl stop NetworkManager'
echo 'sudo systemctl disable NetworkManager'
echo 'sudo init 6 '

sudo cat <<EFF > /etc/cockpit/cockpit.conf
[WebService]
Origins = https://$NEW_DOMAIN wss://$NEW_DOMAIN
ProtocolHeader = X-Forwarded-Proto
UrlRoot=/cockpit
EFF

sudo systemctl enable cockpit
sudo systemctl restart cockpit
sudo systemctl status cockpit

