#!/usr/bin/env bash

echo 'NodeJS, LazyGit and Python3 installation...'

sudo curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt install nodejs -qq
npm --version
node --version

DEBIAN_FRONTEND=noninteractive sudo apt install gyp -yq

#curl -o /tmp/node-gyp-build.deb 'http://archive.ubuntu.com/ubuntu/pool/universe/n/node-gyp-build/node-gyp-build_4.2.3-1_all.deb'
#sudo dpkg -i /tmp/node-gyp-build.deb

MY_FLAVOR='Linux_x86_64'
curl -s -L $(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep -i "$MY_FLAVOR") | sudo tar xzf - -C /usr/local/bin lazygit


sudo apt install python3.9 -yq
sudo apt install python3-pip -yq
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
python --version

sudo apt -yq install python-is-python3

