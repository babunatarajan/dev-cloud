curl -fsSL https://code-server.dev/install.sh | sh
cd /tmp/
wget https://github.com/coder/code-server/releases/download/v3.12.0/code-server_3.12.0_amd64.deb
apt install /tmp/code-server_3.12.0_amd64.deb 
systemctl enable --now code-server@$USER

sed -i 's/127.0.0.1/0.0.0.0/g' $HOME/.config/code-server/config.yaml
sed -i 's/8080/9091/g' $HOME/.config/code-server/config.yaml
systemctl restart code-server@$USER.service
systemctl status code-server@$USER.service
cat $HOME/.config/code-server/config.yaml
echo 'Open the FQDN and login using, password in ~/.config/code-server/config.yaml '
