#!/usr/bin/env bash

os-update(){
echo 'This does an OS pre-reqs and upgrade so the first time it may run for 15 minutes or more, this is normal.'
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
sudo curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt install nodejs -qq
npm --version
node --version

DEBIAN_FRONTEND=noninteractive sudo apt install gyp -yq

curl -o /tmp/node-gyp-build.deb 'http://archive.ubuntu.com/ubuntu/pool/universe/n/node-gyp-build/node-gyp-build_4.2.3-1_all.deb'
sudo dpkg -i /tmp/node-gyp-build.deb

MY_FLAVOR='Linux_x86_64'
curl -s -L $(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep -i "$MY_FLAVOR") | sudo tar xzf - -C /usr/local/bin lazygit


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

sudo apt install python3.9 -yq
sudo apt install python3-pip -yq
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
python --version

sudo apt -yq install python-is-python3
}

npm-pkg-install(){

echo "Installing NPM packages"
npm set progress=false
npm i -g npm
npm i -g --force n
n -p i lts

sudo rm -rf /usr/bin/node
sudo ln -s $USER/n/bin/node /usr/bin/node

npm i -g npm
npm i -g node-gyp
npm i -g nexe
npm i -g zx
npm install -g prebuild

npm uninstall -g node-pre-gyp
npm i -g @mapbox/node-pre-gyp


npm config set python python3

npm i -g nbake
npm i -g npm-check-updates
npm i -g tap

echo 'https://www.tecmint.com/enable-pm2-to-auto-start-node-js-app/'
npm i -g pm2

pm2 startup systemd
ln -s $USER/.pm2/logs

npm i -g @11ty/eleventy@beta
npm i -g jsdoc-to-markdown
npm i -g javascript-obfuscator

// mobile:
npm i -g cordova
npm i -g tiged
npm i -g typescript
npm -v
}

vscode-install(){
curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@$USER

sudo sed -i 's/127.0.0.1/0.0.0.0/g' $HOME/.config/code-server/config.yaml
sudo sed -i 's/8080/9091/g' $HOME/.config/code-server/config.yaml
sudo systemctl restart code-server@$USER.service
sudo systemctl status code-server@$USER.service
cat $HOME/.config/code-server/config.yaml
echo 'Open browser on port 9091, password in ~/.config/code-server/config.yaml '
echo 'Or better: as configured by Caddyfile, ideally with https'
}

caddy-install(){
echo -n "Enter the Sub Domain (Make sure its pointing to this server : "
read NEW_DOMAIN

sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy-stable.asc
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update -qq
sudo apt install caddy -qq
sudo caddy upgrade
ln -s /etc/caddy/Caddyfile ~/Caddyfile

cat <<EFF > ~/Caddyfile
{
	auto_https disable_redirects
	servers {
		protocol {
			experimental_http3
		}
	}
}
# caddy stop, start, validate, reload
# http://caddyserver.com/docs/caddyfile
# Caddy provision SSL Certs automatically, make sure DNS is updated properly.
$NEW_DOMAIN {
	reverse_proxy /cockpit/* localhost:9090 {
		transport http {
			tls_insecure_skip_verify
		}
	}
	reverse_proxy /log/* localhost:2004 {
		transport http {
			tls_insecure_skip_verify
		}
	}
	reverse_proxy localhost:9091
}

:8088 {
	# Set this path to your site's directory.
	root * /root/site/public

	# Enable the static file server.
	file_server

	# Or serve a PHP SSR through php-fpm:
	# php_fastcgi localhost:9000
}
EFF
}


enable-firewall(){
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable
ufw status verbose
}

system-info(){
export i="/tmp/info"
lsblk 						>  $i
free -m						>> $i
cat /etc/os-release | grep "VERSION="		>> $i
curl -s ipinfo.io 				>> $i
echo " "					>> $i
echo "NPM Version: $(npm -v)"			>> $i
echo "Node Version: $(node -v)"			>> $i
echo "Python Version: $(python --version)"	>> $i
systemctl list-units --type=service  	>> $i

echo "File saved in $i"
}

case "$1" in
'os-update')
	os-update;;
'npm-pkg-install')
	npm-pkg-install;;
'vscode-install')
	vscode-install;;
'caddy-install')
	caddy-install;;
'enable-firewall')
	enable-firewall;;
'system-info')
	system-info;;
'install-all')
    os-update;
    vscode-install;
    npm-pkg-install;
    caddy-install;
    system-info;
    enable-firewall;;
*)
       echo "Usage: $0 { os-update | npm-pkg-install | vscode-install | caddy-install | enable-firewall | system-info | install-all }"
       exit 1
       ;;
esac
exit 0
