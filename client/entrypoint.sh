#!/bin/sh
set -e

PROXY_IP=""

# Wait for squid container to be ready
while [ -z "$PROXY_IP" ]
do
  PROXY_IP=$(dig squid +short)
done

iptables -t mangle -A OUTPUT -p tcp -m multiport --dports 80,443 -j MARK --set-mark 1

ip rule add fwmark 1 table 100
ip route add default via $PROXY_IP dev eth0 table 100

tail -f /dev/null
