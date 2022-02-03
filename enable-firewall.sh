#!/usr/bin/env bash

echo "Enabling the Firewall..."
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable
ufw status verbose

