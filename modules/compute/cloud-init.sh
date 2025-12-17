#!/bin/bash
apt-get update
apt-get install -y nginx
echo "Hello Azure!" > /var/www/html/index.html
systemctl enable nginx
systemctl start nginx