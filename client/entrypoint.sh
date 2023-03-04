#!/bin/sh
set -e

PROXY_IP=""

while [ -z "$PROXY_IP" ]
do
  PROXY_IP=$(dig squid +short)
done

iptables -t mangle -A OUTPUT -p tcp --dport 80 -j MARK --set-mark 1
iptables -t mangle -A OUTPUT -p tcp --dport 443 -j MARK --set-mark 1

ip rule add fwmark 1 table 100
ip route add default via $PROXY_IP dev eth0 table 100

tail -f /dev/null
