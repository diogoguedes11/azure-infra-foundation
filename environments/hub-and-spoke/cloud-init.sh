#!/bin/bash
apt-get update
apt-get install -y nginx
echo "Hello spoke!" > /var/www/html/index.html
systemctl enable nginx
systemctl start nginx