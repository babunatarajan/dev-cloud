curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@$USER

sudo sed -i 's/127.0.0.1/0.0.0.0/g' $HOME/.config/code-server/config.yaml
sudo sed -i 's/8080/9091/g' $HOME/.config/code-server/config.yaml
sudo systemctl restart code-server@$USER.service
sudo systemctl status code-server@$USER.service
cat $HOME/.config/code-server/config.yaml
echo 'Open browser on port 9091, password in ~/.config/code-server/config.yaml '
echo 'Or better: as configured by Caddyfile, ideally with https'
