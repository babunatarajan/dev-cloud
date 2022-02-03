#!/usr/bin/env bash

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

