# Squid Transparent Proxy Example

This repo showcases the use of Squid as a transparent proxy for both HTTP and HTTPS traffic.

Run `docker compose up -d` to set up the environment. Then, see [Tests](#tests) for some examples.

Two containers are deployed:
1. a Squid proxy configured in transparent proxy mode, along with some `iptables` rules to redirect port 80 and 443 traffic to its own `http_port` and `https_port` on the transparent proxy.
1. a client for sending HTTP/HTTPS requests. Some `iptables` rules are configured to simulate a gateway device routing HTTP/HTTPS traffic from the client to the Squid proxy.

## Tests

### Access allowed HTTP site
```
$ docker compose exec client curl httpbin.org/ip
{
  "origin": "192.168.48.3, 202.171.162.98"
}
```

Squid log entry:
```
1677905342.286    466 172.18.0.3 TCP_MISS/200 387 GET http://httpbin.org/ip (SNI:-) - - ORIGINAL_DST/34.224.50.110 application/json
```

### Access disallowed HTTP site
```
$ docker compose exec client curl neverssl.com
...
<!-- ERR_ACCESS_DENIED -->
...
```

Squid log entry:
```
1677905358.565      6 172.18.0.3 TCP_DENIED/403 3851 GET http://neverssl.com/ (SNI:-) - - HIER_NONE/- text/html
```

### Access allowed HTTPS site

```
$ docker compose exec client curl https://httpbin.org/ip
{
  "origin": "202.171.162.98"
}
```

Squid log entry:
```
1677905462.330   1082 172.18.0.3 TCP_TUNNEL/200 5802 CONNECT 34.224.50.110:443 (SNI:httpbin.org) splice - ORIGINAL_DST/34.224.50.110 -
```

### Access disallowed HTTPS site
```
$ docker compose exec client curl https://icanhazip.com
curl: (35) error:0A000126:SSL routines::unexpected eof while reading
```

Squid log entry:
```
1677905430.727     53 172.18.0.3 NONE_NONE/000 0 CONNECT 104.18.114.97:443 (SNI:icanhazip.com) terminate - HIER_NONE/- -
```