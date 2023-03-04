#!/bin/bash
set -e

echo "Configuring iptables..."
# based on https://wiki.squid-cache.org/ConfigExamples/Intercept/LinuxDnat
PROXY_IP=$(ip a show eth0 | grep inet | awk '{print $2}' | cut -d '/' -f1)
PROXY_HTTP_PORT=3128
PROXY_HTTPS_PORT=3129

# prevent forward looping as Squid proxies the original request
iptables -t nat -A PREROUTING -s $PROXY_IP -p tcp --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -s $PROXY_IP -p tcp --dport 443 -j ACCEPT

# redirect all HTTP and HTTPS traffic routed to Squid towards the transparent proxy ports
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $PROXY_IP:$PROXY_HTTP_PORT
iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination $PROXY_IP:$PROXY_HTTPS_PORT

# as Squid routes the HTTP/HTTPS traffic to their original destination, perform SNAT
iptables -t nat -A POSTROUTING -j MASQUERADE

# prevent access to the transparent proxy ports from external sources
iptables -t mangle -A PREROUTING -p tcp --dport $PROXY_HTTP_PORT -j DROP
iptables -t mangle -A PREROUTING -p tcp --dport $PROXY_HTTPS_PORT -j DROP

echo "Creating SSL cert for Squid..."
mkdir -p /etc/squid/ssl \
  && openssl genrsa -out /etc/squid/ssl/squid.key 4096 \
  && openssl req -new -key /etc/squid/ssl/squid.key -out /etc/squid/ssl/squid.csr -subj "/C=XX/ST=XX/L=squid/O=squid/CN=squid" \
  && openssl x509 -req -days 3650 -in /etc/squid/ssl/squid.csr -signkey /etc/squid/ssl/squid.key -out /etc/squid/ssl/squid.crt \
  && sh -c "cat /etc/squid/ssl/squid.key /etc/squid/ssl/squid.crt >> /etc/squid/ssl/squid.pem"

echo "Initialize the SSL storage database for dynamically generated SSL certs"
/usr/lib/squid/security_file_certgen -c -s /var/spool/squid/ssl_db -M 4MB

tail -F /var/log/squid/access.log 2>/dev/null &
tail -F /var/log/squid/error.log 2>/dev/null &

echo "Starting squid"
squid -N "$@"
