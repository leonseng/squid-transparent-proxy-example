FROM alpine

RUN apk add --no-cache iptables
RUN apk add --no-cache squid openssl

COPY entrypoint.sh /entrypoint.sh
RUN chmod -R 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]