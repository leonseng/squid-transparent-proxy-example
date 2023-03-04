FROM leonseng/squid-openssl

RUN apt-get update \
  && apt-get install -y iptables iproute2 sudo

RUN apt-get install -y tcpdump \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod -R 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]