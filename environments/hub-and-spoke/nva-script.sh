#!/bin/bash

# activate IP forwarding
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
# configure iptables rules for NAT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# save iptables rules
export DEBIAN_FRONTEND=noninteractive
apt-get update
# Preconfigure iptables-persistent to save current rules without prompting
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y iptables-persistent

# Save the current iptables rules
netfilter-persistent save