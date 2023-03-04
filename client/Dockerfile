FROM alpine

RUN apk update \
  && apk add bind-tools iproute2 iptables curl \
  && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]